import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/data/models/tenis_class.dart';
import 'package:tenis_app/data/models/user.dart';
import 'package:tenis_app/data/web/http_helper.dart';
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
                user = user;
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
        return Scaffold(
            body: Center(
                child: loading ? const CircularProgressIndicator() : SingleChildScrollView (
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text('!Bienvenidos todos a home ${user?.name}!'),
                            ElevatedButton(
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
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: classes?.length,
                                itemBuilder: (context, index) {
                                    return TenisClassItem(tenisclass: classes![index]);
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
    const TenisClassItem({super.key, required this.tenisclass});
    final TenisClass tenisclass;

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
            elevation: 4.0,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(widget.tenisclass.name!),
                    Text(widget.tenisclass.time!),
                    Text(widget.tenisclass.duration!),
                    Text(widget.tenisclass.price.toString()),
                ],
            )
        );
    }
}