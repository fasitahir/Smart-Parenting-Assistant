import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  _AddChildPageState createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  DateTime? _dateOfBirth;
  String? _gender;
  String? _allergies;
  double? _weight;
  double? _height;
  final TextEditingController _dobController = TextEditingController();

  // List of common allergies in babies
  final List<String> _allergyOptions = [
    "None",
    "Dairy",
    "Eggs",
    "Peanuts",
    "Shellfish",
    "Soy",
    "Wheat",
    "Tree nuts",
    "Dust mites",
    "Pet dander"
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      // Call backend to save child data
      _saveChildToBackend(
        name: _name!,
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        allergies: _allergies!,
        weight: _weight!,
        height: _height!,
        userId: userId!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Child added successfully!")),
      );

      // Clear the form or navigate back
      _formKey.currentState!.reset();
      _dobController.clear();
    }
  }

  Future<void> _saveChildToBackend({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String allergies,
    required double weight,
    required double height,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/children/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "date_of_birth": dateOfBirth.toIso8601String(),
        "gender": gender,
        "allergies": allergies,
        "weight": weight,
        "height": height,
        "parentId": userId,
      }),
    );

    // final response2 = await http.post(
    //   Uri.parse('http://127.0.0.1:8000/growth/initial'),
    //   headers: {"Content-Type": "application/json"},
    //   body: jsonEncode({
    //     "child_id": jsonDecode(response.body)['id'],
    //     "date": DateTime.now(),
    //     "weight": weight,
    //     "height": height,
    //     "milestones": [],
    //   }),
    // );

    // if (kDebugMode) {
    //   print("Adding Initial Growth:  $response2.statusCode");
    // }
    if (response.statusCode == 201) {
      if (kDebugMode) {
        print("Child added successfully");
      }
    } else {
      if (kDebugMode) {
        print("Failed to add child");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Child",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
              color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter Child Details",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Child's Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the child's name.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date of Birth Field
                    TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        labelText: "Date of Birth",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dateOfBirth = pickedDate;
                            _dobController.text =
                                "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a date of birth.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Gender Field
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Gender",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: ["Male", "Female", "Other"]
                          .map((gender) => DropdownMenuItem(
                              value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (value) {
                        _gender = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a gender.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Allergies Field (Dropdown)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Allergies",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _allergyOptions
                          .map((allergy) => DropdownMenuItem(
                                value: allergy,
                                child: Text(allergy),
                              ))
                          .toList(),
                      onChanged: (value) {
                        _allergies = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select an allergy option.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Weight Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Weight (kg)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return "Please enter a valid weight.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _weight = double.parse(value!);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Height Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Height (ft)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return "Please enter a valid height.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _height = double.parse(value!);
                      },
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text("Add Child"),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
