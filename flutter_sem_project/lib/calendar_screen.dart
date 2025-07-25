import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_scaffold.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _loadingEvents = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').where('approved', isEqualTo: true).get();
    final events = <DateTime, List<Map<String, dynamic>>>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = data['date'] as String?;
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          final day = DateTime(date.year, date.month, date.day);
          events.putIfAbsent(day, () => []).add(data);
        }
      }
    }
    setState(() {
      _events = events;
      _loadingEvents = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: 2,
      onNavTap: (index) {
        if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
        if (index == 1) Navigator.pushReplacementNamed(context, '/requests');
        if (index == 3) Navigator.pushReplacementNamed(context, '/notifications');
      },
      bodyBuilder: (context) {
        if (_loadingEvents) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD1D5DB).withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                  onDaySelected: (sd, fd) =>
                      setState(() {_selectedDay = sd; _focusedDay = fd;}),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                        color: Color(0xFF1E3A8A), shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(
                        color: const Color(0xFF60A5FA).withOpacity(0.3),
                        shape: BoxShape.circle),
                    defaultTextStyle:
                    GoogleFonts.poppins(color: const Color(0xFF1E3A8A)),
                    markerDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    final d = DateTime(day.year, day.month, day.day);
                    return _events[d] ?? [];
                  },
                ),
              ),
              const SizedBox(height: 30),
              if (_selectedDay != null)
                Text(
                  'Events on ${_selectedDay!.toLocal().toString().split(" ")[0]}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              const SizedBox(height: 10),
              if (_selectedDay != null)
                Builder(
                  builder: (ctx) {
                    final day = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                    final events = _events[day] ?? [];
                    if (events.isEmpty) {
                      return Text('No events scheduled.', style: GoogleFonts.poppins());
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (ctx, i) {
                        final event = events[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD1D5DB).withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event, color: Color(0xFF60A5FA)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event['event_name'] ?? 'Event',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500, fontSize: 16)),
                                  Text(event['description'] ?? '',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
