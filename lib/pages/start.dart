import 'package:flutter/material.dart';
import 'package:tenis_app/pages/login.dart';

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
        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text('Master Cup Tennis'),
                        ElevatedButton(
                            onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login(user: 'Administrador')
                                    )
                                );
                            },
                            child: const Text('Soy Administrador')
                        ),
                        ElevatedButton(
                            onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login(user: 'Usuario')
                                    )
                                );
                            },
                            child: const Text('Soy Usuario')
                        )
                    ],
                ),
            )
        );
    }
}