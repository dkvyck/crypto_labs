import 'dart:math';

class SeriesGenerator {
  Future<List<num>> generate(int amount, num x0, num c, num a, num m) async {
    List<num> result = [];
    num previousNumber = x0;
    for (int i = 0; i < amount; i++) {
      var randomNumber = (a * previousNumber + c) % m;
      result.add(randomNumber);
      previousNumber = randomNumber;
    }

    return result;
  }
}
