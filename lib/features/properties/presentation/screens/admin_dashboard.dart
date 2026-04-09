// lib/features/dashboard/presentation/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user.dart';

/// Dashboard data model
class DashboardData {
  final int totalTenants;
  final double revenue;
  final double occupancy;
  final int overdue;

  DashboardData({
    required this.totalTenants,
    required this.revenue,
    required this.occupancy,
    required this.overdue,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalTenants: json['total_tenants'] ?? 0,
      revenue: (json['total_revenue'] ?? 0).toDouble(),
      occupancy: (json['occupancy'] ?? 0).toDouble(),
      overdue: (json['overdue_invoices'] ?? 0),
    );
  }
}

/// Dashboard provider
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://rentcom.net/api'));

  // Read token from AuthNotifier
  final token = await ref.read(authProvider.notifier).getToken();
  if (token != null) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  final response = await dio.get('/reports/dashboard');
  return DashboardData.fromJson(response.data);
});

/// ----------------------
/// PROPERTIES SCREEN
/// ----------------------
class PropertiesScreen extends ConsumerStatefulWidget {
  const PropertiesScreen({super.key});

  @override
  ConsumerState<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends ConsumerState<PropertiesScreen> {
  List<Map<String, dynamic>> properties = [];
  bool loading = true;

  Future<void> fetchProperties() async {
    setState(() => loading = true);
    final dio = Dio(BaseOptions(baseUrl: 'https://rentcom.net/api'));
    final token = await ref.read(authProvider.notifier).getToken();
    if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await dio.get('/properties');
      final list = (response.data['data'] ?? []) as List<dynamic>;
      setState(() {
        properties = list.map((e) => e as Map<String, dynamic>).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching properties: $e')));
    }
  }

  Future<void> addProperty() async {
    final formKey = GlobalKey<FormState>();
    String? name, location, description;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Property'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (v) => name = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (v) => location = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => description = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final dio = Dio(BaseOptions(baseUrl: 'https://rentcom.net/api'));
                  final token = await ref.read(authProvider.notifier).getToken();
                  if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
                  try {
                    await dio.post('/properties', data: {
                      'name': name,
                      'location': location,
                      'description': description,
                    });
                    Navigator.pop(context);
                    fetchProperties();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Property added successfully')));
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Properties')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: properties.length,
        itemBuilder: (_, i) {
          final prop = properties[i];
          return ListTile(
            title: Text(prop['name'] ?? ''),
            subtitle: Text(prop['location'] ?? ''),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProperty,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ----------------------
/// TENANTS SCREEN
/// ----------------------
class TenantsScreen extends ConsumerStatefulWidget {
  const TenantsScreen({super.key});

  @override
  ConsumerState<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends ConsumerState<TenantsScreen> {
  List<Map<String, dynamic>> tenants = [];
  bool loading = true;

  Future<void> fetchTenants() async {
    setState(() => loading = true);
    final dio = Dio(BaseOptions(baseUrl: 'https://rentcom.net/api'));
    final token = await ref.read(authProvider.notifier).getToken();
    if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await dio.get('/tenants');
      final list = (response.data['data'] ?? []) as List<dynamic>;
      setState(() {
        tenants = list.map((e) => e as Map<String, dynamic>).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching tenants: $e')));
    }
  }

  Future<void> addTenant() async {
    final formKey = GlobalKey<FormState>();
    String? name, phone, email, password;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Tenant'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (v) => name = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) => phone = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (v) => email = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                onSaved: (v) => password = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final dio = Dio(BaseOptions(baseUrl: 'https://rentcom.net/api'));
                  final token = await ref.read(authProvider.notifier).getToken();
                  if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
                  try {
                    await dio.post('/tenants', data: {
                      'name': name,
                      'phone': phone,
                      'email': email,
                      'password': password,
                    });
                    Navigator.pop(context);
                    fetchTenants();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Tenant added successfully')));
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTenants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tenants')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: tenants.length,
        itemBuilder: (_, i) {
          final tenant = tenants[i];
          return ListTile(
            title: Text(tenant['name'] ?? ''),
            subtitle: Text(tenant['email'] ?? ''),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTenant,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ----------------------
/// PAYMENTS SCREEN
/// ----------------------
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  List<Map<String, dynamic>> payments = [];
  bool loading = true;

  Future<void> fetchPayments() async {
    setState(() => loading = true);
    final dio = Dio(BaseOptions(baseUrl: 'https://rentcom.net/api'));
    final token = await ref.read(authProvider.notifier).getToken();
    if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await dio.get('/payments');
      final list = (response.data['data'] ?? []) as List<dynamic>;
      setState(() {
        payments = list.map((e) => e as Map<String, dynamic>).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching payments: $e')));
    }
  }

  Future<void> addPayment() async {
    final formKey = GlobalKey<FormState>();
    String? invoiceId, amount, method, reference;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Payment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Invoice ID'),
                onSaved: (v) => invoiceId = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onSaved: (v) => amount = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Payment Method'),
                onSaved: (v) => method = v,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Reference'),
                onSaved: (v) => reference = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final dio = Dio(BaseOptions(baseUrl: 'https://rentcom.net/api'));
                  final token = await ref.read(authProvider.notifier).getToken();
                  if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
                  try {
                    await dio.post('/payments', data: {
                      'invoice_id': invoiceId,
                      'amount': amount,
                      'payment_method': method,
                      'reference': reference,
                    });
                    Navigator.pop(context);
                    fetchPayments();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Payment added successfully')));
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: payments.length,
        itemBuilder: (_, i) {
          final payment = payments[i];
          return ListTile(
            title: Text(payment['amount'].toString()),
            subtitle: Text(payment['payment_method'] ?? ''),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPayment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ----------------------
/// ADMIN DASHBOARD
/// ----------------------
class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Admin'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Properties'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PropertiesScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Tenants'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TenantsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payments'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentsScreen()),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: dashboardAsync.when(
          data: (data) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildSummaryCard(
                        'Total Tenants', '${data.totalTenants}', Icons.people, Colors.blue),
                    _buildSummaryCard(
                        'Revenue', '\$${data.revenue}', Icons.attach_money, Colors.green),
                    _buildSummaryCard(
                        'Occupancy', '${data.occupancy}%', Icons.home, Colors.orange),
                    _buildSummaryCard(
                        'Overdue', '${data.overdue}', Icons.warning, Colors.red),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}