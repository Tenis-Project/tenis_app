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
        socket = io.io('http://localhost:3000/', <String, dynamic>{
            'transports': ['websocket'],
        });
        socket.on('updatedClassPackageInAdminView', (arg) {
            if (context.mounted && arg['user'] == widget.userId) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Se ha actualizado el estado de paquete de clases'),
                        duration: Duration(seconds: 3),
                    ),
                );
                setState(() {
                    loading = true;
                });
                initialize();
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
                title: loading ? const LinearProgressIndicator() : const Text("Tus paquetes de clases"),
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
                                    return ClassPackageItem(classPackage: classPackages![index]);
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

class ClassPackageItem extends StatefulWidget {
    const ClassPackageItem({super.key, required this.classPackage});
    final ClassPackage classPackage;

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
                child: Column(
                    children: [
                        ListTile(
                            leading: widget.classPackage.tenisClass.time == 'Dia' ? const Icon(Icons.sunny) : const Icon(Icons.nightlight),
                            title: Text('${widget.classPackage.tenisClass.name} - ${widget.classPackage.status}'),
                            subtitle: Text(
                                widget.classPackage.tenisClass.time,
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                        ),
                        ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                                IconButton(
                                    onPressed: buttonEnabled ? () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ClassPackageManager(classPackage: widget.classPackage,),
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