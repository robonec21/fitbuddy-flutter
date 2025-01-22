import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/create_program_screen.dart';
import 'screens/program_detail_screen.dart';
import 'screens/program_selection_screen.dart';
import 'screens/program_logs_screen.dart';
import 'screens/progress_log_edit_screen.dart';
import 'service_locator.dart';

final router = GoRouter(
  initialLocation: '/',
  refreshListenable: ServiceLocator.authNotifier,
  redirect: (context, state) async {
    final token = await ServiceLocator.authService.getToken();
    
    final isAuthRoute = state.matchedLocation.startsWith('/login') || 
                       state.matchedLocation.startsWith('/signup');
                       
    // If no token and trying to access protected route
    if (token == null && !isAuthRoute) {
      // Store the attempted path to redirect back after login
      return '/login?from=${state.uri.path}';
    }
    
    // If has token but trying to access auth routes
    if (token != null && isAuthRoute) {
      return '/dashboard';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) => '/login',
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignUpScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => MainScreen(initialTab: 'programs'),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => MainScreen(initialTab: 'progress'),
    ),
    GoRoute(
      path: '/programs/create',
      builder: (context, state) => CreateProgramScreen(),
    ),
    GoRoute(
      path: '/programs/:id',
      builder: (context, state) => ProgramDetailScreen(
        programId: int.parse(state.pathParameters['id']!),
      ),
    ),
    // Progress tracking routes
    GoRoute(
      path: '/progress/programs/select',
      builder: (context, state) => ProgramSelectionScreen(),
    ),
    GoRoute(
      path: '/progress/programs/:programId/logs',
      builder: (context, state) => ProgramLogsScreen(
        programId: int.parse(state.pathParameters['programId']!),
      ),
    ),
    GoRoute(
      path: '/progress/programs/:programId/logs/create',
      builder: (context, state) => ProgressLogEditScreen(
        programId: int.parse(state.pathParameters['programId']!),
      ),
    ),
    GoRoute(
      path: '/progress/programs/:programId/logs/:logId/edit',
      builder: (context, state) => ProgressLogEditScreen(
        programId: int.parse(state.pathParameters['programId']!),
        logId: int.parse(state.pathParameters['logId']!),
      ),
    ),
  ],
);

// Add this class to notify router when auth state changes
class AuthStateNotifier extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  AuthStateNotifier() {
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    await _storage.read(key: 'jwt_token');
    notifyListeners();
  }
}