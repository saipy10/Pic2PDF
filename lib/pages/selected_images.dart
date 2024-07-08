import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_to_pdf/constants/images_list.dart';
import 'package:img_to_pdf/pages/image_cropper_page.dart';
import 'package:img_to_pdf/widgets/button_utility.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class SelectedImages extends StatefulWidget {
  const SelectedImages({super.key});

  @override
  State<SelectedImages> createState() => _SelectedImagesState();
}

class _SelectedImagesState extends State<SelectedImages> {
  late double progressValue = 0;
  late bool isExporting = false;
  late int convertedImage = 0;
  late File filePath;
  final TextEditingController _nameController =
      TextEditingController(text: "Generated_PDF_0");

  Future<PermissionStatus> cameraPermissionStatus() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;

    if (!cameraPermissionStatus.isGranted) {
      await Permission.camera.request();
    }
    cameraPermissionStatus = await Permission.camera.status;
    return cameraPermissionStatus;
  }

  void convertImage(String name) async {
    setState(() {
      isExporting = true;
    });

    final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);

    final pdf = pw.Document();

    for (final imagePath in imagesList.imagePaths) {
      final imageBytes = await File(imagePath.path).readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image != null) {
        final pdfImage = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage));
          }),
        );
      }

      setState(() {
        convertedImage++;
        progressValue = convertedImage / imagesList.imagePaths.length;
      });
    }

    final outputFile = File('$pathToSave/$name.pdf');
    filePath = outputFile;
    await outputFile.writeAsBytes(await pdf.save());

    MediaScanner.loadMedia(path: outputFile.path);
  }

  void addGalleryImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      imagesList.imagePaths.addAll(images);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SelectedImages()),
      );

      print(imagesList.imagePaths.toString());
    }
  }

  void cropImage(int index) async {
    setState(() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ImageCropperPage(index: index)));
    });
  }

  void captureCameraImages() async {
    PermissionStatus status = await cameraPermissionStatus();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
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

  Future<void> openFile(File filepath) async {
    await OpenFile.open(filepath.path);
  }

  SnackBar showSnackBar() {
    print(imagesList.imagePaths.length);
    print("snack bar should be there");
    const snackdemo = SnackBar(
      content: Text('Enter images first'),
      backgroundColor: Colors.blueGrey,
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(5),
    );
    return snackdemo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Selected Images",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      bottomNavigationBar: Visibility(
        visible: !isExporting,
        child: Row(
          children: [
            Expanded(
              child: myButton(
                "Convert to PDF",
                () => (imagesList.imagePaths.isNotEmpty)
                    ? convertImage(_nameController.text.toString())
                    : ScaffoldMessenger.of(context)
                        .showSnackBar(showSnackBar()),
              ),
            ),
            const Gap(1),
            Expanded(child: myButton("Add from gallery", addGalleryImage)),
            const Gap(1),
            Expanded(child: myButton("Capture image", captureCameraImages)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: isExporting,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      minHeight: 25,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                      value: progressValue,
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.3),
                    (progressValue == 1)
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                              onPressed: () => openFile(filePath),
                              child: const Text(
                                "View PDF",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 40),
                              ),
                            ),
                          )
                        : const Text(""),
                  ],
                ),
              ),
            ),
            const Gap(10),
            Visibility(
              visible: !isExporting,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "File name",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ReorderableGridView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: imagesList.imagePaths.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        key: ValueKey(imagesList.imagePaths[index]),
                        color: Colors.red[50],
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image(
                              image: FileImage(
                                File(imagesList.imagePaths[index].path),
                              ),
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              right: 5,
                              bottom: 5,
                              child: IconButton(
                                onPressed: () => {
                                  setState(() {
                                    imagesList.imagePaths.removeAt(index);
                                  })
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outline_sharp,
                                  color: Colors.redAccent,
                                  size: 30,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 5,
                              bottom: 5,
                              child: IconButton(
                                onPressed: () => cropImage(index),
                                icon: const Icon(
                                  Icons.crop,
                                  color: Colors.redAccent,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        final element =
                            imagesList.imagePaths.removeAt(oldIndex);
                        imagesList.imagePaths.insert(newIndex, element);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
