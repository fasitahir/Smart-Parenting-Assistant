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
  String nutritionResponse = '';
  TextEditingController followUpController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    // Replace with your parent ID fetching logic
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

    // Find the selected child's data from the `children` list
    final selectedChild = children.firstWhere((child) => child['id'] == childId,
        orElse: () => {});

    if (selectedChild.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected child data not found.')),
      );
      return;
    }
    if (kDebugMode) {
      print(selectedChild);
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/nutrition/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "date_of_birth": selectedChild['date_of_birth'],
        "weight": selectedChild['weight'],
        "height": selectedChild['height'],
        //"milestones": selectedChild['milestones'] ?? [],
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        nutritionResponse = jsonDecode(response.body)[
            'suggestions']; // Adjust based on backend response format
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch nutrition suggestions.')),
      );
    }
  }

  Future<void> sendFollowUp(String question) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
          'http://127.0.0.1:8000/nutrition/follow-up/'), // Adjust endpoint
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"question": question}),
    );

    if (response.statusCode == 200) {
      setState(() {
        nutritionResponse +=
            "\n\nFollow-up: $question\nResponse: ${response.body}";
        followUpController.clear();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                  nutritionResponse.isEmpty
                      ? const Text('No suggestions available.')
                      : Text(nutritionResponse),
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
