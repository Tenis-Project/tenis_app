import 'package:flutter/material.dart';
import 'package:tenis_app/data/models/reservation.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class Reservations extends StatefulWidget {
    const Reservations({super.key});

    @override
    State<Reservations> createState() => _ReservationsState();
}

class _ReservationsState extends State<Reservations> {
    late HttpHelper httpHelper;
    late io.Socket socket;

    late Map<String, dynamic> reservationsResponse;
    List<Reservation>? reservations;

    bool loading = true;
    late bool reservationsExist;

    Future initialize() async {
        reservationsResponse = await httpHelper.getMyReservations();
        if (reservationsResponse['status'] == 'error') {
            setState(() {
                loading = false;
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
                title: loading ? const LinearProgressIndicator() : const Text('Tus reservas'), 
            ),
            body: Center(
                child: loading ? const CircularProgressIndicator() : SingleChildScrollView(
                    child: reservationsExist ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: reservations?.length,
                                itemBuilder: (context, index) {
                                    return ReservationItem(reservation: reservations![index]);
                                }
                            )
                        ],
                    ) : const Text("No cuentas con reservaciones aun"),
                )
            )
        );
    }
}

class ReservationItem extends StatefulWidget {
    const ReservationItem({super.key, required this.reservation});
    final Reservation reservation;

    @override
    State<ReservationItem> createState() => _ReservationItemState();
}

class _ReservationItemState extends State<ReservationItem> {
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
                            title: Text(widget.reservation.tenisClass.name),
                            subtitle: Text(
                                widget.reservation.tenisClass.time,
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                '${DateFormat('dd/MM/yyyy').format(widget.reservation.date)} - ${widget.reservation.hour}',
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                        )
                    ],
                ),
            )
        );
    }
}