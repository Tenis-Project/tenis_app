import 'package:flutter/material.dart';
import 'package:tenis_app/data/models/tenis_class.dart';
import 'package:tenis_app/data/models/user.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/reservations.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CreateReservation extends StatefulWidget {
    const CreateReservation({super.key, required this.tenisClass});
    final TenisClass tenisClass;

    @override
    State<CreateReservation> createState() => _CreateReservationState();
}

class _CreateReservationState extends State<CreateReservation> {
    late HttpHelper httpHelper;
    late io.Socket socket;

    User? user;
    late DateTime selectedDate;
    late String selectedTime;
    final List<String> hours = [
        '08:00 AM',
        '09:00 AM',
        '10:00 AM'
    ];

    Future initialize() async {
        selectedDate = DateTime.now();
        selectedTime = '08:00 AM';
    }

    @override
    void initState(){
        httpHelper = HttpHelper();
        socket = io.io('http://localhost:3000/', <String, dynamic>{
            'transports': ['websocket'],
        });
        socket.on('connect', (_) {
            print('Conectado al servidor de sockets');
        });
        initialize();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Crear reserva'),
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text('Estas creando una reserva para: ${widget.tenisClass.name}'), 
                        Text('Turno: ${widget.tenisClass.time}'),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                );
                                if (pickedDate != null && pickedDate != selectedDate) {
                                    setState(() {
                                        selectedDate = pickedDate;
                                    });
                                }
                            },
                            child: const Text('Seleccionar Fecha'),
                        ),
                        DropdownButton(
                            value: selectedTime,
                            onChanged: (String? newValue) {
                                setState(() {
                                    selectedTime = newValue!;
                                });
                            },
                            items: hours.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                );
                            }).toList()
                        ),
                        ElevatedButton(
                            onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: const Text('Confirmación'),
                                            content: const SingleChildScrollView(
                                                child: ListBody(
                                                    children: [
                                                        Text('¿Estás seguro que quieres reservar en estas horas?'),
                                                    ],
                                                ),
                                            ),
                                            actions: <Widget>[
                                                TextButton(
                                                    child: const Text('Cancelar'),
                                                    onPressed: () {
                                                        Navigator.of(context).pop();
                                                    },
                                                ),
                                                TextButton(
                                                    child: const Text('Confirmar'),
                                                    onPressed: () async {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                                content: Text('Creando reserva...'),
                                                                duration: Duration(minutes: 1),
                                                            )
                                                        );
                                                        final Map<String, dynamic> response = await httpHelper.createReservation(selectedDate.toIso8601String(), selectedTime, widget.tenisClass.id);
                                                        socket.emit('createdReservation');
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
                                                                Navigator.of(context).pop();
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => const Reservations()
                                                                    )
                                                                );
                                                            }
                                                            
                                                        }
                                                    },
                                                ),
                                            ]
                                        );
                                    },
                                );
                            },
                            child: const Text('Guardar reserva'),
                        ),
                    ],
                ),
            )
        );
    }
}