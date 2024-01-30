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
        final size = MediaQuery.of(context).size;

        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text('Master Cup Tennis'),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        Image.asset(
                            'assets/logo.png',
                            height: size.height * 0.20,
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
                                child: const Text('Soy Usuario')
                            )
                        )
                    ]
                )
            )
        );
    }
}