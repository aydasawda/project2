import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'addnote.dart';
import 'login.dart';
const String _baseURL = 'http://10.0.2.2/finalNote';

List<Map<String, dynamic>> _notesData = [];

void showNotes(String userId) async {
  try {
    final url = Uri.parse('$_baseURL/getNotes.php');

    // Add userId to the URL query parameters
    final response = await http.get(
      url.replace(queryParameters: {'userId': userId.toString()}),
    ).timeout(const Duration(seconds: 5));

    _notesData.clear(); // clear old notes data

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        print(row['isDone']);
        _notesData.add({
          'title': row['title'],
          'isDone': int.parse(row['isDone']),
          'id': row['id'],
        });
      }
    }
  } catch (e) {
    // Handle errors
  }
}
void clearUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
}
Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // Retrieve userId from SharedPreferences
    getUserId().then((userId) {
      if (userId != null) {
        // Call showNotes with the retrieved userId
        showNotes(userId);
      } else {
        // Handle the case where userId is not available
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyNotes"),
        actions: [
          IconButton(
            onPressed: () {
              // Clear userId from SharedPreferences
              clearUserId();
              _notesData.clear();
              // Navigate to the login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            icon: Icon(Icons.logout_outlined),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                // Reload notes when the user presses the add button
                getUserId().then((userId) {
                  if (userId != null) {
                    showNotes(userId);
                  }
                });
              });
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddNote(),
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(

        itemCount: _notesData.length,
        itemBuilder: (context, index) => GestureDetector(
          onLongPress: () {
            // Handle long press to update isDone status
            _updateIsDoneStatus(_notesData[index]['id'], context);
          },
          child: ListTile(
            contentPadding: const EdgeInsets.only(top: 20, left: 10),
            leading: Checkbox(
              value: _notesData[index]['isDone'] == 1,
              onChanged: (bool? value) {
                // Toggle the "isDone" status when the checkbox is pressed
                setState(() {
                  _notesData[index]['isDone'] = value! ? 1 : 0;
                });
              },
              activeColor: Colors.green,
            ),
            title: Text(
              _notesData[index]['title'],
              style: TextStyle(
                decoration: _notesData[index]['isDone'] == 1
                    ? TextDecoration.lineThrough
                    : null,
                color: _notesData[index]['isDone'] == 1 ? Colors.green : null,
              ),
            ),
          ),

        ),
      ),
    );
  }

  void _updateIsDoneStatus(String noteId, BuildContext context) async {
    // Implement the logic to update isDone status in your database
    // Make an HTTP request or use any method you prefer
    try {
      print(noteId);
      final url = Uri.parse('$_baseURL/updateIsDoneStatus.php');
      await http.post(
        url,
        body: {'noteId': noteId},
      );
      // Refresh the notes after updating isDone status
      getUserId().then((userId) {
        if (userId != null) {
          showNotes(userId);
        }
      });
      // Show a SnackBar to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note updated successfully!'),
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update note.'),
        ),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}
