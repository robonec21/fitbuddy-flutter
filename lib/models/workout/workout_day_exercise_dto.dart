class WorkoutDayExerciseDto {
    final int? id;
    final int exerciseId;
    final String exerciseName;
    final int orderIndex;
    final int sets;
    final int repsPerSet;
    final int? restPeriodBetweenSets;
    final String? notes;

    WorkoutDayExerciseDto({
        this.id,
        required this.exerciseId,
        required this.exerciseName,
        required this.orderIndex,
        required this.sets,
        required this.repsPerSet,
        this.restPeriodBetweenSets,
        this.notes,
    });

    factory WorkoutDayExerciseDto.fromJson(Map<String, dynamic> json) {
        return WorkoutDayExerciseDto(
            id: json['id'],
            exerciseId: json['exerciseId'],
            exerciseName: json['exerciseName'],
            orderIndex: json['orderIndex'],
            sets: json['sets'],
            repsPerSet: json['repsPerSet'],
            restPeriodBetweenSets: json['restPeriodBetweenSets'],
            notes: json['notes'],
        );
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'orderIndex': orderIndex,
        'sets': sets,
        'repsPerSet': repsPerSet,
        'restPeriodBetweenSets': restPeriodBetweenSets,
        'notes': notes,
    };
}