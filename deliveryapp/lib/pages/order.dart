import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:deliveryapp/config.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? orderDetails;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final response = await http.get(
      Uri.parse('$apiURL/order/${widget.orderId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        orderDetails = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load order details');
    }
  }

  Future<void> updateOrderStatus(String status) async {
  final timestamp = DateTime.now().toIso8601String();  // Get current timestamp
  
  final response = await http.post(
    Uri.parse('$apiURL/updateOrderStatus'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'orderId': widget.orderId,
      'timestamp': timestamp,
      'status': status,
    }),
  );

  if (response.statusCode == 200) {
    // Order status update was successful
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order status updated successfully')),
    );
  } else {
    // Handle errors here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update order status')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: orderDetails == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${orderDetails!['orderId']}'),
                  Text('Customer Name: ${orderDetails!['customerName']}'),
                  Text('Username: ${orderDetails!['customerUsername']}'),
                  Text('Contact: ${orderDetails!['customerContact']}'),
                  Text('Type: ${orderDetails!['customerType']}'),
                  Text('Address: ${orderDetails!['customerAddress']}'),
                  Text('Schedule ID: ${orderDetails!['truckScheduleId']}'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => updateOrderStatus("Completed"),
                        child: Text("Complete"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => updateOrderStatus("Cancelled"),
                        child: Text("Cancel"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
