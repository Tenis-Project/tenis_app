import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpHelper {
    //String local = 'http://localhost:3000';
    //String deployed = 'https://tenis-back-dev-dasc.2.us-1.fl0.io';
    final String urlBase = 'https://tenis-back-dev-dasc.2.us-1.fl0.io';
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

    Future<Map<String, dynamic>> register(String name, String lastName, String username, String password) async {
        http.Response response = await http.post(
            Uri.parse('$urlBase/api/users/register'), body: {
                "name": name,
                "lastName": lastName,
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

    Future<Map<String, dynamic>> getUser() async {
        final pref = await _prefs;
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/users/myObject'), 
            headers: <String, String> {'Authorization': '${pref.getString('token')}'}
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> getAllClasses() async {
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/classes/list')
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> createReservation(String date, String hour, String classId) async {
        final pref = await _prefs;
        http.Response response = await http.post(
            Uri.parse('$urlBase/api/reservations'), body: {
                "date": date,
                "hour": hour,
                "class": classId
            },
            headers: <String, String> {'Authorization': '${pref.getString('token')}'}
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> createReservationClassPackage(String date, String hour, String classId, String classPackageId) async {
        final pref = await _prefs;
        http.Response response = await http.post(
            Uri.parse('$urlBase/api/reservations'), body: {
                "date": date,
                "hour": hour,
                "class": classId,
                "status": "Aprobado",
                "classPackage": classPackageId
            },
            headers: <String, String> {'Authorization': '${pref.getString('token')}'}
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> getMyReservations(String date) async {
        final pref = await _prefs;
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/reservations/myObjectsDate?date=$date'),
            headers: <String, String> {'Authorization': '${pref.getString('token')}'}
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> getAllReservations(String date) async {
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/reservations/getAllDate?date=$date')
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> getAllReservationsHourSpaces(String date) async {
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/reservations/getAllHoursSpacesDate?date=$date')
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> getByClassPackage(String classPackageId) async {
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/reservations/getByClassPackage?idClassPackage=$classPackageId')
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> updateReservation(String id, String status) async {
        http.Response response = await http.put(
            Uri.parse('$urlBase/api/reservations?idReservation=$id'), body: {
                "status": status
            }
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> deleteReservation(String id) async {
        http.Response response = await http.delete(
            Uri.parse('$urlBase/api/reservations'), body: {
                "id": id
            }
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> createClassPackage(String classId) async {
        final pref = await _prefs;
        http.Response response = await http.post(
            Uri.parse('$urlBase/api/classPackages'), body: {
                "class": classId
            },
            headers: <String, String> {'Authorization': '${pref.getString('token')}'}
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> getMyClassPackages() async {
        final pref = await _prefs;
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/classPackages/myObjects'),
            headers: <String, String> {'Authorization': '${pref.getString('token')}'}
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> getAllStandByClassPackages() async {
        http.Response response = await http.get(
            Uri.parse('$urlBase/api/classPackages/getAllStandBy')
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> updateClassPackage(String id, String status) async {
        http.Response response = await http.put(
            Uri.parse('$urlBase/api/classPackages?idClassPackage=$id'), body: {
                "status": status
            }
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }

    Future<Map<String, dynamic>> deleteClassPackage(String id) async {
        http.Response response = await http.delete(
            Uri.parse('$urlBase/api/classPackages'), body: {
                "id": id
            }
        );

        try {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse;
        } catch (e) {
            return { 'status': 'error', 'message': 'Error en la peticion' };
        }
    }
}