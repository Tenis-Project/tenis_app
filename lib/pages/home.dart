import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/data/models/user.dart';
import 'package:tenis_app/data/web/http_helper.dart';
import 'package:tenis_app/pages/start.dart';

class Home extends StatefulWidget {
    const Home({super.key});

    @override
    State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
    HttpHelper? httpHelper;
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    User? user;

    Future initialize() async {
        user = await httpHelper?.getUser();
        log(user.toString());
        setState(() {
            user = user;
        });
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
          		child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Text('Master Cup Tennis ${user?.name}')
					],
				),
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