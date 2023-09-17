import 'package:bloc_notas/archivo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  final title = "Bloc de notas | Web App";

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

class _Page extends State<Page> {
  List<Archivo> archivos = [];
  List<TextButton> botones = [];
  var content = "";
  var title = "Bloc de Notas";
  TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  _Page() {
    archivos.add(Archivo("¡Bienvenido!",
        "¡Hola! Gracias por probar mi web app.\nSaludos, Alexito Snow."));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    botones.clear();
    for (Archivo archivo in archivos) {
      var text = TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
            fixedSize: Size(width * 0.3, height * 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
          ),
          onPressed: () => setState(() {
                content = archivo.contenido;
                title = archivo.nombre;
              }),
          child: Text(
            archivo.nombre,
          ));
      botones.add(text);
    }
    _contentController = TextEditingController(text: content);
    Archivo temporal = Archivo(title, "");
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black54,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: guardar,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => borrar(temporal),
          ),
          IconButton(
              icon: const Icon(Icons.drive_file_rename_outline),
              onPressed: () => {
                    if (title != "Bloc de Notas")
                      {
                        temporal = Archivo(title, ""),
                        showDialog(
                            barrierColor: const Color.fromRGBO(0, 0, 0, 0.582),
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Renombrar Archivo"),
                                content: TextField(
                                  controller: _titleController..text = title,
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        if (_titleController.text.toString() !=
                                            "Bloc de Notas") {
                                          renombrar(temporal);
                                          guardar();
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: const Text("Renombrar"))
                                ],
                              );
                            })
                      }
                  }),
          IconButton(onPressed: crear, icon: const Icon(Icons.add))
        ],
      ),
      body: Center(
        child: Row(
          children: [
            Container(
              width: width * 0.3,
              height: height,
              color: Colors.black54,
              child: Column(
                children: botones,
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

  void guardar() {
    if (title != "Bloc de Notas") {
      content = _contentController.text;
      var temporal = Archivo(title, "");
      setState(() {
        archivos[archivos.indexOf(temporal)].contenido = content;
      });
    }
  }

  void renombrar(Archivo temporal) {
    setState(() {
      archivos[archivos.indexOf(temporal)].nombre =
          _titleController.text.toString();
      title = _titleController.text.toString();
    });
  }

  void borrar(Archivo temporal) {
    if (title != "Bloc de Notas") {
      temporal = Archivo(title, "");
      setState(() {
        archivos.removeAt(archivos.indexOf(temporal));
        content = "";
        title = "Bloc de Notas";
      });
    }
  }

  void crear() {
    guardar();
    showDialog(
        barrierColor: const Color.fromRGBO(0, 0, 0, 0.582),
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Crear Archivo"),
            content: TextField(
              controller: _titleController
                ..text = "Archivo ${archivos.length + 1}",
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    if (_titleController.text.toString() != "Bloc de Notas") {
                      setState(() {
                        archivos
                            .add(Archivo(_titleController.text.toString(), ""));
                      });
                      title = _titleController.text.toString();
                      content = "";
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Agregar"))
            ],
          );
        });
  }
}
