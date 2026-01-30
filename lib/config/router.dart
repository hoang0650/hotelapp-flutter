import 'package:go_router/go_router.dart';
import 'package:hotelapp_flutter/screens/auth/login_screen.dart';
import 'package:hotelapp_flutter/screens/auth/signup_screen.dart';
import 'package:hotelapp_flutter/screens/auth/forgot_password_screen.dart';
import 'package:hotelapp_flutter/screens/auth/reset_password_screen.dart';
import 'package:hotelapp_flutter/screens/home/home_screen.dart';
import 'package:hotelapp_flutter/screens/admin/room_screen.dart';
import 'package:hotelapp_flutter/screens/admin/hotel_management_screen.dart';
import 'package:hotelapp_flutter/screens/admin/business_management_screen.dart';
import 'package:hotelapp_flutter/screens/admin/staff_management_screen.dart';
import 'package:hotelapp_flutter/screens/admin/guest_management_screen.dart';
import 'package:hotelapp_flutter/screens/admin/service_management_screen.dart';
import 'package:hotelapp_flutter/screens/admin/debt_management_screen.dart';
import 'package:hotelapp_flutter/screens/admin/shift_handover_screen.dart';
import 'package:hotelapp_flutter/screens/admin/shift_handover_history_screen.dart';
import 'package:hotelapp_flutter/screens/admin/calendar_screen.dart';
import 'package:hotelapp_flutter/screens/admin/revenue_chart_screen.dart';
import 'package:hotelapp_flutter/screens/admin/financial_summary_screen.dart';
import 'package:hotelapp_flutter/screens/admin/reports_screen.dart';
import 'package:hotelapp_flutter/screens/admin/invoices_screen.dart';
import 'package:hotelapp_flutter/screens/admin/payment_history_screen.dart';
import 'package:hotelapp_flutter/screens/admin/bank_transfer_history_screen.dart';
import 'package:hotelapp_flutter/screens/profile/profile_screen.dart';
import 'package:hotelapp_flutter/screens/settings/settings_screen.dart';
import 'package:hotelapp_flutter/screens/admin/management_screen.dart';
import 'package:hotelapp_flutter/screens/admin/electric_setting_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin/rooms',
        builder: (context, state) => const RoomScreen(),
      ),
      GoRoute(
        path: '/admin/management',
        builder: (context, state) => const ManagementScreen(),
      ),
      GoRoute(
        path: '/admin/electric',
        builder: (context, state) => const ElectricSettingScreen(),
      ),
      GoRoute(
        path: '/admin/hotels',
        builder: (context, state) => const HotelManagementScreen(),
      ),
      GoRoute(
        path: '/admin/business',
        builder: (context, state) => const BusinessManagementScreen(),
      ),
      GoRoute(
        path: '/admin/staff',
        builder: (context, state) => const StaffManagementScreen(),
      ),
      GoRoute(
        path: '/admin/guests',
        builder: (context, state) => const GuestManagementScreen(),
      ),
      GoRoute(
        path: '/admin/services',
        builder: (context, state) => const ServiceManagementScreen(),
      ),
      GoRoute(
        path: '/admin/debt',
        builder: (context, state) => const DebtManagementScreen(),
      ),
      GoRoute(
        path: '/admin/shift-handover',
        builder: (context, state) => const ShiftHandoverScreen(),
      ),
      GoRoute(
        path: '/admin/shift-handover-history',
        builder: (context, state) => const ShiftHandoverHistoryScreen(),
      ),
      GoRoute(
        path: '/admin/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/admin/revenue',
        builder: (context, state) => const RevenueChartScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/admin/invoices',
        builder: (context, state) => const InvoicesScreen(),
      ),
      GoRoute(
        path: '/admin/payment-history',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: '/admin/bank-transfer-history',
        builder: (context, state) => const BankTransferHistoryScreen(),
      ),
      GoRoute(
        path: '/admin/financial-summary',
        builder: (context, state) => const FinancialSummaryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

