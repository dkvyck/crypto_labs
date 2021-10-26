import 'dart:typed_data';
import 'package:typed_data/typed_data.dart';
import 'digest.dart';
import 'utils.dart';

abstract class HashSink implements Sink<List<int>> {
  final Sink<Digest> _sink;

  final Endian _endian;

  final Uint32List _currentChunk;

  static const _maxMessageLengthInBytes = 0x0003ffffffffffff;

  int _lengthInBytes = 0;

  final _pendingData = Uint8Buffer();

  bool _isClosed = false;

  Uint32List get digest;

  final int _signatureBytes;

  HashSink(this._sink, int chunkSizeInWords,
      {Endian endian = Endian.big, int signatureBytes = 8})
      : _endian = endian,
        _signatureBytes = signatureBytes,
        _currentChunk = Uint32List(chunkSizeInWords);

  void updateHash(Uint32List chunk);

  @override
  void add(List<int> data) {
    if (_isClosed) throw StateError('Hash.add() called after close().');
    _lengthInBytes += data.length;
    _pendingData.addAll(data);
    _iterate();
  }

  @override
  void close() {
    if (_isClosed) return;
    _isClosed = true;

    _finalizeData();
    _iterate();
    assert(_pendingData.isEmpty);
    _sink.add(Digest(_byteDigest()));
    _sink.close();
  }

  Uint8List _byteDigest() {
    if (_endian == Endian.host) return digest.buffer.asUint8List();

    final cachedDigest = digest;
    final byteDigest = Uint8List(cachedDigest.lengthInBytes);
    final byteData = byteDigest.buffer.asByteData();
    for (var i = 0; i < cachedDigest.length; i++) {
      byteData.setUint32(i * bytesPerWord, cachedDigest[i]);
    }
    return byteDigest;
  }

  void _iterate() {
    var pendingDataBytes = _pendingData.buffer.asByteData();
    var pendingDataChunks = _pendingData.length ~/ _currentChunk.lengthInBytes;
    for (var i = 0; i < pendingDataChunks; i++) {
      for (var j = 0; j < _currentChunk.length; j++) {
        _currentChunk[j] = pendingDataBytes.getUint32(
            i * _currentChunk.lengthInBytes + j * bytesPerWord, _endian);
      }

      updateHash(_currentChunk);
    }

    _pendingData.removeRange(
        0, pendingDataChunks * _currentChunk.lengthInBytes);
  }

  void _finalizeData() {
    _pendingData.add(0x80);

    final contentsLength = _lengthInBytes + 1 + _signatureBytes;
    final finalizedLength =
        _roundUp(contentsLength, _currentChunk.lengthInBytes);

    for (var i = 0; i < finalizedLength - contentsLength; i++) {
      _pendingData.add(0);
    }

    if (_lengthInBytes > _maxMessageLengthInBytes) {
      throw UnsupportedError(
          'Hashing is unsupported for messages with more than 2^53 bits.');
    }

    var lengthInBits = _lengthInBytes * bitsPerByte;

    final offset = _pendingData.length + (_signatureBytes - 8);

    _pendingData.addAll(Uint8List(_signatureBytes));
    var byteData = _pendingData.buffer.asByteData();

    var highBits = lengthInBits >> 32;
    var lowBits = lengthInBits & mask32;
    if (_endian == Endian.big) {
      byteData.setUint32(offset, highBits, _endian);
      byteData.setUint32(offset + bytesPerWord, lowBits, _endian);
    } else {
      byteData.setUint32(offset, lowBits, _endian);
      byteData.setUint32(offset + bytesPerWord, highBits, _endian);
    }
  }

  int _roundUp(int val, int n) => (val + n - 1) & -n;
}
