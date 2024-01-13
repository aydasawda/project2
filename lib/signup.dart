import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const _baseURL = 'http://10.0.2.2/finalNote';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _controllerUsername = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  bool _loading = false;

  void update(String text) {
    Map<String, dynamic> response = convert.jsonDecode(text);

    if (response['status'] == 'success') {
      // Handle successful signup, e.g., navigate to login screen
      // You can customize this based on your application flow
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['message']),
      ));
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
          centerTitle: true,
        ),
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
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controllerPassword,
                  decoration: const InputDecoration(
                    hintText: "Enter your password",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });
                  registerUser(
                    update,
                    _controllerUsername.text.toString(),
                    _controllerPassword.text.toString(),
                  );
                },
                child: const Text('Sign Up'),
              ),
              Visibility(
                visible: _loading,
                child: const CircularProgressIndicator(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

void registerUser(Function(String text) update, String username, String password) async {
 print(username);
  try {
    final response = await http.post(
      Uri.parse('$_baseURL/signup.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, String>{'username': username, 'password': password}),
    ).timeout(const Duration(seconds: 5));
  print(response);
    if (response.statusCode == 200) {
      update(response.body);
    } else {
      update("Error: ${response.statusCode}");
    }
  } catch (e) {
    update("Connection error: $e");
  }
}
