import 'dart:io';

class FileWriter {
  late IOSink _fileSink;

  IOSink? get sink => _fileSink;

  void openFile(String filename, {FileMode mode = FileMode.writeOnly}) {
    File file = File(filename);
    _fileSink = file.openWrite(mode: mode);
  }

  void closeFile() {
    _fileSink.close();
  }
}
