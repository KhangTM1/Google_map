//API key AIzaSyBN2H70aAsosDe8q8Gl1EmpQxBKDJGw_Cs
//Tọa độ ban đầu : 20.964294723446642, 105.82747679824756
//Tọa độ đích : 20.960812885804707, 105.74673021200734

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'authentication_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng? _destination;
  Set<Polyline> _polylines = {};

  PolylinePoints _polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  void _getDirections() async {
    if (_currentPosition != null && _destination != null) {
      String apiKey = 'AIzaSyBN2H70aAsosDe8q8Gl1EmpQxBKDJGw_Cs';
      String baseUrl = 'https://maps.googleapis.com/maps/api';

      // Get current address
      String currentAddress = await _getAddressFromLatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      // Get destination address
      String destinationAddress = await _getAddressFromLatLng(_destination!.latitude, _destination!.longitude);

      // Get directions
      String directionsUrl =
          '$baseUrl/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$apiKey';
      http.Response response = await http.get(Uri.parse(directionsUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String polylineString = data['routes'][0]['overview_polyline']['points'];
        List<PointLatLng> polylinePoints = _polylinePoints.decodePolyline(polylineString);

        List<LatLng> decodedPolyline =
        polylinePoints.map((point) => LatLng(point.latitude, point.longitude)).toList();

        setState(() {
          Polyline polyline = Polyline(
            polylineId: PolylineId('route'),
            points: decodedPolyline,
            color: Colors.blue,
            width: 3,
          );

          _polylines.add(polyline);
        });

        print('Current Address: $currentAddress');
        print('Destination Address: $destinationAddress');
      }
    }
  }

  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    String apiKey = 'AIzaSyBN2H70aAsosDe8q8Gl1EmpQxBKDJGw_Cs';
    String baseUrl = 'https://maps.googleapis.com/maps/api';

    String geocodingUrl = '$baseUrl/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
    http.Response response = await http.get(Uri.parse(geocodingUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['results'][0]['formatted_address'];
    }
    return '';
  }

  void _logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context)
      => AuthenticationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map Clone'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logOut,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 14,
            ),
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Current Location: ${_currentPosition != null ? "${_currentPosition!.latitude}, ${_currentPosition!.longitude}" : "Unknown"}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _destination = LatLng(37.43296265331129, -122.08832357078792);
                  _getDirections();
                });
              },
              child: Text('Get Directions'),
            ),
          ),
        ],
      ),
    );
  }
}