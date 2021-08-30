import 'dart:io';

class SeriesHelper {
  int findPeriod(List<num> series) {
    num firstValue = series.first;
    series.removeAt(0);
    return series.indexOf(firstValue) + 1;
  }

  void writeToFile(List<num> series) {
    File file = File('output.txt');
    file.writeAsString(series.join(' '));
  }
}
