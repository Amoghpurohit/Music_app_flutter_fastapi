import 'dart:io';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_form_field_text.dart';
import 'package:client/core/widgets/progress_loader.dart';
import 'package:client/features/home/viewModel/home_viewmodel.dart';
import 'package:client/features/home/widgets/audio_wave.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<UploadSongPage> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final _artistController = TextEditingController();
  final _songNameController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedImage;
  File? selectedAudio;
  final _formKey = GlobalKey<FormState>();

  void selectImage() async {
    final image = await pickImage();
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  void selectAudio() async {
    final audio = await pickAudio();
    if (audio != null) {
      setState(() {
        selectedAudio = audio;
      });
    }
  }

  @override
  void dispose() {
    _artistController.dispose();
    _songNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(homeViewModelProvider.select((value) => value?.isLoading == true));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Song',
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if(_formKey.currentState!.validate() && selectedAudio != null && selectedImage != null){
              ref.read(homeViewModelProvider.notifier).songUpload(
                  audioFile: selectedAudio!,      //are not part of the textFormField
                  imageFile: selectedImage!,
                  artist: _artistController.text,
                  songName: _songNameController.text,
                  hexCode: selectedColor);
              }else{
                showSnackBar(context, 'Missing fields');
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: isLoading ? const ProgressLoader() :
       SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    onTap: selectImage,
                    child: selectedImage != null
                        ? SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : DottedBorder(
                            color: Pallete.borderColor,
                            dashPattern: const [10, 10],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            strokeCap: StrokeCap.round,
                            child: const SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 40,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text('Select the thumbnail for your song'),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                selectedAudio != null
                    ? AudioWaveForm(path: selectedAudio!.path)
                    : //.path getter exists for File to get the file path directly
                    CustomTextFormField(
                        text: 'Pick Song',
                        controller: null,
                        readOnly: true,
                        onTap: selectAudio,
                      ),
                const SizedBox(
                  height: 30,
                ),
                CustomTextFormField(
                    text: 'Artist', controller: _artistController),
                const SizedBox(
                  height: 30,
                ),
                CustomTextFormField(
                    text: 'Song Name', controller: _songNameController),
                const SizedBox(
                  height: 30,
                ),
                ColorPicker(
                  pickersEnabled: const {ColorPickerType.wheel: true},
                  color: selectedColor,
                  onColorChanged: (color) {
                    setState(
                      () {
                        selectedColor = color;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
