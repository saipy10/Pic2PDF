import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_to_pdf/widgets/images_list_class.dart';
import 'package:img_to_pdf/pages/selected_images.dart';
import 'package:img_to_pdf/widgets/button_utility.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ImagesList imagesList = ImagesList();

  Future<PermissionStatus> storagePermissionStatus() async {
    PermissionStatus storagePermissionStatus = await Permission.storage.status;

    if (!storagePermissionStatus.isGranted) {
      await Permission.storage.request();
    }
    storagePermissionStatus = await Permission.storage.status;
    return storagePermissionStatus;
  }

  Future<PermissionStatus> cameraPermissionStatus() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;

    if (!cameraPermissionStatus.isGranted) {
      await Permission.camera.request();
    }
    cameraPermissionStatus = await Permission.camera.status;
    return cameraPermissionStatus;
  }

  void pickGalleryImage() async {
    PermissionStatus status = await storagePermissionStatus();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        imagesList.clearImagesList();
        imagesList.imagePaths.addAll(images);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectedImages()),
        );
      }
    }
  }

  void captureCameraImages() async {
    PermissionStatus status = await cameraPermissionStatus();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        imagesList.clearImagesList();
        imagesList.imagePaths.add(image);
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SelectedImages(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Convert Images to PDF 📄",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            myButton("Select from gallery", pickGalleryImage),
            const Gap(10),
            myButton("Capture images", captureCameraImages),
          ],
        ),
      ),
    );
  }
}
