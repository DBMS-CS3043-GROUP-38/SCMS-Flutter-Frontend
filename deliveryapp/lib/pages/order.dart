// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:deliveryapp/config.dart';
// import 'package:deliveryapp/pages/assistantSchedule.dart';

// class OrderDetailScreen extends StatefulWidget {
//   final int orderId;
//   final Map<String, dynamic>? orderDetails;

//   OrderDetailScreen({required this.orderId, this.orderDetails});

//   @override
//   _OrderDetailScreenState createState() => _OrderDetailScreenState();
// }

// class _OrderDetailScreenState extends State<OrderDetailScreen> {
//   bool isInProgress = false;
//   bool showButton = true;
//   bool activated = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchOrderDetails();

//     // Set initial button state based on the schedule's status
//     isInProgress = widget.orderDetails['Status'] == 'In Progress';
//   }

//   Future<void> fetchOrderDetails() async {
//     final response = await http.get(
//       Uri.parse('$apiURL/order/${widget.orderId}'),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         orderDetails = jsonDecode(response.body);
//       });
//     } else {
//       throw Exception('Failed to load order details');
//     }
//   }

//   Future<void> updateOrderStatus(String status) async {
//     final timestamp = DateTime.now().toIso8601String(); // Get current timestamp

//     final response = await http.post(
//       Uri.parse('$apiURL/updateOrderStatus'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'orderId': widget.orderId,
//         'timestamp': timestamp,
//         'status': status,
//       }),
//     );

//     if (response.statusCode == 200) {
//       // Order status update was successful
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Order status updated successfully')),
//       );
//     } else {
//       // Handle errors here
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update order status')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Order Details')),
//       body: orderDetails == null
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Display order details
//                   Text('Order ID: ${orderDetails!['orderId']}'),
//                   Text('Customer Name: ${orderDetails!['customerName']}'),
//                   Text('Username: ${orderDetails!['customerUsername']}'),
//                   Text('Contact: ${orderDetails!['customerContact']}'),
//                   Text('Type: ${orderDetails!['customerType']}'),
//                   Text('Address: ${orderDetails!['customerAddress']}'),
//                   Text('Schedule ID: ${orderDetails!['truckScheduleId']}'),
//                   SizedBox(height: 20),

//                   // Begin/End Delivery button
//                   Visibility(
//                     visible: showButton,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (isInProgress) {
//                           updateOrderStatus('Delivered');
//                           showButton = false;
//                           activated = false;
//                         }
//                         setState(() {
//                           isInProgress = !isInProgress;
//                         });
//                       },
//                       child: null,
//                     ),
//                   ),
//                   SizedBox(height: 10),

//                   // Cancel button, only visible when delivery is in progress and activated
//                   Visibility(
//                     visible: activated,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (isInProgress) {
//                           updateOrderStatus('InStore');
//                           activated = false;
//                           isInProgress = false;
//                         }
//                         setState(() {
//                           showButton = true;
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                         backgroundColor: Colors.redAccent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
