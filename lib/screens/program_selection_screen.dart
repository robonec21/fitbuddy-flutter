import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/progress_log_service.dart';
import '../models/workout/workout_program_dto.dart';

class ProgramSelectionScreen extends StatefulWidget {
  const ProgramSelectionScreen({super.key});

  @override
  ProgramSelectionScreenState createState() => ProgramSelectionScreenState();
}

class ProgramSelectionScreenState extends State<ProgramSelectionScreen> {
  final _progressLogService = ProgressLogService();
  bool _isLoading = true;
  List<WorkoutProgramDto> _availablePrograms = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final programs = await _progressLogService.getWorkoutProgramsWithoutLogs();
      if (mounted) {
        setState(() {
          _availablePrograms = programs;
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

  void _selectProgram(WorkoutProgramDto program) {
    context.push('/progress/programs/${program.id}/logs/create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Program'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _availablePrograms.isEmpty
              ? Center(
                  child: Text(
                    'No available programs to track',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              : ListView.builder(
                  itemCount: _availablePrograms.length,
                  itemBuilder: (context, index) {
                    final program = _availablePrograms[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(program.name),
                        subtitle: program.description != null
                            ? Text(program.description!)
                            : null,
                        trailing: Icon(Icons.add),
                        onTap: () => _selectProgram(program),
                      ),
                    );
                  },
                ),
    );
  }
}