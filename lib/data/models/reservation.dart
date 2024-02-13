import 'package:tenis_app/data/models/tenis_class.dart';
import 'package:tenis_app/data/models/user.dart';

class Reservation {
    late String id;
    late DateTime date;
    late String hour;
    late String status;
    late User user;
    late TenisClass tenisClass;

    Reservation({
        required this.id,
        required this.date,
        required this.hour,
        required this.status,
        required this.user,
        required this.tenisClass
    });

    Reservation.fromJson(Map<String, dynamic> json){
        id = json['_id'];
        date = DateTime.parse(json['date']);
        date = DateTime(date.year, date.month, date.day);
        hour = json['hour'];
        status = json['status'];
        user = User.fromJson(json['user']);
        tenisClass = TenisClass.fromJson(json['class']);
    }
}