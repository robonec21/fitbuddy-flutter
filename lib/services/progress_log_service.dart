import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/workout/progress_log_summary_dto.dart';
import 'auth_service.dart';
import '../models/workout/progress_log_dto.dart';
import '../models/workout/workout_program_with_last_log.dart';
import '../models/workout/workout_program_dto.dart';
import 'package:fitbuddy_flutter/service_locator.dart';

class ProgressLogService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService authService;

  ProgressLogService([AuthService? authService]) 
      : authService = authService ?? ServiceLocator.authService;

  Future<List<WorkoutProgramWithLastLog>> getWorkoutProgramsWithLogs() async {
    final token = await authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/workout-programs/with-logs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> programsJson = jsonDecode(response.body);
      return programsJson
          .map((json) => WorkoutProgramWithLastLog.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load programs with logs');
  }

  Future<List<WorkoutProgramDto>> getWorkoutProgramsWithoutLogs() async {
        final token = await authService.getToken();
        final response = await http.get(
            Uri.parse('$baseUrl/workout-programs/without-logs'),
            headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
            },
        );

        if (response.statusCode == 200) {
            final List<dynamic> programsJson = jsonDecode(response.body);
            return programsJson
                .map((json) => WorkoutProgramDto.fromJson(json))
                .toList();
        }
        throw Exception('Failed to load available programs');
    }

    // Add a new method specifically for getting summaries
    Future<List<ProgressLogSummaryDto>> getProgramLogs(int programId) async {
        final token = await authService.getToken();
        final response = await http.get(
            Uri.parse('$baseUrl/progress-logs/program/$programId/summaries'), // Note the /summaries endpoint
            headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
            },
        );

        if (response.statusCode == 200) {
            final List<dynamic> logsJson = jsonDecode(response.body);
            return logsJson
                .map((json) => ProgressLogSummaryDto.fromJson(json))
                .toList();
        }
        throw Exception('Failed to load progress logs');
    }

  Future<List<ProgressLogDto>> getProgramLogDetails(int programId) async {
    final token = await authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/progress-logs/program/$programId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> logsJson = jsonDecode(response.body);
      return logsJson
          .map((json) => ProgressLogDto.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load progress logs');
  }

  Future<ProgressLogDto> createProgressLog(ProgressLogDto log) async {
    final token = await authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/progress-logs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(log.toJson()),
    );

    if (response.statusCode == 200) {
      return ProgressLogDto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create progress log');
  }

  Future<ProgressLogDto> updateProgressLog(ProgressLogDto log) async {
    final token = await authService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/progress-logs/${log.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(log.toJson()),
    );

    if (response.statusCode == 200) {
      return ProgressLogDto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update progress log');
  }

  Future<ProgressLogDto> getProgressLog(int logId) async {
    final token = await authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/progress-logs/$logId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ProgressLogDto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load progress log');
  }

  Future<void> deleteProgressLog(int logId) async {
    final token = await authService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/progress-logs/$logId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete progress log');
    }
  }
}