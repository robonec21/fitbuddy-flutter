import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/workout/index.dart';
import '../services/progress_log_service.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ProgressDashboardScreenState createState() => ProgressDashboardScreenState();
}

class ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  final _progressLogService = ProgressLogService();
  bool _isLoading = true;
  List<WorkoutProgramWithLastLog> _programs = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    setState(() => _isLoading = true); // Set loading true at start
    try {
      final programs = await _progressLogService.getWorkoutProgramsWithLogs();
      if (mounted) {
        setState(() {
          _programs = programs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load programs: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToNewLogProgramSelection() {
    context.push('/progress/programs/select').then((_) => _loadPrograms());
  }

  void _navigateToProgramLogs(int programId) {
    context.push('/progress/programs/$programId/logs').then((_) => _loadPrograms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Tracking'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPrograms,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToNewLogProgramSelection,
                      icon: Icon(Icons.add),
                      label: Text('Start Tracking New Program'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _programs.isEmpty
                        ? Center(
                            child: Text(
                              'No programs with progress logs yet',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _programs.length,
                            itemBuilder: (context, index) {
                              final program = _programs[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  title: Text(program.name),
                                  subtitle: Text(
                                    'Last progress: ${program.lastLogDate.toString().split(' ')[0]}',
                                  ),
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () => _navigateToProgramLogs(program.id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}