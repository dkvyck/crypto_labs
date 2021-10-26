const mask32 = 0xFFFFFFFF;

const bitsPerByte = 8;

const bytesPerWord = 4;

int add32(int x, int y) => (x + y) & mask32;

int rotl32(int val, int shift) {
  var modShift = shift & 31;
  return ((val << modShift) & mask32) | ((val & mask32) >> (32 - modShift));
}
