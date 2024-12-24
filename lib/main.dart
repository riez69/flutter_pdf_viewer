// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
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
      title: 'PDF Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 24, 16, 37)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PDF Viewer'),
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

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white, // Warna latar belakang
                              borderRadius:
                                  BorderRadius.circular(10), // Sudut melengkung
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Warna bayangan
                                  spreadRadius: 2, // Jarak bayangan
                                  blurRadius: 5, // Kelembutan bayangan
                                  offset: const Offset(0, 3), // Posisi bayangan
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(_pdffiles[index]
                                  .path
                                  .split("/")[_lastIndex]
                                  .toString()),
                              subtitle: Text(_pdfCreateTime),
                              leading: SizedBox(
                                height: 50,
                                width: 50,
                                child: FutureBuilder(
                                    future: getImage(_pdfPath),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                snapshot.error.toString()));
                                      } else {
                                        Center(
                                            child: Image.memory(
                                                snapshot.data!.bytes));
                                      }
                                      return Container(
                                          padding: const EdgeInsets.all(1.0),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255,
                                                124,
                                                124,
                                                124), // Warna latar belakang untuk leading
                                            borderRadius: BorderRadius.circular(
                                                8), // Sudut melengkung
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(
                                                    0.3), // Warna bayangan untuk leading
                                                spreadRadius:
                                                    1, // Jarak bayangan
                                                blurRadius:
                                                    3, // Kelembutan bayangan
                                                offset: const Offset(
                                                    0, 2), // Posisi bayangan
                                              ),
                                            ],
                                          ),
                                          child: Image.memory(
                                              snapshot.data!.bytes));
                                    }),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PdfViewPage(filePath: _pdfPath)));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (_displayedFiles.length < _pdffiles.length)
                      TextButton(
                        child: const Text("Selengkapnya"),
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
