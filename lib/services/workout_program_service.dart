import 'dart:convert';
import 'package:fitbuddy_flutter/models/workout/index.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';
import 'package:fitbuddy_flutter/service_locator.dart';

class WorkoutProgramService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService authService;

  WorkoutProgramService([AuthService? authService])
      : authService = authService ?? ServiceLocator.authService;

  Future<WorkoutProgramDto> getWorkoutProgram(int id) async {
    final token = await authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/workout-programs/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return WorkoutProgramDto.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 404) {
      throw Exception('Workout program not found');
    }

    throw Exception('Failed to load workout program: ${response.statusCode}');
  }

  Future<List<WorkoutProgramDto>> getWorkoutPrograms() async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/workout-programs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 403 || response.statusCode == 401) {
        throw Exception('Session expired');
      }

      if (response.statusCode == 200) {
        final List<dynamic> programsJson = jsonDecode(response.body);
        return programsJson
            .map((json) => WorkoutProgramDto.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load workout programs');
    } catch (e) {
      if (e.toString().contains('Session expired') ||
          e.toString().contains('Not authenticated')) {
        await authService.handleUnauthorizedResponse();
      }
      rethrow;
    }
  }

  Future<WorkoutProgramDto> createWorkoutProgram(
      Map<String, dynamic> programData) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/workout-programs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(programData),
      );

      if (response.statusCode == 403 || response.statusCode == 401) {
        throw Exception('Session expired');
      }

      if (response.statusCode == 200) {
        return WorkoutProgramDto.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create workout program');
    } catch (e) {
      if (e.toString().contains('Session expired') ||
          e.toString().contains('Not authenticated')) {
        await authService.handleUnauthorizedResponse();
      }
      rethrow;
    }
  }

  Future<WorkoutProgramDto> addWorkoutDay(
      int programId, WorkoutDayDto day) async {
    final token = await authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/workout-programs/$programId/days'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(day.toJson()),
    );

    if (response.statusCode == 200) {
      return WorkoutProgramDto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to add workout day');
  }

  Future<WorkoutProgramDto> updateWorkoutDay(
      int programId, WorkoutDayDto day) async {
    final token = await authService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/workout-programs/$programId/days/${day.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(day.toJson()),
    );

    if (response.statusCode == 200) {
      return WorkoutProgramDto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update workout day');
  }

  Future<WorkoutProgramDto> deleteWorkoutDay(int programId, int dayId) async {
    final token = await authService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/workout-programs/$programId/days/$dayId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return WorkoutProgramDto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to delete workout day');
  }
}
