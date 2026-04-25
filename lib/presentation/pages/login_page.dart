import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/providers/auth_provider.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/core/services/auth_service.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // Check if login was successful
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Login failed');
      }

      // Determine warehouse payload. API may return either `warehouse` (single)
      // or `warehouses` (list) for admin users. Ensure we don't save id=0.
      dynamic warehouseIdValue;
      String warehouseName = 'Warehouse';

      if (res.containsKey('warehouse') && res['warehouse'] != null) {
        warehouseIdValue = res['warehouse']['id'];
        warehouseName = res['warehouse']['name'] ?? warehouseName;
      } else if (res.containsKey('warehouses') &&
          res['warehouses'] is List &&
          res['warehouses'].isNotEmpty) {
        // If multiple warehouses are returned (admin), pick the first as a fallback.
        // Ideally the app should let admin pick; this is a safe default to avoid id=0.
        final ws = List.from(res['warehouses']);
        warehouseIdValue = ws.first['id'];
        warehouseName = ws.first['name'] ?? warehouseName;
      } else {
        throw Exception('No warehouse assigned. Contact administrator.');
      }

      final warehouseIdStr = warehouseIdValue?.toString();
      if (warehouseIdStr == null || warehouseIdStr == '0') {
        throw Exception('Invalid warehouse assigned. Contact administrator.');
      }

      // Extract user data (including permissions)
      final userData = res['user'] ?? {};

      // Save ALL login data using AuthProvider for reactive state
      final authProvider = context.read<AuthProvider>();
      final loginSuccess = await authProvider.login(
        token: res['token'],
        warehouseId: warehouseIdStr,
        userName: userData['name'],
        userEmail: userData['email'],
        userPhone: userData['phone'],
        userType: userData['user_type'],
        permissions: userData['permissions'] != null
            ? List<String>.from(userData['permissions'])
            : null,
        userId: userData['id'],
      );

      if (!loginSuccess) {
        throw Exception('Failed to update auth state');
      }

      debugPrint('Login successful!');
      debugPrint('Warehouse ID: ${Session.warehouseId}');
      debugPrint('Warehouse Name: $warehouseName');

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('asset/image/logo.png', height: 170),
                const SizedBox(height: 40),

                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF195E4C),
                    fontFamily: 'Exo2',
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF195E4C)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF195E4C)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
