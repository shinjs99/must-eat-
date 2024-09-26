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
  List data = [];
  final box = GetStorage();
  late String userid;

  @override
  void initState() {
    super.initState();
    userid = box.read('id');
    getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내가 경험한 맛집 리스트',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const InsertPage())!
                .then((value) => getJSONData()),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: data.isEmpty
            ? const Text(
                '맛집을 추가하세요',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              )
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => const ShopLocation(),
                              arguments: [data[index][4], data[index][5]])!
                          .then((value) => getJSONData());
                    },
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            flex: 1,
                            onPressed: (context) async {
                              await removeData(data[index][0], data[index][6]);
                              getJSONData();
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: '삭제',
                          ),
                        ],
                      ),
                      startActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            flex: 1,
                            onPressed: (context) {
                              Get.to(
                                const EditPage(),
                                arguments: [
                                  data[index][0], //seq
                                  data[index][1], //id
                                  data[index][2], //name
                                  data[index][3], //phone
                                  data[index][4], //lat
                                  data[index][5], //long
                                  data[index][6], //image
                                  data[index][7], //estimate
                                  data[index][8], //rating
                                ],
                              )!
                                  .then((value) => getJSONData());
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: '수정',
                          ),
                        ],
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        elevation: 5,
                        shadowColor: Colors.amberAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // 이미지 섹션
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    'http://127.0.0.1:8000/view/${data[index][6]}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),

                              // 텍스트 섹션
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data[index][2],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data[index][3],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "별점 : ${data[index][8]}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // --- Functions ---
  getJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/select?user_id=$userid');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
    setState(() {});
  }

  removeData(seq, filename) async {
    await deleteImage(filename);
    var url = Uri.parse('http://127.0.0.1:8000/delete?seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK') {
      showSnackbar('삭제완료', '삭제되었습니다', Colors.green);
    } else {
      showSnackbar('삭제실패', '다시시도하세요', Colors.red);
    }
  }

  showSnackbar(title, message, color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: color,
      colorText: Colors.white,
    );
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
