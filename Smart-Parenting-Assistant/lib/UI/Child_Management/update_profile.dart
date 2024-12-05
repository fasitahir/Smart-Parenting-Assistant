import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateDeleteChildPage extends StatefulWidget {
  const UpdateDeleteChildPage({super.key});

  @override
  _UpdateDeleteChildPageState createState() => _UpdateDeleteChildPageState();
}

class _UpdateDeleteChildPageState extends State<UpdateDeleteChildPage> {
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

  Future<void> updateChild(
      String childId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/children/$childId/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child profile updated successfully!')),
      );
      setState(() {
        _childrenFuture = fetchChildren();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update child profile.')),
      );
    }
  }

  Future<void> deleteChild(String childId) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/children/$childId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child profile deleted successfully!')),
      );
      setState(() {
        _childrenFuture = fetchChildren();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete child profile.')),
      );
    }
  }

  void showEditDialog(Map<String, dynamic> child) {
    final TextEditingController nameController =
        TextEditingController(text: child['name']);
    final TextEditingController dobController =
        TextEditingController(text: child['date_of_birth']);
    final TextEditingController weightController =
        TextEditingController(text: child['weight'].toString());
    final TextEditingController heightController =
        TextEditingController(text: child['height'].toString());
    final TextEditingController allergiesController =
        TextEditingController(text: child['allergies']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Child Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(labelText: 'Height (ft)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: allergiesController,
                  decoration: const InputDecoration(labelText: 'Allergies'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedData = {
                  'name': nameController.text,
                  'date_of_birth': dobController.text,
                  'weight': double.tryParse(weightController.text) ?? 0,
                  'height': double.tryParse(heightController.text) ?? 0,
                  'allergies': allergiesController.text,
                };
                updateChild(child['id'], updatedData);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(String childId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Child'),
          content: const Text('Are you sure you want to delete this child?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteChild(childId);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update/Delete Child'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _childrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No children found.'));
          } else {
            final children = snapshot.data!;
            return ListView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      child['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'DOB: ${child['date_of_birth']}\n'
                      'Gender: ${child['gender']}\n'
                      'Weight: ${child['weight']} kg\n'
                      'Height: ${child['height']} ft\n'
                      'Allergies: ${child['allergies']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            showEditDialog(child);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            confirmDelete(child['id']);
                          },
                        ),
                      ],
                    ),
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
