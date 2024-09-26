import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
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
        title: Text('회원가입'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: idController,
                maxLength: 10,
                readOnly: idValue == true ? T : F,
                decoration: InputDecoration(
                  labelText: 'ID를 입력하세요',
                  suffixIcon: Visibility(
                    visible: idValue,
                    child: const Icon(
                      Icons.lock,
                      ),
                    ),
                ),
              ),
            ),
            Row(
              children: [
                                ElevatedButton(
                  onPressed: () {
                    check();
                  },
                  child: const Text('ID 중복확인')
                  ),
                Text(
                  idcheck,
                style: TextStyle(
                  color: checkColor
                ),
                ),

              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: pwController,
                maxLength: 16,
                obscureText: visibleValue == true ? T : F, // T : 보임, F : 안보임
                decoration: InputDecoration(
                  labelText: '패스워드를 입력하세요',
                  suffixIcon: IconButton(
                    onPressed: () {
                    if(visibleValue == F){
                      visibleValue = T;
                    }else{
                      visibleValue= F;
                    }setState(() {
                      
                    });
                  }, 
                  icon: Icon(Icons.remove_red_eye_sharp)
                  )
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if(idController.text.trim().isEmpty || pwController.text.trim().isEmpty){
                  errorSnackBar('다시', '시도하세요');
                }else{
                userInsert();
                }
              }, 
              child: const Text('가입')
              )
          ],
        ),
      ),
    );
  }
//Function
check()async{
  var url = Uri.parse('http://127.0.0.1:8000/check?id=${idController.text}');
  var response = await http.get(url);
  var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  int result = dataConvertedJSON['result'];
  if(result == 1){
    idcheck = "이미 사용중인 ID입니다.";
    checkColor = Colors.red;
    idValue = F;
  }else{
    idcheck="사용가능한 ID 입니다.";
    checkColor = Colors.green;
    idValue = T;
  }setState(() {
  });
}

userInsert()async{
  if (idValue == T){
  var url = Uri.parse('http://127.0.0.1:8000/signup?id=${idController.text}&pw=${pwController.text}');
  var response = await http.get(url);
  var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  var result = dataConvertedJSON['result'];
  if(result == 'ok'){
    _showDialog();
  }else{
    errorSnackBar('회원가입 실패', '다시 시도하세요');
  }
  }else{
    errorSnackBar('다시', '다시');
  }
}

_showDialog(){
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
        child: const Text('확인')
        )
    ]
  );
}
          controllerClear(){
            idController.clear();
            pwController.clear();
            setState(() {
              
            });
          }



// 로그인 실패 AND 미입력
errorSnackBar(title,message){ 
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM, 
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.red,
    colorText: Colors.black
    );
}



}//End
