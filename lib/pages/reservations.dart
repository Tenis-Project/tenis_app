import 'package:flutter/material.dart';
import 'package:tenis_app/data/models/reservation.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:url_launcher/url_launcher.dart';

class Reservations extends StatefulWidget {
    const Reservations({super.key, required this.userId, required this.date});
    final String userId;
    final DateTime date;

    @override
    State<Reservations> createState() => _ReservationsState();
}

class _ReservationsState extends State<Reservations> {
    late HttpHelper httpHelper;
    late io.Socket socket;

    late Map<String, dynamic> reservationsResponse;
    List<Reservation>? reservations;

    late DateTime date;
    bool loading = true;
    late bool reservationsExist;

    Future initialize() async {
        date = widget.date;
        refreshDate();
    }

    Future<void> refreshDate() async {
        reservationsResponse = await httpHelper.getMyReservations(date.toIso8601String());
        if (reservationsResponse['status'] == 'error') {
            if (context.mounted) {
                setState(() {
                    loading = false;
                    reservationsExist = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(reservationsResponse['message']),
                        duration: const Duration(seconds: 3),
                    ),
                );
            }
        } else {
            final List reservationsMap = reservationsResponse['reservations'];
            reservations = reservationsMap.map((reservationJson) => Reservation.fromJson(reservationJson)).toList();
            setState(() {
                loading = false;
                reservationsExist = true;
            });
        }
    }

    Future<void> _enviarRequest(String date) async {
        socket.emit('deletedReservationInUserView', { 'date': date, 'typeEvent': 'Delete'});
        Navigator.of(context).pop();
    }

    @override
    void initState() {
        httpHelper = HttpHelper();
        super.initState();
        String dev = 'https://tenis-back.onrender.com';
        socket = io.io(dev, <String, dynamic>{
            'transports': ['websocket'],
            'force new connection': true
        });
        socket.on('updatedReservationInAdminView', (arg) {
            DateTime dateShow = DateTime.parse(arg['date'].toString());
            dateShow = DateTime(dateShow.year, dateShow.month, dateShow.day);
            if (context.mounted && arg['user'] == widget.userId) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Se ha actualizado el estado de una reserva del ${DateFormat('dd/MM/yyyy').format(dateShow)}'),
                        duration: const Duration(seconds: 3),
                    ),
                );
            }
            if (date == dateShow) {
                setState(() {
                    loading = true;
                });
                refreshDate();
            }
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
        return Scaffold(
            appBar: AppBar(
                title: loading ? const LinearProgressIndicator() : const Text("Tus reservas"),
            ),
            body: Center(
                child: loading ? const CircularProgressIndicator() : SingleChildScrollView(
                    child: reservationsExist ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    IconButton(
                                        onPressed: () {
                                            setState(() {
                                                date = date.subtract(const Duration(days: 1));
                                                loading = true;
                                            });
                                            refreshDate();
                                        }, 
                                        icon: const Icon(Icons.arrow_back),
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                            final DateTime? pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate: date,
                                                firstDate: DateTime(2024),
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
                                            if (pickedDate != null && pickedDate != date) {
                                                setState(() {
                                                    date = pickedDate;
                                                    loading = true;
                                                });
                                                refreshDate();
                                            }
                                        },
                                        child: Text(DateFormat('dd/MM/yyyy').format(date)),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                            setState(() {
                                                date = date.add(const Duration(days: 1));
                                                loading = true;
                                            });
                                            refreshDate();
                                        }, 
                                        icon: const Icon(Icons.arrow_forward),
                                    ),
                                ],
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: reservations?.length,
                                itemBuilder: (context, index) {
                                    return ReservationItem(reservation: reservations![index], onBotonPresionado: (date)  => _enviarRequest(date));
                                },
                            ),
                        ],
                    ) : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    IconButton(
                                        onPressed: () {
                                            setState(() {
                                                date = date.subtract(const Duration(days: 1));
                                                loading = true;
                                            });
                                            refreshDate();
                                        }, 
                                        icon: const Icon(Icons.arrow_back),
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                            final DateTime? pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate: date,
                                                firstDate: DateTime(2024),
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
                                            if (pickedDate != null && pickedDate != date) {
                                                setState(() {
                                                    date = pickedDate;
                                                    loading = true;
                                                });
                                                refreshDate();
                                            }
                                        },
                                        child: Text(DateFormat('dd/MM/yyyy').format(date)),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                            setState(() {
                                                date = date.add(const Duration(days: 1));
                                                loading = true;
                                            });
                                            refreshDate();
                                        }, 
                                        icon: const Icon(Icons.arrow_forward),
                                    ),
                                ],
                            ),
                            const Text("No cuentas con reservaciones aun"),
                        ],
                    ),
                ),
            ),
        );
    }
}

class ReservationItem extends StatefulWidget {
    const ReservationItem({super.key, required this.reservation, required this.onBotonPresionado});
    final Reservation reservation;
    final Function(String) onBotonPresionado;

    @override
    State<ReservationItem> createState() => _ReservationItemState();
}

class _ReservationItemState extends State<ReservationItem> {
    late HttpHelper httpHelper;

    bool buttonEnabled = true;

    bool calculateMoreThan24Hours(String hour, DateTime date) {
        DateTime today = DateTime.now();
        today = DateTime(today.year, today.month, today.day);
        Duration difference = date.difference(today);
        int todayHour = DateTime.now().hour;

        if (difference.inDays >= 2) {
            return true;
        } else if (difference.inDays == 0) {
            return false;   
        } else {
            return int.parse(hour.substring(0, 2)) > todayHour;
        }
    }

    @override
    void initState(){
        httpHelper = HttpHelper();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
                clipBehavior: Clip.antiAlias,
                color: const Color.fromRGBO(176, 202, 51, 0.75),
                child: Column(
                    children: [
                        ListTile(
                            leading: widget.reservation.tenisClass.time == 'Dia' ? const Icon(Icons.sunny) : const Icon(Icons.nightlight),
                            title: Text(
                                '${widget.reservation.tenisClass.name} - ${widget.reservation.status}',
                                style: const TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            subtitle: Text(
                                widget.reservation.tenisClass.time,
                                style: TextStyle(color: const Color.fromRGBO(10, 36, 63, 1).withOpacity(0.75)),
                            ),
                        ),
                        Text(
                            widget.reservation.hour,
                            style: TextStyle(color: const Color.fromRGBO(10, 36, 63, 1).withOpacity(0.75)),
                        ),
                        ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                                ElevatedButton(
                                    onPressed: buttonEnabled ? () async {
                                        bool statusApproved = widget.reservation.status == 'Aprobado';

                                        bool moreThan24Hours = calculateMoreThan24Hours(widget.reservation.hour, widget.reservation.date);

                                        List<String> hours = [
                                            '06:00', '07:00', '08:00', '09:00', '10:00', '16:00', '17:00', '18:00', '19:00',
                                            '20:00', '21:00'
                                        ];
                                        bool primeHours = hours.contains(widget.reservation.hour);

                                        String message = statusApproved ?
                                            moreThan24Hours ? 
                                                'Su reserva se encuentra aprobada y esta a más de 24 horas de anticipacion, por lo tanto luego de eliminarla se abrira la aplicacion de WhatsApp para contactar sobre su reprogramacion'
                                            : primeHours ?
                                                'Su reserva se encuentra aprobada, faltan menos de 24 horas de anticipacion y la hora reservada es prime, por lo tanto si decide eliminar la reserva no se le hara la devolucion del dinero'
                                                : 
                                                'Su reserva se encuentra aprobada, faltan menos de 24 horas de anticipacion y la hora reservada no es prime, por lo tanto luego de eliminarla se abrira la aplicacion de WhatsApp para contactar sobre su reprogramacion'
                                        :
                                            'Su reserva se encuentra pendiente, por lo tanto puede cancelarla sin problemas';
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: const Text('Advertencia'),
                                                    content: SingleChildScrollView(
                                                        child: Text(message),
                                                    ),
                                                    actions: <Widget>[
                                                        TextButton(
                                                            child: const Text('Salir'),
                                                            onPressed: () {
                                                                Navigator.of(context).pop();
                                                            },
                                                        ),
                                                        TextButton(
                                                            child: const Text('Eliminar'),
                                                            onPressed: () async {
                                                                if (context.mounted) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                        const SnackBar(
                                                                            content: Text('Cancelando reserva...'),
                                                                            duration: Duration(minutes: 1),
                                                                        ),
                                                                    );
                                                                }
                                                                final Map<String, dynamic> response = await httpHelper.deleteReservation(widget.reservation.id);
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
                                                                        if ((statusApproved && moreThan24Hours) || (statusApproved && !moreThan24Hours && !primeHours)) {
                                                                            String phoneNumber = '51940124181';
                                                                            String message = 'Hola, cancele una reserva que cumple para ser reprogramada. El id es el siguiente: ${widget.reservation.id}';
                                                                            String url = 'https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}';

                                                                            await launchUrl(Uri.parse(url));
                                                                        }

                                                                        widget.onBotonPresionado(widget.reservation.date.toIso8601String());
                                                                        if (context.mounted) {
                                                                            Navigator.of(context).pop();
                                                                        }
                                                                        setState(() {
                                                                            widget.reservation.status = 'Cancelado';
                                                                            buttonEnabled = false;
                                                                        });
                                                                    }
                                                                }
                                                            },
                                                        ),
                                                    ],
                                                );
                                            },
                                        );
                                    } : null,
                                    style: ButtonStyle(
                                        foregroundColor: MaterialStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(176, 202, 51, 1) : const Color.fromRGBO(176, 202, 51, 0.5)),
                                        backgroundColor: MaterialStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(10, 36, 63, 1) : const Color.fromRGBO(10, 36, 63, 0.5)),
                                    ),
                                    child: const Text('Eliminar'),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }
}