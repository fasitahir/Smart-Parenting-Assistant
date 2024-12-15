import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GrowthDetectionPage extends StatefulWidget {
  const GrowthDetectionPage({super.key});

  @override
  _GrowthDetectionPageState createState() => _GrowthDetectionPageState();
}

class _GrowthDetectionPageState extends State<GrowthDetectionPage> {
  List<Map<String, dynamic>> children = [];
  String? selectedChildId;
  String growthStatus = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChildrenForParent();
  }

  Future<void> fetchChildrenForParent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? parentId = prefs.getString('userId');

    setState(() {
      isLoading = true;
    });

    try {
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

  Future<void> fetchGrowthDetection(String childId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/growth-detection/?child_id=$childId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          final jsonData = jsonDecode(response.body)['data'];
          final nutritionStatus = jsonData['nutrition_status'];
          final message = formatMessage(
            name: jsonData['name'],
            age: jsonData['age'],
            height: jsonData['height'],
            gender: jsonData['gender'],
            nutritionStatus: nutritionStatus,
          );

          // Display the message in the UI or store it in a variable
          growthStatus = message;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to fetch growth detection data.')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildNutritionStatus(String nutritionStatus) {
    Color textColor = (nutritionStatus == "Normal" || nutritionStatus == "Tall")
        ? Colors.green
        : Colors.red;

    return Text(
      "Nutrition Status: $nutritionStatus",
      style: TextStyle(fontSize: 16, color: textColor),
    );
  }

  Widget buildNutritionLink() {
    return GestureDetector(
      onTap: () {
        // Navigate to the Nutrition Assist page
        Navigator.pushNamed(context, '/nutrition-assist');
      },
      child: const Text(
        "Visit the Nutrition Assist window for dietary recommendations.",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  String formatMessage(
      {required String name,
      required int age,
      required double height,
      required String gender,
      required String nutritionStatus}) {
    String baseMessage = "$nutritionStatus\n"
        "Child: $name\n"
        "Age: $age months\n"
        "Height: $height cm\n"
        "Gender: $gender\n";

    if (nutritionStatus == "Normal" || nutritionStatus == "Tall") {
      baseMessage +=
          "The child's growth is within a healthy range. Keep up the good parenting.";
    } else if (nutritionStatus == "Severely stunned" ||
        nutritionStatus == "Stunned") {
      baseMessage +=
          "The child's growth is abnormal. Please visit a pediatrician for further evaluation.";
    }

    return baseMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Growth Detection',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
                color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width, // Full width
          height: MediaQuery.of(context).size.height, // Full height
          color: Colors.white,
          child: Padding(
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
                      growthStatus = "";
                    });
                    if (value != null) {
                      fetchGrowthDetection(value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Growth Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : growthStatus.isEmpty
                        ? const Text('Select a child to view growth status.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildNutritionStatus(growthStatus),
                              const SizedBox(height: 10),
                              if (growthStatus.contains('abnormal'))
                                buildNutritionLink(),
                            ],
                          ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: selectedChildId == null
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/growth-monitor',
                              arguments: selectedChildId);
                        },
                  child: const Text('Update Growth Data'),
                ),
              ],
            ),
          ),
        ));
  }
}
