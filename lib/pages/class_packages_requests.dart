import 'package:flutter/material.dart';
import 'package:tenis_app/data/models/class_package.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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

    @override
    void initState(){
        httpHelper = HttpHelper();
        socket = io.io('http://localhost:3000/', <String, dynamic>{
            'transports': ['websocket'],
        });
        socket.on('createdClassPackageInUserView', (arg) {
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Se ha creado un nuevo paquete de clases'),
                        duration: Duration(seconds: 3),
                    ),
                );
            }
            setState(() {
                loading = true;
            });
            initialize();
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
                title: loading ? const LinearProgressIndicator() : const Text("Solicitudes de paquetes de clases"),
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
                                    return ClassPackageAdminItem(classPackage: classPackages![index]);
                                },
                            ),
                        ],
                    ) : const Column(
                        children: [
                            Text("No cuentas con paquetes de clases"),
                        ],
                    ),
                ),
            ),
        );
    }
}

class ClassPackageAdminItem extends StatefulWidget {
    const ClassPackageAdminItem({super.key, required this.classPackage});
    final ClassPackage classPackage;

    @override
    State<ClassPackageAdminItem> createState() => _ClassPackageAdminItemState();
}

class _ClassPackageAdminItemState extends State<ClassPackageAdminItem> {
    late HttpHelper httpHelper;
    late io.Socket socket;
    bool buttonEnabled = true;

    @override
    void initState(){
        httpHelper = HttpHelper();
        socket = io.io('http://localhost:3000/', <String, dynamic>{
            'transports': ['websocket'],
        });
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
                            leading: widget.classPackage.tenisClass.time == 'Dia' ? const Icon(Icons.sunny) : const Icon(Icons.nightlight),
                            title: Text('${widget.classPackage.tenisClass.name} - ${widget.classPackage.user.name} ${widget.classPackage.user.lastName}'),
                            subtitle: Text(
                                '${widget.classPackage.tenisClass.time} - ${widget.classPackage.status}',
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
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
                                                    content: Text('Aprobando paquete de clases...'),
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
                                                socket.emit('updatedClassPackage', { 'user': widget.classPackage.user.id });
                                                setState(() {
                                                    widget.classPackage.status = 'Aprobado';
                                                    buttonEnabled = false;
                                                });
                                            }
                                        }
                                    } : null,
                                    child: const Text('Confirmar'),
                                ),
                                ElevatedButton(
                                    onPressed: buttonEnabled ? () async {
                                        if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Cancelando paquete de clases...'),
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
                                                socket.emit('deletedClassPackage', { 'user': widget.classPackage.user.id});
                                                setState(() {
                                                    widget.classPackage.status = 'Cancelado';
                                                    buttonEnabled = false;
                                                });
                                            }
                                        }
                                    } : null,
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