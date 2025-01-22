import 'package:flutter/material.dart';
import '../../services/exercise_service.dart';
import '../../models/workout/exercise_progress_dto.dart';
import '../../models/workout/workout_day_dto.dart';
import '../../models/workout/workout_day_exercise_dto.dart';

class ExerciseProgressDialog extends StatefulWidget {
  final WorkoutDayDto workoutDay;
  final List<ExerciseProgressDto> existingProgresses;
  final ExerciseProgressDto? initialProgress;

  const ExerciseProgressDialog({
    required this.workoutDay,
    required this.existingProgresses,
    this.initialProgress,
    super.key,
  });

  @override
  ExerciseProgressDialogState createState() => ExerciseProgressDialogState();
}

class ExerciseProgressDialogState extends State<ExerciseProgressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseService = ExerciseService();

  late WorkoutDayExerciseDto _selectedExercise;
  Exercise? _replacementExercise;
  int _sets = 1;
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _weightControllers = [];
  bool _isSkipped = false;
  bool _isCompleted = false;
  final _notesController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeExercise();
    _loadAvailableExercises();
  }

  void _initializeExercise() {
    if (widget.initialProgress != null) {
      _initializeFromExistingProgress();
    } else if (widget.workoutDay.exercises.isNotEmpty) {
      // Initialize with first available non-tracked exercise
      _selectedExercise = _findNextAvailableExercise();
      _initializeNewExerciseProgress(_selectedExercise);
    }
  }

  WorkoutDayExerciseDto _findNextAvailableExercise() {
    return widget.workoutDay.exercises.firstWhere(
        (exercise) => !widget.existingProgresses
            .any((progress) => progress.workoutDayExerciseId == exercise.id),
        orElse: () => widget.workoutDay.exercises.first);
  }

  void _initializeNewExerciseProgress(WorkoutDayExerciseDto exercise) {
    _sets = exercise.sets;
    _initializeControllers(exercise.sets, exercise.repsPerSet);
  }

  void _initializeControllers(int sets, int defaultReps) {
    // Clear existing controllers
    _disposeControllers();

    // Create new controllers
    for (int i = 0; i < sets; i++) {
      _repsControllers.add(TextEditingController(text: defaultReps.toString()));
      _weightControllers.add(TextEditingController());
    }
  }

  void _initializeFromExistingProgress() {
    final progress = widget.initialProgress!;
    _selectedExercise = widget.workoutDay.exercises.firstWhere(
      (e) => e.id == progress.workoutDayExerciseId,
    );
    _sets = progress.actualSets;

    // Clear existing controllers
    _disposeControllers();

    // Initialize with existing progress data
    _repsControllers = progress.repsPerSet
        .map((reps) => TextEditingController(text: reps.toString()))
        .toList();
    _weightControllers = progress.weightPerSet
        .map((weight) => TextEditingController(text: weight.toString()))
        .toList();
    _isSkipped = progress.skipped;
    _isCompleted = progress.completed;
    _notesController.text = progress.notes ?? '';
  }

  void _disposeControllers() {
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    _repsControllers.clear();
    _weightControllers.clear();
  }

  Future<void> _loadAvailableExercises() async {
    try {
      await _exerciseService.getExercises();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exercises: ${e.toString()}')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _updateSetsCount(int newSets) {
    if (newSets == _sets) return;

    setState(() {
      if (newSets > _sets) {
        // Add new controllers
        for (int i = _sets; i < newSets; i++) {
          _repsControllers.add(TextEditingController(
              text: _selectedExercise.repsPerSet.toString()));
          _weightControllers.add(TextEditingController());
        }
      } else {
        // Remove excess controllers
        while (_repsControllers.length > newSets) {
          _repsControllers.last.dispose();
          _weightControllers.last.dispose();
          _repsControllers.removeLast();
          _weightControllers.removeLast();
        }
      }
      _sets = newSets;
    });
  }

  ExerciseProgressDto _createProgressDto() {
    return ExerciseProgressDto(
      workoutDayExerciseId: _selectedExercise.id,
      replacementExerciseId: _replacementExercise?.id,
      exerciseName:
          _replacementExercise?.name ?? _selectedExercise.exerciseName,
      orderIndex: widget.existingProgresses.length,
      actualSets: _sets,
      // Map each controller to its value, ensuring proper indexing
      repsPerSet: List.generate(
          _repsControllers.length, (i) => int.parse(_repsControllers[i].text)),
      // Filter out empty weight entries and map them
      weightPerSet: List.generate(
          _weightControllers.length,
          (i) => _weightControllers[i].text.isEmpty
              ? 0.0
              : double.parse(_weightControllers[i].text)),
      restPeriodBetweenSets: _selectedExercise.restPeriodBetweenSets,
      completed: _isCompleted,
      skipped: _isSkipped,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle case where there are no exercises available
    if (widget.workoutDay.exercises.isEmpty) {
      return AlertDialog(
        title: Text('No Exercises Available'),
        content: Text('Please add exercises to this workout day first.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(
          widget.initialProgress != null ? 'Edit Progress' : 'Add Progress'),
      content: _isLoading
          ? SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<WorkoutDayExerciseDto>(
                      value: _selectedExercise,
                      decoration: InputDecoration(
                        labelText: 'Exercise',
                        border: OutlineInputBorder(),
                      ),
                      items: widget.workoutDay.exercises
                          .where((exercise) => !widget.existingProgresses.any(
                              (p) => p.workoutDayExerciseId == exercise.id))
                          .map((exercise) {
                        return DropdownMenuItem(
                          value: exercise,
                          child: Text(exercise.exerciseName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedExercise = value;
                            _updateSetsCount(value.sets);
                          });
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please select an exercise' : null,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Number of Sets',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _sets.toString(),
                            onChanged: (value) {
                              final sets = int.tryParse(value);
                              if (sets != null && sets > 0) {
                                _updateSetsCount(sets);
                              }
                            },
                            validator: (value) {
                              if (value == null ||
                                  int.tryParse(value) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ...List.generate(_sets, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _repsControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Reps for Set ${index + 1}',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      int.tryParse(value) == null) {
                                    return 'Enter reps';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _weightControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Completed'),
                      value: _isCompleted,
                      onChanged: _isSkipped
                          ? null
                          : (value) {
                              setState(() => _isCompleted = value ?? false);
                            },
                    ),
                    CheckboxListTile(
                      title: Text('Skipped'),
                      value: _isSkipped,
                      onChanged: _isCompleted
                          ? null
                          : (value) {
                              setState(() => _isSkipped = value ?? false);
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
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, _createProgressDto());
                  }
                },
          child: Text('Save'),
        ),
      ],
    );
  }
}
