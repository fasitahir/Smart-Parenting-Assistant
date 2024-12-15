import 'package:flutter/material.dart';
import 'package:smart_parenting_assistant/UI/Growth_Evaluation/growth_evaluator.dart';
import 'Child_Management/add_profile.dart';
import 'Child_Management/view_profile.dart';
import 'Child_Management/update_profile.dart';
import 'Child_Management/growth_monitor.dart';
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
  String? _selectedReminderPage; // Initial selection

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onReminderPageSelected(String? value) {
    if (value != null && value != _selectedReminderPage) {
      setState(() {
        _selectedReminderPage = value;
      });

      // Navigate to the selected reminder page
      Widget nextPage;
      switch (value) {
        case "Add Reminder":
          nextPage = const AddReminderPage();
          break;
        case "Update Reminder":
          nextPage = const UpdateReminderPage();
          break;
        case "View Reminders":
          nextPage = const ViewRemindersPage();
          break;
        default:
          return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      ).then((_) {
        // Reset the selected reminder page when coming back
        setState(() {
          _selectedReminderPage = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Parenting",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF1C170D)),
        ),
        backgroundColor: const Color.fromARGB(239, 255, 255, 255),
        actions: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 48, // Minimum touch target size
              minHeight: 48,
            ),
            child: GestureDetector(
              onTap: () async {
                // Show the dropdown menu
                final selectedValue = await showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(100, 80, 10, 0),
                  items: const [
                    // PopupMenuItem(
                    //   value: "View Reminders",
                    //   child: Text("View Reminders"),
                    // ),

                    //
                    PopupMenuItem(
                      value: "View Reminders",
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.blue),
                          SizedBox(width: 8), // Space between icon and text
                          Text("View Reminders"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Add Reminder",
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.green),
                          SizedBox(width: 8),
                          Text("Add Reminder"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Update Reminder",
                      child: Row(
                        children: [
                          Icon(Icons.update, color: Colors.orange),
                          SizedBox(width: 8),
                          Text("Update Reminder"),
                        ],
                      ),
                    ),
                  ],
                );

                // Handle the selected value
                if (selectedValue != null) {
                  _onReminderPageSelected(selectedValue);
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.notifications, color: Color(0xFF1C170D)),
              ),
            ),
          ),
        ],
      ),
      // body: Container(
      //   color: const Color.fromARGB(239, 255, 255, 255),
      //   padding: const EdgeInsets.all(16),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       ElevatedButton.icon(
      //         onPressed: () {
      //           showModalBottomSheet(
      //             shape: const RoundedRectangleBorder(
      //               borderRadius:
      //                   BorderRadius.vertical(top: Radius.circular(20)),
      //             ),
      //             context: context,
      //             builder: (BuildContext context) {
      //               return Container(
      //                 padding: const EdgeInsets.all(20),
      //                 child: Column(
      //                   mainAxisSize: MainAxisSize.min,
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     const Text(
      //                       "Manage Child",
      //                       style: TextStyle(
      //                         color: Colors.black,
      //                         fontWeight: FontWeight.bold,
      //                         fontSize: 18,
      //                       ),
      //                     ),
      //                     const SizedBox(height: 10),
      //                     ListTile(
      //                       leading: const Icon(Icons.add, color: Colors.blue),
      //                       title: const Text('Add Child'),
      //                       onTap: () {
      //                         Navigator.pop(context);
      //                         Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (context) => const AddChildPage(),
      //                           ),
      //                         );
      //                         ScaffoldMessenger.of(context).showSnackBar(
      //                           const SnackBar(
      //                               content: Text("Add Child Selected")),
      //                         );
      //                       },
      //                     ),
      //                     ListTile(
      //                       leading:
      //                           const Icon(Icons.update, color: Colors.orange),
      //                       title: const Text('Update/Delete Child'),
      //                       onTap: () {
      //                         Navigator.pop(context);
      //                         Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (context) =>
      //                                 const UpdateDeleteChildPage(),
      //                           ),
      //                         );
      //                       },
      //                     ),
      //                     ListTile(
      //                       leading:
      //                           const Icon(Icons.person, color: Colors.green),
      //                       title: const Text('View Child Profile'),
      //                       onTap: () {
      //                         Navigator.pop(context);
      //                         Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (context) =>
      //                                 const ViewChildrenPage(),
      //                           ),
      //                         );
      //                       },
      //                     ),
      //                   ],
      //                 ),
      //               );
      //             },
      //           );
      //         },
      //         icon: const Icon(Icons.manage_accounts),
      //         label: const Text(
      //           "Manage Child",
      //           style: TextStyle(
      //             fontWeight: FontWeight.bold, // Make text bold
      //             fontFamily: 'Plus Jakarta Sans', // Use Plus Jakarta Sans font
      //           ),
      //         ),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.blueAccent,
      //           foregroundColor: Colors.white, // Text color
      //           padding: const EdgeInsets.symmetric(vertical: 15),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15),
      //           ),
      //           textStyle: const TextStyle(
      //             fontSize: 18,
      //             fontWeight: FontWeight.bold,
      //             fontFamily: 'Plus Jakarta Sans',
      //           ),
      //           minimumSize: const Size(double.infinity, 50),
      //         ),
      //       ),
      //       const SizedBox(height: 20),
      //       ElevatedButton.icon(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const GrowthMonitorPage(),
      //             ),
      //           );
      //         },
      //         icon: const Icon(Icons.monitor_weight),
      //         label: const Text(
      //           "Growth Monitor",
      //           style: TextStyle(
      //             fontWeight: FontWeight.bold, // Make text bold
      //             fontFamily: 'Plus Jakarta Sans', // Use Plus Jakarta Sans font
      //           ),
      //         ),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: const Color(0xFF009963),
      //           foregroundColor: Colors.white, // Text color
      //           padding: const EdgeInsets.symmetric(vertical: 15),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15),
      //           ),
      //           textStyle: const TextStyle(
      //             fontSize: 18,
      //             fontWeight: FontWeight.bold, // Bold text
      //             fontFamily: 'Plus Jakarta Sans',
      //           ),
      //           minimumSize: const Size(double.infinity, 50),
      //         ),
      //       ),
      //       const SizedBox(height: 20),
      //       ElevatedButton.icon(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const NutritionAssistPage(),
      //             ),
      //           );
      //         },
      //         icon: const Icon(Icons.restaurant_menu),
      //         label: const Text(
      //           "Diet Recomndations",
      //           style: TextStyle(
      //             fontWeight: FontWeight.bold, // Make text bold
      //             fontFamily: 'Plus Jakarta Sans', // Use Plus Jakarta Sans font
      //           ),
      //         ),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.blueAccent,
      //           foregroundColor: Colors.white, // Text color
      //           padding: const EdgeInsets.symmetric(vertical: 15),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15),
      //           ),
      //           textStyle: const TextStyle(
      //               fontSize: 18,
      //               fontWeight: FontWeight.bold,
      //               fontFamily: 'Plus Jakarta Sans'),
      //           minimumSize: const Size(double.infinity, 50),
      //         ),
      //       ),
      //       const SizedBox(height: 20),
      //       ElevatedButton.icon(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const GrowthDetectionPage(),
      //             ),
      //           );
      //         },
      //         icon: const Icon(Icons.monitor_weight),
      //         label: const Text(
      //           "Growth Evaluation",
      //           style: TextStyle(
      //             fontWeight: FontWeight.bold, // Make text bold
      //             fontFamily: 'Plus Jakarta Sans', // Use Plus Jakarta Sans font
      //           ),
      //         ),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Color(0xFF009963),
      //           foregroundColor: Colors.white, // Text color
      //           padding: const EdgeInsets.symmetric(vertical: 15),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15),
      //           ),
      //           textStyle: const TextStyle(
      //               fontSize: 18,
      //               fontWeight: FontWeight.bold,
      //               fontFamily: 'Plus Jakarta Sans'),
      //           minimumSize: const Size(double.infinity, 50),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: Container(
        color: const Color.fromARGB(239, 255, 255, 255),
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2, // Two cards per row
          crossAxisSpacing: 16, // Spacing between columns
          mainAxisSpacing: 16, // Spacing between rows
          childAspectRatio: 1, // Makes the cards square
          children: [
            // Manage Child Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: InkWell(
                onTap: () {
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
                              leading:
                                  const Icon(Icons.add, color: Colors.blue),
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
                              leading: const Icon(Icons.update,
                                  color: Colors.orange),
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
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.manage_accounts,
                          size: 40, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Manage Child",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                splashColor: Colors.blueAccent,
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blueAccent,
            ),

            // Growth Monitor Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GrowthMonitorPage(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.monitor_weight, size: 40, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Growth Monitor",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                splashColor: Color(0xFF009963),
                borderRadius: BorderRadius.circular(15),
              ),
              color: Color(0xFF009963),
            ),

            // Diet Recommendations Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NutritionAssistPage(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.restaurant_menu,
                          size: 40, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Diet Recommendations",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                splashColor: Colors.blueAccent,
                borderRadius: BorderRadius.circular(15),
              ),
              color: Color(0xFF009963),
            ),

            // Growth Evaluation Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GrowthDetectionPage(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.monitor_weight, size: 40, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Growth Evaluation",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                splashColor: Color(0xFF009963),
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blueAccent,
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
          backgroundColor: Colors.white,
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
