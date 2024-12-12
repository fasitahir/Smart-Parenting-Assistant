import 'dart:convert';
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
        Uri.parse('http://127.0.0.1:8000/growth-detection/?childId=$childId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          growthStatus = jsonDecode(response.body)['growth_status'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to fetch growth detection data.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Detection'),
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
                    : Text(
                        growthStatus,
                        style: TextStyle(
                          fontSize: 16,
                          color: growthStatus.contains('Normal')
                              ? Colors.green
                              : Colors.red,
                        ),
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
    );
  }
}
