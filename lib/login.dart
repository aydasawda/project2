import 'package:flutter/material.dart';
import 'signup.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _baseURL = 'http://10.0.2.2/finalNote/login.php';

class Login extends StatefulWidget {
  const Login({super.key});


  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerUsername = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();


  bool _loading = false;
  Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }
  void update(String text) {
    try {
      print("Response: $text"); // Add this line for debugging

      Map<String, dynamic> response = convert.jsonDecode(text);

      if (response.containsKey('status')) {
        if (response['status'] == 'success') {
          // Extract userId from the response
          String userId = response['userId'];

          // Save userId to SharedPreferences
          saveUserId(userId);

          // Navigate to the Home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else if (response['status'] == 'error') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response['message'] ?? 'Login failed'),
          ));
        }
      } else {
        // Handle unexpected response format
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unexpected response format'),
        ));
      }
    } catch (e) {
      // Handle JSON decoding error
      print("JSON Decoding Error: $e"); // Add this line for debugging

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error decoding JSON response'),
      ));
    }

    setState(() {
      _loading = false;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Login'), centerTitle: true,
          actions: [
            TextButton(onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignUp(),));
            }, child: Text("Sign Up", style: TextStyle(
                color: Colors.white
            ),))
          ],),

        body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 25),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controllerUsername,
                  decoration: const InputDecoration(
                      hintText: "Enter your username",
                      border: OutlineInputBorder()),
                ),
              ),
              SizedBox(height:
              20,),
              SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controllerPassword,
                  decoration: const InputDecoration(
                      hintText: "Enter your password",
                      border: OutlineInputBorder()),
                ),
              ),
              SizedBox(height: 20,),

              ElevatedButton(onPressed: () {
                setState(() {
                  _loading = true;
                });
                checkUser(
                    update, _controllerUsername.text.toString(),
                    _controllerPassword.text.toString());
              },
                child: const Text('login'),
              ),

              Visibility(
                  visible: _loading, child: const CircularProgressIndicator())

            ],
          ),
        )
    );
  }}

void checkUser(Function(String text) update,  String username,String password) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseURL'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: convert.jsonEncode(<String, String>{'username': username, 'password': password}),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      update(response.body);
    } else {
      update("Error: ${response.statusCode}");
    }
  } catch (e) {
    update("Connection error: $e");
  }

}