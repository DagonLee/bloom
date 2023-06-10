import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class DetailRoute extends StatelessWidget {
  AssetEntity image;

  DetailRoute({
    required this.image,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailRoute'),
      ),
      body: Column(
        children: [
          Positioned.fill(
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
