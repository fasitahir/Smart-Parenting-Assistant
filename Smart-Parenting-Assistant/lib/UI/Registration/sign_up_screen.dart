import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Ensure this import is present

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _gender = 'Select Gender'; // Default gender selection
  String _relationWithChild = 'Father'; // Default relation

  bool _isLoading = false;

  Future<void> registerUser() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final phone = _phoneController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final dob = _dobController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        dob.isEmpty ||
        _gender == 'Select Gender' ||
        _relationWithChild.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "email": email,
        "password": password,
        "dob": dob,
        "gender": _gender,
        "relation_with_child": _relationWithChild,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );
      Navigator.pop(context); // Navigate back to login screen
    } else {
      final message = jsonDecode(response.body)["detail"];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // Function to pick date
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Welcome text
              Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Sign up to access your Smart Parenting Assistant",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 30),

              // First Name input field
              _buildTextField(
                controller: _firstNameController,
                label: "First Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 20),

              // Last Name input field
              _buildTextField(
                controller: _lastNameController,
                label: "Last Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Phone input field
              _buildTextField(
                controller: _phoneController,
                label: "Phone",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Email input field
              _buildTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password input field
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Date of Birth input field with DatePicker
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dobController,
                    label: "Date of Birth",
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.datetime,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gender dropdown
              _buildDropdown(
                value: _gender,
                label: "Gender",
                icon: Icons.person,
                items: ['Select Gender', 'Male', 'Female', 'Other'],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Relation with child dropdown
              _buildDropdown(
                value: _relationWithChild,
                label: "Relation with Child",
                icon: Icons.child_care,
                items: ['Father', 'Mother', 'Other'],
                onChanged: (value) {
                  setState(() {
                    _relationWithChild = value!;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Register button
              ElevatedButton(
                onPressed: _isLoading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                      Theme.of(context).primaryColor, // Adjust color
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),

              // Already have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Go back to login screen
                    },
                    child: Text(
                      "Log in",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build input fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  // Helper function for dropdowns
  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
