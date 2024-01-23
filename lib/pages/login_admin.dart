import 'package:flutter/material.dart';
import 'package:tenis_app/pages/register.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.user});
  final String user;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    @override
  	void initState(){
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
							onPressed: () {
                    			
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