import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';

class DetailRoute extends StatelessWidget {
  AssetEntity image;
  FlutterTts tts;
  String desc;
  DetailRoute({
    required this.image,
    required this.tts,
    required this.desc,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contstraints) {
      return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Detail'),
        // ),
        body: Stack(children: [
          Container(
              // color: Colors.,
              child: PhotoView(
            imageProvider: AssetEntityImageProvider(image),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
          )),
          // Text(desc)
        ]),
      );
    });
  }
}
