import 'package:flutter/material.dart';

class Register extends StatefulWidget {
    const Register({super.key});

    @override
    State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController dniController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

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
                        const Text("Regístrate"),
                        TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                labelText: 'Nombres'
                            ),
                        ),
                        TextField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                                labelText: 'Apellidos'
                            ),
                        ),
                        TextField(
                            controller: dniController,
                            decoration: const InputDecoration(
                                labelText: 'DNI'
                            ),
                        ),
                        TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                                labelText: 'Número de celular'
                            ),
                        ),
                        TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                                labelText: 'Nombre de usuario'
                            ),
                        ),
                        TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                                labelText: 'Contraseña'
                            ),
                        ),
                        ElevatedButton(
							onPressed: () {
                    			Navigator.pop(context);
                  			},
							child: const Text('Guardar usuario')
						),
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