import 'package:flutter/material.dart';
import 'package:tenis_app/data/models/class_package.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:tenis_app/pages/home_admin.dart';

class ClassPackageRequests extends StatefulWidget {
    const ClassPackageRequests({super.key});

    @override
    State<ClassPackageRequests> createState() => _ClassPackageRequestsState();
}

class _ClassPackageRequestsState extends State<ClassPackageRequests> {
    late HttpHelper httpHelper;
    late io.Socket socket;

    late Map<String, dynamic> classPackagesResponse;
    List<ClassPackage>? classPackages;

    bool loading = true;
    late bool classPackagesExist;

    Future initialize() async {
        classPackagesResponse = await httpHelper.getAllStandByClassPackages();
        if (classPackagesResponse['status'] == 'error') {
            if (context.mounted) {
                setState(() {
                    loading = false;
                    classPackagesExist = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(classPackagesResponse['message']),
                        duration: const Duration(seconds: 3),
                    ),
                );
            }
        } else {
            final List classPackagesMap = classPackagesResponse['classPackages'];
            classPackages = classPackagesMap.map((classPackageJson) => ClassPackage.fromJson(classPackageJson)).toList();
            setState(() {
                loading = false;
                classPackagesExist = true;
            });
        }
    }

    Future<void> _enviarRequest(String type, String id) async {
        if (type == 'Aprobado') {
            socket.emit('updatedClassPackage', { 'user': id});
        } else {
            socket.emit('deletedClassPackage', { 'user': id});
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
        socket.on('createdClassPackageInUserView', (arg) {
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Se ha creado un nuevo paquete de reserva'),
                        duration: Duration(seconds: 3),
                    ),
                );
            }
            setState(() {
                loading = true;
            });
            initialize();
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
        return Scaffold(
            appBar: AppBar(
                title: loading ? const LinearProgressIndicator() : const Text("Solicitudes de paquetes"),
                leading: IconButton(
                    onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeAdmin(),
                            ),
                        );
                    },
                    icon: const Icon(Icons.arrow_back),
                ),
            ),
            body: Center(
                child: loading ? const CircularProgressIndicator() : SingleChildScrollView(
                    child: classPackagesExist ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: classPackages?.length,
                                itemBuilder: (context, index) {
                                    return ClassPackageAdminItem(classPackage: classPackages![index], onBotonPresionado: (type, id)  => _enviarRequest(type, id));
                                },
                            ),
                        ],
                    ) : const Column(
                        children: [
                            Text("No cuentas con paquetes de reserva"),
                        ],
                    ),
                ),
            ),
        );
    }
}

class ClassPackageAdminItem extends StatefulWidget {
    const ClassPackageAdminItem({super.key, required this.classPackage, required this.onBotonPresionado});
    final ClassPackage classPackage;
    final Function(String, String) onBotonPresionado;

    @override
    State<ClassPackageAdminItem> createState() => _ClassPackageAdminItemState();
}

class _ClassPackageAdminItemState extends State<ClassPackageAdminItem> {
    late HttpHelper httpHelper;
    bool buttonEnabled = true;

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
                            leading: widget.classPackage.tenisClass.time == 'Dia' ? const Icon(Icons.sunny) : const Icon(Icons.nightlight),
                            title: Text(
                                '${widget.classPackage.tenisClass.name} - ${widget.classPackage.user.name} ${widget.classPackage.user.lastName}',
                                style: const TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            subtitle: Text(
                                '${widget.classPackage.tenisClass.time} - ${widget.classPackage.status}',
                                style: TextStyle(color: const Color.fromRGBO(10, 36, 63, 1).withOpacity(0.75)),
                            ),
                        ),
                        ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                                ElevatedButton(
                                    onPressed: buttonEnabled ? () async {
                                        if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Aprobando paquete de reserva...'),
                                                    duration: Duration(minutes: 1),
                                                ),
                                            );
                                        }
                                        final Map<String, dynamic> response = await httpHelper.updateClassPackage(widget.classPackage.id, 'Aprobado');
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
                                                widget.onBotonPresionado('Aprobado', widget.classPackage.user.id);
                                                setState(() {
                                                    widget.classPackage.status = 'Aprobado';
                                                    buttonEnabled = false;
                                                });
                                            }
                                        }
                                    } : null,
                                    style: ButtonStyle(
                                        foregroundColor: WidgetStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(176, 202, 51, 1) : const Color.fromRGBO(176, 202, 51, 0.5)),
                                        backgroundColor: WidgetStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(10, 36, 63, 1) : const Color.fromRGBO(10, 36, 63, 0.5)),
                                    ),
                                    child: const Text('Confirmar'),
                                ),
                                ElevatedButton(
                                    onPressed: buttonEnabled ? () async {
                                        if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Cancelando paquete de reserva...'),
                                                    duration: Duration(minutes: 1),
                                                ),
                                            );
                                        }
                                        final Map<String, dynamic> response = await httpHelper.deleteClassPackage(widget.classPackage.id);
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
                                                widget.onBotonPresionado('Cancelado', widget.classPackage.user.id);
                                                setState(() {
                                                    widget.classPackage.status = 'Cancelado';
                                                    buttonEnabled = false;
                                                });
                                            }
                                        }
                                    } : null,
                                    style: ButtonStyle(
                                        foregroundColor: WidgetStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(176, 202, 51, 1) : const Color.fromRGBO(176, 202, 51, 0.5)),
                                        backgroundColor: WidgetStateProperty.all<Color>(buttonEnabled ? const Color.fromRGBO(10, 36, 63, 1) : const Color.fromRGBO(10, 36, 63, 0.5)),
                                    ),
                                    child: const Text('Cancelar'),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }
}