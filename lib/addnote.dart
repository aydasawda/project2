import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';


const _baseURL='http://10.0.2.2/finalNote';
class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {



  TextEditingController _controllerTitle = TextEditingController();




  bool _loading = false;
  void update(String text) {
    try {
      Map<String, dynamic> response = convert.jsonDecode(text);

      if (response.containsKey('status') && response.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message']),
        ));
      } else {
        // Handle unexpected response format
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unexpected response format'),
        ));
      }
    } catch (e) {
      // Handle JSON decoding error
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
      appBar: AppBar(title: Text("Add Note")),

      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),

            SizedBox(
              width: 200,
              child: TextField(
                controller: _controllerTitle,
                decoration: const InputDecoration(hintText: "note", border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 10),


            ElevatedButton(onPressed: () {
              setState(() {
                _loading = true;
              });
              saveNote(
                update,
                _controllerTitle.text.toString(),
              );
            },
              child: const Text('Submit'),
            ),

            const SizedBox(height: 10),


            Visibility(visible: _loading, child: const CircularProgressIndicator())

          ],
        ),
      ),
    );
  }
}


void saveNote(Function(String text) update, String title) async {
  try {
    // Retrieve userId from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      // Handle the case where userId is not available
      update("UserId not found");
      return;
    }

    final response = await http.post(
      Uri.parse('$_baseURL/addnote.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(
        <String, String>{
          'userId': userId,
          'title': title,
        },
      ),
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