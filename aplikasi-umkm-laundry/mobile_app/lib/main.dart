import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'UMKM Laundry',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: token != null ? HomeScreen() : LoginScreen(),
  ));
}
