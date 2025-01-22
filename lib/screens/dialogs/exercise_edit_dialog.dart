import 'package:flutter/material.dart';
import '../../services/exercise_service.dart';

class ExerciseEditDialog extends StatefulWidget {
  final Exercise exercise;

  const ExerciseEditDialog({
    super.key,
    required this.exercise,
  });

  @override
  ExerciseEditDialogState createState() => ExerciseEditDialogState();
}

class ExerciseEditDialogState extends State<ExerciseEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _defaultSetsController = TextEditingController();
  final _defaultRepsController = TextEditingController();
  final _defaultRestController = TextEditingController();
  final _exerciseService = ExerciseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.exercise.name;
    _descriptionController.text = widget.exercise.description ?? '';
    _defaultSetsController.text = widget.exercise.defaultSets.toString();
    _defaultRepsController.text = widget.exercise.defaultRepsPerSet.toString();
    _defaultRestController.text = 
        widget.exercise.defaultRestPeriodBetweenSets?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _defaultSetsController.dispose();
    _defaultRepsController.dispose();
    _defaultRestController.dispose();
    super.dispose();
  }

  Future<void> _updateExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedExercise = Exercise(
        id: widget.exercise.id,
        name: _nameController.text,
        description: _descriptionController.text,
        defaultSets: int.parse(_defaultSetsController.text),
        defaultRepsPerSet: int.parse(_defaultRepsController.text),
        defaultRestPeriodBetweenSets: 
            int.tryParse(_defaultRestController.text),
      );

      final result = await _exerciseService.updateExercise(updatedExercise);
      
      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update exercise: ${e.toString()}')),
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
      title: Text('Edit Exercise'),
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
                validator: (value) {
                  if (value?.isEmpty ?? true) return null;
                  return int.tryParse(value!) == null
                      ? 'Enter a valid number'
                      : null;
                },
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
          onPressed: _isLoading ? null : _updateExercise,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Save'),
        ),
      ],
    );
  }
}