import 'package:flutter/material.dart';
import 'Child_Management/add_profile.dart';
import 'Child_Management/view_profile.dart';
import 'Child_Management/update_profile.dart';
import 'Reminder/view_reminders.dart';
import 'Reminder/add_reminder.dart';
import 'Reminder/update_reminder.dart';
import 'Nutrition/nutritionAssist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  String _selectedReminderPage = "View Reminders"; // Initial selection

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onReminderPageSelected(String? value) {
    if (value != null) {
      // Only update the state if the value is different
      setState(() {
        _selectedReminderPage = value;
      });

      // Navigate to the selected reminder page
      switch (value) {
        case "Add Reminder":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderPage()),
          );
          break;
        case "Update Reminder":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UpdateReminderPage()),
          );
          break;
        case "View Reminders":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ViewRemindersPage()),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Parenting",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Keep the DropdownButton value consistent
          DropdownButton<String>(
            value: _selectedReminderPage, // This stays the same
            icon: const Icon(Icons.notifications, color: Colors.white),
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(
                value: "View Reminders",
                child: Text("View Reminders"),
              ),
              DropdownMenuItem(
                value: "Add Reminder",
                child: Text("Add Reminder"),
              ),
              DropdownMenuItem(
                value: "Update Reminder",
                child: Text("Update Reminder"),
              ),
            ],
            onChanged:
                _onReminderPageSelected, // Only updates when an option is selected
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Manage Child",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            leading: const Icon(Icons.add, color: Colors.blue),
                            title: const Text('Add Child'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddChildPage(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Add Child Selected")),
                              );
                            },
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.update, color: Colors.orange),
                            title: const Text('Update/Delete Child'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UpdateDeleteChildPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.green),
                            title: const Text('View Child Profile'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ViewChildrenPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.manage_accounts),
              label: const Text("Manage Child"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(fontSize: 18),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Growth Monitor Selected")),
                );
              },
              icon: const Icon(Icons.monitor_weight),
              label: const Text("Growth Monitor"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(fontSize: 18),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NutritionAssistPage(),
                  ),
                );
              },
              icon: const Icon(Icons.monitor_weight),
              label: const Text("Nutrition Assist"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(fontSize: 18),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5.0),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 30),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, size: 30),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle, size: 30),
              label: 'Profile',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
