import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:lab3/logic/rc5.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ButtonStyle buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(vertical: 15, horizontal: 20)));

  final _fileFormKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();

  final _encryptedDataController = TextEditingController();
  // final _fileHashLoadPathController = TextEditingController();
  // final _fileHashLoadController = TextEditingController();
  // final _filepathController = TextEditingController();
  // final _filepathSaveController = TextEditingController();
  // final _strOutputController = TextEditingController();
  final _stringInputController = TextEditingController();

  void encryptFile() {
    final file = OpenFilePicker()
      ..filterSpecification = {'All Files': '*.*'}
      ..defaultFilterIndex = 0
      ..title = 'Select a document';

    final result = file.getFile();

    if (result == null) return;

    final rc5 =
        RC5(Uint8List.fromList(utf8.encode(_stringInputController.text)), 16);

    var inputToEncode = result.readAsBytesSync();

    var data = rc5.encryptCBCPAD(inputToEncode);
    // _filepathController.text = result.path;

    saveFile(data);
  }

  void saveFile(Uint8List output) {
    if (output.isEmpty) return;

    final file = SaveFilePicker()
      ..filterSpecification = {'TXT': '*.txt'}
      ..defaultFilterIndex = 0
      ..title = 'Save a document'
      ..defaultExtension = '.txt';

    final result = file.getFile();

    if (result == null) return;

    result.writeAsBytesSync(output, flush: true);
  }

  void decryptFile() {
    final file = OpenFilePicker()
      ..filterSpecification = {'All Files': '*.*'}
      ..defaultFilterIndex = 0
      ..title = 'Select a document';

    final result = file.getFile();

    if (result == null) return;

    final rc5 =
        RC5(Uint8List.fromList(utf8.encode(_stringInputController.text)), 16);

    var inputToDecode = result.readAsBytesSync();

    var data = rc5.decryptCBCPAD(inputToDecode);

    saveFile(data);
  }

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context).size;
    final buttonStyle = ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(Theme.of(context).primaryColor));
    return Scaffold(
      appBar: AppBar(
        title: const Text('RC5 Encrypter'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _stringInputController,
                decoration: const InputDecoration(
                    label: Text('Enter key'), hintText: 'Key'),
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: encryptFile,
                  child: const Text(
                    'Encrypt file',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: buttonStyle,
                ),
                const SizedBox(
                  width: 20,
                ),
                TextButton(
                  onPressed: decryptFile,
                  child: const Text(
                    'Decrypt file',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: buttonStyle,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
