import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController reviewcontroller = TextEditingController();
  late String latitude;
  late String longitude;
  double currentrating = 0;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  String filename = "";
  int firstDisp = 0;
  var value = Get.arguments ?? "__";

  @override
  void initState() {
    super.initState();
    namecontroller.text = value[2];
    phonecontroller.text = value[3];
    reviewcontroller.text = value[7];
    latitude = value[4];
    longitude = value[5];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '맛집 수정',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                onPressed: () => getImageFromGallery(ImageSource.gallery),
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
                    ? Image.network(
                        'http://127.0.0.1:8000/view/${value[6]}',
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(imageFile!.path),
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 20),

              // 위도 및 경도 표시
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '위도: $latitude',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '경도: $longitude',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: double.parse(value[8]),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  currentrating = rating;
                },
              ),
              const SizedBox(height: 20),

              // 수정 버튼
              ElevatedButton(
                onPressed: () {
                  if (firstDisp == 0) {
                    updateAction();
                  } else {
                    updateActionAll();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '수정 완료',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Functions ---

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

  getImageFromGallery(ImageSource imagesource) async {
    final XFile? pickedFile = await picker.pickImage(source: imagesource);
    imageFile = XFile(pickedFile!.path);
    firstDisp = 1;
    setState(() {});
  }

  updateAction() {
    updateJSONData();
  }

  updateJSONData() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/update?seq=${value[0]}&name=${namecontroller.text}&phone=${phonecontroller.text}&estimate=${reviewcontroller.text}&rating=${currentrating.toString()}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'ok') {
      _showDialog();
    } else {
      errorSnackBar();
    }
  }

  updateJSONDataAll() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/updateAll?seq=${value[0]}&name=${namecontroller.text}&phone=${phonecontroller.text}&image=$filename&estimate=${reviewcontroller.text}&rating=${currentrating.toString()}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'ok') {
      _showDialog();
    } else {
      errorSnackBar();
    }
  }

  _showDialog() {
    Get.defaultDialog(
      title: '수정 결과',
      middleText: '수정이 완료되었습니다.',
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

  errorSnackBar() {
    Get.snackbar(
      "수정 실패",
      "다시 시도하세요",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  uploadImage() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/upload'));
    var multipartFile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);

    List preFileName = imageFile!.path.split('/');
    filename = preFileName[preFileName.length - 1];

    var response = await request.send();

    if (response.statusCode == 200) {
      print("Image uploaded successfully");
    } else {
      print("Image upload failed");
    }
  }

  updateActionAll() async {
    await deleteImage(value[6]);
    await uploadImage();
    updateJSONDataAll();
  }

  deleteImage(String filename) async {
    final response = await http
        .delete(Uri.parse('http://127.0.0.1:8000/deleteFile/$filename'));
    if (response.statusCode == 200) {
      print("Image deleted successfully");
    } else {
      print("Image deletion failed");
    }
  }
}
