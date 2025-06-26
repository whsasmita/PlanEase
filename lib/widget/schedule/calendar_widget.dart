import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:plan_ease/model/schedule.dart'; // Assuming your model is here

class ScheduleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final List<Schedule> Function(DateTime day) eventLoader;

  const ScheduleCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<Schedule>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xFF1E8C7A),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFF0F6EC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),
        onDaySelected: onDaySelected,
        calendarFormat: CalendarFormat.month,
        eventLoader: eventLoader,
      ),
    );
  }
}