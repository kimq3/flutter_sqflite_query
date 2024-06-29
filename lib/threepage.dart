import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Threepage extends StatefulWidget {
  const Threepage(
      {super.key,
      required this.id, //선택된 문제의 id
      required this.database,
      required this.content,
      required this.type}); //문제 유형 (객관식, 주관식)

  final int id;
  final Database database;
  final String content;
  final String type;

  @override
  State<Threepage> createState() => _ThreepageState();
}

class _ThreepageState extends State<Threepage> {
  late List<Map> value = []; //객관식 한문제에 5지선다 가져오기
  late String subValue = '';

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    //FutureBuilder 대신 함수로 불러오기 사용
    if (widget.type == 'multiple') {
      // 객관식일때
      final result = await widget.database.rawQuery(
          'select * from multiple_choice_answers where question_id=${widget.id}'); //5지선다 가져오기
      if (result.isNotEmpty) {
        setState(() {
          value = result; //5지선다 담기 (setState 적용)
        });
      } else {
        print('없다!');
      }
    } else if (widget.type == 'subject') {
      final result = await widget.database.rawQuery(
          'select answer from subjective_questions where quiz_id=${widget.id}'); // 주관식 답안 가져오기
      if (result.isNotEmpty) {
        setState(() {
          subValue = result[0]['answer'].toString(); //주관식 답 담기
        });
      } else {
        print('없다!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //아래의 if, else if는 Scaffold를 두번이나 적는 비효율적인 모습을보임
    //하지만 아래와 같이 하지않으면 위의 비동기 로직으로 인해 setState로 값이 제대로 들어와도 리렌더링 과정중에 빠지는 문제가 발생
    //현재로직으로선 이방법이 최선
    // provider 같은것을 사용했을때는 chanenotifier 같은 것이 있으니까 저렇게 까지 안써도 될듯함

    if (widget.type == 'multiple' && value.isNotEmpty) {
      //객관식일때 return
      return Scaffold(
        appBar: AppBar(title: Text('hello')),
        body: Column(
          children: [
            Text(widget.content),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        value[index]['answer'].toString()), //리스트뷰로 5지선다 연속 표현
                  );
                },
                itemCount: value.length,
              ),
            ),
          ],
        ),
      );
    } else if (widget.type == 'subject' && subValue.isNotEmpty) {
      //주관식일때 return
      return Scaffold(
        appBar: AppBar(title: Text('hello')),
        body: Column(
          children: [
            Text(widget.content),
            Text(subValue),
          ],
        ),
      );
    } else {
      // 아예 가져오지 못한경우의 위젯
      return Scaffold(
        appBar: AppBar(title: Text('hello')),
        body: Column(
          children: [
            Text(widget.content),
            Text('데이터를 로딩 중입니다...'),
          ],
        ),
      );
    }
  }
}
