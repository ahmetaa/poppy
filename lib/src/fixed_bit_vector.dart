class FixedBitVector {
  Int32List _words;
  int _size;

  var _setMasks = new Int32List(32);
  var _resetMasks = new Int32List(32);

  _initialize(int capacity) {
      _size = capacity;
      int wordCount = capacity~/32 + 1;
      _words = new Int32List(wordCount);
      for (int i = 0; i < 32; i++) {
        _setMasks[i] = 0x1 << i;
        _resetMasks[i] = ~_setMasks[i];
      }
  }

  get size => _size;

  /** Creates a fixed bit vector with capacity of [bitCount]. */
  FixedBitVector.bitCount(int bitCount) {
    _initialize(bitCount);
  }

  bool getBit (int n) => (_words[n >> 5] & _setMasks[n & 31]) != 0;

  void setBit (int n) {
    _words[n >> 5] |= _setMasks[n & 31];
  }

  void clear(int n) {
    _words[n >> 5] &= _resetMasks[n & 31];
  }
}
