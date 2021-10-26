import 'dart:convert';

import 'digest.dart';
import 'digest_sink.dart';

abstract class Hash extends Converter<List<int>, Digest> {
  int get blockSize;

  const Hash();

  @override
  Digest convert(List<int> input) {
    var innerSink = DigestSink();
    var outerSink = startChunkedConversion(innerSink);
    outerSink.add(input);
    outerSink.close();
    return innerSink.value;
  }

  @override
  ByteConversionSink startChunkedConversion(Sink<Digest> sink);
}
