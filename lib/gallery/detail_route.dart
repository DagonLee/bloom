import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:photo_manager/photo_manager.dart';

class DetailRoute extends StatelessWidget {
  AssetEntity image;
  
  FlutterTts tts;

  DetailRoute({
    required this.image,
    Key? key, required this.tts,
    
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailRoute'),
      ),
      body: Column(
        children: [
          Container(
            child: AssetEntityImage(
              image,
              isOriginal: true,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to first route when tapped.
              },
              child: const Text('Go back!'),
            ),
          ),
        ],
      ),
    );
  }
}
