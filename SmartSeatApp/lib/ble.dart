import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final Telephony telephony = Telephony.instance;

Future<Position> getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied.');
  }

  return await Geolocator.getCurrentPosition();
}


Future<List<String>> getEmergencyContacts() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  List<dynamic> contacts = userDoc['emergencyContacts'] ?? [];
  return contacts.map((contact) => contact.toString()).toList();
}
Future<void> sendLocationSms() async {
  try {
    print("[DEBUG] Starting sendLocationSms function.");

    // Attempting to retrieve location
    print("[DEBUG] Attempting to get location...");
    Position position = await getUserLocation();
    print("[DEBUG] Location retrieved: Latitude=${position.latitude}, Longitude=${position.longitude}");
    String locationUrl = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
    print("[DEBUG] Generated location URL: $locationUrl");
    print("[DEBUG] Requesting SMS permissions...");
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted ?? false) {
      print("[DEBUG] SMS permissions granted.");
      print("[DEBUG] Fetching emergency contacts from Firestore...");
      List<String> contacts = await getEmergencyContacts();
      print("[DEBUG] Emergency contacts retrieved: $contacts");

      for (String contact in contacts) {
        bool smsSent = false;
        int retryCount = 0;
        while (!smsSent) {
          try {
            print("[DEBUG] Attempting to send SMS to $contact (Retry: $retryCount)...");
            await telephony.sendSms(
              to: contact,
              message: 'My current location: $locationUrl',
            );
            print("[DEBUG] SMS successfully sent to $contact.");
            smsSent = true;
          } catch (e) {
            retryCount++;
            print("[DEBUG] Failed to send SMS to $contact. Error: $e");
            print("[DEBUG] Retrying in 2 seconds...");
            await Future.delayed(Duration(seconds: 2));
          }
          if (retryCount >= 5) {
            print("[DEBUG] Maximum retry limit reached for $contact. Skipping...");
            break;
          }
        }
      }
    } else {
      print("[DEBUG] SMS permissions not granted. Cannot send SMS.");
    }
  } catch (e) {
    print("[DEBUG] Error in sendLocationSms: $e");
  } finally {
    print("[DEBUG] Completed sendLocationSms function.");
  }
}

// Singleton class for managing Bluetooth connection
class BluetoothConnectionManager {
  static final BluetoothConnectionManager _instance = BluetoothConnectionManager._internal();
  BluetoothConnection? connection;

  factory BluetoothConnectionManager() {
    return _instance;
  }

  BluetoothConnectionManager._internal();

  Future<void> connect(BluetoothDevice device) async {
    if (connection != null && connection!.isConnected) {
      return; // Already connected
    }
    connection = await BluetoothConnection.toAddress(device.address);
  }

  void disconnect() {
    connection?.dispose();
    connection = null;
  }

  bool isConnected() {
    return connection != null && connection!.isConnected;
  }
}

// UI Class
class BluetoothHomePage extends StatefulWidget {
  @override
  _BluetoothHomePageState createState() => _BluetoothHomePageState();
}

class _BluetoothHomePageState extends State<BluetoothHomePage> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  bool isScanning = false;
  final StreamController<String> _dataStreamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startScan();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.sms,
    ].request();
  }

  Future<void> startScan() async {
    setState(() {
      isScanning = true;
      devicesList.clear();
    });

    devicesList = await FlutterBluetoothSerial.instance.getBondedDevices();

    setState(() {
      isScanning = false;
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await BluetoothConnectionManager().connect(device);
    setState(() {
      connectedDevice = device;
    });

    handleBluetoothConnection(BluetoothConnectionManager().connection, _dataStreamController);
  }

  // Function to handle the Bluetooth connection and listen for incoming data
  void handleBluetoothConnection(
      BluetoothConnection? connection, StreamController<String> dataStreamController) {
    if (connection != null) {
      connection.input?.listen((data) async {
        String received = String.fromCharCodes(data);
        print("Received Data: $received");

        dataStreamController.add(received);
        if (received == "A") {
          print("Data 'A' received. Sending SMS...");
          await sendLocationSms();
        }
      }).onDone(() {
        print('Disconnected from device');
      });
    }
  }

  @override
  void dispose() {
    _dataStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth Devices")),
      body: Column(
        children: [
          isScanning
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: startScan,
            child: Text("Scan for Paired Devices"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                final device = devicesList[index];
                return ListTile(
                  title: Text(device.name ?? "Unknown Device"),
                  subtitle: Text(device.address),
                  onTap: () => connectToDevice(device),
                );
              },
            ),
          ),
          connectedDevice != null
              ? Column(
            children: [
              Text("Connected to: ${connectedDevice!.name}"),
            ],
          )
              : Text("No device connected"),
          SizedBox(height: 20),
          StreamBuilder<String>(
            stream: _dataStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                return Text("Received Data: ${snapshot.data}");
              } else {
                return Text("No data received yet");
              }
            },
          ),
        ],
      ),
    );
  }
}
