import 'dart:typed_data';

/**
 * An int list backed fixed size bit vector.
 */
class FixedBitVector {
  Int32List _words;
  int _size;

  var _setMasks = new Int32List(32);
  var _resetMasks = new Int32List(32);

  _initialize() {
      for (int i = 0; i < 32; i++) {
        _setMasks[i] = 0x1 << i;
        _resetMasks[i] = ~_setMasks[i];
      }
  }

  get size => _size;

  /** Creates a fixed bit vector with capacity of [bitCount]. */
  FixedBitVector.bitCount(int bitCount) {
    if (bitCount <= 0) {
        throw new ArgumentError("${bitCount} must be a positive integer");
    }
    _size = bitCount;
    int wordCount = (bitCount + 31) >> 5;
    _words = new Int32List(wordCount);
    _initialize();
  }
  
  int zeroCount() {
    int total = 0;
    for(int i = 0; i < size; i++) {
      if((_words[i >> 5] & _setMasks[i & 31])==0)
        total++;
    }
    return total;
  }
  
  int oneCount() => size-zeroCount();

  FixedBitVector.fromData(this._words) {
    _size = _words.length*32;
    _initialize();
  }

  bool getBit (int n) => (_words[n >> 5] & _setMasks[n & 31]) != 0;

  void setBit (int n) {
    _words[n >> 5] |= _setMasks[n & 31];
  }

  void clear(int n) {
    _words[n >> 5] &= _resetMasks[n & 31];
  }
}

class Int32BackedBitVector {
  List<int> _words;
  int _size;

  var _setMasks = new Int32List(32);
  var _resetMasks = new Int32List(32);

  int _capacity;

  _initialize() {
      for (int i = 0; i < 32; i++) {
        _setMasks[i] = 0x1 << i;
        _resetMasks[i] = ~_setMasks[i];
      }
  }

  Int32BackedBitVector([int initialSize]) {
    _size = 0;
    _expand();
  }

  _expand({int toBitSize}) {
    int newSize = toBitSize!=null ? (toBitSize+31 >> 5 -_words.length )+7 : 7;
    _words.fillRange(_words.length, _words.length+7, 0);
    _capacity = _words.length * 32;
  }

  bool getBit (int n) => (_words[n >> 5] & _setMasks[n & 31]) != 0;

  void setBit (int n) {
    if(n >= _size) {
      _expand();
      _size = n;
    }
    _words[n >> 5] |= _setMasks[n & 31];
  }

  void add1 () {
    if(_size == _capacity) {
      _expand();
    }
    _words[_size >> 5] |= _setMasks[_size & 31];
    _size++;
  }

  /// adds k amount of 1 and a zero.
  void addUnuary (int k) {
    if(_size+k+1 == _capacity) {
      _expand();
    }
    for(int j = 0; j<k; j++) _words[(_size+j) >> 5] |= _setMasks[(_size+j) & 31];
    // no need to add zero as we increment the size with k+1.
    _size+=(k+1);
  }

  void add0 () {
    if(_size == _capacity) {
      _expand();
    }
    _words[_size >> 5] |= _setMasks[_size & 31];
    _size++;
  }

  void clear(int n) {
    if(n >= _size) {
      _expand();
      _size = n;
    }
    _words[n >> 5] &= _resetMasks[n & 31];
  }
}