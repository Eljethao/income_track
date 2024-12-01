import 'package:flutter/material.dart';
import 'package:income_track/pages/add_income.dart';
import 'package:income_track/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:income_track/pages/profile/profile.dart';
import 'package:income_track/pages/signin/login.dart';
import 'package:income_track/pages/signin/register.dart';
import 'package:income_track/providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>  Login(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => AddIncome(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => Register(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => Profile(),
    )
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Income Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: "NotoSerifLao",
      ),
      routerConfig: _router,
    );
  }
}

// Example of preloading user data
// class ProfilePageLauncher extends ConsumerWidget {
//   final String userDataJson;

//   ProfilePageLauncher({required this.userDataJson});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Load user data into Riverpod provider
//     ref.read(userDataProvider.notifier).loadUserData(userDataJson);

//     return Profile(); // Navigate to the profile page
//   }
// }
