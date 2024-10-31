import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:deliveryapp/config.dart';
import 'package:deliveryapp/pages/ipconfig.dart';

class OrdersScreen extends StatefulWidget {
  final int shipment_id;

  const OrdersScreen({super.key, required this.shipment_id});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
    _sortOrders();
  }

  // Fetch orders from the backend
  void fetchOrders() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.apiURL2}/assistant/${widget.shipment_id}/get-orders'));
    if (response.statusCode == 500) {
      orders = [];
    } else if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load orders');
    }
  }

  void showOrderDialog(
      BuildContext context, int orderId, String cusName, String address) {}

  Future<bool> markAsDelivered(int orderId) async {
    final url = Uri.parse('${ApiConfig.apiURL2}/mark-delivered');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_id': orderId}),
      );

      if (response.statusCode == 201) {
        return true; // Successfully added
      } else {
        print("Failed to add order tracking: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error adding order tracking: $error");
      return false;
    }
  }

  Future<bool> revertDelivery(int orderId) async {
    final url = Uri.parse('${ApiConfig.apiURL2}/revert-delivered');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_id': orderId}),
      );

      if (response.statusCode == 201) {
        return true; // Successfully added
      } else {
        print("Failed to revert order delivery: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error reverting order delivery: $error");
      return false;
    }
  }

  void toggleDeliveryStatus(int index) async {
    final order = orders[index];
    final orderId = order['OrderID'];
    final isDelivered = order['IsDelivered'] == 1;

    bool success;
    if (isDelivered) {
      success = await revertDelivery(orderId);
    } else {
      success = await markAsDelivered(orderId);
    }

    if (success) {
      setState(() {
        orders[index]['IsDelivered'] = isDelivered ? 0 : 1;
        _sortOrders();
      });
    }
  }

  void _sortOrders() {
    orders.sort((a, b) {
      if (a['IsDelivered'] == b['IsDelivered']) return 0;
      return a['IsDelivered'] == 1 ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders in Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text('Nothing to Show!'))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        int orderId = order['OrderID'];
                        String cusName = order['Name'];
                        String address = order['Address'];
                        bool isDelivered = order['IsDelivered'] == 1;

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Order Details'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Order ID: $orderId'),
                                      const SizedBox(height: 8),
                                      Text('Customer Name: $cusName'),
                                      const SizedBox(height: 8),
                                      Text('Address: $address'),
                                    ],
                                  ),
                                  actions: [
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          toggleDeliveryStatus(index);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40, vertical: 15),
                                          backgroundColor: isDelivered
                                              ? Colors.red
                                              : Colors.blueAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                20), // Rounded edges
                                          ),
                                        ),
                                        child: Text(
                                          isDelivered
                                              ? 'Mark as Not Delivered'
                                              : 'Mark as Delivered',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color:
                                  isDelivered ? Colors.green : Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ID: ' + orderId.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      cusName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      address,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}
