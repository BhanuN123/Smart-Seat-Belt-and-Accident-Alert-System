import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esproject/registration.dart';
import 'package:esproject/profile.dart';
import 'package:esproject/ble.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:esproject/editprofile.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = "";

  Future<void> loginUser() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("User logged in successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const homescreen()),
      );
    } catch (e) {
      print("Error: $e");
      // Show an error message
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white10,
      body: Stack(
        children: [
          // Red semicircle background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5, // Covers the top half
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(200), // Creates a semicircle effect
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  // Lock icon

                  Icon(
                    FontAwesomeIcons.car,
                    size: 100,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Smart Seatbelt App',
                    style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.w800),
                  ),

                  SizedBox(height: 70),
                  // Email TextField
                  mytextfield(
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  // Password TextField
                  mytextfield(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  signinbutton(onTap: loginUser),
                  SizedBox(height: 25),
                  if (errorMessage.isNotEmpty)
                    Text(errorMessage, style: TextStyle(color: Colors.red)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterPage()),
                          );
                        },
                        child: Text(
                          'Register here',
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reused widgets from the first code snippet
class mytextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const mytextfield({
    super.key,
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

class signinbutton extends StatelessWidget {
  final Function()? onTap;

  const signinbutton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(25),
        margin: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}



class homescreen extends StatefulWidget {
  const homescreen({super.key});


  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {

  Future<void> _editProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
    if (result == true) {
      (context as Element).reassemble(); // Refresh profile screen on edit
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Accident Alert App'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 30,
        ),
      ),
      backgroundColor: Colors.white10,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airline_seat_recline_extra, // Seatbelt icon
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Smart Seatbelt App',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Text('User Details'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BluetoothHomePage()),
                );
              },
              child: Text('Connect to Bluetooth Device'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _editProfile(context),
              child: Text('Edit Contacts'),
            ),
            SizedBox(height: 40),
            Text(
              'Welcome back',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


class checkseatbeltpage extends StatelessWidget {
  const checkseatbeltpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0), // Reduce app bar height
        child: AppBar(
          title: Text('Check Seatbelt Status'),
          backgroundColor: Colors.red,
        ),
      ),
      body: Center(),
    );
  }
}



class editcontactspage extends StatelessWidget {
  const editcontactspage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0), // Reduce app bar height
        child: AppBar(
          title: Text('edit contacts'),
          backgroundColor: Colors.red,
        ),
      ),
      body: Center(),
    );
  }
}

class monitoringpage extends StatelessWidget {
  const monitoringpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0), // Reduce app bar height
        child: AppBar(
          title: Text('start/stop Monitor'),
          backgroundColor: Colors.red,
        ),
      ),
      body: Center(),
    );
  }
}