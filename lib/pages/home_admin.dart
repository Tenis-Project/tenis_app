import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/data/models/reservation.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/class_packages_requests.dart';
import 'package:tenis_app/pages/start.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class HomeAdmin extends StatefulWidget {
    const HomeAdmin({super.key});

    @override
    State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
    late SharedPreferences _prefs;
    late HttpHelper httpHelper;
    late io.Socket socket;

    late Map<String, dynamic> reservationsResponse;
    List<Reservation>? reservations;
    
    late DateTime date;
    bool loading = true;
    late bool reservationsExist;

    Future initialize() async {
        _prefs = await SharedPreferences.getInstance();
        date = DateTime.now();
        date = DateTime(date.year, date.month, date.day);
        refreshDate();
    }

    Future<void> refreshDate() async {
        if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
        }
        reservationsResponse = await httpHelper.getAllReservations(date.toIso8601String());
        if (reservationsResponse['status'] == 'error') {
            if (!mounted) return;
            setState(() {
                loading = false;
                reservationsExist = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(reservationsResponse['message']),
                    duration: const Duration(seconds: 3)
                )
            );
        } else {
            final List reservationsMap = reservationsResponse['reservations'];
            reservations = reservationsMap.map((reservationJson) => Reservation.fromJson(reservationJson)).toList();
            setState(() {
                loading = false;
                reservationsExist = true;
            });
        }
    }

    Future<void> _enviarRequest(String type, String date, String id) async {
        if (type == 'Aprobado') {
            socket.emit('updatedReservation', { 'date': date, 'user': id});
        } else {
            socket.emit('deletedReservation', { 'date': date, 'user': id});
        }
    }

    @override
    void initState(){
        httpHelper = HttpHelper();
        super.initState();
        initialize();
        String dev = 'http://51.44.59.254:3001';
        socket = io.io(dev, <String, dynamic>{
            'transports': ['websocket'],
            'force new connection': true
        });
        socket.on('updateReservationInUserView', (arg) {
            DateTime dateShow = DateTime.parse(arg['date'].toString());
            String message = '';
            if (arg['typeEvent'] == 'Create') {
                dateShow = DateTime(dateShow.year, dateShow.month, dateShow.day);
                message = 'Se ha creado una nueva reserva el ${DateFormat('dd/MM/yyyy').format(dateShow)}';
            } else {
                dateShow = DateTime(dateShow.year, dateShow.month, dateShow.day);
                message = 'Se ha eliminado una reserva el ${DateFormat('dd/MM/yyyy').format(dateShow)}';
            }
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 3)
                    )
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
                title: loading ? const LinearProgressIndicator() : const Text("Bienvenido Administrador")
            ),
            body: Center(
                child: loading ? const CircularProgressIndicator() : SingleChildScrollView(
                    child: reservationsExist ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            SizedBox(
                                width: size.width * 0.80,
                                child: ElevatedButton(
                                    onPressed: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const ClassPackageRequests()
                                            )
                                        );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                        foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                                    ),
                                    child: const Text('Ver solicitudes de paquete de reserva')
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container()
                            ),
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
                                        icon: const Icon(Icons.arrow_back)
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
                                                            colorScheme: const ColorScheme.light(primary:Color.fromRGBO(176, 202, 51, 1))
                                                        ),
                                                        child: child!
                                                    );
                                                }
                                            );
                                            if (pickedDate != null && pickedDate != date) {
                                                setState(() {
                                                    date = pickedDate;
                                                    loading = true;
                                                });
                                                refreshDate();
                                            }
                                        },
                                        child: Text(DateFormat('dd/MM/yyyy').format(date))
                                    ),
                                    IconButton(
                                        onPressed: () {
                                            setState(() {
                                                date = date.add(const Duration(days: 1));
                                                loading = true;
                                            });
                                            refreshDate();
                                        },
                                        icon: const Icon(Icons.arrow_forward)
                                    )
                                ]
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reservations?.length,
                                itemBuilder: (context, index) {
                                    return ReservationAdminItem(reservation: reservations![index], onBotonPresionado: (type, date, id)  => _enviarRequest(type, date, id));
                                }
                            )
                        ]
                    ) : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            SizedBox(
                                width: size.width * 0.80,
                                child: ElevatedButton(
                                    onPressed: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const ClassPackageRequests()
                                            )
                                        );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(176, 202, 51, 1)),
                                        foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                                    ),
                                    child: const Text('Ver solicitudes de paquetes de reserva')
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container()
                            ),
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
                                        icon: const Icon(Icons.arrow_back)
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                            final DateTime? pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate: date,
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
                                            if (pickedDate != null && pickedDate != date) {
                                                setState(() {
                                                    date = pickedDate;
                                                    loading = true;
                                                });
                                                refreshDate();
                                            }
                                        },
                                        child: Text(DateFormat('dd/MM/yyyy').format(date))
                                    ),
                                    IconButton(
                                        onPressed: () {
                                            setState(() {
                                                date = date.add(const Duration(days: 1));
                                                loading = true;
                                            });
                                            refreshDate();
                                        }, 
                                        icon: const Icon(Icons.arrow_forward)
                                    )
                                ]
                            ),
                            const Text("No cuentas con reservaciones aun")
                        ]
                    )
                ) 
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
                    await _prefs.remove('token');
                },
                child: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white
                )
            )
        );
    }
}

class ReservationAdminItem extends StatefulWidget {
    const ReservationAdminItem({super.key, required this.reservation, required this.onBotonPresionado});
    final Reservation reservation;
    final Function(String, String, String) onBotonPresionado;

    @override
    State<ReservationAdminItem> createState() => _ReservationAdminItemState();
}

class _ReservationAdminItemState extends State<ReservationAdminItem> {
    late HttpHelper httpHelper;
    late bool buttonEnabled;

    @override
    void initState(){
        httpHelper = HttpHelper();
        super.initState();
        buttonEnabled = widget.reservation.status == 'Pendiente';
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
                                '${widget.reservation.tenisClass.name} - ${widget.reservation.user.name} ${widget.reservation.user.lastName}',
                                style: const TextStyle(color: Color.fromRGBO(10, 36, 63, 1))
                            ),
                            subtitle: Text(
                                widget.reservation.price == 0 ? widget.reservation.tenisClass.time : '${widget.reservation.tenisClass.time} - S/.${widget.reservation.price}',
                                style: TextStyle(color: const Color.fromRGBO(10, 36, 63, 1).withOpacity(0.75))
                            )
                        ),
                        Text(
                            widget.reservation.note != "" ? 
                            '${widget.reservation.hour} - ${widget.reservation.status} - Nota: ${widget.reservation.note}' :
                            '${widget.reservation.hour} - ${widget.reservation.status}',
                            style: TextStyle(color: const Color.fromRGBO(10, 36, 63, 1).withOpacity(0.75))
                        ),
                        ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                                ElevatedButton(
                                    onPressed: buttonEnabled ? () async {
                                        if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Actualizando reserva...'),
                                                    duration: Duration(seconds: 10)
                                                )
                                            );
                                        }
                                        final Map<String, dynamic> response = await httpHelper.updateReservation(widget.reservation.id, 'Aprobado');
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
                                                widget.onBotonPresionado('Aprobado', widget.reservation.date.toIso8601String(), widget.reservation.user.id);
                                                setState(() {
                                                    widget.reservation.status = 'Aprobado';
                                                    buttonEnabled = false;
                                                });
                                            }
                                        }
                                    } : null,
                                    style: ButtonStyle(
                                        foregroundColor: WidgetStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(176, 202, 51, 1) : const Color.fromRGBO(176, 202, 51, 0.5)),
                                        backgroundColor: WidgetStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(10, 36, 63, 1) : const Color.fromRGBO(10, 36, 63, 0.5))
                                    ),
                                    child: const Text('Confirmar')
                                ),
                                ElevatedButton(
                                    onPressed: buttonEnabled ? () async {
                                        if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Actualizando reserva...'),
                                                    duration: Duration(seconds: 10)
                                                )
                                            );
                                        }
                                        final Map<String, dynamic> response = await httpHelper.deleteReservation(widget.reservation.id);
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
                                                widget.onBotonPresionado('Cancelado', widget.reservation.date.toIso8601String(), widget.reservation.user.id);
                                                setState(() {
                                                    widget.reservation.status = 'Cancelado';
                                                    buttonEnabled = false;
                                                });
                                            }
                                        }
                                    } : null,
                                    style: ButtonStyle(
                                        foregroundColor: WidgetStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(176, 202, 51, 1) : const Color.fromRGBO(176, 202, 51, 0.5)),
                                        backgroundColor: WidgetStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(10, 36, 63, 1) : const Color.fromRGBO(10, 36, 63, 0.5))
                                    ),
                                    child: const Text('Cancelar')
                                )
                            ]
                        )
                    ]
                )
            )
        );
    }
}