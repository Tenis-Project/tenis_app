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
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    bool acceptTermsAndCons = false;

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
                                    filled: true,
                                    fillColor: Color.fromRGBO(176, 202, 51, 0.75),
                                    prefixIcon: Icon(
                                        Icons.person
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)
                                        )
                                    ),
                                    labelText: 'Nombres'
                                )
                            )
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
                                    filled: true,
                                    fillColor: Color.fromRGBO(176, 202, 51, 0.75),
                                    prefixIcon: Icon(
                                        Icons.person
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)
                                        )
                                    ),
                                    labelText: 'Apellidos'
                                )
                            )
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
                                    filled: true,
                                    fillColor: Color.fromRGBO(176, 202, 51, 0.75),
                                    prefixIcon: Icon(
                                        Icons.person
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)
                                        )
                                    ),
                                    labelText: 'Usuario'
                                )
                            )
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
                                    filled: true,
                                    fillColor: Color.fromRGBO(176, 202, 51, 0.75),
                                    prefixIcon: Icon(
                                        Icons.lock
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)
                                        )
                                    ),
                                    labelText: 'Contraseña',
                                )
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        ElevatedButton(
                            onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: const Text('Terminos y condiciones'),
                                            backgroundColor: const Color.fromRGBO(226, 232, 170, 1),
                                            content: const SingleChildScrollView(
                                                child: Text('1. Aceptación de los Términos: Al descargar o utilizar nuestra aplicación, usted acepta estar legalmente '
                                                'vinculado por estos términos y condiciones, que entrarán en vigor inmediatamente. Si no está de acuerdo con estos términos, '
                                                'no debe acceder ni utilizar nuestros servicios.\n'
                                                '2. Descripción del Servicio: Nuestra aplicación proporciona un servicio de reserva en línea que permite a los usuarios '
                                                'reservar canchas de tenis en nuestras instalaciones. El servicio incluye la selección de la fecha y hora de '
                                                'la reserva, el pago y la confirmación de la misma.\n'
                                                '3. Registro y Cuenta: Para utilizar el servicio, debe registrarse y crear una cuenta personal. Se compromete a proporcionar '
                                                'información veraz y completa durante el proceso de registro y a mantener esa información actualizada.\n'
                                                '4. Reservas: Las reservas se realizan a través de la aplicación y están sujetas a disponibilidad. Se espera que los usuarios '
                                                'lleguen a tiempo y utilicen la cancha solo durante el período reservado.\n'
                                                '5. Pagos: El pago se realizará a través de la aplicación utilizando los métodos de pago aceptados. Todas las transacciones son '
                                                'finales y no reembolsables, salvo en circunstancias excepcionales a discreción de la empresa.\n'
                                                '6. Uso de las Instalaciones: Los usuarios deben cumplir con las normas de conducta y vestimenta adecuadas para el uso de las '
                                                'instalaciones. La empresa se reserva el derecho de negar el acceso a cualquier usuario que no cumpla con estas normas.\n'
                                                '7. Limitación de Responsabilidad: La empresa no será responsable de ningún daño, robo o pérdida que pueda sufrir como resultado del '
                                                'uso de la aplicación o de las instalaciones, salvo en casos de negligencia comprobada por parte de la empresa.\n'
                                                '9. Derechos de Propiedad Intelectual: Todos los derechos de propiedad intelectual relacionados con la aplicación y su contenido '
                                                'son propiedad de la empresa o de sus licenciantes y están protegidos por las leyes de propiedad intelectual.\n'
                                                '10. Modificaciones a los Términos: La empresa se reserva el derecho de modificar estos términos y condiciones en cualquier momento. '
                                                'Las modificaciones entrarán en vigor una vez publicadas en la aplicación o en el sitio web.\n')
                                            ),
                                            actions: <Widget>[
                                                TextButton(
                                                    child: const Text(
                                                        'Declinar',
                                                        style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                                                    ),
                                                    onPressed: () {
                                                        Navigator.of(context).pop();
                                                    }
                                                ),
                                                TextButton(
                                                    child: const Text(
                                                        'Aceptar',
                                                        style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                                                    ),
                                                    onPressed: () {
                                                        acceptTermsAndCons = true;
                                                        Navigator.of(context).pop();
                                                    }
                                                )
                                            ]
                                        );
                                    }
                                );
                            },
                            style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                            ),
                            child: const Text('Aceptar terminos y condiciones')
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                if (acceptTermsAndCons) {
                                    if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text('Creando nuevo usuario...'),
                                                duration: Duration(seconds: 10)
                                            )
                                        );
                                    }
                                    final Map<String, dynamic> response = await httpHelper.register(nameController.text, lastNameController.text, usernameController.text, passwordController.text);
                                    if (context.mounted) {
                                        ScaffoldMessenger.of(context).clearSnackBars();
                                        if (response['status'] == 'error') {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(response['message']),
                                                    duration: const Duration(seconds: 3)
                                                )
                                            );
                                        } else {
                                            Navigator.pop(context);
                                        }
                                    }
                                } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Acepta los terminos y condiciones'),
                                            duration: Duration(seconds: 3)
                                        )
                                    );
                                }
                            },
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                            ),
                            child: const Text('Guardar usuario')
                        )
                    ]
                )
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    Navigator.pop(context);
                },
                backgroundColor: const Color.fromRGBO(176, 202, 51, 1),
                foregroundColor: const Color.fromRGBO(10, 36, 63, 1),
                child: const Icon(Icons.arrow_back)
            )
        );
    }
}