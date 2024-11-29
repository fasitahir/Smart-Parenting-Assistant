// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Dashboard(),
//     );
//   }
// }

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   // To keep track of selected bottom navigation index
//   int _selectedIndex = 0;

//   // Method to change the selected index for bottom navigation
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Smart Parenting"),
//       ),
//       // body: Column(
//       //   children: [
//       //     // Padding at the top for spacing
//       //     Padding(
//       //       padding: const EdgeInsets.only(top: 20.0),
//       //       child: Row(
//       //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       //         children: [
//       //           _buildOptionIcon(Icons.access_alarm),
//       //           _buildOptionIcon(Icons.accessibility),
//       //           _buildOptionIcon(Icons.account_balance),
//       //           _buildOptionIcon(Icons.ac_unit),
//       //         ],
//       //       ),
//       //     ),
//       // Expanded(
//       //   child: Center(
//       //     child: Text("Selected Option: $_selectedIndex",
//       //         style: TextStyle(fontSize: 20)),
//       //   ),
//       // ),
//       //   ],
//       // ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex, // Set selected index
//         onTap: _onItemTapped, // Handle item tap
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: '',
//             backgroundColor: Colors.blue,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: '',
//             backgroundColor: Colors.blue,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: '',
//             backgroundColor: Colors.blue,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle),
//             label: '',
//             backgroundColor: Colors.blue,
//           ),
//         ],
//       ),
//     );
//   }

//   // A function to build each small navigation icon
//   Widget _buildOptionIcon(IconData icon) {
//     return GestureDetector(
//       onTap: () {
//         // You can handle each icon tap here
//         print('Tapped on icon');
//       },
//       child: Icon(
//         icon,
//         size: 40, // Small icon size
//         color: Colors.blue, // Icon color (you can customize)
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // To keep track of selected bottom navigation index
  int _selectedIndex = 0;

  // Method to change the selected index for bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Parenting"),
      ),
      body: Container(
        color: Colors.grey[200], // Set the background to a light shade of white
        child: Center(
          child: Text(
            "Selected Option: $_selectedIndex",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(), // Adds margin at the bottom
        child: BottomNavigationBar(
          currentIndex: _selectedIndex, // Set selected index
          onTap: _onItemTapped, // Handle item tap
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 40), // Increase icon size
              label: '',
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 40), // Increase icon size
              label: '',
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, size: 40), // Increase icon size
              label: '',
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle, size: 40), // Increase icon size
              label: '',
              backgroundColor: Colors.blue,
            ),
          ],
          type: BottomNavigationBarType
              .fixed, // Makes sure the icons don't shrink
        ),
      ),
    );
  }
}
