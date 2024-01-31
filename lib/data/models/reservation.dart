import 'package:tenis_app/data/models/tenis_class.dart';
import 'package:tenis_app/data/models/user.dart';

class Reservation {
    late String id;
    late DateTime date;
    late String hour;
    late User user;
    late TenisClass tenisClass;

    Reservation({
        required this.id,
        required this.date,
        required this.hour,
        required this.user,
        required this.tenisClass
    });

    Reservation.fromJson(Map<String, dynamic> json){
        id = json['_id'];
        date = DateTime.parse(json['date']);
        hour = json['hour'];
        user = User.fromJson(json['user']);
        tenisClass = TenisClass.fromJson(json['class']);
    }
}