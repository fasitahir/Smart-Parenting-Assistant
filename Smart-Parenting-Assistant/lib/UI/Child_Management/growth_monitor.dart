import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GrowthMonitorPage extends StatefulWidget {
  const GrowthMonitorPage({super.key});

  @override
  _GrowthMonitorPageState createState() => _GrowthMonitorPageState();
}

class _GrowthMonitorPageState extends State<GrowthMonitorPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _milestoneController = TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _growthData = [];
  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic>? _selectedChild;

  // API Endpoints
  final String _growthApiEndpoint = 'http://127.0.0.1:8000/growth';

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? parentId = prefs.getString('userId');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/children/?parentId=$parentId'),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        setState(() {
          _children =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        throw Exception('Failed to fetch children');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _fetchChildDetails(String childId) async {
    final String url = 'http://127.0.0.1:8000/children/$childId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> childData = jsonDecode(response.body);

        // Pre-fill fields with the child's data
        setState(() {
          _weightController.text = childData['weight'].toString();
          _heightController.text = childData['height'].toString();
        });
      } else {
        throw Exception('Failed to fetch child details');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _fetchGrowthData() async {
    if (_selectedChild == null) return;

    try {
      final response = await http.get(Uri.parse(_growthApiEndpoint));
      if (response.statusCode == 200) {
        final allGrowthData =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        setState(() {
          _growthData = allGrowthData
              .where((data) => data['child_id'] == _selectedChild!['id'])
              .toList();
        });
      } else {
        throw Exception('Failed to fetch growth data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _addGrowthData() async {
    if (_weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _selectedDate == null ||
        _selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields!")),
      );
      return;
    }

    final Map<String, dynamic> data = {
      "child_id": _selectedChild!['id'],
      "date": _selectedDate!.toIso8601String(),
      "weight": double.tryParse(_weightController.text),
      "height": double.tryParse(_heightController.text),
      "milestone": _milestoneController.text
    };

    try {
      final response = await http.post(
        Uri.parse(_growthApiEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        setState(() {
          _growthData.add(data);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Growth data added successfully!")),
        );
        _fetchGrowthData();
      } else {
        throw Exception('Failed to add growth data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Growth Monitor"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Child",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              value: _selectedChild,
              items: _children.map((child) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: child,
                  child: Text(child['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedChild = value;
                });

                // Fetch child details
                _fetchChildDetails(
                    value!['id']); // Use the child's ID to fetch details
              },
              hint: const Text("Select a child"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Add Growth Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
            ),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Height (ft)"),
            ),
            TextField(
              controller: _milestoneController,
              decoration: const InputDecoration(labelText: "Milestone"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {});
                  },
                  child: const Text("Select Date"),
                ),
                const SizedBox(width: 10),
                Text(
                  _selectedDate == null
                      ? "No Date Selected"
                      : _selectedDate!.toLocal().toString().split(' ')[0],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addGrowthData,
              child: const Text("Add Growth"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Growth Chart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _growthData.isEmpty
                ? const Text("No growth data available.")
                : Expanded(
                    child: ListView.builder(
                      itemCount: _growthData.length,
                      itemBuilder: (context, index) {
                        final data = _growthData[index];
                        return ListTile(
                          title: Text(
                              "Date: ${data['date'].toString().split('T')[0]}"),
                          subtitle: Text(
                              "Weight: ${data['weight']} kg, Height: ${data['height']} ft"),
                          trailing: Text(data['milestone'] ?? "No Milestone"),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
