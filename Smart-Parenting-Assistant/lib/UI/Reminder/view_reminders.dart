import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewRemindersPage extends StatefulWidget {
  const ViewRemindersPage({super.key});

  @override
  State<ViewRemindersPage> createState() => _ViewRemindersPageState();
}

class _ViewRemindersPageState extends State<ViewRemindersPage> {
  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/reminders'));
    if (response.statusCode == 200) {
      setState(() {
        reminders = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch reminders')),
      );
    }
  }

  Future<void> deleteReminder(String title) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/reminders/$title'),
    );
    if (response.statusCode == 200) {
      fetchReminders(); // Refresh reminders
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete reminder')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reminders',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.white)),
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          color: Colors.white,
          child: reminders.isEmpty
              ? const Center(child: Text('No reminders found'))
              : ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return ListTile(
                      title: Text(reminder["title"]),
                      subtitle:
                          Text('${reminder["date"]} at ${reminder["time"]}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteReminder(reminder["title"]),
                      ),
                    );
                  },
                ),
        ));
  }
}
