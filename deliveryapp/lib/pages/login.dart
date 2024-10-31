import 'dart:convert';
import 'package:deliveryapp/pages/assistant.dart';
import 'package:deliveryapp/pages/driver.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:deliveryapp/config.dart';
import 'package:deliveryapp/pages/ipconfig.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${ApiConfig.apiURL}/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 500) {
      final data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Server Error'),
          content: Text(data['error']),
        ),
      );
    } else if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        if (data['type'] == 'Driver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DriverScreen(
                emp_id: data['emp_id'],
                driver_id: data['id'],
                driver_name: data['name'],
              ),
            ),
          );
        } else if (data['type'] == 'Assistant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AssistantScreen(
                emp_id: data['emp_id'],
                assistant_id: data['id'],
                assistant_name: data['name'],
              ),
            ),
          );
        } else {
          // Handle other user types if needed
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Failed'),
            content: Text(data['message']),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(children: <Widget>[
        Positioned.fill(
          child: Image.asset(
            'assets/login_background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9), // Set opacity here
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              'Company A',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 170, 0, 0),
                              ),
                            ),
                            const Text(
                              'Employee Terminal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 123, 0, 0),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                labelText: 'Username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 30),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[700],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
