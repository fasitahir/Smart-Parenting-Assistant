import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GrowthMonitorPage extends StatefulWidget {
  const GrowthMonitorPage({super.key});

  @override
  _GrowthMonitorPageState createState() => _GrowthMonitorPageState();
}

class Legend extends StatelessWidget {
  final Color color;
  final String label;

  const Legend({required this.color, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
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

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

// Inside your _GrowthMonitorPageState class

  Widget _buildGrowthChart() {
    if (_growthData.isEmpty) {
      return const Text("No growth data available to display on the chart.");
    }

    // Sort data by date
    _growthData.sort((a, b) =>
        DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

    // Prepare data points for height and weight
    List<FlSpot> heightDataPoints = [];
    List<FlSpot> weightDataPoints = [];
    for (var i = 0; i < _growthData.length; i++) {
      final entry = _growthData[i];
      double xValue = i.toDouble(); // Sequential index for x-axis
      double heightValue = entry['height'] ?? 0.0; // Height on y-axis
      double weightValue = entry['weight'] ?? 0.0; // Weight on y-axis
      heightDataPoints.add(FlSpot(xValue, heightValue));
      weightDataPoints.add(FlSpot(xValue, weightValue));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Height Chart',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                        );
                      },
                    ),
                    axisNameWidget: const Text(
                      'Height',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _growthData.length) {
                          return Text(
                            _growthData[value.toInt()]['date']
                                .toString()
                                .split('T')[0], // Show dates
                            style: const TextStyle(
                                color: Colors.black, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                    axisNameWidget: const Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: heightDataPoints,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Weight Chart',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                        );
                      },
                    ),
                    axisNameWidget: const Text(
                      'Weight',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _growthData.length) {
                          return Text(
                            _growthData[value.toInt()]['date']
                                .toString()
                                .split('T')[0], // Show dates
                            style: const TextStyle(
                                color: Colors.black, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                    axisNameWidget: const Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightDataPoints,
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.redAccent.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Future<void> _fetchGrowthData(String childId) async {
    if (_selectedChild == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/growth/getGrowthData/$childId"),
      );

      if (response.statusCode == 200) {
        // Use 200 for successful GET
        final decodedResponse = jsonDecode(response.body);

        final allGrowthData =
            List<Map<String, dynamic>>.from(decodedResponse['data']);

        setState(() {
          _growthData = allGrowthData
              .where((data) => data['child_id'] == _selectedChild!['id'])
              .toList();
        });
      } else {
        throw Exception('Failed to fetch growth data');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
        Uri.parse("http://127.0.0.1:8000/growth/add"),
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
        _fetchGrowthData(_selectedChild!['id']);
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
          title: const Text(
            "Growth Monitor",
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
            // Added SingleChildScrollView to make page scrollable
            child: Padding(
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
                      _fetchGrowthData(value['id']);
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
                  SizedBox(
                    // Specify a fixed height for the chart
                    height: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildGrowthChart(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
