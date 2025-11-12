import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'asset/image/logo.png', // 
                height: 170,
              ),
              const SizedBox(height: 40),

              // Title
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

              // Username field
TextField(
  controller: _usernameController,
  decoration: InputDecoration(
    hintText: 'Username',
    filled: true, // ✅ enable background color
    fillColor: Colors.white, // ✅ white background
    suffixIcon: const Icon(Icons.person_outline), // 👉 moved to right side
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


// Password field
TextField(
  
  controller: _passwordController,
  obscureText: _obscurePassword,
  decoration: InputDecoration(
    hintText: 'Password',
    filled: true, // ✅ enable background color
    fillColor: Colors.white, // ✅ white background
    suffixIcon: IconButton( // 👉 icon now on the right
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
                  onPressed: () {
                    // TODO: Add login logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF195E4C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Forget Password
              TextButton(
                onPressed: () {
                  // TODO: Add forget password logic
                },
                child: const Text(
                  'Forget Password?',
                  style: TextStyle(color: Color(0xFF195E4C)),
                ),
              ),
                const SizedBox(height: 100),

            ],
          ),
        ),
      ),
    );
  }
}
