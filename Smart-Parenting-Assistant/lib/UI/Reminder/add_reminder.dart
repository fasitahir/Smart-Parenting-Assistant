import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Convert TimeOfDay to a string format (e.g., "14:30" for 2:30 PM)
  String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  Future<void> addReminder(Map<String, String> reminder) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/reminders'), // Updated URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reminder),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder added successfully!')),
        );
        Navigator.pop(context); // Navigate back to the previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add reminder')),
        );
        print('Failed response: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print("Error adding reminder: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add reminder')),
      );
    }
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final formattedDate = _selectedDate!.toIso8601String(); // ISO 8601 format
      final formattedTime =
          formatTimeOfDay(_selectedTime!); // 24-hour time format

      final reminder = {
        "title": _titleController.text,
        "date": formattedDate,
        "time": formattedTime,
      };

      addReminder(reminder);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Reminder',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.white)),
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Title Input Field
                  TextFormField(
                    controller: _titleController,
                    decoration:
                        const InputDecoration(labelText: 'Reminder Title'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter a title' : null,
                  ),
                  const SizedBox(height: 20),
                  // Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedDate == null
                          ? 'No date selected'
                          : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Time Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedTime == null
                          ? 'No time selected'
                          : 'Time: ${_selectedTime!.format(context)}'),
                      ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => _selectedTime = time);
                          }
                        },
                        child: const Text('Pick Time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveReminder,
                    child: const Text('Save Reminder'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
