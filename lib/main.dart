import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:file_picker/file_picker.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';
import 'package:pdf_viewer/pdfviewpage.dart';
import 'function.dart';

void main() {
  // Ensure the Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set the app to fullscreen mode
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _displayedFileCount = 10; // Jumlah file yang ditampilkan
  @override
  void initState() {
    super.initState();
    requestPermissions(); // Meminta izin saat aplikasi dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: findAllPdfFiles(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<PdfFile>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada file PDF yang ditemukan.'));
                } else {
                  List<PdfFile> _pdffiles = snapshot.data!;
                  List<PdfFile> _displayedFiles =
                      _pdffiles.take(_displayedFileCount).toList();

                  // Mengembalikan ListView jika ada file PDF
                  return Column(children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _displayedFiles.length,
                        itemBuilder: (context, index) {
                          String _pdfPath = _pdffiles[index].path;
                          String _pdfCreateTime =
                              _pdffiles[index].createdTime.toString();
                          int _lastIndex = _pdfPath.split("/").length - 1;

                          return ListTile(
                            title: Text(_pdffiles[index]
                                .path
                                .split("/")[_lastIndex]
                                .toString()),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PdfViewPage(filePath: _pdfPath)));
                            },
                          );
                        },
                      ),
                    ),
                    if (_displayedFiles.length < _pdffiles.length)
                      TextButton(
                        child: Text("Selengkapnya"),
                        onPressed: () {
                          setState(() {
                            _displayedFileCount += 10;
                          });
                        },
                      ),
                  ]);
                }
              },
            )),
            FutureBuilder(
                future: getImage(
                  "/storage/emulated/0/Download/all_lampiran_pengumuman_pembukaan_pengadaan_cpns_kalsel_ta_2024_sign.pdf"
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  
                  } else {
                    Center(child: PdfThumbnail.fromFile("/storage/emulated/0/Download/all_lampiran_pengumuman_pembukaan_pengadaan_cpns_kalsel_ta_2024_sign.pdf", currentPage: 1));
                  }
                  return Text('dataa');
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await pickPdfFile(context: context); // Call the async function
        },
        tooltip: 'cari file pdf',
        child: const Icon(Icons.search),
      ),
    );
  }
}
