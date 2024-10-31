import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:deliveryapp/config.dart';
import 'package:intl/intl.dart';
import 'package:deliveryapp/pages/ipconfig.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

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
    final url = Uri.parse('${ApiConfig.apiURL}/get-employee/${widget.employeeId}');

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
        title: const Text('Employee Details'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : isError
                ? const Text('Error loading employee details')
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildEmployeeInfoCard(),
                        const SizedBox(height: 16),
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
            const Text(
              'Employee Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
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
    String tempcompletedHours = employeeDetails!['CompletedHours'];
    String temptotalHours = employeeDetails!['WorkingHours'];

    List<String> parts1 = tempcompletedHours.split(":");
    List<String> parts2 = temptotalHours.split(":");

    int hours1 = int.parse(parts1[0]);
    int minutes1 = int.parse(parts1[1]);
    int seconds1 = int.parse(parts1[2]);

    int hours2 = int.parse(parts2[0]);
    int minutes2 = int.parse(parts2[1]);
    int seconds2 = int.parse(parts2[2]);

    Duration dur1 =
        Duration(hours: hours1, minutes: minutes1, seconds: seconds1);
    Duration dur2 =
        Duration(hours: hours2, minutes: minutes2, seconds: seconds2);

    print(dur1);
    print(dur2);

    final progress =
        ((dur1.inSeconds / 1.0) / (dur2.inSeconds / 1.0)).clamp(0.0, 1.0);

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
            const Text(
              'Working Hours Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Completed: $tempcompletedHours / $temptotalHours hours',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
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
