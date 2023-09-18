import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// The URI of the server
/// Local: Uri(scheme: 'http', host: 'localhost', port: 9090);
/// Remote: Uri(scheme: 'http', host: 'public-host');
final requestUri = Uri(scheme: 'http', host: 'localhost', port: 9090);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  final title = "Snow's Notepad | Web App";

  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        home: Page(title: title));
  }
}

class Page extends StatefulWidget {
  final String title;
  const Page({super.key, required this.title});

  @override
  State createState() => _Page();
}

/// The main page of the app
class _Page extends State<Page> {
  late Future<List<String>> names;

  var content = "";
  var title = "Notepad";

  TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    names = getTitlesRequest();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    _contentController = TextEditingController(text: content);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black54,
        actions: [
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveRequest,
              tooltip: "Save Content"),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteRequest,
              tooltip: "Delete Current File"),
          IconButton(
              icon: const Icon(Icons.drive_file_rename_outline),
              onPressed: saveButton,
              tooltip: "Rename Current File"),
          IconButton(
              onPressed: createRequest,
              icon: const Icon(Icons.add),
              tooltip: "Create New Empty File")
        ],
      ),
      body: Center(
        child: Row(
          children: [
            Container(
              width: width * 0.3,
              height: height,
              color: Colors.black54,
              child: FutureBuilder<List<String>>(
                future: names,
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                        children: snapshot.data!.map((name) {
                      return TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                            fixedSize: Size(width * 0.3, height * 0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                          onPressed: () => setState(() {
                                getContentRequest(name);
                                title = name;
                              }),
                          child: Text(name));
                    }).toList());
                  } else if (snapshot.hasError) {
                    return const Column(
                        children: [Text('Error while loading files!')]);
                  } else {
                    return const Row(
                      children: [
                        Icon(Icons.change_circle_sharp),
                        Text("Loading...")
                      ],
                    );
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              width: width * 0.7,
              height: height,
              child: TextField(
                cursorColor: Colors.black54,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                minLines: MediaQuery.of(context).size.height.toInt(),
                autofocus: true,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                controller: _contentController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a dialog to rename the current file
  void saveButton() {
    if (title != "Notepad") {
      showDialog(
          barrierColor: const Color.fromRGBO(0, 0, 0, 0.582),
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Rename File"),
              content: TextField(
                controller: _titleController..text = title,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      var newT = _titleController.text;
                      if (newT != "Notepad") {
                        renameRequest(title, newT);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Rename"))
              ],
            );
          });
    }
  }

  /// Get the content of a file from the server
  void getContentRequest(String title) async {
    var getContentUri = requestUri.replace(path: 'file/$title');
    final response = await http.get(getContentUri);
    content = response.body;
    setState(() {
      _contentController.text = content;
    });
  }

  /// Get the list of files on the server
  Future<List<String>> getTitlesRequest() async {
    var getTitlesUri = requestUri.replace(path: 'files/titles');
    final response = await http.get(getTitlesUri);
    return List<String>.from(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  /// Save the content of the file on the server
  void saveRequest() async {
    if (title != "Notepad") {
      var updateContentUri = requestUri.replace(path: 'file/$title');
      content = _contentController.text;
      final response = await http.put(updateContentUri, body: content);
      print("Saved Status: ${response.statusCode}\nBody: ${response.body}");
    }
  }

  /// Rename a file on the server
  /// and update the file list
  void renameRequest(String oldTitle, String newTitle) async {
    saveRequest();
    var renameTitleUri =
        requestUri.replace(path: 'file/rename/$oldTitle/$newTitle');
    final response = await http.put(renameTitleUri);
    print('Rename Response:\n${response.body}');
    if (response.body == "true") {
      setState(() {
        title = newTitle;
        names = getTitlesRequest();
      });
    }
  }

  /// Delete a file from the server
  /// and update the file list
  void deleteRequest() async {
    if (title != "Notepad") {
      var deleteFileUri = requestUri.replace(path: 'file/$title');
      final response = await http.delete(deleteFileUri);
      print('Delete Response:\n${response.body}');
      setState(() {
        names = getTitlesRequest();
        content = "";
        title = "Notepad";
      });
    }
  }

  /// Create a new file on the server
  /// and update the file list
  void createRequest() async {
    saveRequest();
    int nFiles = (await names).length + 1;
    // ignore: use_build_context_synchronously
    showDialog(
        barrierColor: const Color.fromRGBO(0, 0, 0, 0.582),
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Create Empty File"),
            content: TextField(
              controller: _titleController..text = "File $nFiles",
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    var newFile = _titleController.text;
                    if (newFile != "Notepad") {
                      var createFileUri =
                          requestUri.replace(path: 'file/$newFile');
                      final response = await http.post(createFileUri);
                      print('Create Response:\n${response.body}');
                      setState(() {
                        names = getTitlesRequest();
                      });
                      title = newFile;
                      content = "";
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Add"))
            ],
          );
        });
  }
}
