import 'package:flutter/material.dart';
import '../../services/exercise_service.dart';

class ExerciseCreationDialog extends StatefulWidget {
  final Function(Exercise) onExerciseCreated;

  const ExerciseCreationDialog({
    super.key,
    required this.onExerciseCreated,
  });

  @override
  ExerciseCreationDialogState createState() => ExerciseCreationDialogState();
}

class ExerciseCreationDialogState extends State<ExerciseCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _defaultSetsController = TextEditingController(text: '3');
  final _defaultRepsController = TextEditingController(text: '10');
  final _defaultRestController = TextEditingController(text: '60');
  final _exerciseService = ExerciseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _defaultSetsController.dispose();
    _defaultRepsController.dispose();
    _defaultRestController.dispose();
    super.dispose();
  }

  Future<void> _createExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final exercise = await _exerciseService.createExercise(
        name: _nameController.text,
        description: _descriptionController.text,
        defaultSets: int.parse(_defaultSetsController.text),
        defaultRepsPerSet: int.parse(_defaultRepsController.text),
        defaultRestPeriodBetweenSets: int.parse(_defaultRestController.text),
      );

      if (mounted) {
        widget.onExerciseCreated(exercise);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create exercise: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create New Exercise'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Exercise Name',
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
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _defaultSetsController,
                      decoration: InputDecoration(
                        labelText: 'Default Sets',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => int.tryParse(value ?? '') == null
                          ? 'Enter a valid number'
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _defaultRepsController,
                      decoration: InputDecoration(
                        labelText: 'Default Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => int.tryParse(value ?? '') == null
                          ? 'Enter a valid number'
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _defaultRestController,
                decoration: InputDecoration(
                  labelText: 'Default Rest Period (seconds)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value ?? '') == null
                    ? 'Enter a valid number'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createExercise,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Create'),
        ),
      ],
    );
  }
}