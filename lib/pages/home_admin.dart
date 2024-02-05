import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/data/models/reservation.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/start.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class HomeAdmin extends StatefulWidget {
    const HomeAdmin({super.key});

    @override
    State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    late HttpHelper httpHelper;
    late io.Socket socket;
    late DateTime date;

    late Map<String, dynamic> reservationsResponse;
    List<Reservation>? reservations;

    bool loading = true;
    late bool reservationsExist;

    Future initialize() async {
        date = DateTime.now();
        date = DateTime(date.year, date.month, date.day);
        refreshDate();
    }

    Future<void> refreshDate() async {
        reservationsResponse = await httpHelper.getAllReservations(date.toIso8601String());
        if (reservationsResponse['status'] == 'error') {
            if (context.mounted) {
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

    @override
    void initState(){
        httpHelper = HttpHelper();
        socket = io.io('http://localhost:3000/', <String, dynamic>{
            'transports': ['websocket'],
        });
        socket.on('createdReservationInUserView', (arg) {
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Se ha creado una nueva reserva el ${arg.toString()}'),
                        duration: const Duration(seconds: 3)
                    )
                );
            }
            refreshDate();
        });
        initialize();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: loading ? const LinearProgressIndicator() : const Text("Bienvenido Administrador")
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
                                        icon: const Icon(Icons.arrow_back)
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                            final DateTime? pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate: date,
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2100),
                                            );
                                            if (pickedDate != null && pickedDate != date) {
                                                setState(() {
                                                    date = pickedDate;
                                                });
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
                                    ),
                                ],
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: reservations?.length,
                                itemBuilder: (context, index) {
                                    return ReservationAdminItem(reservation: reservations![index]);
                                }
                            )
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
                                        icon: const Icon(Icons.arrow_back)
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                            final DateTime? pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate: date,
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2100),
                                            );
                                            if (pickedDate != null && pickedDate != date) {
                                                setState(() {
                                                    date = pickedDate;
                                                });
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
                                    ),
                                ],
                            ),
                            const Text("No cuentas con reservaciones aun")
                        ],
                    )
                ) 
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () async {
                    socket.disconnect();
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

class ReservationAdminItem extends StatefulWidget {
    const ReservationAdminItem({super.key, required this.reservation});
    final Reservation reservation;

    @override
    State<ReservationAdminItem> createState() => _ReservationAdminItemState();
}

class _ReservationAdminItemState extends State<ReservationAdminItem> {
    @override
    void initState(){
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                    children: [
                        ListTile(
                            leading: widget.reservation.tenisClass.time == 'Dia' ? const Icon(Icons.sunny) : const Icon(Icons.nightlight),
                            title: Text('${widget.reservation.tenisClass.name} - ${widget.reservation.user.name} ${widget.reservation.user.lastName}'),
                            subtitle: Text(
                                widget.reservation.tenisClass.time,
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                        ),
                        Text(
                            '${widget.reservation.hour} - ${widget.reservation.status}',
                            style: TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                        ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                                ElevatedButton(
                                    onPressed: () {
                                    // Perform some action
                                    },
                                    child: const Text('Confirmar'),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                    // Perform some action
                                    },
                                    child: const Text('Borrar'),
                                ),
                            ],
                        ),
                    ],
                ),
            )
        );
    }
}