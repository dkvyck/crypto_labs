import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:lab2/logic/MD5.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ButtonStyle buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(vertical: 15, horizontal: 20)));

  var _fileFormKey = GlobalKey<FormState>();
  var _formKey = GlobalKey<FormState>();

  var _fileHashController = TextEditingController();
  var _fileHashLoadPathController = TextEditingController();
  var _fileHashLoadController = TextEditingController();
  var _filepathController = TextEditingController();
  var _filepathSaveController = TextEditingController();
  var _strOutputController = TextEditingController();
  var _stringInputController = TextEditingController();

  void encryptFile() {
    final file = OpenFilePicker()
      ..filterSpecification = {'All Files': '*.*'}
      ..defaultFilterIndex = 0
      ..title = 'Select a document';

    final result = file.getFile();

    if (result == null) return;

    var hash = md5.convert(result.readAsBytesSync());
    _filepathController.text = result.path;
    _fileHashController.text = hash.toString().toUpperCase();
  }

  void loadHash() {
    final file = OpenFilePicker()
      ..filterSpecification = {'MD5': '*.MD5'}
      ..defaultFilterIndex = 0
      ..title = 'Select a MD5 file';

    final result = file.getFile();

    if (result == null) return;

    var hash = result.readAsStringSync();

    _fileHashLoadPathController.text = result.path;
    _fileHashLoadController.text = hash.toUpperCase();
  }

  void saveHash() {
    if (_fileHashController.text.isEmpty ||
        !_fileFormKey.currentState!.validate()) return;

    final file = SaveFilePicker()
      ..filterSpecification = {'MD5': '*.md5'}
      ..defaultFilterIndex = 0
      ..title = 'Save a document'
      ..defaultExtension = '.md5';

    final result = file.getFile();

    if (result == null) return;

    result.writeAsStringSync(_fileHashController.text);
    _filepathSaveController.text = result.path;
  }

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context).size;
    var fieldWidth = mQuery.width * 0.6;
    return Scaffold(
      appBar: AppBar(
        title: Text('MD5 converter'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'String',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _stringInputController,
                        decoration: InputDecoration(
                            hintText: 'String to encrypt',
                            labelText: 'Input string'),
                        validator: (value) {
                          if (value != null)
                            return null;
                          else
                            return 'Provide a valid string';
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, top: 30),
                      child: ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            var out = md5.convert(Uint8List.fromList(
                                _stringInputController.text.codeUnits));
                            _strOutputController.text =
                                out.toString().toUpperCase();
                          }
                        },
                        child: Text('Hash'),
                      ),
                    )
                  ]),
                  Container(
                    width: fieldWidth,
                    child: TextField(
                      maxLines: null,
                      readOnly: true,
                      controller: _strOutputController,
                      decoration: InputDecoration(labelText: 'Output hash'),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Text(
              'Files',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            //hash file
            Row(children: [
              Container(
                width: fieldWidth,
                child: TextFormField(
                  maxLines: null,
                  readOnly: true,
                  controller: _filepathController,
                  decoration:
                      InputDecoration(hintText: 'Filepath', labelText: 'File'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty)
                      return null;
                    else
                      return 'Provide a valid path';
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, top: 30),
                child: ElevatedButton(
                  style: buttonStyle,
                  onPressed: encryptFile,
                  child: Text('Pick File'),
                ),
              )
            ]),
            // save hash
            Form(
              key: _fileFormKey,
              child: Row(children: [
                Container(
                  width: fieldWidth,
                  child: TextFormField(
                    maxLines: null,
                    readOnly: true,
                    controller: _filepathSaveController,
                    decoration: InputDecoration(
                        hintText: 'Filepath', labelText: 'Saved to'),
                    validator: (value) {
                      if (_fileHashController.text.isNotEmpty)
                        return null;
                      else
                        return 'Select a valid file';
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 30),
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: saveHash,
                    child: Text('Save Hash'),
                  ),
                )
              ]),
            ),
            Row(children: [
              Container(
                width: fieldWidth,
                child: TextFormField(
                  maxLines: null,
                  readOnly: true,
                  controller: _fileHashLoadPathController,
                  decoration: InputDecoration(
                      hintText: 'Filepath', labelText: 'Loaded from'),
                  validator: (value) {
                    if (_fileHashController.text.isNotEmpty)
                      return null;
                    else
                      return 'Select a valid file';
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, top: 30),
                child: ElevatedButton(
                  style: buttonStyle,
                  onPressed: loadHash,
                  child: Text('Load Hash'),
                ),
              )
            ]),
            Container(
              margin: EdgeInsets.only(top: 30),
              width: fieldWidth,
              child: TextFormField(
                maxLines: null,
                readOnly: true,
                controller: _fileHashController,
                decoration: InputDecoration(
                    hintText: 'Calculated hash', labelText: 'Calculated hash'),
                validator: (value) {
                  if (_fileHashController.text.isNotEmpty)
                    return null;
                  else
                    return 'Select a valid file';
                },
              ),
            ),
            Container(
              width: fieldWidth,
              child: TextFormField(
                maxLines: null,
                readOnly: true,
                controller: _fileHashLoadController,
                decoration: InputDecoration(
                    hintText: 'Loaded hash', labelText: 'Loaded hash'),
                validator: (value) {
                  if (_fileHashController.text.isNotEmpty)
                    return null;
                  else
                    return 'Select a valid file';
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
