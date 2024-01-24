import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenis_app/data/models/user.dart';

class HttpHelper {
    final String urlBase = 'http://localhost:3000';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    Future<Map<String, dynamic>> login(String username, String password, String role) async {
        http.Response response = await http.post(
            Uri.parse('$urlBase/api/users/login'), body: {
                "username": username,
                "password": password,
                "role": role
            }
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> register(String name, String lastName, String dni, String phone, String username, String password) async {
        http.Response response = await http.post(
            Uri.parse('$urlBase/api/users/register'), body: {
                "name": name,
                "lastName": lastName,
                "dni": dni,
                "phone": phone,
                "username" : username,
                "password": password,
            }
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<User?> getUser() async {
        final pref = await _prefs;
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/users/myObject'), 
            headers: <String, String> {'Authorization': '${pref.getString('token')}'}
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            
            if (response.statusCode == HttpStatus.ok) {
                final User user = User.fromJson(jsonResponse['user']);
                return user;
            } else {
                return null;
            }
        } catch (e) {
            return null;
        }
  }
}