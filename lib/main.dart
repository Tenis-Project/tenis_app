import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/pages/home_admin.dart';
import 'package:tenis_app/pages/home_user.dart';
import 'package:tenis_app/pages/start.dart';

void main() {
    runApp(const MainApp());
}

class MainApp extends StatelessWidget {
    const MainApp({super.key});

    @override
    Widget build(BuildContext context) {
        return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                } else {
                    final SharedPreferences prefs = snapshot.data!;
                    String? authToken = prefs.getString('token');
                    String? role = prefs.getString('role');

                    Widget initialScreen = authToken != null ? role == 'Administrador' ? const HomeAdmin() : const HomeUser() : const Start();

                    return MaterialApp(
                        home: initialScreen,
                    );
                }
            },
        );
    }
}