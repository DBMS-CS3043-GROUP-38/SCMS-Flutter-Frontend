import 'dart:convert';
import 'package:deliveryapp/pages/driver.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
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
      Uri.parse('http://localhost:3000/login'),
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
          title: Text('Server Error'),
          content: Text(data['message']),
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
                    )),
          );
        } else if (data['type'] == 'Assistant') {
        } else {}
      } else {
        print("nope");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text(data['message']),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: login,
                      child: Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
