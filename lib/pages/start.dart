import 'package:flutter/material.dart';
import 'package:tenis_app/pages/login.dart';
import 'package:tenis_app/pages/home_user.dart';

class Start extends StatefulWidget {
    const Start({super.key});

    @override
    State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
    @override
    void initState(){
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        final size = MediaQuery.of(context).size;

        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text('Master Cup Tenis'),
                        const Text('Version: 1.5.4'),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        Image.asset(
                            'assets/logo.png',
                            height: size.height * 0.20
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.75,
                            child: ElevatedButton(
                                onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Login(user: 'Administrador')
                                        )
                                    );
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                    foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                                ),
                                child: const Text('Soy Administrador')
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.75,
                            child: ElevatedButton(
                                onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Login(user: 'Usuario')
                                        )
                                    );
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                    foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                                ),
                                child: const Text('Soy Usuario')
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.75,
                            child: ElevatedButton(
                                onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const HomeUser(guest: true)
                                        )
                                    );
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                    foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                                ),
                                child: const Text('Ingresar como invitado')
                            )
                        )
                    ]
                )
            )
        );
    }
}