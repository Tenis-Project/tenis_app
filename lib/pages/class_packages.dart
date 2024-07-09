import 'package:flutter/material.dart';
import 'package:tenis_app/data/models/class_package.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:tenis_app/pages/class_package_manager.dart';

class ClassPackages extends StatefulWidget {
    const ClassPackages({super.key, required this.userId});
    final String userId;

    @override
    State<ClassPackages> createState() => _ClassPackagesState();
}

class _ClassPackagesState extends State<ClassPackages> {
    late HttpHelper httpHelper;
    late io.Socket socket;
    
    late Map<String, dynamic> classPackagesResponse;
    List<ClassPackage>? classPackages;

    bool loading = true;
    late bool classPackagesExist;

    Future initialize() async {
        classPackagesResponse = await httpHelper.getMyClassPackages();
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
        super.initState();
        String dev = 'http://51.44.59.254:3001';
        socket = io.io(dev, <String, dynamic>{
            'transports': ['websocket'],
            'force new connection': true
        });
        socket.on('updatedClassPackageInAdminView', (arg) {
            if (context.mounted && arg['user'] == widget.userId) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Se ha actualizado el estado de un paquete de reserva'),
                        duration: Duration(seconds: 3),
                    ),
                );
                setState(() {
                    loading = true;
                });
                initialize();
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
                title: loading ? const LinearProgressIndicator() : const Text("Tus paquetes de reserva"),
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
                                    return ClassPackageItem(classPackage: classPackages![index], userId: widget.userId,);
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

class ClassPackageItem extends StatefulWidget {
    const ClassPackageItem({super.key, required this.classPackage, required this.userId});
    final ClassPackage classPackage;
    final String userId;

    @override
    State<ClassPackageItem> createState() => _ClassPackageItemState();
}

class _ClassPackageItemState extends State<ClassPackageItem> {
    late bool buttonEnabled;

    @override
    void initState(){
        buttonEnabled = widget.classPackage.status == 'Aprobado';
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
                                '${widget.classPackage.tenisClass.name} - ${widget.classPackage.status}',
                                style: const TextStyle(color: Color.fromRGBO(10, 36, 63, 1)),
                            ),
                            subtitle: Text(
                                widget.classPackage.tenisClass.time,
                                style: TextStyle(color: const Color.fromRGBO(10, 36, 63, 1).withOpacity(0.75)),
                            ),
                        ),
                        ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                                IconButton(
                                    onPressed: buttonEnabled ? () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ClassPackageManager(classPackage: widget.classPackage, userId: widget.userId),
                                            ),
                                        );
                                    } : null,
                                    
                                    icon: const Icon(Icons.arrow_forward),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }
}