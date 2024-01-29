import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/pages/home_admin.dart';
import 'package:tenis_app/pages/home_user.dart';
import 'package:tenis_app/pages/start.dart';

void main() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    String? role = prefs.getString('role');

    Widget initialScreen = authToken != null ? role == 'Administrador' ? const HomeAdmin() : const HomeUser() : const Start();
  
    runApp(MainApp(initialScreen));
}

class MainApp extends StatelessWidget {
    final Widget initialScreen;

    const MainApp(this.initialScreen, {super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            home: initialScreen
        );
    }
}
