import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'selected_image.dart';

class GridPhoto extends StatelessWidget {
  List<AssetEntity> images;
  ValueChanged<SelectedImage> onTap;

  GridPhoto({
    required this.images,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  void _selectImage(AssetEntity e) {
    // final item = SelectedImage(entity: e, file: null);
    final item = SelectedImage(entity: e);
    onTap(item);
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      physics: const BouncingScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      children: images.map((e) {
        return _gridPhotoItem(e);
      }).toList(),
    );
  }

  Widget _gridPhotoItem(AssetEntity e) {
    return GestureDetector(
      onTap: () {
        _selectImage(e);
      },
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetEntityImage(
                e,
                isOriginal: false,
                fit: BoxFit.cover,
              ),
            ),

          ],
        ),
      ),
    );
  }
}