import 'package:flutter/material.dart';
import 'package:tenis_app/data/web/http_helper.dart';

class Register extends StatefulWidget {
    const Register({super.key});

    @override
    State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
    late HttpHelper httpHelper;
    
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController dniController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    @override
    void initState(){
        httpHelper = HttpHelper();
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
                        const Text("Regístrate"),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    prefixIcon: Icon(
                                        Icons.person,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                        ),
                                    ),
                                    labelText: 'Nombres'
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: lastNameController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    prefixIcon: Icon(
                                        Icons.person,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                        ),
                                    ),
                                    labelText: 'Apellidos'
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: dniController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    prefixIcon: Icon(
                                        Icons.credit_card,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                        ),
                                    ),
                                    labelText: 'DNI'
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    prefixIcon: Icon(
                                        Icons.phone,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                        ),
                                    ),
                                    labelText: 'Numero de celular'
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    prefixIcon: Icon(
                                        Icons.person,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                        ),
                                    ),
                                    labelText: 'Usuario'
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    prefixIcon: Icon(
                                        Icons.lock,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                        ),
                                    ),
                                    labelText: 'Contraseña'
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Creando nuevo usuario...'),
                                        duration: Duration(minutes: 1),
                                    )
                                );
                                final Map<String, dynamic> response = await httpHelper.register(nameController.text, lastNameController.text, dniController.text, phoneController.text, usernameController.text, passwordController.text);
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    if (response['status'] == 'error') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(response['message']),
                                                duration: const Duration(seconds: 3),
                                            )
                                        );
                                    } else {
                                        Navigator.pop(context);
                                    }
                                }
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