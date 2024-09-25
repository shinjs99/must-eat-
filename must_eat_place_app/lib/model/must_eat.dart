import 'dart:typed_data';

class MustEat{
  int? seq;
  Uint8List image;
  double latitude;
  double longitude;
  String name;
  String phone;
  String review;
  String grade;

  MustEat(
    {
      this.seq,
      required this.image,
      required this.latitude,
      required this.longitude,
      required this.name,
      required this.phone,
      required this.review,
      required this.grade
    }
  );

  MustEat.fromMap(Map<String, dynamic> res):
    seq = res['seq'],
    image = res['image'],
    latitude = res['latitude'],
    longitude = res['longitude'],
    name = res['name'],
    phone = res['phone'],
    review = res['review'],
    grade = res['grade'];
}