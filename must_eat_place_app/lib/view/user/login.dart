import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
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
  //Property

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    box.write('id', "");
  }

  @override
  void dispose() {
    box.erase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: idController,
                maxLength: 10,
                decoration: const InputDecoration(labelText: 'ID를 입력하세요'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: pwController,
                obscureText: T,
                maxLength: 16,
                decoration: const InputDecoration(labelText: '패스워드를 입력하세요'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                  onPressed: () {
                    if (idController.text.trim().isEmpty ||
                        pwController.text.trim().isEmpty) {
                      errorSnackBar('경고', 'id,pw를 입력하세요');
                    } else {
                      loginButton();
                    }
                  },
                  child: const Text('LogIn')),
            ),
            ElevatedButton(
                onPressed: () => Get.to(const Signup()),
                child: const Text('SignUp')),
          ],
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
      errorSnackBar('로그인 실패', 'id,패스워드가 일치 하지 않습니다');
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
              child: const Text('Exit'))
        ]);
  }

// 로그인 실패 AND 미입력
  errorSnackBar(title, message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.black);
  }

// textfield 지우기
  controllerClear() {
    idController.clear();
    pwController.clear();
    setState(() {});
  }
}//End