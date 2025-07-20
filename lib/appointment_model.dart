import 'package:flutter/material.dart';

class AppointmentModel {
  String vessel;
  DateTime date;
  TimeOfDay time;
  String service;
  String flag;

  AppointmentModel({
    required this.vessel,
    required this.date,
    required this.time,
    required this.service,
    required this.flag,
  });
}

class AppointmentStore {
  static final AppointmentStore _instance = AppointmentStore._internal();
  factory AppointmentStore() => _instance;
  AppointmentStore._internal();

  AppointmentModel? latestAppointment;

  // Add these:
  List<Map<String, dynamic>> appointments = [];
  Map<DateTime, Color> vesselHighlights = {};
}
