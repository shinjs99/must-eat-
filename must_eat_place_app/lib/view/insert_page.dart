import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    namecontroller = TextEditingController();
    phonecontroller = TextEditingController();
    reviewcontroller = TextEditingController();
    latitude = 0;
    longitude = 0;
    checkLocationPermission();
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
        child: Center(
          child: Column(children: [
            TextButton(
              onPressed: () => getImageFromDevice(ImageSource.gallery),
              child: const Text(
                'Image',
                style: TextStyle(
                    backgroundColor: Colors.black,
                    color: Colors.white,
                    fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 250,
                height: 180,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.0)),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  child: Center(
                    child: imageFile == null
                        ? const Text(
                            'Image',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          )
                        : Image.file(File(imageFile!.path)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () async {
                      var returnValues =
                          await Get.to(() => const LocationPicker());
                      latitude = returnValues[0];
                      longitude = returnValues[1];
                    },
                    icon: const Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('위도 : ',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(latitude.toString(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('경도 : ',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(longitude.toString(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Row(
                children: [
                  const Text('이름 : ',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: namecontroller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Row(
                children: [
                  const Text('전화 : ',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: phonecontroller,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Row(
                children: [
                  const Text('평가 : ',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: reviewcontroller,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      )),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Row(
                children: [
                  const Text('별점 : ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                  ElevatedButton(
                      onPressed: () {
                        grade = '1';
                      },
                      child: const Text('1')),
                  ElevatedButton(
                      onPressed: () {
                        grade = '2';
                      },
                      child: const Text('2')),
                  ElevatedButton(
                      onPressed: () {
                        grade = '3';
                      },
                      child: const Text('3')),
                  ElevatedButton(
                      onPressed: () {
                        grade = '4';
                      },
                      child: const Text('4')),
                  ElevatedButton(
                      onPressed: () {
                        grade = '5';
                      },
                      child: const Text('5')),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                insertAction();
              },
              child: const Text(
                '입력',
                style: TextStyle(
                    backgroundColor: Colors.black, color: Colors.white),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  getImageFromDevice(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      imageFile = null;
    } else {
      imageFile = XFile(pickedFile.path);
    }
    setState(() {});
  }

  Future insertAction() async {
    if (imageFile == null) return;

    // 1. 이미지 업로드
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/upload'));
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile!.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      // 2. 나머지 데이터 삽입
      final insertResponse = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/insert?name=${namecontroller.text}&phone=${phonecontroller.text}&lat=$latitude&longtitude=$longitude&image=${imageFile!.name}&estimate=${reviewcontroller.text}&user_id=example_user',
        ),
      );
      if (insertResponse.statusCode == 200) {
        _showDialog();
      }
    }
  }

  _showDialog() {
    Get.defaultDialog(
      title: '입력 결과',
      middleText: '입력이 완료되었습니다.',
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
}
