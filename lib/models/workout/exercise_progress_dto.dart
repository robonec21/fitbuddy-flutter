class ExerciseProgressDto {
  final int? id;
  final int? workoutDayExerciseId;
  final int? replacementExerciseId;
  final String exerciseName;
  final int orderIndex;
  final int actualSets;
  final List<int> repsPerSet;
  final List<double> weightPerSet;
  final int? restPeriodBetweenSets;
  final bool completed;
  final bool skipped;
  final String? notes;

  ExerciseProgressDto({
    this.id,
    this.workoutDayExerciseId,
    this.replacementExerciseId,
    required this.exerciseName,
    required this.orderIndex,
    required this.actualSets,
    required this.repsPerSet,
    required this.weightPerSet,
    this.restPeriodBetweenSets,
    this.completed = false,
    this.skipped = false,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutDayExerciseId': workoutDayExerciseId,
    'replacementExerciseId': replacementExerciseId,
    'exerciseName': exerciseName,
    'orderIndex': orderIndex,
    'actualSets': actualSets,
    'repsPerSet': repsPerSet,
    'weightPerSet': weightPerSet,
    'restPeriodBetweenSets': restPeriodBetweenSets,
    'completed': completed,
    'skipped': skipped,
    'notes': notes,
  };

  factory ExerciseProgressDto.fromJson(Map<String, dynamic> json) {
    return ExerciseProgressDto(
      id: json['id'],
      workoutDayExerciseId: json['workoutDayExerciseId'],
      replacementExerciseId: json['replacementExerciseId'],
      exerciseName: json['exerciseName'],
      orderIndex: json['orderIndex'],
      actualSets: json['actualSets'],
      repsPerSet: (json['repsPerSet'] as List).map((e) => e as int).toList(),
      weightPerSet: (json['weightPerSet'] as List).map((e) => e as double).toList(),
      restPeriodBetweenSets: json['restPeriodBetweenSets'],
      completed: json['completed'],
      skipped: json['skipped'],
      notes: json['notes'],
    );
  }
}