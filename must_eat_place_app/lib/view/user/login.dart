import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:must_eat_place_app/view/home.dart';
import 'package:must_eat_place_app/view/user/signup.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Property
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  final box = GetStorage();

  @override
  void dispose() {
    box.erase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '로그인',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.amber,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 또는 이미지 삽입 (선택 사항)
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Image.asset(
                      'images/logo.jpg', // 로고 경로 (있을 경우)
                      height: 250,
                      width: 350,
                    ),
                  ),
      
                  // ID 입력 필드
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: idController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'ID를 입력하세요',
                        labelStyle: const TextStyle(fontSize: 16),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                  ),
      
                  // 패스워드 입력 필드
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: pwController,
                      obscureText: true,
                      maxLength: 16,
                      decoration: InputDecoration(
                        labelText: '패스워드를 입력하세요',
                        labelStyle: const TextStyle(fontSize: 16),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                  ),
      
                  // 로그인 버튼
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (idController.text.trim().isEmpty ||
                              pwController.text.trim().isEmpty) {
                            errorSnackBar('경고', 'ID와 패스워드를 입력하세요');
                          } else {
                            loginButton();
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
                          '로그인',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
      
                  // 회원가입 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controllerClear();
                        Get.to(const Signup());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Function
  loginButton() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login?id=${idController.text}&pw=${pwController.text}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    String result = dataConvertedJSON['result'].toString();
    if (result == '1') {
      _showDialog();
    } else {
      errorSnackBar('로그인 실패', 'ID와 패스워드가 일치하지 않습니다');
    }
  }

  _showDialog() {
    Get.defaultDialog(
        title: "로그인 성공",
        middleText: '환영합니다.',
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
                box.write('id', idController.text.trim());
                controllerClear();
                Get.to(const Home());
              },
              child: const Text('확인'))
        ]);
  }

  // 로그인 실패 및 미입력 시 알림창
  errorSnackBar(title, message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }

  // 텍스트필드 초기화
  controllerClear() {
    idController.clear();
    pwController.clear();
    setState(() {});
  }
}
