import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    final TextEditingController noteController = TextEditingController();

    late Map<String, dynamic> reservationsResponse;
    late List<GroupedReservation> reservationsGroupedHours;

    late bool reservationsExist;
    late bool isIndividualClass;
    late DateTime selectedDate;
    late String selectedTime;
    late List<String> hours;
    late List<String> notPrimeHours;

    int price = 0;

    Future initialize() async {
        isIndividualClass = true;
        //isIndividualClass = widget.tenisClass.name == 'Alquiler de cancha';
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
        notPrimeHours = [
            '11:00', '12:00', '13:00', '14:00', '15:00'
        ];
    }

    Future<void> getAvailability() async {
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Obteniendo Disponibilidad de reservas...'),
                    duration: Duration(seconds: 10),
                ),
            );
        }
        reservationsResponse = await httpHelper.getAllReservationsHourSpaces(selectedDate.toIso8601String());
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        if (reservationsResponse['status'] == 'error') {
            setState(() {
                reservationsExist = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(reservationsResponse['message']),
                    duration: const Duration(seconds: 3),
                ),
            );
        } else {
            final List reservationsMap = reservationsResponse['groupedReservations'];
            reservationsGroupedHours = reservationsMap.map((reservationJson) => GroupedReservation.fromJson(reservationJson)).toList();
            setState(() {
                reservationsExist = true;
            });
        }
    }

    @override
    void initState(){
        httpHelper = HttpHelper();
        super.initState();
        String dev = 'http://51.44.59.254:3001';
        socket = io.io(dev, <String, dynamic>{
            'transports': ['websocket'],
            'force new connection': true
        });
        socket.connect();
        initialize();
    }

    @override
    void dispose() {
        socket.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final size = MediaQuery.of(context).size;

        return Scaffold(
            appBar: AppBar(
                title: const Text('Crear reserva'),
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //Proviene de paquete de clases
                    children: widget.classPackage != 'no' ? [
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
                                    builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                            data: ThemeData.light().copyWith(
                                                colorScheme: const ColorScheme.light(primary:Color.fromRGBO(176, 202, 51, 1))
                                            ),
                                            child: child!
                                        );
                                    }
                                );
                                if (pickedDate != null && pickedDate != selectedDate) {
                                    setState(() {
                                        selectedDate = pickedDate;
                                    });
                                }
                            },
                            style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                            ),
                            child: const Text('Seleccionar Fecha')
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
                                                title: const Text('Reservas actuales'),
                                                backgroundColor: const Color.fromRGBO(226, 232, 170, 1),
                                                content: SingleChildScrollView(
                                                    child: reservationsExist ? Column(
                                                        children: reservationsGroupedHours.map((reservationHour) {
                                                            return Text('${reservationHour.hour} - ${reservationHour.spacesAvailable}/4');
                                                        }).toList()
                                                    ) : const Text('Todos los horarios están disponibles')
                                                ),
                                                actions: <Widget>[
                                                    TextButton(
                                                        child: const Text(
                                                            'Cerrar',
                                                            style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                                                        ),
                                                        onPressed: () {
                                                            Navigator.of(context).pop();
                                                        }
                                                    )
                                                ]
                                            );
                                        }
                                    );
                                }
                            },
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                            ),
                            child: const Text('Ver disponibilidad')
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
                                    child: Text(value)
                                );
                            }).toList()
                        ),
                        SizedBox(
                            width: size.width * 0.50,
                            child: TextField(
                                controller: noteController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    filled: true,
                                    fillColor: Color.fromRGBO(176, 202, 51, 0.75),
                                    prefixIcon: Icon(
                                        Icons.book
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)
                                        )
                                    ),
                                    labelText: 'Ingrese una nota (Opcional)'
                                )
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container()
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
                                                        Text('Hora: $selectedTime')
                                                    ]
                                                )
                                            ),
                                            actions: <Widget>[
                                                TextButton(
                                                    child: const Text(
                                                        'Cancelar',
                                                        style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                                                    ),
                                                    onPressed: () {
                                                        Navigator.of(context).pop();
                                                    }
                                                ),
                                                TextButton(
                                                    child: const Text(
                                                        'Confirmar',
                                                        style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                                                    ),
                                                    onPressed: () async {
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                    content: Text('Creando reserva...'),
                                                                    duration: Duration(seconds: 10)
                                                                )
                                                            );
                                                        }
                                                        final Map<String, dynamic> response = await httpHelper.createReservationClassPackage(selectedDate.toIso8601String(), selectedTime, widget.tenisClass.id, widget.classPackage, noteController.text);
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).clearSnackBars();
                                                            if (response['status'] == 'error') {
                                                                Navigator.of(context).pop();
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                        content: Text(response['message']),
                                                                        duration: const Duration(seconds: 3)
                                                                    )
                                                                );
                                                            } else {
                                                                socket.emit('createdReservation', { 'date': selectedDate.toIso8601String(), 'typeEvent': 'Create' });
                                                                Navigator.of(context).pop();
                                                                Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => const HomeUser(guest: false)
                                                                    ),
                                                                    (route) => false
                                                                );
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => Reservations(userId: response['reservation']['user'], date: selectedDate)
                                                                    )
                                                                );
                                                            }
                                                        }
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
                            child: const Text('Guardar reserva')
                        )
                    //Clase individual de toda la vida
                    ] : isIndividualClass ? [
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
                                    builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                            data: ThemeData.light().copyWith(
                                                colorScheme: const ColorScheme.light(primary:Color.fromRGBO(176, 202, 51, 1))
                                            ),
                                            child: child!
                                        );
                                    }
                                );
                                if (pickedDate != null && pickedDate != selectedDate) {
                                    setState(() {
                                        selectedDate = pickedDate;
                                    });
                                }
                            },
                            style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                            ),
                            child: const Text('Seleccionar Fecha')
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
                                                title: const Text('Reservas actuales'),
                                                backgroundColor: const Color.fromRGBO(226, 232, 170, 1),
                                                content: SingleChildScrollView(
                                                    child: reservationsExist ? Column(
                                                        children: reservationsGroupedHours.map((reservationHour) {
                                                            return Text('${reservationHour.hour} - ${reservationHour.spacesAvailable}/4');
                                                        }).toList()
                                                    ) : const Text('Todos los horarios están disponibles')
                                                ),
                                                actions: <Widget>[
                                                    TextButton(
                                                        child: const Text(
                                                            'Cerrar',
                                                            style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                                                        ),
                                                        onPressed: () {
                                                            Navigator.of(context).pop();
                                                        }
                                                    )
                                                ]
                                            );
                                        }
                                    );
                                }
                            },
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                            ),
                            child: const Text('Ver disponibilidad')
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
                                    child: Text(value)
                                );
                            }).toList()
                        ),
                        SizedBox(
                            width: size.width * 0.50,
                            child: TextField(
                                controller: noteController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    filled: true,
                                    fillColor: Color.fromRGBO(176, 202, 51, 0.75),
                                    prefixIcon: Icon(
                                        Icons.book
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)
                                        )
                                    ),
                                    labelText: 'Ingrese una nota (Opcional)'
                                )
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container()
                        ),
                        ElevatedButton(
                            onPressed: () {
                                String dayOfWeek = DateFormat('EEEE').format(selectedDate);
                                if (widget.tenisClass.name == 'Alquiler de cancha' && widget.tenisClass.time == 'Dia') {
                                    if (notPrimeHours.contains(selectedTime)) {
                                        if (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {
                                            price = 30;
                                        } else {
                                            price = 25;
                                        }
                                    } else {
                                        price = 45;
                                    }
                                } else {
                                    price = widget.tenisClass.price;
                                }
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
                                                        Text('Pago: S/. $price'),
                                                        const Text('Recuerda realizar el pago para que tu reserva pase a: "Aprobada"'),
                                                        const Text('Al Yape o Plin de 940124181'),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                                Clipboard.setData(const ClipboardData(text: "940124181"));
                                                                if (context.mounted) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                        const SnackBar(
                                                                            content: Text('Número copiado'),
                                                                            duration: Duration(seconds: 3)
                                                                        )
                                                                    );
                                                                }
                                                            },
                                                            style: ButtonStyle(
                                                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                                                backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                                                            ),
                                                            child: const Text("Copiar")
                                                        )
                                                    ]
                                                )
                                            ),
                                            actions: <Widget>[
                                                TextButton(
                                                    child: const Text(
                                                        'Cancelar',
                                                        style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                                                    ),
                                                    onPressed: () {
                                                        Navigator.of(context).pop();
                                                    }
                                                ),
                                                TextButton(
                                                    child: const Text(
                                                        'Confirmar',
                                                        style: TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                                                    ),
                                                    onPressed: () async {
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                    content: Text('Creando reserva...'),
                                                                    duration: Duration(seconds: 10)
                                                                )
                                                            );
                                                        }
                                                        final Map<String, dynamic> response = await httpHelper.createReservation(selectedDate.toIso8601String(), selectedTime, widget.tenisClass.id, noteController.text);
                                                        if (context.mounted) {
                                                            ScaffoldMessenger.of(context).clearSnackBars();
                                                            if (response['status'] == 'error') {
                                                                Navigator.of(context).pop();
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                        content: Text(response['message']),
                                                                        duration: const Duration(seconds: 3)
                                                                    )
                                                                );
                                                            } else {
                                                                socket.emit('createdReservation', { 'date': selectedDate.toIso8601String(), 'typeEvent': 'Create'});
                                                                Navigator.of(context).pop();
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => Reservations(userId: response['reservation']['user'], date: selectedDate)
                                                                    )
                                                                );
                                                            }
                                                        }
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
                            child: const Text('Guardar reserva')
                        )
                    //Paquete de clases
                    ] : [
                        Text('Estas comprando: ${widget.tenisClass.name}'), 
                        Text('Turno: ${widget.tenisClass.time}'),
                        Text('Recuerde realizar el pago de: S/.${widget.tenisClass.price}'),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Creando reserva...'),
                                            duration: Duration(seconds: 10)
                                        )
                                    );
                                }
                                final Map<String, dynamic> response = await httpHelper.createClassPackage(widget.tenisClass.id);
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
                                        socket.emit('createdClassPackage');
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ClassPackages(userId: response['classPackage']['user'])
                                            )
                                        );
                                    }
                                }
                            },
                            style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                            ),
                            child: const Text('Guardar reserva')
                        )
                    ]
                )
            )
        );
    }
}