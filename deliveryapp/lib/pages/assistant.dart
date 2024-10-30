import 'package:deliveryapp/pages/driver_account.dart';
import 'package:deliveryapp/pages/login.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:deliveryapp/config.dart';
import 'package:deliveryapp/pages/assistantSchedule.dart';

class AssistantScreen extends StatefulWidget {
  final int emp_id;
  final int assistant_id;
  final String assistant_name;

  AssistantScreen(
      {required this.emp_id,
      required this.assistant_id,
      required this.assistant_name});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  List schedules = [];

  @override
  void initState() {
    super.initState();
    fetchSchedules();
    print(widget.emp_id);
  }

  Future<void> fetchSchedules() async {
    final response = await http.get(
      Uri.parse('$api2URL/assistant/${widget.assistant_id}/schedules'),
    );

    if (response.statusCode == 500) {
      schedules = [];
    } else if (response.statusCode == 200) {
      setState(() {
        schedules = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, ' + widget.assistant_name + "!",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        backgroundColor: Color.fromARGB(255, 141, 0, 0),
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Your Schedules',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: schedules.isEmpty
                  ? Center(child: Text('Nothing to Show!'))
                  : ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        final isInProgress =
                            schedule['Status'] == 'In Progress';
                        // Parse and format the date/time from the schedule
                        final DateTime dateTime =
                            DateTime.parse(schedule['ScheduleDateTime']);
                        final formattedDateTime =
                            DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

                        return GestureDetector(
                          onTap: () async {
                            // Navigate to schedule details page when tapped
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScheduleDetailScreen(
                                  schedule: schedule,
                                  assistant_id: widget
                                      .assistant_id, // Change to assistantId
                                ),
                              ),
                            );

                            if (schedule['Status'] == 'In Progress') {
                              setState(() {
                                refreshSchedules();
                              });
                            }

                            if (schedule['Status'] == 'Completed') {
                              setState(() {
                                schedules.removeWhere((s) =>
                                    s['TruckScheduleID'] ==
                                    schedule['TruckScheduleID']);
                              });
                            }

                            // Refresh schedules if navigating back from the detail screen
                            if (result == true) {
                              refreshSchedules();
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: isInProgress
                                  ? Colors.green
                                  : Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDateTime,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshSchedules,
        child: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 165, 0, 0),
      ),
    );
  }

  void refreshSchedules() {
    schedules.clear();
    fetchSchedules();
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Placeholder for profile picture
                ),
                SizedBox(height: 10),
                Text(
                  widget.assistant_name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EmployeeDetailScreen(employeeId: widget.emp_id),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Perform logout and navigate back to the login page
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) =>
                    false, // This will remove all previous routes
              );
            },
          ),
        ],
      ),
    );
  }
}


