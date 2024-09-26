import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
  TextEditingController reviewconstroller = TextEditingController();
  late String latitude;
  late String longitude;
  late String grade;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  String filename = "";

  int firstDisp = 0;
  var value = Get.arguments ?? "__";

  @override
  void initState() {
    super.initState();
    namecontroller.text = value[1];
    phonecontroller.text = value[2];
    reviewconstroller.text = value[7];
    latitude = value[3];
    longitude = value[4];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집 수정'),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () => getImageFromGallery(ImageSource.gallery),
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
                child: firstDisp == 0
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.black, width: 2.0)),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 180,
                          child: Center(
                            child: imageFile == null
                                ? const Text('Image')
                                : Image.file(File(imageFile!
                                    .path)), //imageFile은 ?로 되어있기에 !를 붙여준다.
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          color: Colors.grey,
                          child: Center(
                            child: imageFile == null
                                ? const Text('이미지를 선택하세요')
                                : Image.file(File(imageFile!.path)),
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('위도 : ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(latitude.toString()),
                      const Text('경도 : ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(longitude.toString()),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                child: Row(
                  children: [
                    const Text('이름 : ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
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
                  if (firstDisp == 0) {
                    updateAction();
                  } else {
                    updateActionAll();
                  }
                },
                child: const Text(
                  '수정',
                  style: TextStyle(
                      backgroundColor: Colors.black, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Functions ---
  getImageFromGallery(ImageSource imagesource) async {
    final XFile? pickedFile = await picker.pickImage(source: imagesource);
    imageFile = XFile(pickedFile!.path);
    firstDisp = 1;
    setState(() {});
  }

  updateAction() {
    // filename이 필요하므로 filename을 얻기 전까지는 다음 단계를 멈춘다.
    updateJSONData();
  }

  updateJSONData() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/update?seq=${value[0]}&name=${value[1]}&phone=${value[2]}&estimate=${value[7]}');
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
        'http://127.0.0.1:8000/updateAll?seq=${value[0]}&name=${value[1]}&phone=${value[2]}&image=$filename&estimate=${value[7]}');
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

  errorSnackBar() {
    //get package SnackBar
    Get.snackbar("수정 실패", "다시 시도하세요",
        snackPosition: SnackPosition.BOTTOM, //기본값 = top
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError);
  }

  uploadImage() async {
    var request = http.MultipartRequest(
        //multipartrequest : file쪼개서 보내기 => list형태
        'POST',
        Uri.parse('http://127.0.0.1:8000/upload'));
    var multipartFile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);

    //for gettting file name
    List preFileName = imageFile!.path.split('/');
    // print(preFileName[preFileName.length-1]); // imagefile이름
    filename = preFileName[preFileName.length - 1];
    print('file name : $filename');

    var response = await request.send();

    //200 = 정상작동
    if (response.statusCode == 200) {
      print("Image upladed successfully");
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
