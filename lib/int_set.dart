library poppy;
import 'dart:typed_data';
import 'dart:math';

class IntSet {

  static final int INITIAL_SIZE = 8;
  static final num DEFAULT_LOAD_FACTOR = 0.6;
  int modulo;
  List<int> keys;
  Uint8List flags;

  static final int EMPTY=0;
  static final int OCCUPIED=1;
  static final int DELETED=2;

  int keyCount=0;
  int threshold;

  IntSet([int initialSize]) {
    int size = initialSize==null ? INITIAL_SIZE : initialSize;
    if (size < 2) {
      size = 2;
    }
    if ((size & (size - 1)) != 0) { // check for power of two
      int power = log(size) ~/ log(2);
      size = 1 << (power + 1);
    }
    keys = new List<int>(size);
    flags = new Uint8List(size);
    threshold =  (size * DEFAULT_LOAD_FACTOR).toInt();
    modulo = size - 1;
  }

  int get length => keyCount;

  int get capacity => threshold;

  int get slotSize => keys.length;

  int _hash(int key) => key & modulo;

  int _locate(int key) {
    int slot = _hash(key);
    int pointer = -1;
    while (true) {
      int flag = flags[slot];
      if (flag == DELETED) {
          if (pointer < 0) {
              pointer = slot;
          }
          slot = (slot + 1) & modulo;
          continue;
      }
      if (flag == EMPTY) {
          return pointer < 0 ? (-slot - 1) : (-pointer - 1);
      }
      if (keys[slot] == key) {
          return slot;
      }
      slot = (slot + 1) & modulo;
    }
  }

  bool contains(int key) {
    int slot = _hash(key);
    while (true) {
      int flag = flags[slot];
      if (flag == DELETED) {
          slot = (slot + 1) & modulo;
          continue;
      }
      if (flag == EMPTY) {
          return false;
      }
      if (keys[slot] == key) {
          return true;
      }
      slot = (slot + 1) & modulo;
    }
  }

  /// removes the key. if key does not exist, does nothing.
  void remove(int key) {
      int k = _locate(key);
      if (k < 0) {
          return;
      }
      flags[k] = DELETED; // mark deletion
      keyCount--;
  }

  void _expand() {
      var h = new IntSet(keys.length * 2);
      for (int i = 0; i < keys.length; i++) {
          if (flags[i] == OCCUPIED) {
              h.add(keys[i]);
          }
      }
      assert (h.keyCount == keyCount);
      this.keys = h.keys;
      this.flags = h.flags;
      this.modulo = h.modulo;
      this.threshold = h.threshold;
  }

  void add(int key) {
      if (keyCount == threshold) {
          _expand();
      }
      int loc = _locate(key);
      if (loc >= 0) {
          return;
      }
      loc = -loc - 1;
      keys[loc] = key;
      flags[loc] = OCCUPIED;
      keyCount++;
  }

  List<int> allKeys() {
    var result = new List<int>(keyCount);
    int j =0;
    for (int i = 0; i < keys.length; i++) {
      if (flags[i] == OCCUPIED) {
        result[j++]=keys[i];
      }
    }
    return result;
  }

}
