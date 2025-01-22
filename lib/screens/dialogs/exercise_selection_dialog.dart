import 'package:flutter/material.dart';
import '../../services/exercise_service.dart';

class ExerciseSelectionDialog extends StatefulWidget {
  final Function(Exercise) onExerciseSelected;

  const ExerciseSelectionDialog({
    super.key,
    required this.onExerciseSelected,
  });

  @override
  ExerciseSelectionDialogState createState() => ExerciseSelectionDialogState();
}

class ExerciseSelectionDialogState extends State<ExerciseSelectionDialog> {
  final _exerciseService = ExerciseService();
  bool _isLoading = true;
  List<Exercise> _exercises = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _exerciseService.getExercises();
      if (mounted) {
        setState(() {
          _exercises = exercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exercises: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  List<Exercise> get _filteredExercises {
    if (_searchQuery.isEmpty) return _exercises;
    return _exercises.where((exercise) =>
      exercise.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Exercise'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return ListTile(
                        title: Text(exercise.name),
                        subtitle: exercise.description != null
                          ? Text(exercise.description!)
                          : null,
                        trailing: Text(
                          '${exercise.defaultSets}×${exercise.defaultRepsPerSet}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () {
                          widget.onExerciseSelected(exercise);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}