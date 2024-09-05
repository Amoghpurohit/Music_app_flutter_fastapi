import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          content,
        ),
      ),
    );
}

Future<File?> pickAudio() async {
  try {
    final pickedAudioFile = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (pickedAudioFile != null && pickedAudioFile.files.isNotEmpty) {
      return File(pickedAudioFile.files.first.xFile.path);
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<File?> pickImage() async {
  try {
    final pickedImageFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // allowCompression: false,
      // withData: true
      compressionQuality: 0,
      
    );
    if (pickedImageFile != null && pickedImageFile.files.isNotEmpty) {
      return File(pickedImageFile.files.single.path!);
    }
    return null;
  } catch (e) {
    print('error picking as $e');
    return null;
  }
}

String rgbToHex(Color color){
  return '${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}   //example - rgbToHex(Colors.deepPurple) -> color.red extracts red from provided color i.e 61, so 61.toRadixString(16) is 3d.padLeft(2,'0') is 3d, similarly for green and blue

Color hexToColor(String hex){
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}