import 'package:flutter/material.dart';
import '../services/exercise_service.dart';
import 'dialogs/exercise_edit_dialog.dart';
import 'dialogs/exercise_deletion_warning_dialog.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ExerciseListScreenState createState() => ExerciseListScreenState();
}

class ExerciseListScreenState extends State<ExerciseListScreen> {
  final _exerciseService = ExerciseService();
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Exercise> _exercises = [];
  final Set<int> _selectedExercises = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _exerciseService.searchExercises(_searchQuery);
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

  Future<void> _deleteSelectedExercises() async {
    try {
      // Get usage information for all selected exercises
      final usages = await Future.wait(
        _selectedExercises.map((id) => _exerciseService.getExerciseUsage(id))
      );

      if (!mounted) return;

      // Show warning dialog with usage information
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => ExerciseDeletionWarningDialog(usages: usages),
      );

      if (shouldDelete == true && mounted) {
        await _exerciseService.deleteExercises(_selectedExercises.toList());
        setState(() {
          _selectedExercises.clear();
        });
        await _loadExercises();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exercises deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete exercises: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _editExercise(Exercise exercise) async {
    final updatedExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) => ExerciseEditDialog(exercise: exercise),
    );

    if (updatedExercise != null && mounted) {
      await _loadExercises();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises'),
        actions: [
          if (_selectedExercises.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedExercises,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search exercises...',
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                  _isLoading = true;
                });
                _loadExercises();
              },
              trailing: [
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isLoading = true;
                    });
                    _loadExercises();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _exercises.isEmpty
                    ? Center(child: Text('No exercises found'))
                    : ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          return ListTile(
                            leading: Checkbox(
                              value: _selectedExercises.contains(exercise.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedExercises.add(exercise.id);
                                  } else {
                                    _selectedExercises.remove(exercise.id);
                                  }
                                });
                              },
                            ),
                            title: Text(exercise.name),
                            subtitle: Text(
                              exercise.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editExercise(exercise),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}