import 'dart:io';

import 'package:dbtest/timertest.dart';
import 'package:dbtest/twopage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/*
실행을 시켜보면 dart 파일 기준
main -> twopage -> three 페이지로 이동하는 원리

windows app 기준 sqflite이며(sqflite_ffi 사용) 안드로이드 수행시 void main의 init을 바꿔주면됨
*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  Database database =
      await initializeDatabase(); //하단 함수 참조 DB를 생성하거나 찾아 open하는 구조임

  runApp(MyApp(
      database:
          database)); // 최상위 위젯에 DB 연동 차후 provider로 DB에 데이터를 넣는 것이 필요 (지금은 위젯마다 DB를 받도록 설정함)
}

class MyApp extends StatelessWidget {
  final Database database;
  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Timertest(),
    );
  }
}

class Method extends StatelessWidget {
  final Database database;

  const Method({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('hello')),
        body: Center(
          // DB 단일값이 아닌 리스트들을 가져오는 형태이고 값을 가져올때 비동기처리를 위한 FutureBuilder와 가져온 값을 나열하는데 ListView를 사용한다.
          child: FutureBuilder(
            future: database.rawQuery(
                'select * from categories where type="quiz"'), // 카테고리 중에서 type이 퀴즈인 것들만 가져온다. 현재 데이터는 객관식 문제집 1, 주관식 문제집 1
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erorrr');
              } else {
                List<Map> result =
                    snapshot.data as List<Map>; //기다린 끝에 가져온 snapshot을 리스트에 담는다.
                return ListView.builder(
                  itemBuilder: (context, index) {
                    //리스트뷰 작성 index 활용
                    return ListTile(
                      title: Text(result[index]['top_cateroty']
                          .toString()), //현재 DB 데이터 기준 객관식1, 주관식1 총 2개가 나열된다.
                      onTap: () {
                        Navigator.push(
                            //원하는 것을 클릭했을때 2번째 페이지로 넘어간다.
                            context,
                            MaterialPageRoute(
                                builder: (context) => Second(
                                    //두번째 페이지에 넘어가면 활용을 위해 해당 인덱스의 id와 DB(차후 provider 처리필요)를 넘겨준다.
                                    result: result[index]['id'],
                                    database: database)));
                      },
                    );
                  },
                  itemCount: result.length, // 리스트뷰의 길이를 지정해주지 않으면 오버플로우가 난다.
                );
              }
            },
          ),
        ));
  }
}

Future<Database> initializeDatabase() async {
  // 애플리케이션의 내부 저장소 경로 가져오기
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, 'englishapp.db');

  // 데이터베이스 파일이 존재하는지 확인
  bool dbExists = await File(path).exists();

  if (!dbExists) {
    // 존재하지 않으면 assets 폴더에서 복사
    ByteData data = await rootBundle.load('assets/englishapp.db');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes);
  }

  // 데이터베이스 열기
  return await openDatabase(path);
}
