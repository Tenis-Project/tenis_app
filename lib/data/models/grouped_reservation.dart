class GroupedReservation {
    late String hour;
    late int spacesAvailable;

    GroupedReservation({
        required this.hour,
        required this.spacesAvailable,
    });

    GroupedReservation.fromJson(Map<String, dynamic> json){
        hour = json['hour'];
        spacesAvailable = json['spacesAvailable'];
    }
}