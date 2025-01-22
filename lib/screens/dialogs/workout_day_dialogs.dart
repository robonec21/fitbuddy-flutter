import 'package:flutter/material.dart';
import '../../models/workout/index.dart';
import '../../services/exercise_service.dart';
import '../dialogs/exercise_selection_dialog.dart';
import '../dialogs/exercise_creation_dialog.dart';

class EditWorkoutDayDialog extends StatefulWidget {
  final WorkoutDayDto workoutDay;
  final Function(WorkoutDayDto) onDayUpdated;

  const EditWorkoutDayDialog({
    super.key,
    required this.workoutDay,
    required this.onDayUpdated,
  });

  @override
  EditWorkoutDayDialogState createState() => EditWorkoutDayDialogState();
}

class EditWorkoutDayDialogState extends State<EditWorkoutDayDialog> {
  late List<WorkoutDayExerciseDto> exercises;

  @override
  void initState() {
    super.initState();
    exercises = List.from(widget.workoutDay.exercises);
  }

  Future<void> _addExercise() async {
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,  // Prevent accidental dismissal
      builder: (context) => AlertDialog(
        title: Text('Add Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'select'),
              child: Text('Select Existing Exercise'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'create'),
              child: Text('Create New Exercise'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    if (!mounted || choice == null) return;

    Exercise? selectedExercise;
    if (choice == 'select') {
      selectedExercise = await showDialog<Exercise>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ExerciseSelectionDialog(
              onExerciseSelected: (exercise) {
                  Navigator.pop(context, exercise);
              },
          ),
      );
    } else if (choice == 'create') {
      selectedExercise = await showDialog<Exercise>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ExerciseCreationDialog(
          onExerciseCreated: (exercise) {
              Navigator.pop(context, exercise);
          },
        ),
      );
    }

    if (selectedExercise != null && mounted) {
      final exercise = selectedExercise; // This creates a non-nullable local variable
      setState(() {
        exercises.add(WorkoutDayExerciseDto(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          orderIndex: exercises.length,
          sets: exercise.defaultSets,
          repsPerSet: exercise.defaultRepsPerSet,
          restPeriodBetweenSets: exercise.defaultRestPeriodBetweenSets,
        ));
      });
      
      // Update the parent with the new state
      widget.onDayUpdated(WorkoutDayDto(
        id: widget.workoutDay.id,
        dayOfWeek: widget.workoutDay.dayOfWeek,
        exercises: exercises,
      ));
    }
  }

  void _removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
      // Update order indices
      for (var i = 0; i < exercises.length; i++) {
        exercises[i] = WorkoutDayExerciseDto(
          id: exercises[i].id,
          exerciseId: exercises[i].exerciseId,
          exerciseName: exercises[i].exerciseName,
          orderIndex: i,
          sets: exercises[i].sets,
          repsPerSet: exercises[i].repsPerSet,
          restPeriodBetweenSets: exercises[i].restPeriodBetweenSets,
        );
      }
    });
  }

  void _editExercise(int index) {
    final exercise = exercises[index];
    showDialog(
      context: context,
      builder: (context) => ExerciseDetailsDialog(
        exercise: exercise,
        onExerciseUpdated: (updatedExercise) {
          setState(() {
            exercises[index] = updatedExercise;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.workoutDay.dayOfWeek} Workout'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    title: Text(exercise.exerciseName),
                    subtitle: Text(
                      '${exercise.sets} sets × ${exercise.repsPerSet} reps'
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          exercises.removeAt(index);
                        });
                        widget.onDayUpdated(WorkoutDayDto(
                          id: widget.workoutDay.id,
                          dayOfWeek: widget.workoutDay.dayOfWeek,
                          exercises: exercises,
                        ));
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addExercise,
              child: Text('Add Exercise'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
        ),
      ],
    );
  }
}

class ExerciseDetailsDialog extends StatefulWidget {
  final WorkoutDayExerciseDto exercise;
  final Function(WorkoutDayExerciseDto) onExerciseUpdated;

  const ExerciseDetailsDialog({
    super.key,
    required this.exercise,
    required this.onExerciseUpdated,
  });

  @override
  ExerciseDetailsDialogState createState() => ExerciseDetailsDialogState();
}

class ExerciseDetailsDialogState extends State<ExerciseDetailsDialog> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(text: widget.exercise.sets.toString());
    _repsController = TextEditingController(text: widget.exercise.repsPerSet.toString());
    _restController = TextEditingController(
      text: widget.exercise.restPeriodBetweenSets?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.exercise.exerciseName,
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16),
            TextFormField(
              controller: _setsController,
              decoration: InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _repsController,
              decoration: InputDecoration(
                labelText: 'Reps per set',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _restController,
              decoration: InputDecoration(
                labelText: 'Rest period (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedExercise = WorkoutDayExerciseDto(
              id: widget.exercise.id,
              exerciseId: widget.exercise.exerciseId,
              exerciseName: widget.exercise.exerciseName,
              orderIndex: widget.exercise.orderIndex,
              sets: int.tryParse(_setsController.text) ?? widget.exercise.sets,
              repsPerSet: int.tryParse(_repsController.text) ?? widget.exercise.repsPerSet,
              restPeriodBetweenSets: int.tryParse(_restController.text),
            );
            widget.onExerciseUpdated(updatedExercise);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}