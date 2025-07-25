import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerPage extends StatefulWidget {
  final LatLng initialLocation;
  const LocationPickerPage({super.key, required this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late LatLng _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Event Location')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _pickedLocation, zoom: 16),
        markers: {
          Marker(
            markerId: const MarkerId('picked'),
            position: _pickedLocation,
            draggable: true,
            onDragEnd: (pos) => setState(() => _pickedLocation = pos),
          ),
        },
        onTap: (pos) => setState(() => _pickedLocation = pos),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _pickedLocation),
        label: const Text('Select Location'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
