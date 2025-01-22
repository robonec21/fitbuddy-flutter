import 'package:flutter/material.dart';
import '../../services/exercise_service.dart';

class ExerciseDeletionWarningDialog extends StatelessWidget {
  final List<ExerciseUsage> usages;

  const ExerciseDeletionWarningDialog({
    super.key,
    required this.usages,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Warning'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The following exercises are used in workout programs:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            ...usages.map((usage) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usage.exerciseName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...usage.programs.map((program) => Padding(
                  padding: EdgeInsets.only(left: 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ${program.programName}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          program.days
                              .map((day) => day.dayOfWeek)
                              .join(', '),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
                SizedBox(height: 16),
              ],
            )),
            SizedBox(height: 8),
            Text(
              'Are you sure you want to delete these exercises? This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
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
    );
  }
}