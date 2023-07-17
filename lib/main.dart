import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
// import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImagePickerWidget(),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({Key? key}) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;
  String extractedText = '';
  bool loading = false;

  Future<void> _chooseImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _chooseImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _chooseImage(ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _selectedImage != null
              ? Center(
                  child: Image.file(
                    _selectedImage!,
                    width: 300,
                    height: 300,
                  ),
                )
              : const Center(
                  child: Text('No image selected'),
                ),
          ElevatedButton(
            onPressed: () async {
              await _showImageSourceDialog();
              if (_selectedImage != null) {
                extractedText = await FlutterTesseractOcr.extractText(
                  _selectedImage!.path,
                  args: {
                    "psm": "4",
                    "preserve_interword_spaces": "1",
                  },
                );
              }
              setState(() {
                loading = false;
              });
            },
            child: const Text('Pick Image'),
          ),
          const SizedBox(height: 30),
          loading
              ? const CircularProgressIndicator()
              : Text(
                  extractedText,
                ),
        ],
      ),
    );
  }
}
