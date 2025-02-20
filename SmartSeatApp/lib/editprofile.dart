import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  List<TextEditingController> contactControllers = [TextEditingController()];

  bool isLoading = false;
  String errorMessage = "";

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = data['name'] ?? '';
          phoneNumberController.text = data['phoneNumber'] ?? '';
          addressController.text = data['address'] ?? '';
          List<String> emergencyContacts = List<String>.from(data['emergencyContacts'] ?? []);
          contactControllers = emergencyContacts.map((e) => TextEditingController(text: e)).toList();
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data. Please try again.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        List<String> emergencyContacts = contactControllers
            .map((controller) => controller.text.trim())
            .where((contact) => contact.isNotEmpty)
            .toList();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': nameController.text,
          'phoneNumber': phoneNumberController.text,
          'address': addressController.text,
          'emergencyContacts': emergencyContacts,
        });

        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to save data. Please try again.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addContactField() {
    setState(() {
      contactControllers.add(TextEditingController());
    });
  }

  void _removeContactField(int index) {
    setState(() {
      if (contactControllers.length > 1) {
        contactControllers[index].dispose();
        contactControllers.removeAt(index);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    for (var controller in contactControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Address"),
            ),
            SizedBox(height: 20),
            Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Emergency Contact TextFields
            for (int i = 0; i < contactControllers.length; i++)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: contactControllers[i],
                      decoration: InputDecoration(labelText: "Contact ${i + 1}"),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.red),
                    onPressed: () {
                      _removeContactField(i);
                    },
                  ),
                ],
              ),
            SizedBox(height: 10),
            // Add Another Contact Button
            GestureDetector(
              onTap: _addContactField,
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.blue),
                  SizedBox(width: 5),
                  Text('Add Another Contact', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
