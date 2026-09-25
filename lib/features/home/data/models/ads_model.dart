import '../../domain/entities/ad_entity.dart';

class AdsModel extends AdEntity {
  const AdsModel({super.id, super.image, super.link});

  factory AdsModel.fromJson(Map<String, dynamic> json) {
    return AdsModel(
      id: json['id'],
      image: json['image'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'link': link,
    };
  }
}
