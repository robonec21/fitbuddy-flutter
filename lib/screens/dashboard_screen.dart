import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/workout/index.dart';
import '../services/workout_program_service.dart';
import '../service_locator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _workoutProgramService = WorkoutProgramService();
  bool _isLoading = true;
  List<WorkoutProgramDto> _programs = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  void _handleAuthError() {
    if (mounted) {
      GoRouter.of(context).go('/login');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _loadPrograms() async {
    try {
      final programs = await _workoutProgramService.getWorkoutPrograms();
      if (mounted) {
        setState(() {
          _programs = programs;
        });
      }
    } catch (e) {
      if (e.toString().contains('Session expired') ||
          e.toString().contains('Not authenticated')) {
        _handleAuthError();
      } else {
         _showErrorMessage('Failed to load programs: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await ServiceLocator.authService.logout();
      if (mounted) {
        GoRouter.of(context).go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToCreateProgram() {
    GoRouter.of(context).go('/programs/create');
  }

  void _navigateToProgramDetails(int programId) {
    GoRouter.of(context).go('/programs/$programId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Programs'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _programs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No workout programs found'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _navigateToCreateProgram,
                        child: Text('Create New Program'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _programs.length,
                  itemBuilder: (context, index) {
                    final program = _programs[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(program.name),
                        subtitle: program.description != null
                            ? Text(program.description!)
                            : null,
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => _navigateToProgramDetails(program.id!),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateProgram,
        child: Icon(Icons.add),
      ),
    );
  }
}
