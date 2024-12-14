// import 'package:flutter/material.dart';

// class UpdateReminderPage extends StatefulWidget {
//   const UpdateReminderPage({super.key});

//   @override
//   _UpdateReminderPageState createState() => _UpdateReminderPageState();
// }

// class _UpdateReminderPageState extends State<UpdateReminderPage> {
//   final List<Map<String, dynamic>> reminders = [
//     {
//       "id": 1,
//       "title": "Doctor Appointment",
//       "date": "2023-12-15",
//       "time": "10:00 AM"
//     },
//     {
//       "id": 2,
//       "title": "Feeding Time",
//       "date": "2023-12-07",
//       "time": "12:00 PM"
//     },
//   ]; // Replace with real data from backend

//   Map<String, dynamic>? _selectedReminder;
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;

//   void _loadReminderDetails(Map<String, dynamic> reminder) {
//     _titleController.text = reminder["title"];
//     _selectedDate = DateTime.parse(reminder["date"]);
//     _selectedTime = TimeOfDay(
//       hour: int.parse(reminder["time"].split(":")[0]),
//       minute: int.parse(reminder["time"].split(":")[1].split(" ")[0]),
//     );
//   }

//   void _saveUpdatedReminder() {
//     if (_formKey.currentState!.validate() &&
//         _selectedDate != null &&
//         _selectedTime != null) {
//       setState(() {
//         _selectedReminder!["title"] = _titleController.text;
//         _selectedReminder!["date"] = _selectedDate!.toIso8601String();
//         _selectedReminder!["time"] = _selectedTime!.format(context);
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Reminder updated successfully')),
//       );
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Update Reminder'),
//       ),
//       body: _selectedReminder == null
//           ? ListView.builder(
//               itemCount: reminders.length,
//               itemBuilder: (context, index) {
//                 final reminder = reminders[index];
//                 return ListTile(
//                   title: Text(reminder["title"]),
//                   subtitle: Text('${reminder["date"]} at ${reminder["time"]}'),
//                   onTap: () {
//                     setState(() {
//                       _selectedReminder = reminder;
//                     });
//                     _loadReminderDetails(reminder);
//                   },
//                 );
//               },
//             )
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _titleController,
//                       decoration:
//                           const InputDecoration(labelText: 'Reminder Title'),
//                       validator: (value) => value == null || value.isEmpty
//                           ? 'Enter a title'
//                           : null,
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(_selectedDate == null
//                             ? 'No date selected'
//                             : 'Date: ${_selectedDate!.toLocal()}'
//                                 .split(' ')[0]),
//                         ElevatedButton(
//                           onPressed: () async {
//                             DateTime? date = await showDatePicker(
//                               context: context,
//                               initialDate: _selectedDate!,
//                               firstDate: DateTime.now(),
//                               lastDate: DateTime(2101),
//                             );
//                             if (date != null) {
//                               setState(() => _selectedDate = date);
//                             }
//                           },
//                           child: const Text('Pick Date'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(_selectedTime == null
//                             ? 'No time selected'
//                             : 'Time: ${_selectedTime!.format(context)}'),
//                         ElevatedButton(
//                           onPressed: () async {
//                             TimeOfDay? time = await showTimePicker(
//                               context: context,
//                               initialTime: _selectedTime!,
//                             );
//                             if (time != null) {
//                               setState(() => _selectedTime = time);
//                             }
//                           },
//                           child: const Text('Pick Time'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 40),
//                     ElevatedButton(
//                       onPressed: _saveUpdatedReminder,
//                       child: const Text('Save Reminder'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateReminderPage extends StatefulWidget {
  const UpdateReminderPage({super.key});

  @override
  _UpdateReminderPageState createState() => _UpdateReminderPageState();
}

class _UpdateReminderPageState extends State<UpdateReminderPage> {
  List<Map<String, dynamic>> reminders = [];
  Map<String, dynamic>? _selectedReminder;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Fetch reminders from the backend
  Future<void> fetchReminders() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/reminders'));
    if (response.statusCode == 200) {
      setState(() {
        reminders = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load reminders')),
      );
    }
  }

  // Load selected reminder details into form
  // void _loadReminderDetails(Map<String, dynamic> reminder) {
  //   _titleController.text = reminder["title"];
  //   _selectedDate = DateTime.parse(reminder["date"]);
  //   _selectedTime = TimeOfDay(
  //     hour: int.parse(reminder["time"].split(":")[0]),
  //     minute: int.parse(reminder["time"].split(":")[1].split(" ")[0]),
  //   );
  // }
  void _loadReminderDetails(Map<String, dynamic> reminder) {
    _titleController.text = reminder["title"];
    _selectedDate = DateTime.parse(reminder["date"]);
    _selectedTime = TimeOfDay(
      hour: int.parse(reminder["time"].split(":")[0]),
      minute: int.parse(reminder["time"].split(":")[1].split(" ")[0]),
    );
    print("Loaded reminder with id: ${reminder["id"]}");
  }

  // Update the selected reminder
  Future<void> _saveUpdatedReminder() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final updatedReminder = {
        "title": _titleController.text,
        "date": _selectedDate!.toIso8601String(),
        "time": _selectedTime!.format(context),
      };

      // Send update to the backend using title in URL
      final response = await http.put(
        Uri.parse(
            'http://127.0.0.1:8000/reminders/${_selectedReminder!["title"]}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedReminder),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update reminder')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Reminder',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.white)),
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          color: Colors.white,
          child: _selectedReminder == null
              ? ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return ListTile(
                      title: Text(reminder["title"]),
                      subtitle:
                          Text('${reminder["date"]} at ${reminder["time"]}'),
                      onTap: () {
                        setState(() {
                          _selectedReminder = reminder;
                        });
                        _loadReminderDetails(reminder);
                      },
                    );
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                              labelText: 'Reminder Title'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter a title'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDate == null
                                ? 'No date selected'
                                : 'Date: ${_selectedDate!.toLocal()}'
                                    .split(' ')[0]),
                            ElevatedButton(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate!,
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
                                  initialTime: _selectedTime!,
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
                          onPressed: _saveUpdatedReminder,
                          child: const Text('Save Reminder'),
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }
}
