
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';

final Telephony telephony = Telephony.instance;

// Function to get the user's current location
Future<Position> getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  // Check for location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // Get the current location
  return await Geolocator.getCurrentPosition();
}

// Function to send an SMS with the user's location
void sendLocationSms(String recipient) async {
  try {
    // Get user's current location
    Position position = await getUserLocation();
    String locationUrl = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

    // Request SMS permissions
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted ?? false) {
      // Send the SMS with location
      telephony.sendSms(
        to: recipient,
        message: 'My current location: $locationUrl',
      );
      print("SMS Sent");
    } else {
      print("SMS permissions not granted");
    }
  } catch (e) {
    print('Error: $e');
  }
}