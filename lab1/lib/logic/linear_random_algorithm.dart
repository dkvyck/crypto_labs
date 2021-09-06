import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:lab1/logic/series_helper.dart';
import 'package:rxdart/rxdart.dart';

class SeriesGenerator {
  final BehaviorSubject<GeneratorState> _subject =
      BehaviorSubject<GeneratorState>();
  FileWriter _fileWriter = FileWriter();

  BehaviorSubject<GeneratorState> get subject => _subject;

  Future<void> generate(
    int uiAmount,
    num x0,
    num c,
    num a,
    num m, {
    int fileAmount = 1000,
  }) async {
    _fileWriter.openFile('output.txt');
    num firstNumber = x0;
    num randomNumber = x0;
    for (int i = 0;; i++) {
      randomNumber = (a * randomNumber + c) % m;

      if (i <= uiAmount) {
        // update ui
        _subject.sink.add(ValueGeneratorState(randomNumber, i));
      }

      if (i < fileAmount) {
        //reopening stream to free memory
        if (i + 1 % 10000 == 0) {
          _fileWriter.closeFile();
          _fileWriter.openFile('output.txt', mode: FileMode.writeOnlyAppend);
        }
        // write to file
        _fileWriter.sink?.write(' ${randomNumber.toInt()}');
      }
      // if period found
      if (randomNumber == firstNumber) {
        _subject.sink.add(PeriodGeneratorState(i + 1));
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
