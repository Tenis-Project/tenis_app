import 'package:flutter/material.dart';
import 'package:tenis_app/data/models/tenis_class.dart';
import 'package:tenis_app/data/models/user.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/reservations.dart';

class CreateReservation extends StatefulWidget {
    const CreateReservation({super.key, required this.tenisClass});
    final TenisClass tenisClass;

    @override
    State<CreateReservation> createState() => _CreateReservationState();
}

class _CreateReservationState extends State<CreateReservation> {
    HttpHelper? httpHelper;
    User? user;
    DateTime? selectedDate;
    String? selectedTime;
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
                                                    onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => const Reservations()
                                                            )
                                                        );
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