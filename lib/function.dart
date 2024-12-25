import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pdfviewpage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

// file picker dialog
Future<void> pickPdfFile({required BuildContext context}) async {
  // Menggunakan FilePicker untuk memilih file PDF
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'], // Hanya izinkan file PDF
  );

  if (result != null) {
    // Navigasi ke halaman baru untuk menampilkan PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewPage(filePath: result.files.single.path!),
      ),
    );
  } else {
    // User membatalkan pemilihan file
    _showFilePathDialog('Tidak ada file yang dipilih.', context);
  }
}

// pop up jika tidak ada file yang dipilih
void _showFilePathDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hasil Pemilihan File'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Tutup'),
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
            },
          ),
        ],
      );
    },
  );
}

// fungsi untuk mencari list file pdf
Future<List<PdfFile>> findAllPdfFiles() async {
  List<PdfFile> pdfFiles = [];
  // Memeriksa izin sebelum mencari file
  if (await Permission.storage.isGranted) {
    // Mendapatkan direktori penyimpanan eksternal
    Directory? externalDir = await getExternalStorageDirectory();
    Directory? parentDir = (externalDir?.parent.parent.parent.parent);
    print(parentDir);
    if (parentDir != null) {
      // Mencari semua file PDF di direktori penyimpanan eksternal
      List<FileSystemEntity> files =
          parentDir!.listSync(recursive: true, followLinks: true);
      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          var fileStat = file.statSync();
          pdfFiles.add(PdfFile(
              file.path, fileStat.changed)); // Menambahkan file PDF ke daftar
        }
      }
    }
  } else {
    // Tampilkan pesan jika izin tidak diberikan
    print('Storage permission not granted');
  }
  // sort file pdf berdasarkan yang terbaru
  pdfFiles.sort((a, b) => b.createdTime.compareTo(a.createdTime));
  print(pdfFiles);
  return pdfFiles;
}

// permintaan izin aplikasi
Future<void> requestPermissions() async {
  // Meminta izin untuk membaca penyimpanan
  var status = await Permission.storage.status;
  print(status);
  if (!status.isGranted) {
    // Jika izin belum diberikan, minta izin
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }
}

// format list pdf
class PdfFile {
  final String path;
  final DateTime createdTime;

  PdfFile(this.path, this.createdTime);
}

// membuat preview image
Future<PdfPageImage?> getImage(String path) async {
  final document = await PdfDocument.openFile(path);

  final page = await document.getPage(1);

  final image = await page.render(
    width: page.width * 2, //decrement for less quality
    height: page.height * 2,
    format: PdfPageImageFormat.jpeg,
    backgroundColor: '#ffffff',

    // Crop rect in image for render
    //cropRect: Rect.fromLTRB(left, top, right, bottom),
  );

  return image;
}

// intent jika aplikasi dibuka dari file

