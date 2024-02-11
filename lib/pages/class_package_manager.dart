import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tenis_app/data/models/class_package.dart';
import 'package:tenis_app/data/models/reservation.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/create_reservation.dart';

class ClassPackageManager extends StatefulWidget {
    const ClassPackageManager({super.key, required this.classPackage});
    final ClassPackage classPackage;

    @override
    State<ClassPackageManager> createState() => _ClassPackageManagerState();
}

class _ClassPackageManagerState extends State<ClassPackageManager> {
    late HttpHelper httpHelper;

    late Map<String, dynamic> reservationsResponse;
    List<Reservation>? reservations;

    bool loading = true;
    late bool reservationsExist;
    bool classPackageOpen = true;

    Future initialize() async {
        refreshClassPackages();
    }

    Future<void> refreshClassPackages() async {
        reservationsResponse = await httpHelper.getByClassPackage(widget.classPackage.id);
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
                classPackageOpen = reservations!.length < 8;
            });
        }
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
                title: loading ? const LinearProgressIndicator() : const Text("Administrador de clases"),
                actions: [
                    IconButton(
                        onPressed: classPackageOpen ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateReservation(tenisClass: widget.classPackage.tenisClass, classPackage: widget.classPackage.id,),
                                ),
                            );
                        } : null,
                        icon: const Icon(Icons.add),
                    ),
                ],
            ),
            body: Center(
                child: loading ? const CircularProgressIndicator() : SingleChildScrollView(
                    child: reservationsExist ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            const Text("Tus reservas del paquete de clases"),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: reservations?.length,
                                itemBuilder: (context, index) {
                                    return ReservationPackageClassItem(reservation: reservations![index]);
                                },
                            ),
                        ],
                    ) : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text("No haz reservado ninguna clase de tu paquete"),
                        ],
                    ),
                ),
            ),
        );
    }
}

class ReservationPackageClassItem extends StatefulWidget {
    const ReservationPackageClassItem({super.key, required this.reservation});
    final Reservation reservation;

    @override
    State<ReservationPackageClassItem> createState() => _ReservationPackageClassItemState();
}

class _ReservationPackageClassItemState extends State<ReservationPackageClassItem> {
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
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                '${DateFormat('dd/MM/yyyy').format(widget.reservation.date)} - ${widget.reservation.hour}',
                                style: TextStyle(color: const Color.fromRGBO(10, 36, 63, 1).withOpacity(0.75)),
                            ),
                        )
                    ],
                ),
            ),
        );
    }
}