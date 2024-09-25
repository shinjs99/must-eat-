import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler{
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'musteat.db'),
      onCreate: (db, version) async {
        await db.execute("""
            create table musteat
            (
              seq integer primary key autoincrement,
              image blob,
              latitude real,
              longitude real,
              name text,
              phone text,
              review text,
              grade text
            )
        """);
      },
      version: 1,
    );
  }

    Future<int> insertMustEat(MustEat musteat) async {
    int result = 0;
    final Database db = await initializeDB();

    result = await db.rawInsert("""
      insert into musteat(image, latitude, longitude, name, phone, review, grade)
      values (?, ?, ?, ?, ?, ?, ?)
      """, [
      musteat.image,
      musteat.latitude,
      musteat.longitude,
      musteat.name,
      musteat.phone,
      musteat.review,
      musteat.grade
    ]);
    return result;
  }

    Future<List<MustEat>> queryMustEat() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery('''
          select *
          from musteat
          ''');
    return queryResult.map((e) => MustEat.fromMap(e)).toList();
  }

  Future<int> deleteMustEat(int? seq) async {
    final Database db = await initializeDB();
    final int queryResult = await db.rawDelete('''
          delete from
            musteat
          where
            seq = ?
          ''', [seq]);
    return queryResult;
  }

  Future<int> updateMustEat(MustEat mustEat) async {
    int result = 0;
    final Database db = await initializeDB();

    result = await db.rawUpdate("""
      update
        musteat 
      set 
        image = ?, latitude = ?, longitude = ?, name = ?, phone = ?, review = ? , grade = ?
      where
        seq = ?
      """, [
      mustEat.image,
      mustEat.latitude,
      mustEat.longitude,
      mustEat.name,
      mustEat.phone,
      mustEat.review,
      mustEat.grade,
      mustEat.seq
    ]);

    return result;
  }

  // Future<List<GradeList>> queryGrade(String gradenumber) async {
  //   String recive = '';
  //   String notRecive = '';
  //   if(gradenumber == "1"){ 
  //     recive = '1';
  //   }else if(gradenumber =='2'){
  //     notRecive ='미수령';
  //   }else if(gradenumber == '3'){
      
  //     }else if(gradenumber == '4'){

  //     }else if(gradenumber == '5'){

  //     }
  //   final Database db = await initializeDB();
  //   final List<Map<String, Object?>> queryResult =
  //       await db.rawQuery(
  //         '''
  //         SELECT 
  //           image , 
  //         FROM musteat
  //         WHERE 
  //         GROUP BY grade
  //         HAVING grade in (?, ?)
  //         ''',[recive, notRecive]);

  //   return queryResult
  //       .map(
  //         (e) => .fromMap(e),
  //       )
  //       .toList();
  // }
}