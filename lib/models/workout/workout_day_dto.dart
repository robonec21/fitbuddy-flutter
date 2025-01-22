import 'workout_day_exercise_dto.dart';

class WorkoutDayDto {
    final int id;
    final String dayOfWeek;
    final List<WorkoutDayExerciseDto> exercises;

    WorkoutDayDto({
        required this.id,
        required this.dayOfWeek,
        required this.exercises,
    });

    factory WorkoutDayDto.fromJson(Map<String, dynamic> json) {
        return WorkoutDayDto(
            id: json['id'],
            dayOfWeek: json['dayOfWeek'],
            exercises: (json['exercises'] as List)
                .map((e) => WorkoutDayExerciseDto.fromJson(e))
                .toList(),
        );
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'dayOfWeek': dayOfWeek,
        'exercises': exercises.map((e) => e.toJson()).toList(),
    };
}