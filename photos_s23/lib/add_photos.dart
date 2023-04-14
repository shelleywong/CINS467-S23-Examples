import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class AddPhotos extends StatefulWidget {
  const AddPhotos({super.key, required this.title});

  final String title;

  @override
  State<AddPhotos> createState() => _MyAddPhotosState();
}

class _MyAddPhotosState extends State<AddPhotos> {
  File? _image;
  Position? _position;
  final TextEditingController _myController = TextEditingController();

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    // Capture photo
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (photo != null) {
        _image = File(photo.path);
      }
    });
  }

  Future<void> _upload() async {
    if (_image != null) {
      _position = await _determinePosition();
      // Generate a v4 (random) id (universally unique identifier)
      const uuid = Uuid();
      final String uid = uuid.v4();
      // Upload image file to storage (using uid) and generate a downloadURL
      final String downloadURL = await _uploadFile(uid);
      // Add downloadURL (ref to the image) to the database
      await _addItem(downloadURL, uid);
      // Navigate back to the previous screen
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<String> _uploadFile(String filename) async {
    // Create a reference to file location in Google Cloud Storage object
    Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    // Add metadata to the image file
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      contentLanguage: 'en',
    );
    // Upload the file to Storage
    final UploadTask uploadTask = ref.putFile(_image!, metadata);
    TaskSnapshot uploadResult = await uploadTask;
    // After the upload task is complete, get a (String) download URL
    final String downloadURL = await uploadResult.ref.getDownloadURL();
    // Return the download URL (to be used in the database entry)
    return downloadURL;
  }

  Future<void> _addItem(String downloadURL, String id) async {
    await FirebaseFirestore.instance.collection('photos').add(<String, dynamic>{
      'downloadURL': downloadURL,
      'title': _myController.text,
      'geopoint': GeoPoint(_position!.latitude, _position!.longitude),
      'timestamp': DateTime.now(),
      'id': id,
    });
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
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
            Expanded(
              flex: 4,
              child: _image == null
                  ? const Text('no image selected')
                  : Image.file(_image!, width: 300),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton(
                  onPressed: _getImage,
                  child: const Text(
                    'Take a Photo',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _myController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Image Title',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton(
                  onPressed: _upload,
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.cyan),
                  ),
                  child: const Text(
                    'Upload Photo',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
