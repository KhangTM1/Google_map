import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectDestination extends StatefulWidget {
  final Function(LatLng destination) onDestinationSelected;

  SelectDestination({required this.onDestinationSelected});

  @override
  _SelectDestinationState createState() => _SelectDestinationState();
}

class _SelectDestinationState extends State<SelectDestination> {
  LatLng? _selectedDestination;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Destination'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(20.964294723446642, 105.82747679824756),
              zoom: 14,
            ),
            onTap: (LatLng location) {
              setState(() {
                _selectedDestination = location;
                _markers.clear();
                _markers.add(
                  Marker(
                    markerId: MarkerId('selected_destination'),
                    position: location,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
                );
              });
            },
            markers: _markers,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedDestination != null) {
                  widget.onDestinationSelected(_selectedDestination!);
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('No destination selected'),
                        content: Text('Please tap on the map to select a destination.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Confirm Destination'),
            ),
          ),
        ],
      ),
    );
  }
}
