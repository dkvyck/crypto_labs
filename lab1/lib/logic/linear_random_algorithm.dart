import 'dart:math';

class SeriesGenerator {
  Future<List<num>> generate(int amount) async {
    num x0 = 64;
    num c = 8;
    num a = pow(2, 3);
    num m = pow(2, 13) - 1;

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
