import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:must_eat_place_app/view/edit_page.dart';
import 'package:must_eat_place_app/view/insert_page.dart';
import 'package:must_eat_place_app/view/shop_location.dart';
import 'package:must_eat_place_app/vm/database_handler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // late List<String> items;
  // late String dropdownValue;
  DatabaseHandler handler = DatabaseHandler();

  @override
  void initState() {
    super.initState();
    // items = ['전체','1','2','3','4','5'];
    // dropdownValue = items[0];
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
                  .then((value) => reloadData()),
              icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder(
        future: handler.queryMustEat(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => const ShopLocation(), arguments: [
                        snapshot.data![index].latitude,
                        snapshot.data![index].longitude
                      ])!
                          .then((value) => reloadData());
                    },
                    child: Slidable(
                      endActionPane:
                          ActionPane(motion: const DrawerMotion(), children: [
                        SlidableAction(
                            flex: 1,
                            onPressed: (context) => handler
                                .deleteMustEat(snapshot.data![index].seq!)
                                .then((value) => reloadData()),
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
                                snapshot.data![index].seq,
                                snapshot.data![index].image,
                                snapshot.data![index].latitude,
                                snapshot.data![index].longitude,
                                snapshot.data![index].name,
                                snapshot.data![index].phone,
                                snapshot.data![index].review,
                                snapshot.data![index].grade
                              ])!.then((value) =>  reloadData());
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
                                child: Image.memory(snapshot.data![index].image),
                              ),
                              SizedBox(
                                width: 300,
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(snapshot.data![index].name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                    Text(snapshot.data![index].phone,
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
                });
          } else {
            return const Center(
              child: Text('리스트를 추가 해주세요'),
            );
          }
        },
      ),
    );
  }

  // --- Functions ---
  reloadData() {
    setState(() {});
  }
}
