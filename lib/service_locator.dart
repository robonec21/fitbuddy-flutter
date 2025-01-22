import 'router.dart';
import 'services/auth_service.dart';

class ServiceLocator {
  static final authNotifier = AuthStateNotifier();
  static final authService = AuthService(authNotifier);
}