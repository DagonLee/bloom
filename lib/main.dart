import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'gallery/sample_screen.dart';
import 'sqlhelper.dart';
import 'picture/record.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MaterialApp(
    title: 'My Memory',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    ),
    home: MyHomePage(title: 'My Memory', camera: firstCamera),
    debugShowCheckedModeBanner: false,
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.camera,
  });
  final String title;
  final CameraDescription camera;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum TtsState { playing, stopped, paused, continued }

class _MyHomePageState extends State<MyHomePage> {
  late FlutterTts flutterTts;
  String language = "ko";
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    // TODO: implement initState

    SQLHelper.getInfos().then((value) => print(value));
    super.initState();
    initTts();
    _speak("안녕하세요 My Memory 입니다.");
    _speak("조작법에 대해서 설명드리겠습니다.");
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak(String txt) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (txt != "") {
      await flutterTts.speak(txt);
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contstraints) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: GestureDetector(
          onDoubleTap: () {
            print("촬영모드로 이동");
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      RecordPage(camera: widget.camera, tts: flutterTts)),
            );
          },
          onLongPress: () {
            print("앨범모드로 이동");
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AlbumRoute(tts: flutterTts)),
            );
          },
          child: Center(
            child: Container(
              // color: Colors.orangeAccent,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20, right: 40, left: 40, bottom: 40),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('Camera 버튼 클릭!');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RecordPage(
                                      camera: widget.camera, tts: flutterTts)),
                            );
                          },
                          //Contents of the button
                          style: ElevatedButton.styleFrom(
                            //Change font size
                            textStyle: const TextStyle(
                              fontSize: 18,
                            ),
                            //padding: const EdgeInsets.all(50.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            size: 50,
                          ),
                          label: Text('Camera'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('Gallery 버튼 클릭!');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AlbumRoute(tts: flutterTts)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            //Change font size
                            textStyle: const TextStyle(
                              fontSize: 18,
                            ),
                            padding: const EdgeInsets.all(50.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                          icon: Icon(
                            Icons.photo_outlined,
                            size: 50,
                          ),
                          label: Text('Gallery'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// class RecordPage extends StatefulWidget {
//   final CameraDescription camera;
//   final FlutterTts tts;
//   RecordPage({super.key, required this.camera, required this.tts});
//   @override
//   State<RecordPage> createState() => _RecordPageState();
// }

// class _RecordPageState extends State<RecordPage> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   @override
//   void initState() {
//     _speak("촬영모드입니다.");
//     super.initState();
//     // To display the current output from the Camera,
//     // create a CameraController.
//     _controller = CameraController(
//       // Get a specific camera from the list of available cameras.
//       widget.camera,
//       // Define the resolution to use.
//       ResolutionPreset.medium,
//     );
//     // Next, initialize the controller. This returns a Future.
//     _initializeControllerFuture = _controller.initialize();
//   }

//   Future _speak(String txt) async {
//     if (txt != "") {
//       await widget.tts.speak(txt);
//     }
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     SQLHelper.getInfos().then((value) => print(value));
//     return Scaffold(
//       appBar: AppBar(title: const Text('촬영 모드')),
//       // You must wait until the controller is initialized before displaying the
//       // camera preview. Use a FutureBuilder to display a loading spinner until the
//       // controller has finished initializing.
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             // If the Future is complete, display the preview.
//             return CameraPreview(_controller);
//           } else {
//             // Otherwise, display a loading indicator.
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         // Provide an onPressed callback.
//         onPressed: () async {
//           // Take the Picture in a try / catch block. If anything goes wrong,
//           // catch the error.
//           try {
//             // Ensure that the camera is initialized.
//             await _initializeControllerFuture;

//             // Attempt to take a picture and get the file `image`
//             // where it was saved.
//             final image = await _controller.takePicture();

//             if (!mounted) return;

//             // If the picture was taken, display it on a new screen.
//             await Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => DisplayPictureScreen(
//                     // Pass the automatically generated path to
//                     // the DisplayPictureScreen widget.
//                     imagePath: image.path,
//                     tts: widget.tts),
//               ),
//             );
//           } catch (e) {
//             // If an error occurs, log the error to the console.
//             print(e);
//           }
//         },
//         child: const Icon(Icons.camera_alt),
//       ),
//     );
//   }
// }

// A widget that displays the picture taken by the user.
// class DisplayPictureScreen extends StatefulWidget {
//   final String imagePath;
//   final FlutterTts tts;
//   const DisplayPictureScreen(
//       {super.key, required this.imagePath, required this.tts});
//   @override
//   DisplayPictureState createState() => DisplayPictureState();
// }

// class DisplayPictureState extends State<DisplayPictureScreen> {
//   var tmpRes;
//   Future<String> callApi(dynamic file) async {
//     // var postUri = Uri.parse("http://211.184.1.44:5000/predict");
//     var postUri = Uri.parse("http://172.20.10.8:5000/predict");
//     var request = http.MultipartRequest("POST", postUri);
//     request.files.add(await http.MultipartFile.fromPath(
//         "file", widget.imagePath,
//         contentType: new MediaType('image', 'jpeg')));

//     // Await the http get response, then decode the json-formatted response.
//     var streamedResponse = await request.send();
//     var response = await http.Response.fromStream(streamedResponse);
//     var data = response.body;
//     return data;
//   }

//   @override
//   void initState() {
//     // api 호출
//     callApi(File(widget.imagePath)).then((value) {
//       print(value);
//       final ans = json.decode(value);
      
//       getTranslation_papago(ans["ans"]).then((value) {
//         tmpRes = value;
//         widget.tts.speak(value);
//         widget.tts.speak("사진 저장을 원하시면 화면을 두드려주세요!");
//       });
//       // widget.tts.speak(res);
//     });
    
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     widget.tts.speak("사진을 해석중입니다");
    
//     return Scaffold(
      
//       appBar: AppBar(title: const Text('Display the Picture')),
//       // // The image is stored as a file on the device. Use the `Image.file`
//       // // constructor with the given path to display the image.

//       body:GestureDetector(
//           onTap: () {
//             GallerySaver.saveImage(widget.imagePath,albumName: "MyMemory").then((value) => widget.tts.speak("사진 저장을 성공하였습니다."));
//             print(tmpRes);
//             String imageName = widget.imagePath.split("/").last;
//             print(imageName);
//             addItem(imageName, tmpRes);
//             SQLHelper.getInfos().then((value)=> print(value));
//           },
//         child:Container(
//           child: Image.file(File(widget.imagePath)),
//         )
//       )
//     );
//     // );
//   }
// }

// Future getTranslation_papago(String txt) async {
//   String _client_id = "WYX9Cy9eD1ffV5IUEDAo";
//   String _client_secret = "n2AsCIc6L6";
//   String _content_type = "application/x-www-form-urlencoded; charset=UTF-8";
//   String _url = "https://openapi.naver.com/v1/papago/n2mt";

//   http.Response trans = await http.post(
//     Uri.parse(_url),
//     headers: {
//       'Content-Type': _content_type,
//       'X-Naver-Client-Id': _client_id,
//       'X-Naver-Client-Secret': _client_secret
//     },
//     body: {
//       'source': "en", //위에서 언어 판별 함수에서 사용한 language 변수
//       'target': "ko", //원하는 언어를 선택할 수 있다.
//       'text': txt,
//     },
//   );
//   if (trans.statusCode == 200) {
//     var dataJson = jsonDecode(trans.body);
//     var resultPapago = dataJson['message']['result']['translatedText'];
//     return resultPapago;
//   } else {
//     return trans.statusCode;
//   }
// }

// Future<void> addItem(String imgname, String imgdesc) async {
//     await SQLHelper.createInfo(
//         imgname, imgdesc);
//   }

// // Delete an item
// void deleteItem(String imgName) async {
//   await SQLHelper.deleteItem(imgName).then((value) => print("성공적으로 삭제되었습니다."));
  
// }
