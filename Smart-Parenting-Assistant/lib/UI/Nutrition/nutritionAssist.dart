import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NutritionAssistPage extends StatefulWidget {
  const NutritionAssistPage({super.key});

  @override
  _NutritionAssistPageState createState() => _NutritionAssistPageState();
}

class _NutritionAssistPageState extends State<NutritionAssistPage> {
  List<Map<String, dynamic>> children = [];
  String? selectedChildId;
  List<Map<String, String>> nutritionSuggestions = [];
  TextEditingController followUpController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? parentId = prefs.getString('userId');

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/children/?parentId=$parentId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      setState(() {
        children = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch children.')),
      );
    }
  }

  Future<void> fetchNutritionSuggestions(String childId) async {
    setState(() {
      isLoading = true;
    });

    final selectedChild = children.firstWhere(
      (child) => child['id'] == childId,
      orElse: () => {},
    );

    if (selectedChild.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected child data not found.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/nutrition/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "date_of_birth": selectedChild['date_of_birth'],
          "weight": selectedChild['weight'],
          "height": selectedChild['height'],
          "milestones": selectedChild['milestones'] ?? [],
          "allergies": selectedChild['allergies'],
          "gender": selectedChild['gender'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['diet_plan'] != null &&
            data['diet_plan']['sections'] != null) {
          setState(() {
            // Safely casting List<dynamic> to List<Map<String, String>>
            nutritionSuggestions =
                (data['diet_plan']['sections'] as List<dynamic>).map((section) {
              // Ensure each section is a Map<String, dynamic>, and convert it to Map<String, String>
              return Map<String, String>.from(
                section as Map<String,
                    dynamic>, // Cast section to Map<String, dynamic>
              );
            }).toList();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No nutrition suggestions available.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to fetch nutrition suggestions.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendFollowUp(String question) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/nutrition/follow-up/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"question": question}),
    );

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final content =
          response.body.isNotEmpty ? response.body : 'No response from server.';
      setState(() {
        nutritionSuggestions.add({
          "title": "Follow-up: $question",
          "content": content,
        });
        followUpController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send follow-up question.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Assist'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Child',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedChildId,
              hint: const Text('Select a child'),
              items: children.map((child) {
                return DropdownMenuItem<String>(
                  value: child['id'],
                  child: Text(child['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedChildId = value;
                  fetchNutritionSuggestions(value!);
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Nutrition Suggestions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : nutritionSuggestions.isEmpty
                        ? const Text('No suggestions available.')
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: nutritionSuggestions.map((section) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '• ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            text:
                                                '${section['title']}: ', // Bold title
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: section['content'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
              ),
            ),
            const Divider(),
            const Text(
              'Ask Follow-up Question',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: followUpController,
              decoration: const InputDecoration(
                labelText: 'Type your question...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                sendFollowUp(followUpController.text);
              },
              child: const Text('Ask Question'),
            ),
          ],
        ),
      ),
    );
  }
}
