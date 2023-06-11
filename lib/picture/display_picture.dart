import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../sqlhelper.dart';
import '../main.dart';
import 'package:namer_app/gallery/sample_screen.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final FlutterTts tts;
  const DisplayPictureScreen(
      {super.key, required this.imagePath, required this.tts});
  @override
  DisplayPictureState createState() => DisplayPictureState();
}

class DisplayPictureState extends State<DisplayPictureScreen> {
  var tmpRes;
  var selectedIndex = 1;
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
    // api 호출
    widget.tts.speak("사진을 해석 중입니다.");
    callApi(File(widget.imagePath)).then((value) {
      final ans = json.decode(value);
      
      getTranslation_papago(ans["ans"]).then((value) {
        tmpRes = value;
        widget.tts.speak(value);
        widget.tts.speak("사진 저장을 원하시면 화면을 터치해주세요!");
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // // The image is stored as a file on the device. Use the `Image.file`
      // // constructor with the given path to display the image.
      body: GestureDetector(
        onLongPress: () {
            print("앨범모드로 이동");
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AlbumRoute(tts: widget.tts)),
            );
          },
        onDoubleTap: (){
          Navigator.pop(context);
        },
          onTap: () {
            GallerySaver.saveImage(widget.imagePath, albumName: "MyMemory")
                .then((value) => widget.tts.speak("사진 저장을 성공하였습니다."));
            String imageName = widget.imagePath.split("/").last;
            addItem(imageName, tmpRes);
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: Image.file(File(widget.imagePath)),
                ),
              ),
              // Text("TESTESETES")
            ],
          )),
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: colorScheme.background,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.replay_outlined),
            label: 'camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.download,
              size: 40,
            ),
            label: 'save',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'gallery',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: colorScheme.primary,
        onTap: (value) {
          if (value == 0) {
            Navigator.pop(context);
          } else if (value == 1) {
            print("다운로드 클릭");
            GallerySaver.saveImage(widget.imagePath, albumName: "MyMemory")
                .then((value) => widget.tts.speak("사진 저장을 성공하였습니다."));
            print(tmpRes);
            String imageName = widget.imagePath.split("/").last;
            print(imageName);
            addItem(imageName, tmpRes);
            SQLHelper.getInfos().then((value) => print(value));
          } else if (value == 2) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AlbumRoute(tts: widget.tts)),
            );
          }
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
    // );
  }
}

Future getTranslation_papago(String txt) async {
  String _client_id = "WYX9Cy9eD1ffV5IUEDAo";
  String _client_secret = "n2AsCIc6L6";
  String _content_type = "application/x-www-form-urlencoded; charset=UTF-8";
  String _url = "https://openapi.naver.com/v1/papago/n2mt";

  http.Response trans = await http.post(
    Uri.parse(_url),
    headers: {
      'Content-Type': _content_type,
      'X-Naver-Client-Id': _client_id,
      'X-Naver-Client-Secret': _client_secret
    },
    body: {
      'source': "en", //위에서 언어 판별 함수에서 사용한 language 변수
      'target': "ko", //원하는 언어를 선택할 수 있다.
      'text': txt,
    },
  );
  if (trans.statusCode == 200) {
    var dataJson = jsonDecode(trans.body);
    var resultPapago = dataJson['message']['result']['translatedText'];
    return resultPapago;
  } else {
    return trans.statusCode;
  }
}

Future<void> addItem(String imgname, String imgdesc) async {
  await SQLHelper.createInfo(imgname, imgdesc);
}

// Delete an item
void deleteItem(String imgName) async {
  await SQLHelper.deleteItem(imgName).then((value) => print("성공적으로 삭제되었습니다."));
}
