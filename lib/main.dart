import 'dart:async';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
Future<void> main() async{
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(MaterialApp(
      title: 'My Memory Proto1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'MyMemory Proto1', camera: firstCamera),
    ));
}

class MyAppState extends ChangeNotifier {
  void getNext() {
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.camera,});
  final String title;
  final CameraDescription camera;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contstraints) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
              ElevatedButton(onPressed: (){
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecordPage(camera: widget.camera)),
            );
              }, child : const Text('촬영모드')),
              ElevatedButton(onPressed: (){
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlbumRoute()),
                );
              }, child : const Text('앨범모드')),
              ]
            )
          ),
        );
      }
    );
  }
}

class AlbumRoute extends StatelessWidget {
  const AlbumRoute({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
class RecordPage extends StatefulWidget{
  final CameraDescription camera;
  RecordPage({super.key, required this.camera});
  @override
  State<RecordPage> createState() => _RecordPageState();
}
class _RecordPageState extends State<RecordPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
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

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
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
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.imagePath});
  @override
  DisplayPictureState createState() => DisplayPictureState();
}
class DisplayPictureState extends State<DisplayPictureScreen>{
  Future<String> callApi(dynamic file) async{
    var postUri = Uri.parse("http://211.184.1.44:5000/predict");
    var request = http.MultipartRequest("POST", postUri);
    request.files.add(await http.MultipartFile.fromPath("file", widget.imagePath, contentType: new MediaType('image', 'jpeg')));
    
  // Await the http get response, then decode the json-formatted response.
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var data = response.body;
    return data;
  }
  @override
  void initState()  {
    // api 호출
    callApi(File(widget.imagePath)).then((value){
      print(value);
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(widget.imagePath)),
    );
  }
}

