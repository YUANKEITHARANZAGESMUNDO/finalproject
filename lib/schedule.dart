import 'appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();

  final AppointmentStore _store = AppointmentStore();

  int _currentAppointmentIndex = 0;

  // Helper for month name
  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Show add client dialog
  void _showAddClientDialog() {
    final nameController = TextEditingController();
    DateTime selectedDate = _focusedDay;
    TimeOfDay selectedTime = TimeOfDay.now();
    String? selectedService;
    String? selectedVessel;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : const Color(0xFFF7F3FA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Client',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: nameController,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[900]
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date Picker (improved design)
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? ColorScheme.dark(
                                      primary: Colors.deepPurple,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.white,
                                      surface: Colors.grey[900]!,
                                    )
                                  : ColorScheme.light(
                                      primary: Colors.deepPurple,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black87,
                                      surface: Colors.white,
                                    ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.deepPurple,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              dialogTheme: DialogThemeData(
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[900]
                                    : const Color(0xFFF7F3FA),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[900]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.deepPurple,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Time Picker (improved design)
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) => Theme(
                            data:
                                Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: Colors.deepPurple,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.white,
                                      surface: Colors.grey[900]!,
                                    ),
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: Colors.grey[900],
                                    ),
                                  )
                                : Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.deepPurple,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black87,
                                      surface: Colors.white,
                                    ),
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: const Color(0xFFF7F3FA),
                                    ),
                                  ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() => selectedTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[900]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.deepPurple,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Time: ${selectedTime.format(context)}',
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedService,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      dropdownColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[900]
                          : Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Type of Service',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[900]
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Mooring',
                          child: Text('Mooring'),
                        ),
                        DropdownMenuItem(
                          value: 'Unmooring',
                          child: Text('Unmooring'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => selectedService = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedVessel,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      dropdownColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[900]
                          : Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Vessel',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[900]
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      hint: Text(
                        'Vessel',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Local', child: Text('Local')),
                        DropdownMenuItem(
                          value: 'Foreign',
                          child: Text('Foreign'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => selectedVessel = value);
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isNotEmpty &&
                              selectedService != null &&
                              selectedVessel != null) {
                            // Save to Firestore
                            await FirebaseFirestore.instance.collection('appointments').add({
                              'name': nameController.text,
                              'date': Timestamp.fromDate(selectedDate),
                              'time': selectedTime.format(context), // or store as string
                              'service': selectedService,
                              'vessel': selectedVessel,
                              // Optionally add userId if you have authentication
                              // 'userId': FirebaseAuth.instance.currentUser?.uid,
                            });

                            setState(() {
                              _store.appointments.add({
                                'name': nameController.text,
                                'date': selectedDate,
                                'time': selectedTime,
                                'service': selectedService,
                                'vessel': selectedVessel,
                              });
                              _store.vesselHighlights[DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                              )] = selectedVessel == 'Local'
                                  ? Colors.green
                                  : Colors.blue;
                              _currentAppointmentIndex =
                                  _store.appointments.length - 1;
                            });
                            AppointmentStore().latestAppointment =
                                AppointmentModel(
                                  vessel: selectedVessel!,
                                  date: selectedDate,
                                  time: selectedTime,
                                  service: selectedService!,
                                  flag: selectedVessel!,
                                );
                            Navigator.pop(context);
                            this.setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade100,
                          foregroundColor: Colors.deepPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _fetchAppointments() async {
    final snapshot = await FirebaseFirestore.instance.collection('appointments').get();
    setState(() {
      _store.appointments = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'],
          'date': (data['date'] as Timestamp).toDate(),
          'time': TimeOfDay(
            hour: int.parse(data['time'].split(":")[0]),
            minute: int.parse(data['time'].split(":")[1]),
          ),
          'service': data['service'],
          'vessel': data['vessel'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF7F3FA);
    final appBarTextColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    final user = FirebaseAuth.instance.currentUser;
    final isCarla = user?.email == 'carla@gmail.com';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset('images/ap.png', fit: BoxFit.cover),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 12.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Next client',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: SizedBox(
                    // Remove fixed height and use IntrinsicHeight to fit content
                    child: _store.appointments.isEmpty
                        ? Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFFE0DEE2),
                                  ),
                                ),
                                elevation: 0,
                                color: cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.directions_boat,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white.withOpacity(
                                                        0.3,
                                                      )
                                                    : Colors.black54
                                                          .withOpacity(0.3),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Vessel',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                            .withOpacity(0.3)
                                                      : Colors.black54
                                                            .withOpacity(0.3),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                size: 22,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white.withOpacity(
                                                        0.3,
                                                      )
                                                    : Colors.black54
                                                          .withOpacity(0.3),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Date',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                            .withOpacity(0.3)
                                                      : Colors.black54
                                                            .withOpacity(0.3),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white.withOpacity(
                                                        0.3,
                                                      )
                                                    : Colors.black54
                                                          .withOpacity(0.3),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Time',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                            .withOpacity(0.3)
                                                      : Colors.black54
                                                            .withOpacity(0.3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.pan_tool_sharp,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white.withOpacity(
                                                        0.3,
                                                      )
                                                    : Colors.black54
                                                          .withOpacity(0.3),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Service',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                            .withOpacity(0.3)
                                                      : Colors.black54
                                                            .withOpacity(0.3),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white.withOpacity(
                                                        0.3,
                                                      )
                                                    : Colors.black54
                                                          .withOpacity(0.3),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Flag',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                            .withOpacity(0.3)
                                                      : Colors.black54
                                                            .withOpacity(0.3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Empty state overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return GestureDetector(
                                onTap: () {
                                  final appt = _store
                                      .appointments[_currentAppointmentIndex];
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black
                                          : const Color(0xFFF7F3FA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 22,
                                          ),
                                      title: Text(
                                        'Appointment Details',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: textColor,
                                          letterSpacing: 1.1,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.directions_boat,
                                                color: iconColor,
                                                size: 22,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Name: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  appt['name'] ?? '',
                                                  style: TextStyle(
                                                    color: textColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                color: iconColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Date: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                              Text(
                                                appt['date'] != null
                                                    ? '${appt['date'].year}-${appt['date'].month.toString().padLeft(2, '0')}-${appt['date'].day.toString().padLeft(2, '0')}'
                                                    : '',
                                                style: TextStyle(
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: iconColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Time: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                              Text(
                                                appt['time'] != null
                                                    ? appt['time'].format(
                                                        context,
                                                      )
                                                    : '',
                                                style: TextStyle(
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.pan_tool_sharp,
                                                color: iconColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Service: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                              Text(
                                                appt['service'] ?? '',
                                                style: TextStyle(
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color: iconColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Vessel: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                              Text(
                                                appt['vessel'] ?? '',
                                                style: TextStyle(
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                      color: Color(0xFFE0DEE2),
                                    ),
                                  ),
                                  elevation: 0,
                                  color: cardColor.withOpacity(0.85),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 10,
                                    ),
                                    child: SizedBox(
                                      height:
                                          200, // increased height to prevent overflow
                                      child: PageView.builder(
                                        controller: PageController(
                                          initialPage: _currentAppointmentIndex,
                                        ),
                                        itemCount: _store.appointments.length,
                                        onPageChanged: (index) {
                                          setState(() {
                                            _currentAppointmentIndex = index;
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          final appt =
                                              _store.appointments[index];
                                          return GestureDetector(
                                            onTap: () {
                                              final appt =
                                                  _store.appointments[index];
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.black
                                                      : const Color(0xFFF7F3FA),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 22,
                                                      ),
                                                  title: Text(
                                                    'Appointment Details',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22,
                                                      color: textColor,
                                                      letterSpacing: 1.1,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .directions_boat,
                                                            color: iconColor,
                                                            size: 22,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Name: ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              appt['name'] ??
                                                                  '',
                                                              style: TextStyle(
                                                                color:
                                                                    textColor,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: iconColor,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Date: ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                          Text(
                                                            appt['date'] != null
                                                                ? '${appt['date'].year}-${appt['date'].month.toString().padLeft(2, '0')}-${appt['date'].day.toString().padLeft(2, '0')}'
                                                                : '',
                                                            style: TextStyle(
                                                              color: textColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.access_time,
                                                            color: iconColor,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Time: ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                          Text(
                                                            appt['time'] != null
                                                                ? appt['time']
                                                                      .format(
                                                                        context,
                                                                      )
                                                                : '',
                                                            style: TextStyle(
                                                              color: textColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .pan_tool_sharp,
                                                            color: iconColor,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Service: ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                          Text(
                                                            appt['service'] ??
                                                                '',
                                                            style: TextStyle(
                                                              color: textColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.flag,
                                                            color: iconColor,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Vessel: ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                          Text(
                                                            appt['vessel'] ??
                                                                '',
                                                            style: TextStyle(
                                                              color: textColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        'Close',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.deepPurple,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                side: const BorderSide(
                                                  color: Color(0xFFE0DEE2),
                                                ),
                                              ),
                                              elevation: 0,
                                              color: cardColor.withOpacity(
                                                0.85,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 10,
                                                    ),
                                                child: SizedBox(
                                                  height:
                                                      200, // increased height to prevent overflow
                                                  child: PageView.builder(
                                                    controller: PageController(
                                                      initialPage:
                                                          _currentAppointmentIndex,
                                                    ),
                                                    itemCount: _store
                                                        .appointments
                                                        .length,
                                                    onPageChanged: (index) {
                                                      setState(() {
                                                        _currentAppointmentIndex =
                                                            index;
                                                      });
                                                    },
                                                    itemBuilder: (context, index) {
                                                      final appt = _store
                                                          .appointments[index];
                                                      return Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              // Vessel
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .directions_boat,
                                                                    color:
                                                                        Theme.of(
                                                                              context,
                                                                            ).brightness ==
                                                                            Brightness.dark
                                                                        ? Colors
                                                                              .white
                                                                        : Colors
                                                                              .black54,
                                                                    size: 28,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Vessel',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Theme.of(
                                                                                context,
                                                                              ).brightness ==
                                                                              Brightness.dark
                                                                          ? Colors.white
                                                                          : Colors.black54,
                                                                    ),
                                                                  ),
                                                                  if (appt['name'] !=
                                                                      null)
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                            top:
                                                                                2,
                                                                          ),
                                                                      child: Text(
                                                                        appt['name'],
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                              // Date
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .calendar_today_outlined,
                                                                    color:
                                                                        Theme.of(
                                                                              context,
                                                                            ).brightness ==
                                                                            Brightness.dark
                                                                        ? Colors
                                                                              .white
                                                                        : Colors
                                                                              .black54,
                                                                    size: 28,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Date',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Theme.of(
                                                                                context,
                                                                              ).brightness ==
                                                                              Brightness.dark
                                                                          ? Colors.white
                                                                          : Colors.black54,
                                                                    ),
                                                                  ),
                                                                  if (appt['date'] !=
                                                                      null)
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                            top:
                                                                                2,
                                                                          ),
                                                                      child: Text(
                                                                        '${appt['date'].year}-${appt['date'].month.toString().padLeft(2, '0')}-${appt['date'].day.toString().padLeft(2, '0')}',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                              // Time
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .access_time,
                                                                    color:
                                                                        Theme.of(
                                                                              context,
                                                                            ).brightness ==
                                                                            Brightness.dark
                                                                        ? Colors
                                                                              .white
                                                                        : Colors
                                                                              .black54,
                                                                    size: 28,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Time',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Theme.of(
                                                                                context,
                                                                              ).brightness ==
                                                                              Brightness.dark
                                                                          ? Colors.white
                                                                          : Colors.black54,
                                                                    ),
                                                                  ),
                                                                  if (appt['time'] !=
                                                                      null)
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                            top:
                                                                                2,
                                                                          ),
                                                                      child: Text(
                                                                        appt['time'].format(
                                                                          context,
                                                                        ),
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 12),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              // Service
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .pan_tool_sharp,
                                                                    color:
                                                                        Theme.of(
                                                                              context,
                                                                            ).brightness ==
                                                                            Brightness.dark
                                                                        ? Colors
                                                                              .white
                                                                        : Colors
                                                                              .black54,
                                                                    size: 28,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Service',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Theme.of(
                                                                                context,
                                                                              ).brightness ==
                                                                              Brightness.dark
                                                                          ? Colors.white
                                                                          : Colors.black54,
                                                                    ),
                                                                  ),
                                                                  if (appt['service'] !=
                                                                      null)
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                            top:
                                                                                2,
                                                                          ),
                                                                      child: Text(
                                                                        appt['service'],
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                              // Flag
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons.flag,
                                                                    color:
                                                                        Theme.of(
                                                                              context,
                                                                            ).brightness ==
                                                                            Brightness.dark
                                                                        ? Colors
                                                                              .white
                                                                        : Colors
                                                                              .black54,
                                                                    size: 28,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Flag',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Theme.of(
                                                                                context,
                                                                              ).brightness ==
                                                                              Brightness.dark
                                                                          ? Colors.white
                                                                          : Colors.black54,
                                                                    ),
                                                                  ),
                                                                  if (appt['vessel'] !=
                                                                      null)
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                            top:
                                                                                2,
                                                                          ),
                                                                      child: Text(
                                                                        appt['vessel'],
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Calendar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE0DEE2)),
                    ),
                    elevation: 0,
                    color: cardColor.withOpacity(0.85),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // Month and Year with left/right arrows
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: iconColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime(
                                      _focusedDay.year,
                                      _focusedDay.month - 1,
                                      1,
                                    );
                                  });
                                },
                              ),
                              Text(
                                '${_monthName(_focusedDay.month)} ${_focusedDay.year}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: iconColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime(
                                      _focusedDay.year,
                                      _focusedDay.month + 1,
                                      1,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => false,
                            calendarFormat: CalendarFormat.month,
                            headerVisible: false,
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: subTextColor,
                              ),
                              weekendStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: subTextColor,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                final dateKey = DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                );
                                // Gather all appointments for this day
                                final appointmentsForDay = _store.appointments
                                    .where((appt) {
                                      final apptDate = appt['date'];
                                      return apptDate.year == day.year &&
                                          apptDate.month == day.month &&
                                          apptDate.day == day.day;
                                    })
                                    .toList();

                                Color? highlightColor;
                                if (appointmentsForDay.length > 1) {
                                  // More than one appointment: show light gray
                                  highlightColor = Colors.grey.shade300;
                                } else if (appointmentsForDay.length == 1) {
                                  // One appointment: use vessel color
                                  final vessel =
                                      appointmentsForDay.first['vessel'];
                                  highlightColor = vessel == 'Local'
                                      ? Colors.green
                                      : Colors.blue;
                                }

                                if (highlightColor != null) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: highlightColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          color:
                                              highlightColor ==
                                                  Colors.grey.shade300
                                              ? textColor
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                              todayBuilder: (context, day, focusedDay) {
                                final dateKey = DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                );
                                final appointmentsForDay = _store.appointments
                                    .where((appt) {
                                      final apptDate = appt['date'];
                                      return apptDate.year == day.year &&
                                          apptDate.month == day.month &&
                                          apptDate.day == day.day;
                                    })
                                    .toList();

                                Color? highlightColor;
                                if (appointmentsForDay.length > 1) {
                                  highlightColor = Colors.grey.shade300;
                                } else if (appointmentsForDay.length == 1) {
                                  final vessel =
                                      appointmentsForDay.first['vessel'];
                                  highlightColor = vessel == 'Local'
                                      ? Colors.green
                                      : Colors.blue;
                                }

                                if (highlightColor != null) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: highlightColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          color:
                                              highlightColor ==
                                                  Colors.grey.shade300
                                              ? textColor
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                // Default today style
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              rangeHighlightColor: Colors.transparent,
                              weekendTextStyle: TextStyle(color: subTextColor),
                              defaultTextStyle: TextStyle(color: textColor),
                              outsideTextStyle: TextStyle(color: subTextColor),
                              disabledTextStyle: TextStyle(color: subTextColor),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            onPageChanged: (focusedDay) {
                              setState(() {
                                _focusedDay = focusedDay;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 14,
                        color: Color.fromARGB(255, 47, 46, 47),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Current date',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Next client icon with dynamic color
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _store.appointments.isEmpty
                              ? Colors.white
                              : (
                                // Use the vessel color of the first appointment, even if there are multiple
                                _store.appointments[0]['vessel'] == 'Local'
                                    ? Colors.green
                                    : Colors.blue),
                          border: Border.all(color: Colors.black26, width: 1),
                        ),
                        child: _store.appointments.isEmpty
                            ? const Icon(
                                Icons.circle_outlined,
                                size: 14,
                                color: Colors.black26,
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Next client',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: isCarla
          ? Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: FloatingActionButton(
                onPressed: _showAddClientDialog,
                backgroundColor: Colors.red,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
