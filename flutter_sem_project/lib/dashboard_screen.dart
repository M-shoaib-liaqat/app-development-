import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_scaffold.dart';
import 'display_data_page.dart';
import 'auth_service.dart';
import 'user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
    State<DashboardScreen> createState() => _DashboardScreenState();
  }

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void _handleNavTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/requests');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/calendar');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/notifications');
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: _currentIndex,
      onNavTap: _handleNavTap,
      bodyBuilder: (_) => const DashboardContent(),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final PageController _pc = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
        AuthService.getCurrentUserRole().then((role) {
            setState(() {
                _userRole = role;
            });
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }
    String? dashboardRoute;
    String? dashboardLabel;
    if (_userRole == UserRole.admin) {
      dashboardRoute = '/admin_dashboard';
      dashboardLabel = 'Admin Dashboard';
    } else if (_userRole == UserRole.organizer) {
      dashboardRoute = '/organizer_dashboard';
      dashboardLabel = 'Organizer Dashboard';
    } else if (_userRole == UserRole.faculty) {
      dashboardRoute = '/faculty_dashboard';
      dashboardLabel = 'Faculty Dashboard';
    } else if (_userRole == UserRole.student) {
      dashboardRoute = '/student_dashboard';
      dashboardLabel = 'Student Dashboard';
    }
    return DashboardContentBody(
      dashboardRoute: dashboardRoute,
      dashboardLabel: dashboardLabel,
      pc: _pc,
      currentPage: _currentPage,
      onPageChanged: (pg) => setState(() => _currentPage = pg),
      userRole: _userRole,
    );
  }
}

class DashboardContentBody extends StatelessWidget {
  final String? dashboardRoute;
  final String? dashboardLabel;
  final PageController pc;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final UserRole? userRole;

  const DashboardContentBody({
    super.key,
    required this.dashboardRoute,
    required this.dashboardLabel,
    required this.pc,
    required this.currentPage,
    required this.onPageChanged,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dashboardRoute != null && dashboardLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.dashboard),
                label: Text(dashboardLabel!),
                onPressed: () => Navigator.pushNamed(context, dashboardRoute!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          SizedBox(
            height: 90,
            child: FutureBuilder<List<int>>(
              future: fetchApprovedRejectedCounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.connectionState == ConnectionState.none) {
                  debugPrint('No connection to Firestore');
                  return const Center(child: Text('No connection'));
                }
                if (snapshot.hasError) {
                  debugPrint('Stats error: \\${snapshot.error}');
                  return const Center(child: Text('Failed to load stats', style: TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  debugPrint('Stats: No data');
                  return const Center(child: Text('No stats available'));
                }
                final counts = snapshot.data!;
                debugPrint('Approved: \\${counts[0]}, Rejected: \\${counts[1]}');
                return AnimatedStatsRow(
                  stats: [
                    _StatInfo(label: 'Approved Events', count: counts[0], icon: Icons.check_circle),
                    _StatInfo(label: 'Rejected Events', count: counts[1], icon: Icons.cancel),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.list_alt, size: 16),
                label: const Text('See All Events'),
                onPressed: () => Navigator.pushNamed(context, '/all_events'),
              ),
            ],
          ),
          const SizedBox(height: 8),
SizedBox(
  height: 220,
  child: _EventSlider(
    pc: pc,
    currentPage: currentPage,
    onPageChanged: onPageChanged,
  ),
),
const SizedBox(height: 8),
Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (i) {
      final isActive = i == currentPage;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 12 : 8,
        height: isActive ? 12 : 8,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A8A) : Colors.grey[300],
          shape: BoxShape.circle,
        ),
      );
    }),
  ),
),
          const SizedBox(height: 24),
          Text('Quick Actions', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          FutureBuilder(
            future: AuthService.getCurrentUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              final userRole = snapshot.data;
              List<Widget> actions = [];
              // Only admin, faculty, student can see 'New Event' (not organizer)
              if (userRole == UserRole.admin || userRole == UserRole.faculty || userRole == UserRole.student) {
                actions.add(QuickAction(icon: Icons.add, label: 'New Event', onTap: () => Navigator.pushNamed(context, '/event_form')));
              }
              // All roles see 'Settings'
              actions.add(QuickAction(icon: Icons.settings, label: 'Settings', onTap: () => Navigator.pushNamed(context, '/settings')));
              // Only admin (not faculty, organizer, or student) sees 'Facilities Mgmt'
              if (userRole == UserRole.admin) {
                actions.add(QuickAction(icon: Icons.business, label: 'Facilities Mgmt', onTap: () => Navigator.pushNamed(context, '/facility_management')));
              }
              return SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: actions,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


// ==== Stat Row & Card ====

class _StatInfo {
  final String label;
  final int count;
  final IconData icon;
  const _StatInfo({required this.label, required this.count, required this.icon});
}

class AnimatedStatsRow extends StatelessWidget {
  final List<_StatInfo> stats;
  const AnimatedStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((info) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _StatCard(info: info),
        ),
      )).toList(),
    );
  }
}

class _StatCard extends StatefulWidget {
  final _StatInfo info;
  const _StatCard({required this.info});

  @override
  State<_StatCard> createState() => __StatCardState();
}

class __StatCardState extends State<_StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctr;
  late Animation<int> _anim;

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _anim = IntTween(begin: 0, end: widget.info.count).animate(
      CurvedAnimation(parent: _ctr, curve: Curves.easeOut),
    )..addListener(() => setState(() {}));
    _ctr.forward();
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.info.icon, color: const Color(0xFF60A5FA), size: 28),
          const SizedBox(height: 4),
          Text(widget.info.label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800])),
          const SizedBox(height: 4),
          Text('${_anim.value}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Slider widget to prevent full page reload
class _EventSlider extends StatefulWidget {
  final PageController pc;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  const _EventSlider({required this.pc, required this.currentPage, required this.onPageChanged});

  @override
  State<_EventSlider> createState() => _EventSliderState();
}

class _EventSliderState extends State<_EventSlider> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .orderBy('created_at', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data!.docs;
        if (events.isEmpty) {
          return const Center(child: Text('No upcoming events.'));
        }
        return PageView.builder(
          controller: widget.pc,
          itemCount: events.length,
          onPageChanged: widget.onPageChanged,
          itemBuilder: (ctx, i) {
            final evt = events[i].data()! as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _HeroCard(
                title: evt['event_name'] ?? 'Unnamed',
                date: evt['date'] ?? '',
                time: evt['time'] ?? '',
                onSeeDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DisplayDataPage(documentId: events[i].id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ==== Hero Card ====

class _HeroCard extends StatelessWidget {
  final String title, date, time;
  final VoidCallback onSeeDetails;

  const _HeroCard({
    required this.title,
    required this.date,
    required this.time,
    required this.onSeeDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/event_image.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(color: Colors.black26),
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date, style: GoogleFonts.poppins(color: Colors.white70)),
                      Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(time, style: GoogleFonts.poppins(color: Colors.white70)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                    ),
                  ),
                  onPressed: onSeeDetails,
                  child: const Text('See Details'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==== Quick Action ====

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickAction({super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFDBEAFE),
              child: Icon(icon, color: const Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


// Fetch event and alert counts from Firestore
Future<List<int>> fetchApprovedRejectedCounts() async {
  try {
    debugPrint('Fetching approved/rejected event counts...');
    final approvedSnap = await FirebaseFirestore.instance
        .collection('events')
        .where('approved', isEqualTo: true)
        .get();
    final rejectedSnap = await FirebaseFirestore.instance
        .collection('events')
        .where('approved', isEqualTo: false)
        .get();
    debugPrint('Approved: \\${approvedSnap.size}, Rejected: \\${rejectedSnap.size}');
    return [approvedSnap.size, rejectedSnap.size];
  } catch (e, st) {
    debugPrint('Error fetching event counts: \\${e.toString()}');
    debugPrint(st.toString());
    rethrow;
  }
}
