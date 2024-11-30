import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewChildrenPage extends StatefulWidget {
  ViewChildrenPage();

  @override
  _ViewChildrenPageState createState() => _ViewChildrenPageState();
}

class _ViewChildrenPageState extends State<ViewChildrenPage> {
  late Future<List<dynamic>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = fetchChildren();
  }

  Future<List<dynamic>> fetchChildren() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? parentId = prefs.getString('userId');
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/children/?parentId=$parentId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return []; // No children found
    } else {
      throw Exception('Failed to fetch children');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Children List'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _childrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No children found.'));
          } else {
            final children = snapshot.data!;
            return ListView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      child['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'DOB: ${child['date_of_birth']}\n'
                      'Gender: ${child['gender']}\n'
                      'Weight: ${child['weight']} kg\n'
                      'Height: ${child['height']} ft\n'
                      'Allergies: ${child['allergies']}',
                    ),
                    trailing: Icon(Icons.child_care, color: Colors.blue),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
