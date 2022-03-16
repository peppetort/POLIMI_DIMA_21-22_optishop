class UserModel {
  final String uid;
  final String email;
  final String name;
  final String surname;
  final String phone;
  final double distance;

  UserModel(this.uid, this.email, this.name, this.surname, this.phone, this.distance);

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'surname': surname,
        'phone': phone,
        'distance': distance,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          name == other.name &&
          surname == other.surname &&
          phone == other.phone &&
          distance == other.distance;

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      name.hashCode ^
      surname.hashCode ^
      phone.hashCode ^
      distance.hashCode;
}
