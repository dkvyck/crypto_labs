import 'dart:io';

class FileWriter {
  late IOSink _fileSink;

  IOSink? get sink => _fileSink;

  int findPeriod(List<num> series) {
    num firstValue = series.first;
    series.removeAt(0);
    return series.indexOf(firstValue) + 1;
  }

  void openFile(String filename, {FileMode mode = FileMode.writeOnly}) {
    File file = File(filename);
    _fileSink = file.openWrite(mode: mode);
  }

  void closeFile() {
    _fileSink.close();
  }
}
