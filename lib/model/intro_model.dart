import 'dart:convert';

class IntroModel {
  String? description;
  String? image;
  String? title;

  IntroModel(this.image, this.title, this.description);

  IntroModel copyWith({
    String? image,
    String? title,
    String? description,
  }) {
    return IntroModel(
      image ?? this.image,
      title ?? this.title,
      description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'image': image,
      'title': title,
    };
  }

  factory IntroModel.fromMap(Map<String, dynamic> map) {
    return IntroModel(
      map['image'],
      map['title'],
      map['description'],
    );
  }

  String toJson() => json.encode(toMap());

  factory IntroModel.fromJson(String source) =>
      IntroModel.fromMap(json.decode(source));
}
