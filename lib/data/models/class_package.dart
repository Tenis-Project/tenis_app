import 'package:tenis_app/data/models/tenis_class.dart';
import 'package:tenis_app/data/models/user.dart';

class ClassPackage {
    late String id;
    late String status;
    late User user;
    late TenisClass tenisClass;

    ClassPackage({
        required this.id,
        required this.status,
        required this.user,
        required this.tenisClass
    });

    ClassPackage.fromJson(Map<String, dynamic> json){
        id = json['_id'];
        status = json['status'];
        user = User.fromJson(json['user']);
        tenisClass = TenisClass.fromJson(json['class']);
    }
}