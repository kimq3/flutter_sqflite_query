import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

class Timertest extends StatefulWidget {
  const Timertest({super.key});

  @override
  State<Timertest> createState() => _TimertestState();
}

class _TimertestState extends State<Timertest> {
  late Timer _timer; //타이머 컨트롤 변수
  int seconds = 0; //시간 기록
  bool starting = false; //동작 여부 파악(필요 없을수도?)

  void startTime() {
    starting = true;
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      // 지금은 시작버튼을 눌러야 타이머 동작을 시작하지만 퀴즈 페이지 시작시 initState에 이 로직 넣어주면 된다.
      setState(() {
        //1초마다 setState를 동작시키게 하여 시간을 1씩 늘리는 구조
        seconds++;
      });
    });
  }

  void stopTime() {
    setState(() {
      starting = false;
    });

    _timer.cancel(); // 1초마다 반복하고 있던 작업을 멈출때 사용
  }

  void reset() {
    setState(() {
      seconds = 0;
    });
  }

// 아래 두개의 String 함수는 초단위인 변수를 분/초로 구분해준다.
//pubspec.yaml에 sprinf 패키지 추가해야함
  String timetoString(int time) {
    return sprintf("%02d:%02d", [time ~/ 60, time % 60]);
  }

  String timetoKorean(int time) {
    return sprintf("%02d분 %02d초", [time ~/ 60, time % 60]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                timetoString(seconds),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                  onPressed: starting ? null : startTime, child: Text('시작')),
              ElevatedButton(
                  onPressed: starting ? stopTime : null, child: Text('정지')),
              ElevatedButton(onPressed: reset, child: Text('초기화')),
            ],
          ),
        ),
      ),
    );
  }
}
