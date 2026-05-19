import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/error_handler.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<FirebaseAuthService>(context, listen: false);
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getFriendlyErrorMessage(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPharmacist = _selectedRole == UserRole.pharmacist;
    final ThemeData baseTheme = Theme.of(context);

    // Dynamic light theme for the Pharmacist role
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: baseTheme.primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF5F8FA),
      colorScheme: ColorScheme.light(
        primary: baseTheme.primaryColor,
        surface: Colors.white,
        error: baseTheme.colorScheme.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F8FA),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: baseTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: baseTheme.colorScheme.error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIconColor: Colors.black54,
        suffixIconColor: Colors.black54,
      ),
      elevatedButtonTheme: baseTheme.elevatedButtonTheme,
    );

    // Wrap the Scaffold in an AnimatedTheme for a smooth UI transition
    return AnimatedTheme(
      data: isPharmacist ? lightTheme : baseTheme,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dynamic icon styling based on the selected role
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isPharmacist ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: isPharmacist 
                            ? [BoxShadow(color: baseTheme.primaryColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)] 
                            : [],
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_rounded, 
                        size: 70, 
                        color: baseTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: isPharmacist ? Colors.black87 : Colors.white),
                      validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: isPharmacist ? Colors.black87 : Colors.white),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Enter a valid email';
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(color: isPharmacist ? Colors.black87 : Colors.white),
                      validator: (val) => val != null && val.length < 6 ? 'Password must be 6+ chars' : null,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<UserRole>(
                      initialValue: _selectedRole,
                      dropdownColor: isPharmacist ? Colors.white : baseTheme.colorScheme.surface,
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            role == UserRole.customer ? 'I am a Customer' : 'I am a Pharmacist',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isPharmacist ? Colors.black87 : Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedRole = val!),
                      decoration: const InputDecoration(
                        labelText: 'Select Role',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signUp,
                            child: const Text('CREATE ACCOUNT'),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}