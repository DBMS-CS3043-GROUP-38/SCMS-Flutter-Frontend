import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For HTTP requests

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;

  EmployeeDetailScreen({required this.employeeId});

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  Map<String, dynamic>? employeeDetails;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeDetails(); // Fetch employee details when the screen is loaded
  }

  // Function to fetch employee details from the server
  Future<void> _fetchEmployeeDetails() async {
    final url = Uri.parse(
        'http://localhost:3000/get-employee/${widget.employeeId}'); // Replace with your server URL

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          employeeDetails = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print('Error fetching employee details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Details'),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while fetching
          : isError
              ? Center(child: Text('Error loading employee details'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${employeeDetails!['Name']}',
                          style: TextStyle(fontSize: 18)),
                      Text('Username: ${employeeDetails!['Username']}',
                          style: TextStyle(fontSize: 18)),
                      Text('Address: ${employeeDetails!['Address'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 18)),
                      Text('Contact: ${employeeDetails!['Contact'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 18)),
                      Text('Role: ${employeeDetails!['Type']}',
                          style: TextStyle(fontSize: 18)),
                      Text(
                          'Worked Hours: ${employeeDetails!['CompletedHours']}/${employeeDetails!['WorkingHours']}',
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
    );
  }
}
