import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/pages/start.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class HomeAdmin extends StatefulWidget {
    const HomeAdmin({super.key});

    @override
    State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    late io.Socket socket;

    @override
    void initState(){
        socket = io.io('http://localhost:3000/', <String, dynamic>{
            'transports': ['websocket'],
        });
        socket.on('connect', (_) {
            print('Conectado al servidor de sockets');
        });
        socket.on('createdReservationInUserView', (_) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Se ha creado una nueva reserva'),
                    duration: Duration(seconds: 3)
                )
            );
        });
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text('Bienvenido Administrador'),
                    ],
                ),
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () async {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Start()
                        )
                    );
                    final SharedPreferences prefs = await _prefs;
                    await prefs.remove('token');
                },
                child: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                ),
            ),
        );
    }
}