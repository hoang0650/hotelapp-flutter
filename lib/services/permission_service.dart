import 'package:hotelapp_flutter/services/auth_service.dart';

class PermissionService {
  final AuthService _authService = AuthService();

  // Roles
  static const String SUPER_ADMIN = 'SUPER_ADMIN';
  static const String ADMIN = 'ADMIN';
  static const String MANAGER = 'MANAGER';
  static const String RECEPTIONIST = 'RECEPTIONIST';
  static const String STAFF = 'STAFF';

  // Features
  static const String MANAGE_SERVICES = 'MANAGE_SERVICES';
  static const String MANAGE_STAFF = 'MANAGE_STAFF';
  static const String MANAGE_ROOMS = 'MANAGE_ROOMS';
  static const String MANAGE_GUESTS = 'MANAGE_GUESTS';
  static const String MANAGE_DEBT = 'MANAGE_DEBT';
  static const String ELECTRIC_CONTROL = 'ELECTRIC_CONTROL';
  static const String VIEW_REPORTS = 'VIEW_REPORTS';
  static const String MANAGE_SETTINGS = 'MANAGE_SETTINGS';

  Future<bool> hasRole(List<String> allowedRoles) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return false;
    // Normalize role to uppercase just in case
    final userRole = (user.role ?? '').toUpperCase();
    return allowedRoles.contains(userRole);
  }

  Future<bool> canAccess(String feature) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return false;
    
    final userRole = (user.role ?? '').toUpperCase();
    if (userRole == SUPER_ADMIN) return true;

    switch (feature) {
      case MANAGE_SERVICES:
        return [ADMIN, MANAGER].contains(userRole);
      case MANAGE_STAFF:
        return [ADMIN].contains(userRole);
      case MANAGE_ROOMS:
        return [ADMIN, MANAGER].contains(userRole);
      case MANAGE_GUESTS:
        return [ADMIN, MANAGER, RECEPTIONIST].contains(userRole);
      case MANAGE_DEBT:
        return [ADMIN, MANAGER].contains(userRole);
      case ELECTRIC_CONTROL:
        return [ADMIN, MANAGER, RECEPTIONIST].contains(userRole);
      case VIEW_REPORTS:
        return [ADMIN, MANAGER].contains(userRole);
      case MANAGE_SETTINGS:
        return [ADMIN].contains(userRole);
      default:
        return true;
    }
  }
}
