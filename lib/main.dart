import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/properties/presentation/screens/admin_dashboard.dart';
import 'features/auth/presentation/screens/tenant_dashboard.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Tenant Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: _getHome(authState),
    );
  }

  Widget _getHome(AuthState authState) {
    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    if (authState.user?.roleId == 1) { // Admin
      return const AdminDashboard();
    } else { // Tenant
      return const TenantDashboard();
    }
  }
}
