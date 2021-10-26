import 'dart:math';
import 'dart:typed_data';

import 'package:lab3/logic/utils.dart';
import 'package:ninja/utils/ufixnum.dart';

class RC5 {
  int w = 16;

  int _r = 0;
  Uint8List _k = Uint8List(0);
  Uint32List _s = Uint32List(0);

  final int _pw = 0xB7E1;
  final int _qw = 0x9E37;
  RC5(Uint8List key, int rounds) {
    if (rounds > 0) {
      _r = rounds;
    } else {
      throw ArgumentError("rounds must be more or equal than 0");
    }
    _k = key;
    _generateExtendedKeys();
  }

  void _generateExtendedKeys() {
    int u = w ~/ 8;
    int b = _k.length;
    int c = b % u > 0 ? b ~/ u + 1 : b ~/ u;
    List<int> L = List.filled(c, 0);

    for (int i = b - 1; i >= 0; i--) {
      L[i ~/ u] = (_rol(L[i ~/ u], 8) + _k[i]).toUnsigned(32);
    }

    int size = (2 * _r + 2).toInt();
    _s = Uint32List(size);
    _s[0] = _pw;
    for (int i = 1; i < size; i++) {
      _s[i] = (_s[i - 1] + _qw).toUnsigned(16);
    }

    int A = 0, B = 0;
    int i = 0, j = 0;
    int n = (3 * max(size, c)).toInt();
    for (int k = 0; k < n; k++) {
      int sum = (_s[i] + A + B).toUnsigned(16);
      _s[i] = _rol(sum.toUnsigned(16), 3).toUnsigned(16);
      A = _s[i].toUnsigned(16);
      L[j] = _rol(
        (L[j].toUnsigned(16) + A.toUnsigned(16) + B.toUnsigned(16))
            .toUnsigned(16),
        A + B,
      ).toUnsigned(32);
      B = L[j].toUnsigned(16);
      i = (i + 1) % size;
      j = (j + 1) % c;
    }
  }

  int _rol(int x, int n) {
    n %= 2;

    return ((x << (n)) | (x >> (w - n))).toUnsigned(16);
  }

  int _ror(int x, int n) {
    n %= 2;
    return (x >> n | x << (w - n)).toUnsigned(16);
  }

  Uint8List encryptECB(Uint8List data) {
    int a = _get16bitValue(data, 0);
    int b = _get16bitValue(data, 2);

    Uint32List s = _s;

    a = (a + s[0]).toUnsigned(16);
    b = (b + s[1]).toUnsigned(16);

    for (int i = 1; i < _r + 1; i++) {
      a = (_rol(
                (a.toUnsigned(16) ^ b.toUnsigned(16)).toUnsigned(16),
                b.toUnsigned(32),
              ) +
              s[2 * i].toUnsigned(16))
          .toUnsigned(16);
      b = (_rol(
                (b.toUnsigned(16) ^ a.toUnsigned(16)).toUnsigned(16),
                a.toUnsigned(32),
              ) +
              s[2 * i + 1].toUnsigned(16))
          .toUnsigned(16);
    }

    return Uint8List.fromList([a.toSigned(8), rotr32(a, 8), b, rotr32(b, 8)]);
  }

  int _get16bitValue(Uint8List data, int offset) =>
      ByteData.view(data.buffer).getUint16(offset, Endian.little);
  Uint8List int16LitteEndianBytes(Uint8List list, int value, int offset) =>
      list..buffer.asByteData().setInt16(0, value, Endian.little);

  Uint8List encryptCBCPAD(Uint8List inputList) {
    int max = pow(2, 31).toInt() - 1;

    Uint8List pprev =
        Uint8List.fromList(List.generate(4, (index) => Random().nextInt(max)));

    Uint8List padding = getPadding(inputList);

    Uint8List extendedArray = Uint8List(inputList.length + padding.length);

    extendedArray = copyBytes(inputList, 0, extendedArray, 0);
    extendedArray = copyBytes(padding, 0, extendedArray, inputList.length);

    Uint8List resultArray = Uint8List(extendedArray.length + pprev.length);

    Uint8List block = encryptECB(pprev);

    int bytesPerBlock = w * 2 ~/ 8;

    resultArray = copyBytes(block, 0, resultArray, 0);

    for (int i = 0; i < extendedArray.length; i += bytesPerBlock) {
      var chunk = Uint8List(bytesPerBlock);

      chunk = copyBytes(extendedArray, i, chunk, 0, length: chunk.length);

      chunk = xor(chunk, pprev);

      Uint8List result = encryptECB(chunk);

      resultArray = copyBytes(result, 0, resultArray, i + bytesPerBlock);

      pprev = copyBytes(
        resultArray,
        i + bytesPerWord,
        pprev,
        0,
        length: chunk.length,
      );
    }

    return resultArray;
  }

  Uint8List decryptCBCPAD(Uint8List encryptedData) {
    int bytesPerBlock = w * 2 ~/ 8;

    Uint8List result = Uint8List(encryptedData.length - bytesPerBlock);

    var cnPrev = decryptECB(encryptedData);

    for (int i = bytesPerBlock; i < encryptedData.length; i += bytesPerBlock) {
      var chunk = Uint8List(bytesPerBlock);

      chunk = copyBytes(encryptedData, i, chunk, 0, length: chunk.length);

      var block = decryptECB(chunk);

      block = xor(block, cnPrev);

      result =
          copyBytes(block, 0, result, i - bytesPerBlock, length: block.length);

      cnPrev = copyBytes(encryptedData, i, cnPrev, 0, length: cnPrev.length);
    }

    late Uint8List resultWithoutPadding;

    if (result.last < result.length) {
      resultWithoutPadding = Uint8List(result.length - result.last);
    } else {
      resultWithoutPadding = Uint8List(result.length);
    }

    resultWithoutPadding = copyBytes(result, 0, resultWithoutPadding, 0,
        length: resultWithoutPadding.length);

    return resultWithoutPadding;
  }

  Uint8List copyBytes(Uint8List src, int index1, Uint8List dest, int index2,
      {int? length}) {
    length ??= src.length;

    Uint8List result = Uint8List.fromList(dest);

    for (int i = index2, j = index1;
        i < dest.length && j < src.length;
        i++, j++) {
      result[i] = src[j];
    }

    return result;
  }

  Uint8List xor(Uint8List left, Uint8List right) {
    for (int i = 0; i < left.length; ++i) {
      left[i] ^= right[i];
    }
    return left;
  }

  Uint8List getPadding(Uint8List data) {
    var bytesInBlock = w * 2 ~/ 8;
    var paddingLength = bytesInBlock - data.length % (bytesInBlock);

    var padding = Uint8List(paddingLength);

    for (int i = 0; i < padding.length; ++i) {
      padding[i] = paddingLength.toUnsigned(8);
    }

    return padding;
  }

  Uint8List decryptECB(Uint8List encryptedData) {
    int a = _get16bitValue(encryptedData, 0);
    int b = _get16bitValue(encryptedData, 2);

    for (int i = _r; i > 0; i--) {
      b = ((_ror((b - _s[2 * i + 1]).toUnsigned(16), a.toUnsigned(32))) ^ a)
          .toUnsigned(16);
      a = ((_ror((a - _s[2 * i]).toUnsigned(16), b.toUnsigned(32))) ^ b)
          .toUnsigned(16);
    }
    a = (a - _s[0]).toUnsigned(16);
    b = (b - _s[1]).toUnsigned(16);
    Uint8List outputData = Uint8List(encryptedData.length)
      ..buffer.asByteData().setInt16(0, a, Endian.little)
      ..buffer.asByteData().setInt16(2, b, Endian.little);
    return outputData;
  }
}
