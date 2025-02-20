import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:esproject/login.dart';

class mytextfield extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  const mytextfield({super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
        ),
      ),
    );
  }
}

// Sign Up Button
class SignUpButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const SignUpButton({super.key, required this.onTap, this.text = 'Sign Up'});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  List<TextEditingController> contactControllers = [TextEditingController()];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    for (var controller in contactControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phoneNumber = phoneController.text.trim();
    String address = addressController.text.trim();
    String password = passwordController.text.trim();
    List<String> emergencyContacts = contactControllers
        .map((controller) => controller.text.trim())
        .where((contact) => contact.isNotEmpty)
        .toList();

    if (name.isEmpty || email.isEmpty || phoneNumber.isEmpty || address.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the fields.")),
      );
      return;
    }

    try {
      // Create a new user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      String uid = userCredential.user!.uid;

      // Save user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'emergencyContacts': emergencyContacts,
      });

      print("User registered successfully!");

      // Navigate to the ProfilePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const homescreen()),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.white10,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                'Create an Account',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              SizedBox(height: 40),

              // Name TextField
              mytextfield(
                controller: nameController,
                hintText: 'Name',
                obscureText: false,
              ),
              SizedBox(height: 10),

              // Email TextField
              mytextfield(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              SizedBox(height: 10),

              // Phone Number TextField
              mytextfield(
                controller: phoneController,
                hintText: 'Phone Number',
                obscureText: false,
              ),
              SizedBox(height: 10),

              // Address TextField
              mytextfield(
                controller: addressController,
                hintText: 'Address',
                obscureText: false,
              ),
              SizedBox(height: 10),

              // Password TextField
              mytextfield(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              SizedBox(height: 10),

              // Confirm Password TextField
              mytextfield(
                controller: passwordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              SizedBox(height: 20),

              // Emergency Contacts Section
              Text(
                'Emergency Contacts',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 10),

              // Emergency Contact TextFields
              for (int i = 0; i < contactControllers.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: mytextfield(
                        controller: contactControllers[i],
                        hintText: 'Contact ${i + 1}',
                        obscureText: false,
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

              // Register Button
              SignUpButton(
                onTap: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}