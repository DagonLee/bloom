import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:photo_manager/photo_manager.dart';

import 'album.dart';
import 'grid_photo.dart';
import 'selected_image.dart';
import 'detail_route.dart';
import '../sqlhelper.dart';



class AlbumRoute extends StatefulWidget {
  const AlbumRoute({super.key, required this.tts});
  final FlutterTts tts;
  @override
  State<AlbumRoute> createState() => _AlbumRouteState();
}

class _AlbumRouteState extends State<AlbumRoute> {
  List<AssetPathEntity>? _paths;
  List<Album> _albums = [];
  late List<AssetEntity> _images;
  int _currentPage = 0;
  late Album _currentAlbum;

  //권한 확인
  Future<void> checkPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      //Granted
      await getAlbum();
    } else {
      //Rejected or Limited
      await PhotoManager.openSetting(); //권한 설정 페이지 이동
    }
  }

  Future<void> getAlbum() async {
    _paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    _paths!.removeWhere((item) => item.name != "MyMemory");
    // print("*****");
    print( _paths);
    _albums = _paths!.map((e) {
      return Album(
        id: e.id,
        // name: e.isAll ? '모든 사진' : e.name,
        name: e.name,
      );
    }).toList();

    await getPhotos(_albums[0], albumChange: true);
  }

  Future<void> getPhotos(
    Album album, {
    bool albumChange = false,
  }) async {
    _currentAlbum = album;
    albumChange ? _currentPage = 0 : _currentPage++;

    final loadImages = await _paths!
        .singleWhere((element) => element.id == album.id)
        .getAssetListPaged(
          page: _currentPage,
          size: 20,
        );

    final photoCount = await _paths!
        .singleWhere((element) => element.id == album.id)
        .assetCountAsync;
    print(loadImages.length);
    print(photoCount);
    setState(() {
      if (albumChange) {
        _images = loadImages;
      } else {
        _images.addAll(loadImages);
      }
    });
  }

  void _selectImage(SelectedImage image) async {
    print("_selectImage::sample_screen.dart");
    File? originFile = await image.entity.originFile;
    String originPath = originFile!.path;
    String file_name = originPath.split("/").last;
    SQLHelper.getItem(file_name).then((value)=> {
        widget.tts.speak(value.first["imgDesc"])
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailRoute(image: image.entity, tts: widget.tts)),
    );
    // final addedImageCheck =
    //     _selectedImages.any((e) => _addedImageCheck(image, e));

    // setState(() {
    //   if (addedImageCheck) {
    //     _selectedImages.removeWhere((e) => _addedImageCheck(image, e));
    //   } else {
    //     final item = SelectedImage(entity: image.entity, file: image.file);
    //     _selectedImages.add(item);
    //   }
    // });

    // if (!addedImageCheck && _scrollController.hasClients) {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
            child: _albums.isNotEmpty
                ? DropdownButton(
                    value: _currentAlbum,
                    items: _albums
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            ))
                        .toList(),
                    onChanged: (value) => getPhotos(value!, albumChange: true),
                  )
                : const SizedBox()),
      ),
      body: NotificationListener<ScrollNotification>(
        // 현재 스크롤 위치 - scroll.metrics.pixels
        // 스크롤 끝 위치 scroll.metrics.maxScrollExtent
        onNotification: (ScrollNotification scroll) {
          final scrollPixels =
              scroll.metrics.pixels / scroll.metrics.maxScrollExtent;

          print('scrollPixels = $scrollPixels');
          if (scrollPixels > 0.7) getPhotos(_currentAlbum);

          return false;
        },
        child: SafeArea(
          child: _paths == null
              ? const Center(child: CircularProgressIndicator())
              : GridPhoto(
                  images: _images,
                  onTap: _selectImage,
                ),
        ),
      ),
    );
  }
}
