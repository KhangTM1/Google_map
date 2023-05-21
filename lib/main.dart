import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import'package:flutter_uber_location/screen/authentication_screen.dart';
import 'package:flutter_uber_location/screen/map_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
      // home: AuthenticationScreen(),
    );
  }
}
