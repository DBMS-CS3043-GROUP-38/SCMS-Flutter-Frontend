import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:deliveryapp/config.dart';

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
    _fetchEmployeeDetails();
  }

  Future<void> _fetchEmployeeDetails() async {
    final url = Uri.parse('$apiURL/get-employee/${widget.employeeId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          employeeDetails = json.decode(response.body);
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
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : isError
                ? Text('Error loading employee details')
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildEmployeeInfoCard(),
                        SizedBox(height: 16),
                        _buildProgressCard(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Employee Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: 16),
            if (employeeDetails != null) ...[
              _buildInfoRow('Name', employeeDetails!['Name']),
              _buildInfoRow('Username', employeeDetails!['Username']),
              _buildInfoRow('Address', employeeDetails!['Address'] ?? 'N/A'),
              _buildInfoRow('Contact', employeeDetails!['Contact'] ?? 'N/A'),
              _buildInfoRow('Role', employeeDetails!['Type']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final completedHours = employeeDetails!['CompletedHours'] ?? 0;
    final totalHours = employeeDetails!['WorkingHours'] ?? 1;
    final progress = (completedHours / totalHours).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Working Hours Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Completed: $completedHours / $totalHours hours',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.green[600],
              minHeight: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
