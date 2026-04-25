import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_camsme_sana_project/core/providers/auth_provider.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/login_page.dart';

class LoginPageWithProvider extends StatelessWidget {
  const LoginPageWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const LoginPage(),
    );
  }
}
