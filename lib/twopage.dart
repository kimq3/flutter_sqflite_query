import 'package:dbtest/threepage.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Second extends StatelessWidget {
  const Second({super.key, required this.result, required this.database});

  final int result;
  final Database database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('hello')),
      body: Center(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              //main 페이지와 유사하게 FutureBuilder와 ListView가 순서대로 쓰인다.
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              List<Map> value = snapshot.data as List<Map>;
              return ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        '${index + 1}. ${value[index]['title'].toString()}'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Threepage(
                                    //다음페이지를 위해 필요한 값들과 DB를 전달한다.
                                    id: value[index]['id'],
                                    database: database,
                                    content: value[index]['content'].toString(),
                                    type: value[index]['quiz_type'].toString(),
                                  )));
                    },
                  );
                },
                itemCount: value.length,
              );
            }
          },
          future: database.rawQuery(
              'select * from quizzes where categoty_id=${result}'), //가져온 id로 맞는 quiz 문제들을 가져온다.
        ),
      ),
    );
  }
}
