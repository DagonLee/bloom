import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'display_picture.dart';
import '../sqlhelper.dart';
import '../main.dart';
import 'package:namer_app/gallery/sample_screen.dart';

class RecordPage extends StatefulWidget {
  final CameraDescription camera;
  final FlutterTts tts;
  RecordPage({super.key, required this.camera, required this.tts});
  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  var selectedIndex = 1;

  @override
  void initState() {
    _speak("촬영모드입니다.");
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  Future _speak(String txt) async {
    if (txt != "") {
      await widget.tts.speak(txt);
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    SQLHelper.getInfos().then((value) => print(value));
    return Scaffold(
      appBar: AppBar(title: const Text('촬영 모드')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Column(children: [
              Expanded(
                child: CameraPreview(
                  _controller,
                ),
              ),
            ]);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   // Provide an onPressed callback.
      //   onPressed: () async {
      //     // Take the Picture in a try / catch block. If anything goes wrong,
      //     // catch the error.
      //     try {
      //       // Ensure that the camera is initialized.
      //       await _initializeControllerFuture;

      //       // Attempt to take a picture and get the file `image`
      //       // where it was saved.
      //       final image = await _controller.takePicture();

      //       if (!mounted) return;

      //       // If the picture was taken, display it on a new screen.
      //       await Navigator.of(context).push(
      //         MaterialPageRoute(
      //           builder: (context) => DisplayPictureScreen(
      //               // Pass the automatically generated path to
      //               // the DisplayPictureScreen widget.
      //               imagePath: image.path,
      //               tts: widget.tts),
      //         ),
      //       );
      //     } catch (e) {
      //       // If an error occurs, log the error to the console.
      //       print(e);
      //     }
      //   },
      //   child: const Icon(Icons.camera_alt),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: colorScheme.background,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.camera_alt,
              size: 40,
            ),
            label: 'photo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'gallery',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: colorScheme.primary,
        onTap: (value) async {
          if (value == 0) {
            print("home");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => MyHomePage(
                        title: 'MyMemory Proto1', camera: widget.camera)),
                (route) => false);

            // Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => MyHomePage(
            //           title: 'MyMemory Proto1', camera: widget.camera)),
            // );
          } else if (value == 1) {
            print("사진 촬영");
            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              // Attempt to take a picture and get the file `image`
              // where it was saved.
              final image = await _controller.takePicture();

              if (!mounted) return;

              // If the picture was taken, display it on a new screen.
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                      // Pass the automatically generated path to
                      // the DisplayPictureScreen widget.
                      imagePath: image.path,
                      tts: widget.tts),
                ),
              );
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          } else if (value == 2) {
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
  }
}
