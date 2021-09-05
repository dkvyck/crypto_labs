import 'package:flutter/cupertino.dart';
import 'package:lab1/logic/series_helper.dart';
import 'package:rxdart/rxdart.dart';

class SeriesGenerator {
  final BehaviorSubject<GeneratorState> _subject =
      BehaviorSubject<GeneratorState>();
  FileWriter _fileWriter = FileWriter();

  BehaviorSubject<GeneratorState> get subject => _subject;

  Future<void> generate(int amount, num x0, num c, num a, num m) async {
    _fileWriter.openFile('output.txt');
    num firstNumber = x0;
    num randomNumber = x0;
    for (int i = 0;; i++) {
      randomNumber = (a * randomNumber + c) % m;
      if (i <= amount) {
        _subject.sink.add(ValueGeneratorState(randomNumber, i));

        _fileWriter.sink?.write(' $randomNumber');
      }

      if (randomNumber == firstNumber) {
        _subject.sink.add(PeriodGeneratorState(i));
        _subject.sink.add(FinishedGeneratorState());
        return;
      }
    }
  }
}

abstract class GeneratorState {}

@immutable
class ValueGeneratorState extends GeneratorState {
  ValueGeneratorState(num value, int index)
      : this.value = value,
        this.index = index;

  final num value;
  final int index;
}

@immutable
class PeriodGeneratorState extends GeneratorState {
  PeriodGeneratorState(int period) : this.period = period;

  final int period;
}

@immutable
class FinishedGeneratorState extends GeneratorState {}
