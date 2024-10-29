import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:deliveryapp/config.dart';
import 'package:deliveryapp/pages/order.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final int assistant_id;

  const ScheduleDetailScreen({
    Key? key,
    required this.schedule,
    required this.assistant_id,
  }) : super(key: key);

  @override
  _ScheduleDetailScreenState createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  List orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    // Fetch orders for the schedule
    final response = await http.get(
      Uri.parse('$apiURL/schedule/${widget.schedule['TruckScheduleID']}/orders'),
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(widget.schedule['ScheduleDateTime']);
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Details'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schedule Information
            Text('Date: $formattedDate', style: TextStyle(fontSize: 18)),
            Text('Time: $formattedTime', style: TextStyle(fontSize: 18)),
            Text('Route ID: ${widget.schedule['RouteID']}',
                style: TextStyle(fontSize: 18)),
            Text('Driver: ${widget.schedule['DriverName']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            // Orders List
            Text('Orders', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: orders.isEmpty
                ? Center(child: Text('No orders found'))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to OrderDetailScreen and pass the orderId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(orderId: order['OrderID']),
                            ),
                          );
                        },
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Order ${order['OrderID']}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),

          ],
        ),
      ),
    );
  }
}
