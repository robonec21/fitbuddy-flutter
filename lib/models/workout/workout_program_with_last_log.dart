class WorkoutProgramWithLastLog {
  final int id;
  final String name;
  final String? description;
  final DateTime lastLogDate;

  WorkoutProgramWithLastLog({
    required this.id,
    required this.name,
    this.description,
    required this.lastLogDate,
  });

  factory WorkoutProgramWithLastLog.fromJson(Map<String, dynamic> json) {
    return WorkoutProgramWithLastLog(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      lastLogDate: DateTime.parse(json['lastLogDate']),
    );
  }
}