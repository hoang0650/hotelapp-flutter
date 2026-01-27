class AppConstants {
  // API Configuration
  static const String apiUrl = 'https://nest-production-8106.up.railway.app';
  static const String aiBaseUrl = 'https://phgroup-ai-production.up.railway.app';
  
  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String hotelIdKey = 'hotelId';
  static const String businessIdKey = 'businessId';
  
  // API Endpoints
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String forgotPasswordEndpoint = '/users/forgot-password';
  static const String resetPasswordEndpoint = '/users/reset-password';
  static const String usersEndpoint = '/users';
  static const String userProfileEndpoint = '/users/profile';
  static const String roomsEndpoint = '/rooms';
  static const String hotelsEndpoint = '/hotels';
  static const String businessEndpoint = '/business';
  static const String staffsEndpoint = '/staffs';
  static const String guestsEndpoint = '/guests';
  static const String servicesEndpoint = '/services';
  static const String bookingsEndpoint = '/bookings';
  static const String shiftHandoverEndpoint = '/shift-handover';
  static const String transactionsEndpoint = '/transactions';
  static const String invoicesEndpoint = '/invoices';
  static const String debtEndpoint = '/debt';
  static const String financialSummaryEndpoint = '/financial-summary';
  static const String settingsEndpoint = '/settings';
  static const String contactsEndpoint = '/contacts';
  static const String blogsEndpoint = '/blog';
  
  // User Roles
  static const String roleSuperadmin = 'superadmin';
  static const String roleAdmin = 'admin';
  static const String roleBusiness = 'business';
  static const String roleHotel = 'hotel';
  static const String roleStaff = 'staff';
  static const String roleGuest = 'guest';
}

