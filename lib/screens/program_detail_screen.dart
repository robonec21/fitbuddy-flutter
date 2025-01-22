import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/workout/index.dart';
import '../services/workout_program_service.dart';
import 'dialogs/workout_day_dialogs.dart';
import 'dialogs/add_workout_day_dialog.dart'; 

class ProgramDetailScreen extends StatefulWidget {
  final int programId;

  const ProgramDetailScreen({
    required this.programId,
    super.key,
  });

  @override
  ProgramDetailScreenState createState() => ProgramDetailScreenState();
}

class ProgramDetailScreenState extends State<ProgramDetailScreen> {
  final _workoutProgramService = WorkoutProgramService();
  bool _isLoading = true;
  WorkoutProgramDto? _program;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    try {
      final program =
          await _workoutProgramService.getWorkoutProgram(widget.programId);
      if (mounted) {
        setState(() {
          _program = program;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load program: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addWorkoutDay() async {
    if (_program == null) return;

    final existingDays = _program!.workoutDays.map((d) => d.dayOfWeek).toList();

    final day = await showDialog<WorkoutDayDto>(
      context: context,
      builder: (context) => AddWorkoutDayDialog(
        existingDays: existingDays,
      ),
    );

    if (day != null && mounted) {
      try {
        final updatedProgram = await _workoutProgramService.addWorkoutDay(
          _program!.id!,
          day,
        );
        setState(() {
          _program = updatedProgram;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to add workout day: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _updateWorkoutDay(WorkoutDayDto updatedDay) async {
    if (_program == null) return;

    try {
      final updatedProgram = await _workoutProgramService.updateWorkoutDay(
        _program!.id!,
        updatedDay,
      );
      setState(() {
        _program = updatedProgram;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update workout day: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteWorkoutDay(WorkoutDayDto day) async {
    if (_program == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Workout Day'),
        content: Text('Are you sure you want to delete this workout day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final updatedProgram = await _workoutProgramService.deleteWorkoutDay(
          _program!.id!,
          day.id,
        );
        setState(() {
          _program = updatedProgram;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete workout day: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_program?.name ?? 'Workout Program'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/dashboard'),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _program == null
              ? Center(child: Text('Program not found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _program!.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _program!.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Workout Schedule',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: _addWorkoutDay,
                            tooltip: 'Add Workout Day',
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ..._program!.workoutDays.map(
                        (day) => _WorkoutDayCard(
                          day: day,
                          onEdit: (updatedDay) => _updateWorkoutDay(updatedDay),
                          onDelete: () => _deleteWorkoutDay(day),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  final WorkoutDayDto day;
  final Function(WorkoutDayDto) onEdit;
  final VoidCallback onDelete;

  const _WorkoutDayCard({
    required this.day,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(day.dayOfWeek)),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditWorkoutDayDialog(
                    workoutDay: day,
                    onDayUpdated: onEdit,
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: day.exercises.length,
            itemBuilder: (context, index) {
              final exercise = day.exercises[index];
              return ListTile(
                title: Text(exercise.exerciseName),
                subtitle: Text(
                  '${exercise.sets} sets × ${exercise.repsPerSet} reps${exercise.restPeriodBetweenSets != null ? ' | Rest: ${exercise.restPeriodBetweenSets}s' : ''}',
                ),
                leading: CircleAvatar(
                  child: Text((index + 1).toString()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
