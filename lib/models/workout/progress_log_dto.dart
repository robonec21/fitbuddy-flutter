import 'exercise_progress_dto.dart';

class ProgressLogDto {
  final int? id;
  final DateTime date;
  final String? notes;
  final int workoutProgramId;
  final int workoutDayId;
  final List<ExerciseProgressDto> exerciseProgresses;

  ProgressLogDto({
    this.id,
    required this.date,
    this.notes,
    required this.workoutProgramId,
    required this.workoutDayId,
    required this.exerciseProgresses,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'notes': notes,
    'workoutProgramId': workoutProgramId,
    'workoutDayId': workoutDayId,
    'exerciseProgresses': exerciseProgresses.map((e) => e.toJson()).toList(),
  };

  factory ProgressLogDto.fromJson(Map<String, dynamic> json) {
    return ProgressLogDto(
      id: json['id'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      workoutProgramId: json['workoutProgramId'],
      workoutDayId: json['workoutDayId'],
      exerciseProgresses: (json['exerciseProgresses'] as List)
          .map((e) => ExerciseProgressDto.fromJson(e))
          .toList(),
    );
  }
}