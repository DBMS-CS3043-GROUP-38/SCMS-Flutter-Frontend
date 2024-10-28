import 'package:deliveryapp/pages/driver_account.dart';
import 'package:deliveryapp/pages/login.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DriverScreen extends StatefulWidget {
  final int emp_id;
  final int driver_id;
  final String driver_name;

  DriverScreen(
      {required this.emp_id,
      required this.driver_id,
      required this.driver_name});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  List schedules = [];

  @override
  void initState() {
    super.initState();
    fetchSchedules();
    print(widget.emp_id);
  }

  // Fetch schedules from the backend
  void fetchSchedules() async {
    final response = await http.get(Uri.parse(
        'http://localhost:3000/driver/${widget.driver_id}/schedules'));
    if (response.statusCode == 500) {
      schedules = [];
    } else if (response.statusCode == 200) {
      setState(() {
        schedules = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load schedules');
    }
    print("actually");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, ' + widget.driver_name + "!",
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
                                builder: (context) =>
                                    ScheduleDetailScreen(schedule: schedule),
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
                  widget.driver_name, // Display driver's name
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

class ScheduleDetailScreen extends StatefulWidget {
  final Map<String, dynamic>
      schedule; // Expecting a map containing schedule details

  const ScheduleDetailScreen({Key? key, required this.schedule})
      : super(key: key);

  @override
  _ScheduleDetailScreenState createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  bool isInProgress = false;
  bool showButton = true;
  bool activated = false;
  @override
  void initState() {
    super.initState();
    // Set initial button state based on the schedule's status
    isInProgress = widget.schedule['Status'] == 'In Progress';
  }

  // Future<void> beginDelivery(int scheduleId) async {
  //   final scheduleId = widget.schedule['TruckScheduleID'];

  //   final url =
  //       'http://localhost:3000/begin-delivery'; // Replace with your backend URL

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'TruckScheduleID': scheduleId, 'Status': 'InTruck'}),
  //     );

  //     if (response.statusCode == 200) {
  //     } else {}
  //   } catch (error) {}
  // }

  // Function to handle status update
  Future<void> _updateStatus(String newStatus) async {
    final scheduleId = widget.schedule['TruckScheduleID'];

    final url =
        'http://localhost:3000/update-status'; // Replace with your backend URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'TruckScheduleID': scheduleId, 'Status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.schedule['Status'] = newStatus;
          isInProgress = newStatus == 'In Progress';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeId = widget.schedule['RouteID'];
    final truckId = widget.schedule['truckID'];
    final scheduleId = widget.schedule['TruckScheduleID'];
    final assistantName = widget.schedule['Name'];
    final departureDate = widget.schedule['ScheduleDateTime'].split('T')[0];
    final departureTime = widget.schedule['ScheduleDateTime'].split('T')[1];
    final storeId = widget.schedule['StoreID'];
    final status = widget.schedule['Status'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pop-up card for schedule details
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Schedule ID: $scheduleId',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Status: $status',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Route ID: $routeId',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Truck ID: $truckId',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Assistant Name: $assistantName',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Departure Date: $departureDate',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Departure Time: $departureTime',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Store ID: $storeId',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // Space between card and button

              // Begin/End Delivery button
              Visibility(
                visible: showButton ? true : false,
                child: ElevatedButton(
                  onPressed: () {
                    if (isInProgress) {
                      _updateStatus('Completed');
                      showButton = false;
                      activated = false;
                    } else {
                      _updateStatus('In Progress');
                      //beginDelivery(scheduleId);
                      activated = true;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor:
                        isInProgress ? Colors.redAccent : Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded edges
                    ),
                  ),
                  child: Text(
                    isInProgress ? 'End Delivery' : 'Begin Delivery',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Visibility(
                visible: activated ? true : false,
                child: ElevatedButton(
                  onPressed: () {
                    if (isInProgress) {
                      _updateStatus('Not Completed');
                      activated = false;
                      isInProgress = false;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded edges
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
