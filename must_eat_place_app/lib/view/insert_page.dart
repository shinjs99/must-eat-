import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:must_eat_place_app/view/location_picker.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  late TextEditingController namecontroller;
  late TextEditingController phonecontroller;
  late TextEditingController reviewcontroller;
  late double latitude;
  late double longitude;
  late Position currentPosition;
  late String grade;
  final box = GetStorage();
  late String userid;
  late Color iconColor;
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  late double currentrating;

  @override
  void initState() {
    super.initState();
    namecontroller = TextEditingController();
    phonecontroller = TextEditingController();
    reviewcontroller = TextEditingController();
    latitude = 0; // 기본 위도 설정
    longitude = 0; // 기본 경도 설정
    checkLocationPermission();
    userid = box.read('id');
    iconColor = Colors.black;
    currentrating = 0;
  }

  checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      getCurrentLocation();
    }
  }

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    latitude = position.latitude;
    longitude = position.longitude;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text('맛집 추가'),
        ),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 이미지 선택 버튼
              ElevatedButton(
                onPressed: () => getImageFromDevice(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '이미지 선택',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // 이미지 미리보기
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: imageFile == null
                    ? const Center(
                        child: Text(
                          '이미지를 선택하세요',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : Image.file(
                        File(imageFile!.path),
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 20),

              // 위치 확인 버튼 및 위도, 경도 표시
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        var returnValues =
                            await Get.to(() => const LocationPicker());
                        // null 체크 및 기존 위치 유지
                        if (returnValues != null) {
                          latitude = returnValues[0];
                          longitude = returnValues[1];
                        }
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.location_on, color: Colors.white),
                      label: const Text('위치 선택',
                          style: TextStyle(color: Colors.white)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('위도: $latitude',
                            style: const TextStyle(fontSize: 16)),
                        Text('경도: $longitude',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              // 이름 입력 필드
              buildTextField('이름', namecontroller),
              const SizedBox(height: 20),

              // 전화번호 입력 필드
              buildTextField('전화', phonecontroller),
              const SizedBox(height: 20),

              // 리뷰 입력 필드
              buildTextField('평가', reviewcontroller),
              const SizedBox(height: 20),

              // 별점 입력 필드
              const Text(
                '별점',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  currentrating = rating;
                },
              ),
              const SizedBox(height: 20),

              // 입력 버튼
              ElevatedButton(
                onPressed: () {
                  insertAction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '입력 완료',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 입력 필드를 빌드하는 함수 ---
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 이미지 선택 함수
  getImageFromDevice(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    setState(() {
      imageFile = pickedFile;
    });
  }

  // 입력 처리 함수
  insertAction() async {
    if (imageFile == null ||
        namecontroller.text.trim().isEmpty ||
        phonecontroller.text.trim().isEmpty ||
        reviewcontroller.text.trim().isEmpty) {
      return errorSnackBar('경고', '모두 입력하세요');
    }

    // 이미지 업로드
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/upload'));
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile!.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      // 나머지 데이터 삽입
      final insertResponse = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/insert?name=${namecontroller.text}&phone=${phonecontroller.text}&latitude=$latitude&longitude=$longitude&image=${imageFile!.name}&estimate=${reviewcontroller.text}&rating=$currentrating&user_id=$userid',
        ),
      );
      if (insertResponse.statusCode == 200) {
        _showDialog();
      }
    }
  }

  // 입력 완료 다이얼로그
  _showDialog() {
    Get.defaultDialog(
      title: '입력 결과',
      middleText: '입력이 완료되었습니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  // 경고 스낵바
  errorSnackBar(title, message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
