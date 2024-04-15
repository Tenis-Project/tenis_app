class User {
    late String id;
    late String name;
    late String lastName;
    late String username;
    late String password;
    late String role;

    User({
        required this.id,
        required this.name,
        required this.lastName,
        required this.username,
        required this.password,
        required this.role
    });

    User.fromJson(Map<String, dynamic> json){
        id = json['_id'];
        name = json['name'];
        lastName = json['lastName'];
        username = json['username'];
        password = json['password'];
        role = json['role'];
    }
}