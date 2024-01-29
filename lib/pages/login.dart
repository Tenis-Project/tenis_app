import 'package:flutter/material.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/home_admin.dart';
import 'package:tenis_app/pages/home_user.dart';
import 'package:tenis_app/pages/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
    const Login({super.key, required this.user});
    final String user;

    @override
    State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
    HttpHelper? httpHelper;
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    @override
    void initState(){
        httpHelper = HttpHelper();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        bool isAdmin = widget.user == "Administrador";

        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text("Bienvenido ${widget.user}"),
                        TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                                labelText: 'Nombre de usuario'
                            ),
                        ),
                        TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'Contraseña'
                            ),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                final Map<String, dynamic>? response = await httpHelper?.login(usernameController.text, passwordController.text, widget.user);
                                if (response != null && context.mounted) {
                                    if (response['status'] == 'error') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(response['message']),
                                                duration: const Duration(seconds: 3),
                                            )
                                        );
                                    } else {
                                        if (response['user']['role'] == 'Administrador') {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => const HomeAdmin()),
                                                (route) => false
                                            );
                                        } else {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => const HomeUser()),
                                                (route) => false
                                            );
                                        }
                                        final SharedPreferences prefs = await _prefs;
                                        await prefs.setString('token', response['token']);
                                        await prefs.setString('role', response['user']['role']);
                                    }
                                }
                            },
                            child: const Text('Ingresar')
                        ),
                        if (!isAdmin)
                            ElevatedButton(
                                onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Register()
                                        )
                                    );
                                },
                                child: const Text('Registrarse')
                            )
                    ],
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back),
            ),
        );
    }
}