import 'package:deliveryapp/pages/login.dart';
import 'package:flutter/material.dart';
import './pages/ipconfig.dart';  // Add this import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assistant Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitialScreen(),  // Changed this line
    );
  }
}

// Add this new class
class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    // Show IP configuration dialog when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showIpConfigDialog(context);
      // After IP is configured, navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}