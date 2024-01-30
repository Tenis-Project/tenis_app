import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/data/models/tenis_class.dart';
import 'package:tenis_app/data/models/user.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/create_reservation.dart';
import 'package:tenis_app/pages/reservations.dart';
import 'package:tenis_app/pages/start.dart';

class HomeUser extends StatefulWidget {
    const HomeUser({super.key});

    @override
    State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
    late HttpHelper httpHelper;
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    late Map<String, dynamic> userResponse;
    late Map<String, dynamic> classesResponse;
    User? user;
    List<TenisClass>? classes;

    bool buttonEnabled = true;
    bool loading = true;

    Future initialize() async {
        userResponse = await httpHelper.getUser();
        classesResponse = await httpHelper.getAllClasses();
        if (userResponse['status'] == 'error') {
            setState(() {
                buttonEnabled = false;
                loading = false;
            });
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(userResponse['message']),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                            label: 'Ir a login',
                            onPressed: () {
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Start()
                                )
                            );
                            },
                        ),
                    )
                );
            }
        } else {
            user = User.fromJson(userResponse['user']);
            setState(() {
                loading = false;
            });
        }
        if (classesResponse['status'] == 'error') {
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(classesResponse['message']),
                        duration: const Duration(seconds: 3)
                    )
                );
            }
        } else {
            final List classesMap = classesResponse['classes'];
            classes = classesMap.map((classJson) => TenisClass.fromJson(classJson)).toList();
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
        final size = MediaQuery.of(context).size;

        return Scaffold(
            appBar: AppBar(
                title: loading ? const LinearProgressIndicator() : Text('!Bienvenido a home, ${user?.name}!'), 
            ),
            body: Center(
                child: loading ? const CircularProgressIndicator() : SingleChildScrollView (
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            SizedBox(
                                width: size.width * 0.80,
                                child: ElevatedButton(
                                    onPressed: buttonEnabled ? () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const Reservations()
                                            )
                                        );
                                    }: null,
                                    child: const Text('Ver mis reservas')
                                ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container()
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: classes?.length,
                                itemBuilder: (context, index) {
                                    return TenisClassItem(tenisclass: classes![index], buttonEnabled: buttonEnabled,);
                                }
                            )
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

class TenisClassItem extends StatefulWidget {
    const TenisClassItem({super.key, required this.tenisclass, required this.buttonEnabled});
    final TenisClass tenisclass;
    final bool buttonEnabled;

    @override
    State<TenisClassItem> createState() => _TenisClassItemState();
}

class _TenisClassItemState extends State<TenisClassItem> {
    @override
    void initState(){
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Card(
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
                child: Column(
                    children: [
                        ListTile(
                            leading: widget.tenisclass.time == 'Dia' ? const Icon(Icons.sunny) : const Icon(Icons.nightlight),
                            title: Text(widget.tenisclass.name),
                            subtitle: Text(
                                widget.tenisclass.time,
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.tenisclass.description.length,
                            itemBuilder: (context, index) {
                            return Text(
                                    widget.tenisclass.description[index],
                                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                );
                            },
                        ),
                        ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                                ElevatedButton(
                                    onPressed: widget.buttonEnabled ? () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => CreateReservation(tenisClass: widget.tenisclass)
                                            )
                                        );
                                    }: null,
                                    child: const Text('Reservar'),
                                ),
                            ],
                        )
                    ],
                ),
            )
        );
    }
}