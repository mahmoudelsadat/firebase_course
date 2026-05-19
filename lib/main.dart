import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/customer_home.dart';
import 'screens/home/pharmacist_home.dart';
import 'models/user_model.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Pharmacy App',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode, // Dynamic theme mode
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<FirebaseAuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserModel?>(
            future: authService.getUserData(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                if (userSnapshot.data!.role == UserRole.pharmacist) {
                  return PharmacistHomeScreen();
                } else {
                  return const CustomerHomeScreen();
                }
              }

              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off_outlined, size: 80, color: Colors.orangeAccent),
                        const SizedBox(height: 24),
                        const Text('Profile Missing', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('Your account exists, but we couldn\'t load your profile details.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async => await authService.signOut(),
                          child: const Text('Sign Out & Recover'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}