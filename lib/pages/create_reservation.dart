import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tenis_app/data/models/grouped_reservation.dart';
import 'package:tenis_app/data/models/tenis_class.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/class_packages.dart';
import 'package:tenis_app/pages/home_user.dart';
import 'package:tenis_app/pages/reservations.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CreateReservation extends StatefulWidget {
    const CreateReservation({super.key, required this.tenisClass, required this.classPackage});
    final TenisClass tenisClass;
    final String classPackage;

    @override
    State<CreateReservation> createState() => _CreateReservationState();
}

class _CreateReservationState extends State<CreateReservation> {
    late HttpHelper httpHelper;
    late io.Socket socket;

    late Map<String, dynamic> reservationsResponse;
    late List<GroupedReservation> reservationsGroupedHours;

    late bool reservationsExist;
    late bool isIndividualClass;
    late DateTime selectedDate;
    late String selectedTime;
    late List<String> hours;

    Future initialize() async {
        isIndividualClass = widget.tenisClass.name == 'Alquiler Individual';
        selectedDate = DateTime.now();
        selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        if (widget.tenisClass.time == 'Dia') {
            hours = [
                '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', 
                '15:00', '16:00', '17:00',
            ];
            selectedTime = '06:00';
        } else {
            hours = [
                '18:00', '19:00', '20:00', '21:00', '22:00'
            ];
            selectedTime = '18:00';
        }
    }

    Future<void> getAvailability() async {
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Obteniendo Disponibilidad de reservas...'),
                    duration: Duration(minutes: 1),
                ),
            );
        }
        reservationsResponse = await httpHelper.getAllReservationsHourSpaces(selectedDate.toIso8601String());
        if (context.mounted) {
            if (reservationsResponse['status'] == 'error') {
                ScaffoldMessenger.of(context).clearSnackBars();
                setState(() {
                    reservationsExist = false;
                });
                if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(reservationsResponse['message']),
                            duration: const Duration(seconds: 3),
                        ),
                    );
                }
            } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                final List reservationsMap = reservationsResponse['groupedReservations'];
                reservationsGroupedHours = reservationsMap.map((reservationJson) => GroupedReservation.fromJson(reservationJson)).toList();
                setState(() {
                    reservationsExist = true;
                });
            }
        }
    }

    @override
    void initState(){
        httpHelper = HttpHelper();
        super.initState();
        String dev = 'https://tenis-back-dev-dasc.2.us-1.fl0.io';
        socket = io.io(dev, <String, dynamic>{
            'transports': ['websocket'],
            'force new connection': true
        });
        socket.onConnect((_) {
            print('Connect create');
        });
        socket.connect();
        initialize();
    }

    @override
    void dispose() {
        socket.dispose();
        super.dispose();
        print("Bye create");
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
                    children: widget.classPackage != 'no' ? [
                        Text('Estas creando una reserva para: ${widget.tenisClass.name}'), 
                        Text('Turno: ${widget.tenisClass.time}'),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                            data: ThemeData.light().copyWith(
                                                colorScheme: const ColorScheme.light(primary:Color.fromRGBO(176, 202, 51, 1)),
                                            ),
                                            child: child!,
                                        );
                                    },
                                );
                                if (pickedDate != null && pickedDate != selectedDate) {
                                    setState(() {
                                        selectedDate = pickedDate;
                                    });
                                }
                            },
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            child: const Text('Seleccionar Fecha'),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(),
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
                                                title: const Text('Reservas actuales'),
                                                backgroundColor: const Color.fromRGBO(226, 232, 170, 1),
                                                content: SingleChildScrollView(
                                                    child: reservationsExist ? Column(
                                                        children: reservationsGroupedHours.map((reservationHour) {
                                                            return Text('${reservationHour.hour} - ${reservationHour.spacesAvailable}/4');
                                                        }).toList(),
                                                    ) : const Text('Horarios libres'),
                                                ),
                                                actions: <Widget>[
                                                    TextButton(
                                                        child: const Text(
                                                            'Cerrar',
                                                            style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                                                        ),
                                                        onPressed: () {
                                                            Navigator.of(context).pop();
                                                        },
                                                    ),
                                                ],
                                            );
                                        },
                                    );
                                }
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                            ),
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
                            }).toList(),
                        ),
                        ElevatedButton(
                            onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: const Text('Confirmación'),
                                            backgroundColor: const Color.fromRGBO(226, 232, 170, 1),
                                            content: SingleChildScrollView(
                                                child: ListBody(
                                                    children: [
                                                        const Text('¿Estás seguro que quieres reservar en esta fecha y hora?'),
                                                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                                                        Text('Hora: $selectedTime'),
                                                    ],
                                                ),
                                            ),
                                            actions: <Widget>[
                                                TextButton(
                                                    child: const Text(
                                                            'Cancelar',
                                                            style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                                                        ),
                                                    onPressed: () {
                                                        Navigator.of(context).pop();
                                                    },
                                                ),
                                                TextButton(
                                                    child: const Text(
                                                            'Confirmar',
                                                            style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                                                        ),
                                                    onPressed: () async {
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                    content: Text('Creando reserva...'),
                                                                    duration: Duration(minutes: 1),
                                                                ),
                                                            );
                                                        }
                                                        final Map<String, dynamic> response = await httpHelper.createReservationClassPackage(selectedDate.toIso8601String(), selectedTime, widget.tenisClass.id, widget.classPackage);
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).clearSnackBars();
                                                            if (response['status'] == 'error') {
                                                                Navigator.of(context).pop();
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                        content: Text(response['message']),
                                                                        duration: const Duration(seconds: 3),
                                                                    ),
                                                                );
                                                            } else {
                                                                socket.emit('createdReservation', { 'date': selectedDate.toIso8601String(), 'typeEvent': 'Create' });
                                                                Navigator.of(context).pop();
                                                                Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => const HomeUser(),
                                                                    ),
                                                                    (route) => false,
                                                                );
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => Reservations(userId: response['reservation']['user'], date: selectedDate,),
                                                                    ),
                                                                );
                                                            }
                                                        }
                                                    },
                                                ),
                                            ],
                                        );
                                    },
                                );
                            },
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            child: const Text('Guardar reserva'),
                        ),
                    ] : isIndividualClass ? [
                        Text('Estas creando una reserva para: ${widget.tenisClass.name}'), 
                        Text('Turno: ${widget.tenisClass.time}'),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                            data: ThemeData.light().copyWith(
                                                colorScheme: const ColorScheme.light(primary:Color.fromRGBO(176, 202, 51, 1)),
                                            ),
                                            child: child!,
                                        );
                                    },
                                );
                                if (pickedDate != null && pickedDate != selectedDate) {
                                    setState(() {
                                        selectedDate = pickedDate;
                                    });
                                }
                            },
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            child: const Text('Seleccionar Fecha'),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(),
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
                                                title: const Text('Reservas actuales'),
                                                backgroundColor: const Color.fromRGBO(226, 232, 170, 1),
                                                content: SingleChildScrollView(
                                                    child: reservationsExist ? Column(
                                                        children: reservationsGroupedHours.map((reservationHour) {
                                                            return Text('${reservationHour.hour} - ${reservationHour.spacesAvailable}/4');
                                                        }).toList(),
                                                    ) : const Text('Horarios libres'),
                                                ),
                                                actions: <Widget>[
                                                    TextButton(
                                                        child: const Text(
                                                            'Cerrar',
                                                            style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                                                        ),
                                                        onPressed: () {
                                                            Navigator.of(context).pop();
                                                        },
                                                    ),
                                                ],
                                            );
                                        },
                                    );
                                }
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                            ),
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
                            }).toList(),
                        ),
                        ElevatedButton(
                            onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: const Text('Confirmación'),
                                            backgroundColor: const Color.fromRGBO(226, 232, 170, 1),
                                            content: SingleChildScrollView(
                                                child: ListBody(
                                                    children: [
                                                        const Text('¿Estás seguro que quieres reservar en esta fecha y hora?'),
                                                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                                                        Text('Hora: $selectedTime'),
                                                        Text('Recuerda realizar el pago de S/.${widget.tenisClass.price} que tu reserva pase a: "Aprobada"'),
                                                    ],
                                                ),
                                            ),
                                            actions: <Widget>[
                                                TextButton(
                                                    child: const Text(
                                                            'Cancelar',
                                                            style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                                                        ),
                                                    onPressed: () {
                                                        Navigator.of(context).pop();
                                                    },
                                                ),
                                                TextButton(
                                                    child: const Text(
                                                            'Confirmar',
                                                            style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                                                        ),
                                                    onPressed: () async {
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                    content: Text('Creando reserva...'),
                                                                    duration: Duration(minutes: 1),
                                                                ),
                                                            );
                                                        }
                                                        final Map<String, dynamic> response = await httpHelper.createReservation(selectedDate.toIso8601String(), selectedTime, widget.tenisClass.id);
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).clearSnackBars();
                                                            if (response['status'] == 'error') {
                                                                Navigator.of(context).pop();
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                        content: Text(response['message']),
                                                                        duration: const Duration(seconds: 3),
                                                                    ),
                                                                );
                                                            } else {
                                                                socket.emit('createdReservation', { 'date': selectedDate.toIso8601String(), 'typeEvent': 'Create'});
                                                                Navigator.of(context).pop();
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => Reservations(userId: response['reservation']['user'], date: selectedDate,),
                                                                    ),
                                                                );
                                                            }
                                                        }
                                                    },
                                                ),
                                            ],
                                        );
                                    },
                                );
                            },
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            child: const Text('Guardar reserva'),
                        ),
                    ] : [
                        Text('Estas comprando: ${widget.tenisClass.name}'), 
                        Text('Turno: ${widget.tenisClass.time}'),
                        Text('Recuerde realizar el pago de: S/.${widget.tenisClass.price}'),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Creando reserva...'),
                                            duration: Duration(minutes: 1),
                                        ),
                                    );
                                }
                                final Map<String, dynamic> response = await httpHelper.createClassPackage(widget.tenisClass.id);
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    if (response['status'] == 'error') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(response['message']),
                                                duration: const Duration(seconds: 3),
                                            ),
                                        );
                                    } else {
                                        socket.emit('createdClassPackage');
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ClassPackages(userId: response['classPackage']['user'],),
                                            ),
                                        );
                                    }
                                }
                            },
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            child: const Text('Guardar reserva'),
                        ),
                    ],
                ),
            ),
        );
    }
}