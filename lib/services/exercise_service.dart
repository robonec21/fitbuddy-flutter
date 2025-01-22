import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';
import 'package:fitbuddy_flutter/service_locator.dart';

class ExerciseService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService authService;

  ExerciseService([AuthService? authService]) 
      : authService = authService ?? ServiceLocator.authService;

  Future<List<Exercise>> getExercises() async {
    final token = await authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/exercises'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> exercisesJson = jsonDecode(response.body);
      return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
    }
    throw Exception('Failed to load exercises');
  }

  Future<Exercise> createExercise({
    required String name,
    required String description,
    required int defaultSets,
    required int defaultRepsPerSet,
    required int defaultRestPeriodBetweenSets,
    }) async {
      final token = await authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/exercises'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'defaultSets': defaultSets,
          'defaultRepsPerSet': defaultRepsPerSet,
          'defaultRestPeriodBetweenSets': defaultRestPeriodBetweenSets,
        }),
      );

      if (response.statusCode == 200) {
        return Exercise.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create exercise');
    }

  Future<List<Exercise>> searchExercises(String? query) async {
    final token = await authService.getToken();
    
    Uri uri = Uri.parse('$baseUrl/exercises');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: {'name': query});
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> exercisesJson = jsonDecode(response.body);
      return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
    }
    throw Exception('Failed to load exercises: ${response.statusCode}');
  }

  Future<ExerciseUsage> getExerciseUsage(int id) async {
    final token = await authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/$id/usage'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ExerciseUsage.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to get exercise usage: ${response.statusCode}');
  }

  Future<void> deleteExercises(List<int> ids) async {
    final token = await authService.getToken();
    final queryParams = ids.map((id) => 'ids=$id').join('&');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/exercises?$queryParams'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete exercises: ${response.statusCode}');
    }
  }

  Future<Exercise> updateExercise(Exercise exercise) async {
    final token = await authService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/exercises/${exercise.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': exercise.name,
        'description': exercise.description,
        'defaultSets': exercise.defaultSets,
        'defaultRepsPerSet': exercise.defaultRepsPerSet,
        'defaultRestPeriodBetweenSets': exercise.defaultRestPeriodBetweenSets,
      }),
    );

    if (response.statusCode == 200) {
      return Exercise.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update exercise: ${response.statusCode}');
  }  
}

class Exercise {
  final int id;
  final String name;
  final String? description;
  final int defaultSets;
  final int defaultRepsPerSet;
  final int? defaultRestPeriodBetweenSets;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.defaultSets,
    required this.defaultRepsPerSet,
    this.defaultRestPeriodBetweenSets,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      defaultSets: json['defaultSets'],
      defaultRepsPerSet: json['defaultRepsPerSet'],
      defaultRestPeriodBetweenSets: json['defaultRestPeriodBetweenSets'],
    );
  }
}

class ExerciseUsage {
  final int exerciseId;
  final String exerciseName;
  final List<ProgramUsage> programs;

  ExerciseUsage({
    required this.exerciseId,
    required this.exerciseName,
    required this.programs,
  });

  factory ExerciseUsage.fromJson(Map<String, dynamic> json) {
    return ExerciseUsage(
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      programs: (json['programs'] as List)
          .map((program) => ProgramUsage.fromJson(program))
          .toList(),
    );
  }
}

class ProgramUsage {
  final int programId;
  final String programName;
  final List<DayUsage> days;

  ProgramUsage({
    required this.programId,
    required this.programName,
    required this.days,
  });

  factory ProgramUsage.fromJson(Map<String, dynamic> json) {
    return ProgramUsage(
      programId: json['programId'],
      programName: json['programName'],
      days: (json['days'] as List)
          .map((day) => DayUsage.fromJson(day))
          .toList(),
    );
  }
}

class DayUsage {
  final int dayId;
  final String dayOfWeek;

  DayUsage({
    required this.dayId,
    required this.dayOfWeek,
  });

  factory DayUsage.fromJson(Map<String, dynamic> json) {
    return DayUsage(
      dayId: json['dayId'],
      dayOfWeek: json['dayOfWeek'],
    );
  }
}