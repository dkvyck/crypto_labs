import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:fixnum/fixnum.dart';

import 'dart:typed_data';

class MD5Hasher {
  Uint32List _digest =
      Uint32List.fromList([0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]);
  final List<int> _s = [
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, //
    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
  ];
  final Int32List _K = Int32List.fromList([
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, //
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
  ]);

  Uint8List generateMD5Hash(String data) {
    _digest =
        Uint32List.fromList([0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]);
    var convertedData = utf8.encode(data);
    if (convertedData.length > 64) {
      //for ()
    } else {
      var normalizedData =
          _normalizeLenght(Uint8List.fromList(convertedData), true);
      _generatehash(Uint8List.fromList(normalizedData));
      List<int> hash = List.empty(growable: true);
      for (var element in _digest) {
        hash.addAll(int32LitteEndianBytes(element));
      }
      //var resultString = _hexEncode(_digest);
      return Uint8List.fromList(hash);
    }
    return Uint8List(0);
  }

  Future<String> generateMD5HashFromFile(String path) async {
    _digest =
        Uint32List.fromList([0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]);

    final reader = ChunkedStreamReader(File(path).openRead());
    //While the reader has a next byte
    List<int> data = [];
    bool isEnd = false;
    int lenght = 0;
    while (!isEnd) {
      data = await reader.readChunk(64); // read one block
      lenght += data.length;
      if (data.length < 64) {
        //print('End of file reached');
        isEnd = true;
        //var convertedData = utf8.encode(Uint8List.fromList(data));
        var normalizedData = _normalizeLenght(
            Uint8List.fromList(Uint8List.fromList(data)), false,
            lenghtInBytes: lenght);
        _generatehash(Uint8List.fromList(normalizedData));
      } else {
        _generatehash(Uint8List.fromList(data));
      }
    }
    reader.cancel();
    var resultString = _hexEncode(_digest);
    return resultString;

    // var convertedData = utf8.encode(data);
    // if (convertedData.length > 64) {
    //   //for ()
    // } else {
    //   var normalizedData = _normalizeLenght(Uint8List.fromList(convertedData), true);
    //   _generatehash(Uint8List.fromList(normalizedData));
    //   var resultString = _hexEncode(_digest);
    //   return resultString;
    // }
    // return "";
  }

  Uint8List _normalizeLenght(Uint8List data, bool isSingleBlock,
      {int lenghtInBytes = 0}) {
    var addLength =
        (56 - ((data.length + 1) % 64)) % 64; //new lenght with padding
    var processedInput = Uint8List(data.length + 1 + addLength + 8); //
    for (int i = 0; i < data.length; ++i) {
      processedInput[i] = data[i];
    }
    processedInput[data.length] = 0x80; // add 1
    Uint8List lenght = Uint8List(0);
    if (isSingleBlock) {
      lenght = int64LitteEndianBytes(data.length * 8);
    } else {
      lenght = int64LitteEndianBytes(lenghtInBytes * 8);
    }
    for (int i = 0; i < lenght.length; ++i) {
      processedInput[processedInput.length - 8 + i] = lenght[i];
    }
    return processedInput;
  }

  void _generatehash(Uint8List chunk) {
    //final digest = Uint32List(4);
    // digest[0] = 0x67452301; // A //a0
    // digest[1] = 0xefcdab89; // B //b0
    // digest[2] = 0x98badcfe; // C c0
    // digest[3] = 0x10325476; // D d0
    // var addLength = (56 - ((input.length + 1) % 64)) % 64; //new lenght with padding
    // var processedInput = new Uint8List(input.length + 1 + addLength + 8); //
    // for (int i = 0; i < input.length; ++i) {
    //   processedInput[i] = input[i];
    // }
    // processedInput[input.length] = 0x80; // add 1

    // //Uint8List lenght = Uint8List(4)..buffer.asByteData().setInt8(0, input.length * 8, Endian.little);
    // Uint8List lenght = int64LitteEndianBytes(input.length * 8);
    // //Array.Copy(length, 0, processedInput, processedInput.Length - 8, 4);
    // for (int i = 0; i < lenght.length; ++i) {
    //   processedInput[processedInput.length - 8 + i] = lenght[i];
    // }
    for (int i = 0; i < chunk.length / 64; ++i) {
      // copy the input to M
      Uint32List M = Uint32List(16);
      for (int j = 0; j < 16; ++j) {
        int index = (i * 64) + (j * 4);
        M[j] = ByteData.view(Uint8List.fromList([
          chunk[index],
          chunk[index + 1],
          chunk[index + 2],
          chunk[index + 3]
        ]).buffer)
            .getUint32(0, Endian.little);
      }
      //M[j] = ].asByteArray.ge
      // initialize round variables
      var A = _digest[0],
          B = _digest[1],
          C = _digest[2],
          D = _digest[3],
          e = 0,
          f = 0;

      // primary loop
      for (var k = (0); k < 64; ++k) {
        if (k <= 15) {
          e = (B & C) | ((~B & mask32) & D);
          f = k;
        } else if (k >= 16 && k <= 31) {
          e = (D & B) | ((~D & mask32) & C);
          //g = (((Int32(5) * k) + Int32(1)) % Int32(16)).toInt32();
          f = ((5 * k) + 1) % 16;
        } else if (k >= 32 && k <= 47) {
          e = B ^ C ^ D;
          //g = (((Int32(3) * k) + Int32(5)) % Int32(16)).toInt32();
          f = ((3 * k) + 5) % 16;
        } else if (k >= 48) {
          e = C ^ (B | (~D & mask32));
          //g = (((Int32(7) * k) % Int32(16))).toInt32();
          f = (7 * k) % 16;
        }

        var dtemp = D;
        D = C;
        C = B;
        //B = (B + leftRotate((A + F + _K[k.toInt()] + M[g.toInt()]).toInt32(), _s[k.toInt()])).toInt32();
        B = add32(B, rotl32(add32(add32(A, e), add32(_K[k], M[f])), _s[k]));
        A = dtemp;
      }

      _digest[0] = add32(A, _digest[0]);
      _digest[1] = add32(B, _digest[1]);
      _digest[2] = add32(C, _digest[2]);
      _digest[3] = add32(D, _digest[3]);
    }
    //return _digest;
  }

  int add32(int x, int y) => (x + y) & mask32;
  final mask32 = 0xFFFFFFFF;

  int rotl32(int val, int shift) {
    var modShift = shift & 31;
    return ((val << modShift) & mask32) | ((val & mask32) >> (32 - modShift));
  }

  static Uint8List int64LitteEndianBytes(int value) =>
      Uint8List(8)..buffer.asByteData().setInt64(0, value, Endian.little);
  static Uint8List int32LitteEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.little);

  String _hexEncode(Uint32List bytes) {
    String output = "";
    for (var element in bytes) {
      var bytes = int32LitteEndianBytes(element);
      for (var element2 in bytes) {
        output += element2.toRadixString(16);
      }
      //output += element.toRadixString(16);
    }
    return output;
  }
}
