import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../sqlhelper.dart';


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
    callApi(File(widget.imagePath)).then((value) {
      print(value);
      final ans = json.decode(value);
      
      getTranslation_papago(ans["ans"]).then((value) {
        tmpRes = value;
        widget.tts.speak(value);
        widget.tts.speak("사진 저장을 원하시면 화면을 두드려주세요!");
      });
      // widget.tts.speak(res);
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.tts.speak("사진을 해석중입니다");
    
    return Scaffold(
      
      appBar: AppBar(title: const Text('Display the Picture')),
      // // The image is stored as a file on the device. Use the `Image.file`
      // // constructor with the given path to display the image.

      body:GestureDetector(
          onTap: () {
            GallerySaver.saveImage(widget.imagePath,albumName: "MyMemory").then((value) => widget.tts.speak("사진 저장을 성공하였습니다."));
            print(tmpRes);
            String imageName = widget.imagePath.split("/").last;
            print(imageName);
            addItem(imageName, tmpRes);
            SQLHelper.getInfos().then((value)=> print(value));
          },
        child:Container(
          child: Image.file(File(widget.imagePath)),
        )
      )
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
    await SQLHelper.createInfo(
        imgname, imgdesc);
  }

// Delete an item
void deleteItem(String imgName) async {
  await SQLHelper.deleteItem(imgName).then((value) => print("성공적으로 삭제되었습니다."));
  
}