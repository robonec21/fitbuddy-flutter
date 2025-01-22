import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/progress_log_service.dart';
import '../services/workout_program_service.dart';
import '../models/workout/index.dart';
import 'dialogs/exercise_progress_dialog.dart';

class ProgressLogEditScreen extends StatefulWidget {
  final int programId;
  final int? logId;  // null for creation, non-null for editing

  const ProgressLogEditScreen({
    required this.programId,
    this.logId,
    super.key,
  });

  @override
  ProgressLogEditScreenState createState() => ProgressLogEditScreenState();
}

class ProgressLogEditScreenState extends State<ProgressLogEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _progressLogService = ProgressLogService();
  final _workoutProgramService = WorkoutProgramService();

  bool _isLoading = true;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();
  WorkoutProgramDto? _program;
  WorkoutDayDto? _selectedWorkoutDay;
  List<ExerciseProgressDto> _exerciseProgresses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final program = await _workoutProgramService.getWorkoutProgram(widget.programId);

      if (widget.logId != null) {
        final log = await _progressLogService.getProgressLog(widget.logId!);
        _selectedDate = log.date;
        _notesController.text = log.notes ?? '';
        _selectedWorkoutDay = program.workoutDays
            .firstWhere((day) => day.id == log.workoutDayId);
        _exerciseProgresses = List.from(log.exerciseProgresses);
      }

      if (mounted) {
        setState(() {
          _program = program;
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkoutDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a workout day')),
      );
      return;
    }
    if (_exerciseProgresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one exercise progress')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dto = ProgressLogDto(
        id: widget.logId,
        date: _selectedDate,
        notes: _notesController.text,
        workoutProgramId: widget.programId,
        workoutDayId: _selectedWorkoutDay!.id,
        exerciseProgresses: _exerciseProgresses,
      );

      if (widget.logId != null) {
        await _progressLogService.updateProgressLog(dto);
        if (mounted) {
            context.pop(); // Return to previous screen
          }
      } else {
        await _progressLogService.createProgressLog(dto);
        if (mounted) {
            // Pop twice to go back to progress dashboard
            context.pop();
            context.pop();
        }
      }

      // if (mounted) {
      //   context.pop(); // Return to previous screen
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save progress: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addExerciseProgress() async {
    final exerciseProgress = await showDialog<ExerciseProgressDto>(
      context: context,
      builder: (context) => ExerciseProgressDialog(
        workoutDay: _selectedWorkoutDay!,
        existingProgresses: _exerciseProgresses,
      ),
    );

    if (exerciseProgress != null && mounted) {
      setState(() {
        _exerciseProgresses.add(exerciseProgress);
      });
    }
  }

  void _editExerciseProgress(int index) async {
    final updatedProgress = await showDialog<ExerciseProgressDto>(
      context: context,
      builder: (context) => ExerciseProgressDialog(
        workoutDay: _selectedWorkoutDay!,
        existingProgresses: _exerciseProgresses,
        initialProgress: _exerciseProgresses[index],
      ),
    );

    if (updatedProgress != null && mounted) {
      setState(() {
        _exerciseProgresses[index] = updatedProgress;
      });
    }
  }

  void _removeExerciseProgress(int index) {
    setState(() {
      _exerciseProgresses.removeAt(index);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.logId != null ? 'Edit Progress' : 'New Progress'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _isSaving ? null : _save,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('Date'),
                      subtitle: Text(_selectedDate.toString().split(' ')[0]),
                      trailing: Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<WorkoutDayDto>(
                      value: _selectedWorkoutDay,
                      decoration: InputDecoration(
                        labelText: 'Workout Day',
                        border: OutlineInputBorder(),
                      ),
                      items: _program!.workoutDays.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day.dayOfWeek),
                        );
                      }).toList(),
                      onChanged: (day) {
                        setState(() {
                          if (_selectedWorkoutDay?.id != day?.id) {
                            _selectedWorkoutDay = day;
                            _exerciseProgresses.clear();
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercise Progress',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (_selectedWorkoutDay != null)
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: _addExerciseProgress,
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_exerciseProgresses.isEmpty)
                      Center(
                        child: Text(
                          'No exercises added yet',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _exerciseProgresses.length,
                        itemBuilder: (context, index) {
                          final progress = _exerciseProgresses[index];
                          return Card(
                            child: ListTile(
                              title: Text(progress.exerciseName),
                              subtitle: Text(
                                '${progress.actualSets} sets × ${progress.repsPerSet.join(", ")} reps'
                                '${progress.weightPerSet.isNotEmpty ? '\nWeight: ${progress.weightPerSet.join(", ")} kg' : ''}'
                                '${progress.skipped ? '\nSkipped' : progress.completed ? '\nCompleted' : '\nIn Progress'}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _editExerciseProgress(index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _removeExerciseProgress(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}