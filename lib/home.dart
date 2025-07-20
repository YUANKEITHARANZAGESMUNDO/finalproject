import 'appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'search.dart';
import 'schedule.dart';
import 'edit_profile.dart';
import 'login.dart';
import 'main.dart';
import 'weather_widget.dart';

class AnchorPointRoot extends StatefulWidget {
  final String userName;
  final String userEmail;

  const AnchorPointRoot({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<AnchorPointRoot> createState() => _AnchorPointRootState();
}

class _AnchorPointRootState extends State<AnchorPointRoot> {
  double _textScaleFactor = 1.0;

  void _increaseTextScale() {
    setState(() {
      _textScaleFactor = (_textScaleFactor + 0.1).clamp(0.8, 2.5);
    });
  }

  void _decreaseTextScale() {
    setState(() {
      _textScaleFactor = (_textScaleFactor - 0.1).clamp(0.8, 2.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnchorTextScale(
      textScaleFactor: _textScaleFactor,
      increase: _increaseTextScale,
      decrease: _decreaseTextScale,
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final scale = AnchorTextScale.of(context)?.textScaleFactor ?? 1.0;
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            );
          },
          home: MyHomePage(
            userName: widget.userName,
            userEmail: widget.userEmail,
          ),
        ),
      ),
    );
  }
}

// InheritedWidget to provide text scale and actions
class AnchorTextScale extends InheritedWidget {
  final double textScaleFactor;
  final VoidCallback increase;
  final VoidCallback decrease;

  const AnchorTextScale({
    super.key,
    required this.textScaleFactor,
    required this.increase,
    required this.decrease,
    required super.child,
  });

  static AnchorTextScale? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnchorTextScale>();
  }

  @override
  bool updateShouldNotify(AnchorTextScale oldWidget) =>
      textScaleFactor != oldWidget.textScaleFactor;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(userName: '', userEmail: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const MyHomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  List<DateTime> _savedDays = [];
  Map<DateTime, List<String>> _assignedWorkers = {};

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeInfoCard(selectedDays: _savedDays, assignedWorkers: _assignedWorkers),
      ScheduleScreen(), // <-- This will show the content of schedule.dart
      SearchScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 14, 18, 61),
        elevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Anchor',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              TextSpan(
                text: 'Point',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('images/ap.png', fit: BoxFit.cover),
          ),
          // Add a subtle overlay to improve text contrast, but not too strong
          Container(
            color: Colors.black.withOpacity(
              0.2,
            ), // Lower opacity for less washout
          ),
          pages[_currentIndex], // <-- This will switch to ScheduleScreen when index is 1
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Color.fromARGB(255, 255, 49, 49),
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Color.fromARGB(255, 255, 234, 254),
                      child: Text(
                        getInitials(widget.userName),
                        style: TextStyle(
                          fontSize: 30,
                          color: Color.fromARGB(255, 243, 33, 131),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.userName,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    widget.userEmail,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Info'),
                  contentPadding: const EdgeInsets.only(
                    left: 40.0,
                    right: 16.0,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('View Schedule'),
                  contentPadding: const EdgeInsets.only(
                    left: 40.0,
                    right: 16.0,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    // Open the schedule page and wait for the result
                    final result = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserScheduleCalendarPage(
                          initialSavedDays: _savedDays,
                          initialAssignments: _assignedWorkers,
                          onSubmit: (days, assignments) {
                            Navigator.pop(context, {
                              'days': days,
                              'assignments': assignments,
                            }); // Return both days and assignments to home
                          },
                        ),
                      ),
                    );
                    // If user submitted, update the saved days and assigned workers, reflect on home page
                    if (result != null) {
                      setState(() {
                        _savedDays = result['days'] as List<DateTime>;
                        _assignedWorkers =
                            result['assignments']
                                as Map<DateTime, List<String>>;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('View Personal Billing Information'),
                  contentPadding: const EdgeInsets.only(
                    left: 40.0,
                    right: 16.0,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TotalIncomePage(
                          userName: widget.userName,
                          userEmail: widget.userEmail,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.color_lens,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black54,
                  ),
                  title: const Text('Theme', style: TextStyle(fontSize: 16)),
                  trailing: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, mode, _) => Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: (val) {
                        themeNotifier.value = val
                            ? ThemeMode.dark
                            : ThemeMode.light;
                      },
                      activeColor: Colors.deepPurple,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: const Color(0xFFF7F3FA),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 24.0,
                    right: 16.0,
                  ),
                ),
              ],
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black54,
              ),
              title: const Text('About Us', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              },
              contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFFF7F3FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Proceed',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        fixedColor: Colors.pink,
        items: const [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(
            label: "Schedule",
            icon: Icon(Icons.calendar_view_day_outlined),
          ),
          BottomNavigationBarItem(label: "Search", icon: Icon(Icons.search)),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeInfoCard extends StatelessWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, List<String>> assignedWorkers;
  const HomeInfoCard({
    super.key,
    required this.selectedDays,
    required this.assignedWorkers,
  });

  @override
  Widget build(BuildContext context) {
    final appointments = AppointmentStore().appointments;
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight =
        120.0; // Approximate height of the banner (adjust as needed)

    // --- Banner/Header ---
    final header = Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.anchor, color: Colors.white, size: 70),
          ),
          const SizedBox(height: 18),
          Text(
            "L.E.O Marines",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "L.E.O Marines – Anchoring Trust, Navigating Excellence Since 2011.",
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: screenHeight / 2.5 - bannerHeight / 2,
          ), // Reduced gap to center banner with less space above
          header, // Banner at the center
          SizedBox(
            height: 240,
          ), // Reduced space to bring first container closer to banner
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Appointment Card(s) ---
                if (appointments.isNotEmpty)
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, themeMode, _) {
                      final isDarkMode = themeMode == ThemeMode.dark;
                      return Container(
                        width: 370,
                        height: 220,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                          color: isDarkMode ? Colors.grey[850] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 12,
                            ),
                            child: PageView.builder(
                              itemCount: appointments.length,
                              itemBuilder: (context, index) {
                                final appt = appointments[index];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _iconText(
                                          Icons.directions_boat,
                                          'Vessel',
                                          appt['name'] ?? '',
                                          isDarkMode,
                                        ),
                                        _iconText(
                                          Icons.calendar_today_outlined,
                                          'Date',
                                          appt['date'] != null
                                              ? '${appt['date'].year}-${appt['date'].month.toString().padLeft(2, '0')}-${appt['date'].day.toString().padLeft(2, '0')}'
                                              : '',
                                          isDarkMode,
                                        ),
                                        _iconText(
                                          Icons.access_time,
                                          'Time',
                                          appt['time'] != null
                                              ? appt['time'].format(context)
                                              : '',
                                          isDarkMode,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _iconText(
                                          Icons.pan_tool_sharp,
                                          'Service',
                                          appt['service'] ?? '',
                                          isDarkMode,
                                        ),
                                        _iconText(
                                          Icons.flag,
                                          'Flag',
                                          appt['vessel'] ?? '',
                                          isDarkMode,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (appointments.isEmpty)
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, themeMode, _) {
                      final isDarkMode = themeMode == ThemeMode.dark;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                        child: Container(
                          width: 370,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _iconText(Icons.directions_boat, 'Vessel', '', isDarkMode),
                                  _iconText(
                                    Icons.calendar_today_outlined,
                                    'Date',
                                    '',
                                    isDarkMode,
                                  ),
                                  _iconText(Icons.access_time, 'Time', '', isDarkMode),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _iconText(Icons.pan_tool_sharp, 'Service', '', isDarkMode),
                                  _iconText(Icons.flag, 'Flag', '', isDarkMode),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                // --- Weather Widget ---
                const WeatherWidget(),
                const SizedBox(height: 16),
                // --- Available Workers container removed ---
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String label, String value, bool isDarkMode) {
    return Column(
      children: [
        Icon(
          icon, 
          color: isDarkMode ? Colors.white70 : Colors.black54, 
          size: 28
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13, 
            color: isDarkMode ? Colors.white70 : Colors.black54
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class UserScheduleCalendarPage extends StatefulWidget {
  final List<DateTime> initialSavedDays;
  final Map<DateTime, List<String>> initialAssignments;
  final void Function(List<DateTime>, Map<DateTime, List<String>>) onSubmit;
  const UserScheduleCalendarPage({
    super.key,
    required this.initialSavedDays,
    required this.initialAssignments,
    required this.onSubmit,
  });

  @override
  State<UserScheduleCalendarPage> createState() =>
      _UserScheduleCalendarPageState();
}

class _UserScheduleCalendarPageState extends State<UserScheduleCalendarPage> {
  late Set<DateTime> _selectedDays;
  late Map<DateTime, List<String>> _assignedWorkers;
  DateTime? _activeDay; // The day being assigned workers

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialSavedDays.toSet();
    _assignedWorkers = Map<DateTime, List<String>>.from(
      widget.initialAssignments,
    );
    if (_selectedDays.isNotEmpty) {
      _activeDay = _selectedDays.last;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointments = AppointmentStore().appointments;

    // Get all appointment dates for highlighting
    final appointmentDates = appointments
        .where((appt) => appt['date'] != null)
        .map<DateTime>(
          (appt) =>
              DateTime(appt['date'].year, appt['date'].month, appt['date'].day),
        )
        .toSet();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFF7F3FA),
      appBar: AppBar(
        title: Text(
          'Your Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.1,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 18, 61),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.5,
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: DateTime.now(),
                    selectedDayPredicate: (day) {
                      return _selectedDays.any(
                        (d) =>
                            d.year == day.year &&
                            d.month == day.month &&
                            d.day == day.day,
                      );
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        final alreadySelected = _selectedDays.any(
                          (d) =>
                              d.year == selectedDay.year &&
                              d.month == selectedDay.month &&
                              d.day == selectedDay.day,
                        );
                        if (alreadySelected) {
                          _selectedDays.removeWhere(
                            (d) =>
                                d.year == selectedDay.year &&
                                d.month == selectedDay.month &&
                                d.day == selectedDay.day,
                          );
                          _assignedWorkers.remove(selectedDay);
                          if (_activeDay == selectedDay) {
                            _activeDay = _selectedDays.isNotEmpty
                                ? _selectedDays.last
                                : null;
                          }
                        } else {
                          _selectedDays.add(selectedDay);
                          _activeDay = selectedDay;
                        }
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final isAppointment = appointmentDates.any(
                          (d) =>
                              d.year == day.year &&
                              d.month == day.month &&
                              d.day == day.day,
                        );
                        if (isAppointment) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                      titleCentered: true,
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.deepPurple,
                        size: 28,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.deepPurple,
                        size: 28,
                      ),
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white12
                                : Color(0xFFE0DEE2),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      weekendTextStyle: TextStyle(color: Colors.pinkAccent),
                      defaultTextStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                      cellMargin: const EdgeInsets.all(4),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Days you will work:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: 120,
                      minHeight: 60,
                    ),
                    child: _selectedDays.isEmpty
                        ? Center(
                            child: Text(
                              "No days selected.",
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  (_selectedDays.toList()
                                        ..sort((a, b) => a.compareTo(b)))
                                      .map(
                                        (date) => ChoiceChip(
                                          label: Text(
                                            "${_monthName(date.month)} ${date.day}, ${date.year}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          selected: _activeDay == date,
                                          onSelected: (selected) {
                                            setState(() {
                                              _activeDay = date;
                                            });
                                          },
                                          selectedColor:
                                              Colors.deepPurple.shade100,
                                          backgroundColor:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.white,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSubmit(_selectedDays.toList(), _assignedWorkers);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selected days and workers submitted!',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getWorkersList(BuildContext context) async {
    return [];
  }
}

String _monthName(int month) {
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  return months[month - 1];
}

class TotalIncomePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const TotalIncomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final userInitials = getInitials(userName);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Billing Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 18, 61),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.5,
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFF7F3FA),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : const Color.fromARGB(255, 255, 234, 254),
                      child: Text(
                        userInitials,
                        style: TextStyle(
                          fontSize: 32,
                          color: Color.fromARGB(255, 243, 33, 131),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 0,
                      ),
                      child: Center(
                        child: Text(
                          "Billing of this day (${_formattedToday()})",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(18),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Table(
                      border: TableBorder.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black54,
                        width: 1,
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      children: [
                        _emptyRow("LOCAL", context),
                        _emptyRow("FOREIGN", context),
                        _emptyRow("TOTAL", context),
                        _emptyRow("PAG-IBIG LOAN", context),
                        _emptyRow("CASH ADVANCE", context),
                        _emptyRow("BALANCE", context),
                        _emptyRow("SSS/PI/PH", context),
                        _emptyRow("TOTAL DEDUCTIONS", context),
                        _emptyRow("TOTAL", context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _emptyRow(String left, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              left,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "",
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _row(
    String left,
    String right, {
    bool bold = false,
    Color color = Colors.black87,
  }) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              left,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formattedToday() {
    final now = DateTime.now();
    final month = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ][now.month - 1];
    return "$month ${now.day}, ${now.year}";
  }
}

String getInitials(String name) {
  return name.isNotEmpty
      ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
      : '';
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF7F3FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 18, 61),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('images/ap.png', fit: BoxFit.cover),
          ),
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.7)
                : Colors.white.withOpacity(0.7),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.anchor, color: Colors.red, size: 64),
                        SizedBox(width: 12),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Anchor',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'Point',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Text(
                      'LEO Marines was established in 2011 in Santa Rita Aplaya, Batangas City, Philippines, by maritime professional Leonides "Leo" Camus. Since the start, a small line-handling crew serving Batangas Bay has become a reliable mooring partner for coastal, inter-island, and international operators using Luzon ports. Based on community values and seafaring discipline, we developed our reputation one vessel at a time by arriving prepared, operating safely, and finishing on time.',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
    );
  }
}
