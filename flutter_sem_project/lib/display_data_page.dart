import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplayDataPage extends StatefulWidget {
  final String documentId;

  const DisplayDataPage({super.key, required this.documentId});

  @override
  State<DisplayDataPage> createState() => _DisplayDataPageState();
}

class _DisplayDataPageState extends State<DisplayDataPage> {
  Map<String, dynamic> formData = {};
  List<String> selectedFacilities = [];
  List<String> availableFacilities = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchAvailableFacilities();
  }

  Future<void> fetchAvailableFacilities() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('facilities').get();
    setState(() {
      availableFacilities = snapshot.docs
          .map((doc) => doc['facility'] as String)
          .toList();
    });
  }

  Future<void> fetchData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.documentId)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      setState(() {
        formData = data;
        selectedFacilities = List<String>.from(data['facilities'] ?? []);
      });
    }
  }

  Future<void> saveFacilities() async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.documentId)
        .update({
      'facilities': selectedFacilities,
    });

    // Send email to each provider of the selected facilities
    try {
      final facilitiesSnapshot = await FirebaseFirestore.instance
          .collection('facilities')
          .where('facility', whereIn: selectedFacilities)
          .get();
      for (var doc in facilitiesSnapshot.docs) {
        final data = doc.data();
        final providerEmail = data['email'];
        final facilityName = data['facility'];
        final providerName = data['provider'];
        await http.post(
          Uri.parse('https://shoaib1010.pythonanywhere.com/send-facility-email/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'to': providerEmail,
            'facility': facilityName,
            'provider': providerName,
            'event_id': widget.documentId,
          }),
        );
      }
    } catch (e) {
      // Optionally show error or log
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Facilities updated and providers notified')),
    );
    fetchData(); // Refresh UI
  }

  void showFacilitiesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final tempSelected = [...selectedFacilities];
        return AlertDialog(
          title: const Text('Select Facilities'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: availableFacilities.map((facility) {
                    return CheckboxListTile(
                      title: Text(facility),
                      value: tempSelected.contains(facility),
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          value!
                              ? tempSelected.add(facility)
                              : tempSelected.remove(facility);
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedFacilities = tempSelected;
                });
                saveFacilities();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = formData.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (hasData)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Add/Edit Facilities',
              onPressed: showFacilitiesDialog,
            ),
        ],
      ),
      body: hasData
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Field')),
                  DataColumn(label: Text('Value')),
                ],
                rows: formData.entries.map((entry) {
                  final value = entry.value;
                  String displayValue;

                  if (value is Timestamp) {
                    displayValue = value.toDate().toString();
                  } else if (value is List) {
                    displayValue = value.join(', ');
                  } else {
                    displayValue = value.toString();
                  }

                  return DataRow(cells: [
                    DataCell(Text(entry.key)),
                    DataCell(Text(displayValue)),
                  ]);
                }).toList(),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: hasData
          ? FloatingActionButton.extended(
              onPressed: showFacilitiesDialog,
              icon: const Icon(Icons.add_business),
              label: const Text("Add Facilities"),
            )
          : null,
    );
  }
}
