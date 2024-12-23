import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:file_picker/file_picker.dart';
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
  @override
  void initState() {
    super.initState();
    requestPermissions(); // Meminta izin saat aplikasi dibuka
    print(findAllPdfFiles());
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
                        AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Tidak ada file PDF yang ditemukan.'));
                      } else {
                        List<String> _pdffiles = snapshot.data!;
                        ListView.builder(
                            itemCount: _pdffiles.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_pdffiles[index]),
                              );
                            });
                      }
                      return Container();
                    }))
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
