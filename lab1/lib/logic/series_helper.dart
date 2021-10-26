import 'dart:io';

class FileWriter {
  late IOSink _fileSink;
  late RandomAccessFile syncFile;
  IOSink? get sink => _fileSink;

  void openFile(String filename, {FileMode mode = FileMode.writeOnly}) {
    File file = File(filename);
    _fileSink = file.openWrite(mode: mode);
  }

  void openFileSync(String filename, {FileMode mode = FileMode.writeOnly}) {
    File file = File(filename);
    syncFile = file.openSync(mode: FileMode.writeOnlyAppend);
  }

  void closeFile() {
    _fileSink.close();
  }

  Future<void> flush() async {
    return _fileSink.flush();
  }
}
