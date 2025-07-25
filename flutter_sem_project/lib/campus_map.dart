import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  static const LatLng _defaultCenter = LatLng(31.4511737468889, 73.6934394082883);

  @override
  void initState() {
    super.initState();
    _loadEventMarkers();
  }

  Future<void> _loadEventMarkers() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    final markers = <Marker>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['location'] != null) {
        final loc = data['location'].split(',');
        if (loc.length == 2) {
          final lat = double.tryParse(loc[0].trim());
          final lng = double.tryParse(loc[1].trim());
          if (lat != null && lng != null) {
            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: data['event_name'] ?? 'Event',
                  snippet: data['date'] != null ? 'Time: ${data['date']}' : '',
                ),
              ),
            );
          }
        }
      }
    }
    setState(() => _markers.addAll(markers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultCenter,
          zoom: 16,
        ),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
}
