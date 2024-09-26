import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  //property
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  String idcheck = "";
  Color checkColor = Colors.black;
  bool idValue = false;
  bool visibleValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '회원가입',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지 또는 삽입 가능 (옵션)
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Image.asset(
                  'images/logo.jpg', // 로고 파일 경로 (선택사항)
                  height: 250,
                  width: 350,
                ),
              ),

              // ID 입력 필드
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: idController,
                  maxLength: 10,
                  readOnly: idValue,
                  decoration: InputDecoration(
                    labelText: 'ID를 입력하세요',
                    labelStyle: const TextStyle(fontSize: 16),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: idValue
                        ? const Icon(
                            Icons.lock,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),

              // ID 중복확인 버튼 및 상태 텍스트
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if(idController.text.trim().isEmpty){
                        idcheck='ID를 입력하세요';
                        checkColor = Colors.red;
                      }else{
                      check();}
                      setState(() {
                        
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ID 중복확인',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    idcheck,
                    style: TextStyle(color: checkColor, fontSize: 16),
                  ),
                ],
              ),

              // 패스워드 입력 필드
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: pwController,
                  maxLength: 16,
                  obscureText: !visibleValue, // T : 보임, F : 안보임
                  decoration: InputDecoration(
                    labelText: '패스워드를 입력하세요',
                    labelStyle: const TextStyle(fontSize: 16),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          visibleValue = !visibleValue;
                        });
                      },
                      icon: Icon(
                        visibleValue ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
              ),

              // 가입 버튼
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (idController.text.trim().isEmpty ||
                          pwController.text.trim().isEmpty) {
                        errorSnackBar('다시', '시도하세요');
                      } else {
                        userInsert();
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
                      '가입',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Function
  check() async {
    var url = Uri.parse('http://127.0.0.1:8000/check?id=${idController.text}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    int result = dataConvertedJSON['result'];
    if (result == 1) {
      idcheck = "이미 사용중인 ID입니다.";
      checkColor = Colors.red;
      idValue = false;
    } else {
      idcheck = "사용가능한 ID 입니다.";
      checkColor = Colors.green;
      idValue = true;
    }
    setState(() {});
  }

  userInsert() async {
    if (idValue) {
      var url = Uri.parse(
          'http://127.0.0.1:8000/signup?id=${idController.text}&pw=${pwController.text}');
      var response = await http.get(url);
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      var result = dataConvertedJSON['result'];
      if (result == 'ok') {
        _showDialog();
      } else {
        errorSnackBar('회원가입 실패', '다시 시도하세요');
      }
    } else {
      errorSnackBar('다시', '다시');
    }
  }

  _showDialog() {
    Get.defaultDialog(
        title: "회원가입 성공",
        middleText: '환영합니다.',
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
                controllerClear();
                Get.back();
              },
              child: const Text('확인'))
        ]);
  }

  controllerClear() {
    idController.clear();
    pwController.clear();
    setState(() {});
  }

  // 로그인 실패 AND 미입력
  errorSnackBar(title, message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }
}
