import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:must_eat_place_app/view/location_picker.dart';
import 'package:must_eat_place_app/vm/database_handler.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  late TextEditingController namecontroller;
  late TextEditingController phonecontroller;
  late TextEditingController reviewconstroller;
  late double latitude;
  late double longitude;
  late Position currentPosition;
  late String grade;
  DatabaseHandler handler = DatabaseHandler();

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    namecontroller = TextEditingController();
    phonecontroller = TextEditingController();
    reviewconstroller = TextEditingController();
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
                          : Image.file(File(
                              imageFile!.path)), //imageFile은 ?로 되어있기에 !를 붙여준다.
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
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
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              Text(latitude.toString(),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('경도 : ',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              Text(longitude.toString(),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
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
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
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
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: phonecontroller,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
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
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: reviewconstroller,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                child: Row(
                  children: [
                    const Text('별점 : ',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                        )),
                        ElevatedButton(
                          onPressed: () {
                            grade = '1';
                          }
                          ,child: const Text('1')),
                        ElevatedButton(
                          onPressed: () {
                            grade = '2';
                          }
                          ,child: const Text('2')),
                        ElevatedButton(
                          onPressed: () {
                            grade = '3';
                          }
                          ,child: const Text('3')),
                        ElevatedButton(
                          onPressed: () {
                            grade = '4';
                          }
                          ,child: const Text('4')),
                        ElevatedButton(
                          onPressed: () {
                            grade = '5';
                          }
                          ,child: const Text('5')),
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
        ));
  }

  // --- Functions ---
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
    //File Type을 Byte Type으로 변환하기
    File imageFile1 = File(imageFile!.path); //이미지 제작
    Uint8List getImage = await imageFile1.readAsBytes();

    var shopInsert = MustEat(
        image: getImage,
        latitude: latitude,
        longitude: longitude,
        name: namecontroller.text.trim(),
        phone: phonecontroller.text.trim(),
        review: reviewconstroller.text.trim(),
        grade: grade);
    int result = await handler.insertMustEat(shopInsert);
    if (result != 0) {
      _showDialog();
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
        ]);
  }
}
