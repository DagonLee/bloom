import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'display_picture.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SplashScreen extends StatefulWidget {
  final String imagePath;
  final FlutterTts tts;
  const SplashScreen({super.key, required this.imagePath, required this.tts});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<String> callApi(dynamic file) async {
    // var postUri = Uri.parse("http://211.184.1.44:5000/predict");
    var postUri = Uri.parse("http://172.20.10.8:5000/predict");
    var request = http.MultipartRequest("POST", postUri);
    request.files.add(await http.MultipartFile.fromPath(
        "file", widget.imagePath,
        contentType: new MediaType('image', 'jpeg')));

    // Await the http get response, then decode the json-formatted response.
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var data = response.body;
    return data;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    //오래걸리는 작업 수행
    widget.tts.speak("사진을 해석 중입니다.");
    print(DateTime.now());
    final result = await callApi(File(widget.imagePath));
    print(DateTime.now());

    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: widget.imagePath,
                  tts: widget.tts,
                  result: result,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
                backgroundColor: Colors.white, strokeWidth: 6),
            SizedBox(height: 20),
            Text('사진 분석 중...',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(offset: Offset(4, 4), color: Colors.white10)
                    ],
                    decorationStyle: TextDecorationStyle.solid))
          ],
        ),
      ),
    );
  }
}
