import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/workout_program_service.dart';
import '../services/progress_log_service.dart';
import '../models/workout/index.dart';

class ProgramLogsScreen extends StatefulWidget {
  final int programId;

  const ProgramLogsScreen({
    required this.programId,
    super.key,
  });

  @override
  ProgramLogsScreenState createState() => ProgramLogsScreenState();
}

class ProgramLogsScreenState extends State<ProgramLogsScreen> {
  final _workoutProgramService = WorkoutProgramService();
  final _progressLogService = ProgressLogService();
  bool _isLoading = true;
  WorkoutProgramDto? _program;
  List<ProgressLogSummaryDto> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadProgramAndLogs();
  }

  Future<void> _loadProgramAndLogs() async {
    try {
      setState(() => _isLoading = true);
      
      final program = await _workoutProgramService.getWorkoutProgram(widget.programId);
      final logs = await _progressLogService.getProgramLogs(widget.programId);
      
      if (mounted) {
        setState(() {
          _program = program;
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToCreateLog() {
    context.push('/progress/programs/${widget.programId}/logs/create')
      .then((_) => _loadProgramAndLogs()); // Refresh after returning
  }

  void _navigateToEditLog(int logId) {
    context.push('/progress/programs/${widget.programId}/logs/$logId/edit')
      .then((_) => _loadProgramAndLogs()); // Refresh after returning
  }

  String _getCompletionStats(ProgressLogSummaryDto log) {
    return '${log.completedExercises}/${log.totalExercises} exercises completed'
        '${log.skippedExercises > 0 ? ', ${log.skippedExercises} skipped' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_program?.name ?? 'Program Progress'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/progress'),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgramAndLogs,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToCreateLog,
                      icon: Icon(Icons.add),
                      label: Text('Add Progress Log'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _logs.isEmpty
                        ? Center(
                            child: Text(
                              'No progress logs yet',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  title: Text(log.date.toString().split(' ')[0]),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(log.workoutDayName),
                                      Text(
                                        _getCompletionStats(log),
                                        style: TextStyle(
                                          color: log.skippedExercises > 0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .error
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  trailing: Icon(Icons.edit),
                                  onTap: () => _navigateToEditLog(log.id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateLog,
        child: Icon(Icons.add),
      ),
    );
  }
}