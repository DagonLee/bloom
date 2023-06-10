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
    print("_selectImage::grid_photo");
    print(item.entity);
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
            // _dimContainer(e),
            // _selectNumberContainer(e)
          ],
        ),
      ),
    );
  }
  // Widget _dimContainer(AssetEntity e) {
  //   final isSelected = selectedImages.any((element) => element.entity == e);
  //   return Positioned.fill(
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: isSelected ? Colors.black38 : Colors.transparent,
  //         border: Border.all(
  //           color: isSelected ? Colors.lightBlue : Colors.transparent,
  //           width: 5,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _selectNumberContainer(AssetEntity e) {
  //   final num = selectedImages.indexWhere((element) => element.entity == e) + 1;
  //   return Positioned(
  //       right: 10,
  //       top: 10,
  //       child: num != 0
  //           ? Container(
  //               padding: const EdgeInsets.all(10.0),
  //               decoration: const BoxDecoration(
  //                 color: Colors.blue,
  //                 shape: BoxShape.circle,
  //               ),
  //               child: Text(
  //                 '$num',
  //                 style: const TextStyle(color: Colors.white),
  //               ),
  //             )
  //           : const SizedBox());
  // }
}
