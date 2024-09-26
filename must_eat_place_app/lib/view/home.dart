import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:must_eat_place_app/view/edit_page.dart';
import 'package:must_eat_place_app/view/insert_page.dart';
import 'package:must_eat_place_app/view/shop_location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // late List<String> items;
  // late String dropdownValue;
  // DatabaseHandler handler = DatabaseHandler();
  List data = [];
  final box =GetStorage();
  late String userid;

  @override
  void initState() {
    super.initState();
    // items = ['전체','1','2','3','4','5'];
    // dropdownValue = items[0];
    userid = box.read('id');
    getJSONData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 경험한 맛집 리스트'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
              onPressed: () => Get.to(() => const InsertPage())!
                  .then((value) => getJSONData()),
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Center(
        child: data.isEmpty
        ? Text('맛집을 추가하세요')
        : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => const ShopLocation(), arguments: [
                        data[index][4],
                        data[index][5]
                      ])!
                          .then((value) => getJSONData());
                    },
                    child: Slidable(
                      endActionPane:
                          ActionPane(motion: const DrawerMotion(), children: [
                        SlidableAction(
                            flex: 1,
                            onPressed: (context) async {
                              await removeData(data[index][0],data[index][6]);
                              getJSONData();
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: '삭제'),
                      ]),
                      startActionPane:
                          ActionPane(motion: const DrawerMotion(), children: [
                        SlidableAction(
                            flex: 1,
                            onPressed: (context) {
                              Get.to(const EditPage(), arguments: [
                                data[index][0],
                                data[index][1],
                                data[index][2],
                                data[index][3],
                                data[index][4],
                                data[index][5],
                                data[index][6],
                                data[index][7]
                              ])!.then((value) =>  getJSONData());
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.edit_document,
                            label: '수정')
                      ]),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.zero),
                      ),
                        child: Card(
                          shadowColor: Colors.amber,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.network('http://127.0.0.1:8000/view/${data[index][6]}'),
                              ),
                              SizedBox(
                                width: 300,
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(data[index][2],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                    Text(data[index][3],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              )
          ));
}

  // --- Functions ---

  getJSONData()async{
  var url = Uri.parse('http://127.0.0.1:8000/select?user_id=$userid');
  var response = await http.get(url);
  data.clear();
  var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  List result = dataConvertedJSON['results'];
  data.addAll(result);
  setState(() {});
  }

  removeData(seq, filename)async{
  await deleteImage(filename);
  var url = Uri.parse('http://127.0.0.1:8000/delete?seq=$seq');
  var response = await http.get(url);
  var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  var result = dataConvertedJSON['result'];
  if (result=='OK'){
    showSnackbar('삭제완료','삭제되었습니다',Colors.green);
  }else{
    showSnackbar('삭제실패','다시시도하세요',Colors.red);
  }
  }
  
  showSnackbar(title,message,color){
    Get.snackbar(
    title,
    message,
   snackPosition: SnackPosition.BOTTOM,   //기본값 = top
    duration: Duration(seconds: 2),
    backgroundColor: color
  );
  }

  deleteImage(String filename)async{
    final response = await http.delete(Uri.parse('http://127.0.0.1:8000/deleteFile/$filename'));
    if(response.statusCode==200){
      print("Image deleted successfully");
    }else{
      print("Image deletion failed");
    }
  }
}
