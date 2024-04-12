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
    late SharedPreferences _prefs;
    late HttpHelper httpHelper;
    
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future initialize() async {
        _prefs = await SharedPreferences.getInstance();
    }

    @override
    void initState(){
        httpHelper = HttpHelper();
        initialize();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        bool isAdmin = widget.user == "Administrador";
        final size = MediaQuery.of(context).size;

        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text("Bienvenido ${widget.user}"),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(),
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    filled: true,
                                    fillColor: Color.fromRGBO(176, 202, 51, 0.75),
                                    prefixIcon: Icon(
                                        Icons.person,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                        ),
                                    ),
                                    labelText: 'Usuario',
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(),
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    filled: true,
                                    fillColor: Color.fromRGBO(176, 202, 51, 0.75),
                                    prefixIcon: Icon(
                                        Icons.lock,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30),
                                        ),
                                    ),
                                    labelText: 'Contraseña',
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Iniciando sesion...'),
                                            duration: Duration(minutes: 1),
                                        ),
                                    );
                                }
                                final Map<String, dynamic> response = await httpHelper.login(usernameController.text, passwordController.text, widget.user);
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    if (response['status'] == 'error') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(response['message']),
                                                duration: const Duration(seconds: 3),
                                            ),
                                        );
                                    } else {
                                        if (response['user']['role'] == 'Administrador') {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => const HomeAdmin()),
                                                (route) => false,
                                            );
                                        } else {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => const HomeUser(guest: false,)),
                                                (route) => false,
                                            );
                                        }
                                        await _prefs.setString('token', response['token']);
                                        await _prefs.setString('role', response['user']['role']);
                                    }
                                }
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            child: const Text('Ingresar'),
                        ),
                        if (!isAdmin)
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(),
                            ),
                        if (!isAdmin)
                            ElevatedButton(
                                onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Register(),
                                        ),
                                    );
                                },
                                style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                                ),
                                child: const Text('Registrarse'),
                            ),
                    ],
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    Navigator.pop(context);
                },
                backgroundColor: const Color.fromRGBO(176, 202, 51, 1),
                foregroundColor: const Color.fromRGBO(10, 36, 63, 1),
                child: const Icon(Icons.arrow_back),
            ),
        );
    }
}