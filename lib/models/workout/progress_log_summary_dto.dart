class ProgressLogSummaryDto {
    final int id;
    final DateTime date;
    final String workoutDayName;
    final int totalExercises;
    final int completedExercises;
    final int skippedExercises;

    ProgressLogSummaryDto({
        required this.id,
        required this.date,
        required this.workoutDayName,
        required this.totalExercises,
        required this.completedExercises,
        required this.skippedExercises,
    });

    factory ProgressLogSummaryDto.fromJson(Map<String, dynamic> json) {
        return ProgressLogSummaryDto(
            id: json['id'],
            date: DateTime.parse(json['date']),
            workoutDayName: json['workoutDayName'],
            totalExercises: json['totalExercises'],
            completedExercises: json['completedExercises'],
            skippedExercises: json['skippedExercises'],
        );
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'workoutDayName': workoutDayName,
        'totalExercises': totalExercises,
        'completedExercises': completedExercises,
        'skippedExercises': skippedExercises,
    };
}