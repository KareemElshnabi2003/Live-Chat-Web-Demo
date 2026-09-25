import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final dynamic power;

  const UserModel({
    super.id,
    super.name,
    super.username,
    super.email,
    super.phone,
    super.image,
    super.gender,
    super.age,
    super.countryId,
    super.countryName,
    super.numberOfStars,
    super.bio,
    this.power,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      bio: json['bio'],
      power: json['user_power'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      gender: json['gender'],
      age: json['age'],
      countryId: json['country_id'],
      countryName: json['country_name'],
      numberOfStars: json['number_of_stars']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'user_power': power,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'image': image,
      'gender': gender,
      'age': age,
      'country_id': countryId,
      'country_name': countryName,
      'number_of_stars': numberOfStars,
    };
  }
}
