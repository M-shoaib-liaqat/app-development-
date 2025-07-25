import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_scaffold.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final int _selectedIndex = 1;
  String _filter = 'pending';

  void _onNavTap(int idx) {
    if (idx == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    if (idx == 2) Navigator.pushReplacementNamed(context, '/calendar');
    if (idx == 3) Navigator.pushReplacementNamed(context, '/notifications');
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: _selectedIndex,
      onNavTap: _onNavTap,
      bodyBuilder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('event_requests')
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final pendingCount = docs.where((d) => (d['status'] ?? 'pending') == 'pending').length;
            final approvedCount = docs.where((d) => d['status'] == 'approved').length;
            final rejectedCount = docs.where((d) => d['status'] == 'rejected').length;

            final filtered = docs
                .where((doc) => (doc['status'] ?? 'pending') == _filter)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RequestStatCard(
                      label: 'Pending',
                      count: pendingCount,
                      icon: Icons.hourglass_empty,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _RequestStatCard(
                      label: 'Approved',
                      count: approvedCount,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _RequestStatCard(
                      label: 'Rejected',
                      count: rejectedCount,
                      icon: Icons.cancel,
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  children: ['pending', 'approved', 'rejected'].map((c) {
                    final sel = c == _filter;
                    return ChoiceChip(
                      label: Text(c[0].toUpperCase() + c.substring(1)),
                      selected: sel,
                      onSelected: (_) => setState(() => _filter = c),
                      selectedColor: const Color(0xFF60A5FA),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No ${_filter[0].toUpperCase() + _filter.substring(1)} requests',
                            style: GoogleFonts.poppins(),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final req = filtered[i].data() as Map<String, dynamic>;
                            final eventName = req['eventName'] ?? req['eventId'] ?? 'Event';
                            final status = req['status'] ?? 'pending';
                            final type = req['type'] ?? 'N/A';
                            final createdBy = req['createdBy'] ?? 'N/A';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(eventName.toString()[0].toUpperCase()),
                                ),
                                title: Text(
                                  eventName.toString(),
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Type: $type\nStatus: $status\nCreated By: $createdBy',
                                  style: GoogleFonts.poppins(),
                                ),
                                trailing: null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestStatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _RequestStatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text('$count',
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.poppins(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
