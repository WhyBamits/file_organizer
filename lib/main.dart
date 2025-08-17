import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'settings_page.dart';

void main() {
  runApp(SimpleFileOrganizerApp());
}

class SimpleFileOrganizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple File Organizer',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MultiOnboardingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/onboard2.jpeg', fit: BoxFit.cover),
          Container(color: Colors.deepPurple.withOpacity(0.6)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text('Simple File Organizer',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Onboarding Pages
class MultiOnboardingPage extends StatefulWidget {
  @override
  _MultiOnboardingPageState createState() => _MultiOnboardingPageState();
}

class _MultiOnboardingPageState extends State<MultiOnboardingPage> {
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/splash.webp',
      'title': 'Welcome to Simple File Organizer!',
      'subtitle': 'Organize and preview your documents easily.🗃️📚',
    },
    {
      'image': 'assets/onboard1.jpeg',
      'title': 'Quick File Access',
      'subtitle': 'Browse and find your files with ease.🔍📂',
    },
    {
      'image': 'assets/onboard3.jpeg',
      'title': 'Preview and Print',
      'subtitle': 'Preview DOCX & PDF and print instantly.🖨️📄',
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      setState(() => _currentPage++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = onboardingData[_currentPage];

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: SafeArea(
        child: Column(
          children: [
            Spacer(),
            Image.asset(current['image']!, height: 220),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    current['title']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    current['subtitle']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                child: Text(_currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

// Dashboard and File Handling
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? directoryPath;
  List<FileSystemEntity> files = [];
  List<FileSystemEntity> filteredFiles = [];
  TextEditingController searchController = TextEditingController();
  final List<String> supportedExtensions = ['.pdf', '.doc', '.docx', '.xls', '.xlsx'];

  void pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        directoryPath = selectedDirectory;
        loadFiles();
      });
    }
  }

  void loadFiles() {
    if (directoryPath != null) {
      final dir = Directory(directoryPath!);
      final allFiles = dir.listSync().whereType<File>().toList();
      files = allFiles.where((file) {
        final ext = p.extension(file.path).toLowerCase();
        return supportedExtensions.contains(ext);
      }).toList();
      filteredFiles = List.from(files);
      setState(() {});
    }
  }

  void filterFiles(String query) {
    if (query.isEmpty) {
      filteredFiles = List.from(files);
    } else {
      filteredFiles = files.where((file) {
        return p.basename(file.path).toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  void openFile(FileSystemEntity file) {
    OpenFile.open(file.path);
  }

  void previewFile(FileSystemEntity file) {
    final ext = p.extension(file.path).toLowerCase();
    if (ext == '.pdf') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(file: file),
      ));
    } else if (ext == '.docx') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => DocxPreviewScreen(file: file),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preview not supported for this file type')));
    }
  }

  void printFile(FileSystemEntity file) {
    Printing.layoutPdf(onLayout: (_) => File(file.path).readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: Colors.deepPurple.shade700,
            child: Column(
              children: [
                DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 48, color: Colors.white),
                      SizedBox(height: 8),
                      Text('File Organizer', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.dashboard, color: Colors.white),
                  title: Text('Dashboard', style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text('Settings', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 1,
                  title: Text('Dashboard', style: TextStyle(color: Colors.black)),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.folder_open, color: Colors.black),
                      onPressed: pickFolder,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search files...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: filterFiles,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: filteredFiles.isEmpty
                        ? Center(child: Text('No files found.'))
                        : ListView.builder(
                            itemCount: filteredFiles.length,
                            itemBuilder: (context, index) {
                              final file = filteredFiles[index];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.insert_drive_file, color: Colors.deepPurple),
                                      title: Text(p.basename(file.path)),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton.icon(
                                          icon: Icon(Icons.open_in_new),
                                          label: Text("Open"),
                                          onPressed: () => openFile(file),
                                        ),
                                        TextButton.icon(
                                          icon: Icon(Icons.visibility),
                                          label: Text("Preview"),
                                          onPressed: () => previewFile(file),
                                        ),
                                        TextButton.icon(
                                          icon: Icon(Icons.print),
                                          label: Text("Print"),
                                          onPressed: () => printFile(file),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PDF Preview Screen
class PdfPreviewScreen extends StatelessWidget {
  final FileSystemEntity file;
  PdfPreviewScreen({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Preview')),
      body: PdfPreview(
        build: (format) => File(file.path).readAsBytes(),
      ),
    );
  }
}

// DOCX Preview Screen
class DocxPreviewScreen extends StatelessWidget {
  final FileSystemEntity file;
  DocxPreviewScreen({required this.file});

  Future<String> extractTextFromDocx(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    final docXml = archive.firstWhere((file) => file.name == 'word/document.xml');
    final content = utf8.decode(docXml.content as List<int>);
    final document = xml.XmlDocument.parse(content);
    final textBuffer = StringBuffer();
    document.findAllElements('w:t').forEach((element) {
      textBuffer.write(element.text);
    });
    return textBuffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DOCX Preview')),
      body: FutureBuilder<String>(
        future: extractTextFromDocx(file.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Failed to preview DOCX file'));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(snapshot.data ?? '', style: TextStyle(fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
