import 'workout_day_dto.dart';

class WorkoutProgramDto {
    final int? id;
    final String name;
    final String? description;
    final List<WorkoutDayDto> workoutDays;

    WorkoutProgramDto({
        this.id,
        required this.name,
        this.description,
        required this.workoutDays,
    });

    factory WorkoutProgramDto.fromJson(Map<String, dynamic> json) {
        return WorkoutProgramDto(
            id: json['id'],
            name: json['name'],
            description: json['description'],
            workoutDays: (json['workoutDays'] as List)
                .map((e) => WorkoutDayDto.fromJson(e))
                .toList(),
        );
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'workoutDays': workoutDays.map((e) => e.toJson()).toList(),
    };
}