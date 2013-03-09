library poppy;

import 'dart:math';
import 'dart:scalarlist';

/// A data structure for counting objects. Counts can be negative.

class CountSet<T> extends Iterable<T> {

  static final int INITIAL_SIZE = 8;
  static final num DEFAULT_LOAD_FACTOR = 0.6;
  /// used for marking removed objects.
  Object _SENTINEL;
  int modulo;
  List<T> keys;
  Int32List values;
  int keyCount=0;
  int threshold;

  CountSet([int initialSize]) {
    _SENTINEL = new Object();
    int size = initialSize==null ? INITIAL_SIZE : initialSize;
    if (size < 2) {
      size = 2;
    }
    if ((size & (size - 1)) != 0) { // check for power of two
      int power = (log(size) / log(2)).toInt();
      size = 1 << (power + 1);
    }
    keys = new List.filled(size,null);
    values = new Int32List(size) ;
    threshold =  (size * DEFAULT_LOAD_FACTOR).toInt();
    modulo = size - 1;
  }

  int _hash(int key) => key & modulo;

  int _locate(T key) {
      int slot = _hash(key.hashCode);
      int pointer = -1;
      while (true) {
          Object t = keys[slot];
          if (t == _SENTINEL) {
              if (pointer < 0) {
                  pointer = slot;
              }
              slot = (slot + 1) & modulo;
              continue;
          }
          if (keys[slot] == null) {
              return pointer < 0 ? (-slot - 1) : (-pointer - 1);
          }
          if (t == key) {
              return slot;
          }
          slot = (slot + 1) & modulo;
      }
  }

  int increment(T key) => incrementByAmount(key, 1);

  int operator [] (T key) {
    if (key == null) {
        throw new ArgumentError("Key cannot be null");
    }
    int slot = _hash(key.hashCode);
    while (true) {
        final Object k = keys[slot];
        if (k == _SENTINEL) {
            slot = (slot + 1) & modulo;
            continue;
        }
        if (keys[slot] == null) {
            return 0;
        }
        if (k == key) {
            return values[slot];
        }
        slot = (slot + 1) & modulo;
    }
  }

  int decrement(T key) {
      return incrementByAmount(key, -1);
  }

  int incrementByAmount(T key, num amount) {
    if (key == null) {
      throw new ArgumentError("Key cannot be null");
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
        return values[l];
    }
  }

  /// removes the key. if key does not exist, does nothing.
  void remove(T key) {
      int k = _locate(key);
      if (k < 0) {
          return;
      }
      keys[k] = _SENTINEL; // mark deletion
      keyCount--;
  }

  void _expand() {
      var h = new CountSet<T>(values.length * 2);
      for (int i = 0; i < keys.length; i++) {
          if (keys[i] != null) {
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
  
  int add(T key) {
    return increment(key);
  }
  
  int addAll(Iterable<T> keys) {
    for(T t in keys) {
      increment(t);  
    }    
  }  
    
  void operator []=(T key, num value) {
    if (key == null) {
      throw new ArgumentError("Key cannot be null");
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

  Iterator<T> get iterator {
      return new _TIterator(this);
  }
}

class _TIterator<T> extends Iterator<T> {

  int i=0;
  int k=0;
  CountSet<T> vector;
  T current;

  _TIterator(this.vector);

  bool moveNext() {
    if(k == vector.keyCount) {
      return false;
    }
    while (vector.keys[i] == null || vector.keys[i]==vector._SENTINEL) {
      i++;
    }
    current = vector.keys[i];
    i++;
    k++;
    return true;
  }

  T next() {
    return current;
  }
}


class _TableIterator<T> extends Iterator<TableEntry> {

  int i=0;
  int k=0;
  CountSet<T> vector;
  TableEntry current;

  _TableIterator(this.vector);

  bool moveNext() {
    if(k == vector.keyCount) {
      return false;
    }
    while (vector.keys[i] == null || vector.keys[i]==vector._SENTINEL) {
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

class TableEntry<T> {
  T key;
  num value;

  TableEntry(this.key, this.value);
}