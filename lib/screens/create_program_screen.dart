import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/workout/index.dart';
import '../services/workout_program_service.dart';
import './dialogs/workout_day_dialogs.dart';
import 'dialogs/add_workout_day_dialog.dart'; 

class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  CreateProgramScreenState createState() => CreateProgramScreenState();
}

class CreateProgramScreenState extends State<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workoutProgramService = WorkoutProgramService();
  bool _isLoading = false;
  final List<WorkoutDayDto> _workoutDays = [];

  Future<void> _createProgram() async {
    if (!_formKey.currentState!.validate()) return;
    if (_workoutDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add at least one workout day')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final programData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'workoutDays': _workoutDays
            .map((day) => {
                  'dayOfWeek': day.dayOfWeek,
                  'exercises': day.exercises
                      .map((exercise) => {
                            'exerciseId': exercise.exerciseId,
                            'orderIndex': exercise.orderIndex,
                            'sets': exercise.sets,
                            'repsPerSet': exercise.repsPerSet,
                            'restPeriodBetweenSets':
                                exercise.restPeriodBetweenSets,
                          })
                      .toList(),
                })
            .toList(),
      };

      await _workoutProgramService.createWorkoutProgram(programData);

      if (mounted) {
        GoRouter.of(context).go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('Session expired') || 
            e.toString().contains('Not authenticated')) {
          GoRouter.of(context).go('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create program: ${e.toString()}')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addWorkoutDay() async {
    final day = await showDialog<WorkoutDayDto>(
      context: context,
      builder: (context) => AddWorkoutDayDialog(
        existingDays: _workoutDays.map((d) => d.dayOfWeek).toList(),
      ),
    );

    if (day != null && mounted) {
      setState(() {
        _workoutDays.add(day);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Workout Program'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/dashboard'),
        ),
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
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Program Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Workout Days',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    if (_workoutDays.isEmpty)
                      Center(
                        child: Text(
                          'No workout days added yet',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _workoutDays.length,
                        itemBuilder: (context, index) {
                          final day = _workoutDays[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(day.dayOfWeek),
                              subtitle: Text(
                                '${day.exercises.length} exercises',
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _workoutDays.removeAt(index);
                                  });
                                },
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => EditWorkoutDayDialog(
                                    workoutDay: day,
                                    onDayUpdated: (updatedDay) {
                                      setState(() {
                                        _workoutDays[index] = updatedDay;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addWorkoutDay,
                        icon: Icon(Icons.add),
                        label: Text('Add Workout Day'),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createProgram,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Create Program'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
