class UserModel {
  final String uid;
  final String email;
  final String name;
  final String surname;
  final String phone;
  final double distance;

  UserModel(this.uid, this.email, this.name, this.surname, this.phone, this.distance);

  UserModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        email = json['email'],
        name = json['name'],
        surname = json['surname'],
        phone = json['phone'],
        distance = json['distance'];

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'surname': surname,
        'phone': phone,
        'distance': distance,
      };
}
