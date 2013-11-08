library poppy;
import 'dart:math';
import 'dart:collection';

/// a simple sparse vector that can only hold non zero values in it.
/// it uses positive integer keys and any num type value. Because vector is sparse, it does not
/// hold zero valued keys.
/// implementation uses simple hash table with linear probing.
/// For marking deleten keys, -1 key value used.
class SparseVector extends IterableBase<TableEntry> {

  static final int INITIAL_SIZE = 8;
  static final num DEFAULT_LOAD_FACTOR = 0.6;
  int modulo;
  List<int> keys;
  List<num> values;
  int keyCount=0;
  int threshold;

  SparseVector([int initialSize]) {
    int size = initialSize==null ? INITIAL_SIZE : initialSize;
    if (size < 2) {
      size = 2;
    }
    if ((size & (size - 1)) != 0) { // check for power of two
      int power = log(size) ~/ log(2);
      size = 1 << (power + 1);
    }
    keys = new List<int>.filled(size, 0);
    values = new List<num>.filled(size, 0);
    threshold =  (size * DEFAULT_LOAD_FACTOR).toInt();
    modulo = size - 1;
  }

  int _hash(int key) => key & modulo;

  /*
   * locate operation does the following:
   * - finds the slot
   * - if there was a deleted key before (flag[slot]==-1) and pointer is not set yet (pointer==-1) pointer is set to this
   *   slot index and index is incremented.
   *   This is necessary for the following problem.
   *   Suppose we add key 5 first then key 9 with key clash. first one is put to slotindex=1 and the other one is
   *   located to slot=2. Then we erase the key 5. Now if we do not use the flag, and want to access the value of key 9.
   *   we would get a 0 because slot will be 1 and key does not exist there.
   *   that is why we use a flag for marking deleted slots. So when getting a value we pass the deleted slots. And when we insert,
   *   we use the first deleted slot if any.
   *    Key Val  Key Val  Key Val
   *     0   0    0   0    0   0
   *     5   2    5   2    -1  0
   *     0   0    9   3    9   3
   *     0   0    0   0    0   0
   * - if there was no deleted key in that slot, check the value. if value is 0 then we can put our key here. However,
   *   we cannot return the slot value immediately. if pointer value is set, we use it as the vacant index. we do not use
   *   the slot or the pointer value itself. we use negative of it, pointing the key does not exist in this list. Also we
   *   return -slot-1 or -pointer-1 to avoid the 0 index problem.
   */
  int _locate(int key) {
      int slot = _hash(key);
      int pointer = -1;
      while (true) {
          int k = keys[slot];
          if (k < 0) {
              if (pointer < 0) {
                  pointer = slot;
              }
              slot = (slot + 1) & modulo;
              continue;
          }
          if (values[slot] == 0) {
              return pointer < 0 ? (-slot - 1) : (-pointer - 1);
          }
          if (k == key) {
              return slot;
          }
          slot = (slot + 1) & modulo;
      }
  }

  int increment(int key) => incrementByAmount(key, 1);

  num operator [] (int key) {
      if (key < 0) {
          throw new ArgumentError("Key cannot be negative. But it is: $key");
      }
      int slot = _hash(key);
      while (true) {
          final int k = keys[slot];
          if (k < 0) {
              slot = (slot + 1) & modulo;
              continue;
          }
          if (values[slot] == 0) {
              return 0;
          }
          if (k == key) {
              return values[slot];
          }
          slot = (slot + 1) & modulo;
      }
  }

  int decrement(int key) {
      return incrementByAmount(key, -1);
  }

  int incrementByAmount(int key, num amount) {
      if (key < 0) {
          throw new ArgumentError("Key cannot be negative. But it is: $key");
      }
      if (keyCount == threshold) {
          _expand();
      }
      int l = _locate(key);
      if (l < 0) {
          l = -l - 1;
          values[l] = amount;
          keys[l] = key;
          keyCount++;
          return values[l];
      } else {
          values[l] += amount;
          if (values[l] == 0) {
              keyCount--;
              keys[l] = -1; // mark deletion
          }
          return values[l];
      }
  }

  /// removes the key. if key does not exist, does nothing.
  void remove(int key) {
      int k = _locate(key);
      if (k < 0) {
          return;
      }
      values[k] = 0;
      keys[k] = -1; // mark deletion
      keyCount--;
  }

  void _expand() {
      var h = new SparseVector(values.length * 2);
      for (int i = 0; i < keys.length; i++) {
          if (values[i] != 0) {
              h[keys[i]]=values[i];
          }
      }
      assert (h.keyCount == keyCount);
      this.values = h.values;
      this.keys = h.keys;
      this.keyCount = h.keyCount;
      this.modulo = h.modulo;
      this.threshold = h.threshold;
  }

  void operator []=(int key, num value) {
      if (key < 0) {
          throw new ArgumentError("Key cannot be negative. But it is: $key");
      }
      if (value == 0) {
          remove(key);
          return;
      }
      if (keyCount == threshold) {
          _expand();
      }
      int loc = _locate(key);
      if (loc >= 0) {
          values[loc] = value;
          return;
      }
      loc = -loc - 1;
      keys[loc] = key;
      values[loc] = value;
      keyCount++;
  }

  int get length => keyCount;

  int get capacity => threshold;

  int get slotSize => keys.length;

  Iterator<TableEntry> get iterator {
      return new _TableIterator(this);
  }
}

class _TableIterator extends Iterator<TableEntry> {

  int i=0;
  int k=0;
  SparseVector vector;
  TableEntry current;

  _TableIterator(this.vector);

  bool moveNext() {
    if(k == vector.keyCount) {
      return false;
    }
    while (vector.values[i] == 0) {
      i++;
    }
    current = new TableEntry(vector.keys[i], vector.values[i]);
    i++;
    k++;
    return true;
  }

  TableEntry next() {
    return current;
  }
}

class TableEntry {
  int key;
  num value;

  TableEntry(this.key, this.value);
}