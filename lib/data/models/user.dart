class User {
    String? id;
    String? name;
    String? lastName;
    String? username;
    String? password;
    String? dni;
    String? phone;
    String? role;

    User({
        required this.id,
        required this.name,
        required this.lastName,
        required this.username,
        required this.password,
        required this.dni,
        required this.phone,
        required this.role
    });

    User.fromJson(Map<String, dynamic> json){
        id = json['_id'];
        name = json['name'];
        lastName = json['lastName'];
        username = json['username'];
        password = json['password'];
        dni = json['dni'];
        phone = json['phone'];
        role = json['role'];
    }
}