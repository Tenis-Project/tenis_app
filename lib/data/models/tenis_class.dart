class TenisClass {
    String? id;
    String? name;
    String? time;
    String? duration;
    int? price;
    List<String>? description;

    TenisClass({
        required this.id,
        required this.name,
        required this.time,
        required this.duration,
        required this.price,
        required this.description
    });

    TenisClass.fromJson(Map<String, dynamic> json){
        id = json['_id'];
        name = json['name'];
        time = json['time'];
        duration = json['duration'];
        price = json['price'];
        description = (json['description'] as List<dynamic>).cast<String>();
    }
}