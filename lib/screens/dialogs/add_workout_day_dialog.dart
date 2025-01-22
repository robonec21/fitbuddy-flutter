import 'package:flutter/material.dart';
import '../../models/workout/index.dart';

class AddWorkoutDayDialog extends StatefulWidget {
  final List<String> existingDays;

  const AddWorkoutDayDialog({super.key, 
    required this.existingDays,
  });

  @override
  AddWorkoutDayDialogState createState() => AddWorkoutDayDialogState();
}

class AddWorkoutDayDialogState extends State<AddWorkoutDayDialog> {
  String? _selectedDay;
  final List<String> _daysOfWeek = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
  ];

  @override
  Widget build(BuildContext context) {
    final availableDays =
        _daysOfWeek.where((day) => !widget.existingDays.contains(day)).toList();

    return AlertDialog(
      title: Text('Add Workout Day'),
      content: availableDays.isEmpty
          ? Text('All days have been added')
          : DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(
                labelText: 'Select Day',
                border: OutlineInputBorder(),
              ),
              items: availableDays.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value;
                });
              },
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: availableDays.isEmpty || _selectedDay == null
              ? null
              : () {
                  final newDay = WorkoutDayDto(
                    id: 0,
                    dayOfWeek: _selectedDay!,
                    exercises: [],
                  );
                  Navigator.pop(
                      context, newDay); // Return the WorkoutDay directly
                },
          child: Text('Add'),
        ),
      ],
    );
  }
}