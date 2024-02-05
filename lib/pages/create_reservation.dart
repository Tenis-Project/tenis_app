import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    late bool reservationsExist;

    User? user;
    late DateTime selectedDate;
    late String selectedTime;
    late List<String> hours;

    late Map<String, dynamic> reservationsResponse;
    late List<String> reservationsHours;

    Future initialize() async {
        selectedDate = DateTime.now();
        selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        if (widget.tenisClass.time == 'Dia') {
            hours = [
                '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM', '12:00 AM', '01:00 PM', '02:00 PM', 
                '03:00 PM', '04:00 PM', '05:00 PM',
            ];
            selectedTime = '06:00 AM';
        } else {
            hours = [
                '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM', '10:00 PM'
            ];
            selectedTime = '06:00 PM';
        }
    }

    Future<void> getAvailability() async {
        reservationsResponse = await httpHelper.getAllReservationsHours(selectedDate.toIso8601String());
        if (reservationsResponse['status'] == 'error') {
            setState(() {
                reservationsExist = false;
            });
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(reservationsResponse['message']),
                        duration: const Duration(seconds: 3)
                    )
                );
            }
        } else {
            final List reservationsMap = reservationsResponse['uniqueReservationHours'];
            reservationsHours = reservationsMap.map((reservationJson) => reservationJson.toString()).toList();
            setState(() {
                reservationsExist = true;
            });
        }
    }

    @override
    void initState(){
        httpHelper = HttpHelper();
        socket = io.io('http://localhost:3000/', <String, dynamic>{
            'transports': ['websocket'],
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
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                await getAvailability();
                                if (context.mounted) {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: const Text('Disponibilidad de reserva'),
                                                content: SingleChildScrollView(
                                                    child: reservationsExist ? Column(
                                                        children: reservationsHours.map((reservationHour) {
                                                            return Text(reservationHour);
                                                        }).toList(),
                                                    ) : const Text('Horarios libres'),
                                                ),
                                                actions: <Widget>[
                                                    TextButton(
                                                        child: const Text('Cancelar'),
                                                        onPressed: () {
                                                            Navigator.of(context).pop();
                                                        },
                                                    ),
                                                ]
                                            );
                                        },
                                    );
                                }
                            },
                            child: const Text('Ver disponibilidad'),
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
                                            content: SingleChildScrollView(
                                                child: ListBody(
                                                    children: [
                                                        const Text('¿Estás seguro que quieres reservar en esta fecha y hora?'),
                                                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                                                        Text('Horaa: $selectedTime')
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
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).clearSnackBars();
                                                            if (response['status'] == 'error') {
                                                                Navigator.of(context).pop();
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                        content: Text(response['message']),
                                                                        duration: const Duration(seconds: 3),
                                                                    )
                                                                );
                                                            } else {
                                                                socket.emit('createdReservation', DateFormat('dd/MM/yyyy').format(selectedDate));
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