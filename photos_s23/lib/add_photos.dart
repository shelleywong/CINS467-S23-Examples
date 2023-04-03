import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPhotos extends StatefulWidget{
  const AddPhotos({super.key, required this.title});

  final String title;

  @override
  State<AddPhotos> createState() => _MyAddPhotosState();
}

class _MyAddPhotosState extends State<AddPhotos> {
  File? _image;

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    // Capture photo
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if(photo != null){
        _image = File(photo.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _image == null
              ? const Text('no image selected')
              : Image.file(_image!, width: 300),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text(
                'Take a photo',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}