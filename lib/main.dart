import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/admin_dashboard_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ShopVIPApp(),
    ),
  );
}

class ShopVIPApp extends StatelessWidget {
  const ShopVIPApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'شوب VIP Iraq',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Tajawal',
      ),
      home: appState.currentUser == null
          ? const LoginPage()
          : appState.currentUser!.isAdmin
              ? const AdminDashboardPage()
              : const HomePage(),
    );
  }
}
