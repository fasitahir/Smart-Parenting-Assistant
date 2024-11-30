import 'package:flutter/material.dart';
import 'Child_Management/add_profile.dart';
import 'Child_Management/view_profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Smart Parenting",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Manage Child" button
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Manage Child",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          ListTile(
                            leading: Icon(Icons.add, color: Colors.blue),
                            title: Text('Add Child'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddChildPage(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Add Child Selected")),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.update, color: Colors.orange),
                            title: Text('Update/Delete Child'),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Update/Delete Child Selected")),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.person, color: Colors.green),
                            title: Text('View Child Profile'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewChildrenPage(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("View Child Profile Selected")),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.manage_accounts),
              label: Text("Manage Child"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: TextStyle(fontSize: 18),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),

            // "Growth Monitor" button
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Growth Monitor Selected")),
                );
              },
              icon: Icon(Icons.monitor_weight),
              label: Text("Growth Monitor"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: TextStyle(fontSize: 18),
                minimumSize: Size(double.infinity, 50),
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
