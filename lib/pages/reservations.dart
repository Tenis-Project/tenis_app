import 'package:flutter/material.dart';
import 'package:tenis_app/data/models/reservation.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
    late DateTime date;

    late Map<String, dynamic> reservationsResponse;
    List<Reservation>? reservations;

    bool loading = true;
    late bool reservationsExist;

    Future initialize() async {
        date = widget.date;
        refreshDate();
    }

    Future<void> refreshDate() async {
        reservationsResponse = await httpHelper.getMyReservations(date.toIso8601String());
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
    void initState() {
        httpHelper = HttpHelper();
        socket = io.io('http://localhost:3000/', <String, dynamic>{
            'transports': ['websocket'],
        });
        socket.on('updatedReservationInAdminView', (arg) {
            DateTime dateShow = DateTime.parse(arg['date'].toString());
            if (context.mounted && arg['user'] == widget.userId) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Se ha actualizado el estado de una reserva del ${DateFormat('dd/MM/yyyy').format(dateShow)}'),
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
        initialize();
        super.initState();
    }

    @override
    void dispose() {
        socket.disconnect();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: loading ? const LinearProgressIndicator() : const Text("Tus reservas")
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
                                    ),
                                ],
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: reservations?.length,
                                itemBuilder: (context, index) {
                                    return ReservationItem(reservation: reservations![index]);
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
                    ),
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
                            title: Text('${widget.reservation.tenisClass.name} - ${widget.reservation.status}'),
                            subtitle: Text(
                                widget.reservation.tenisClass.time,
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                widget.reservation.hour,
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                        )
                    ],
                ),
            )
        );
    }
}