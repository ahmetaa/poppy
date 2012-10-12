library poppy;

import 'int_set.dart';
import 'dart:scalarlist';

int hash(int input) {
  int h1 = 0x14D41585;
  for (int i=0; i<8; ++i) {
    h1 += input>>(i*8) & 0xff;
    h1 += (h1 << 10) & 0xfffffffffffffff;
    h1 ^= (h1 >> 6);
  }
  return h1 & 0xfffffffffffffff;
}

int hammingDistance(int i, int j) {
  int k = i^j;
  int dist=0;
  while(k!=0) {
    k= k&(k-1);
    dist++;
  }
  return dist;
}

class SimHash {

  static final int HASH_SIZE = 64;
  static final int GRAM_SIZE = 4;

  static var _setMasks = new Int64List(64);
  static var _resetMasks = new Int64List(64);

  _initialize() {
      for (int i = 0; i < 64; i++) {
        _setMasks[i] = 1 << i;
      }
  }

  SimHash() {
    _initialize();
  }

  int getHash(List<int> input) {
    IntSet shingles = new IntSet(input.length);
    int shingle = 0;
    for(int k = 0; k<input.length-GRAM_SIZE; ++k) {
      shingle = input[k];
      shingle = shingle<<16;
      shingle |= input[k+1];
      shingle = shingle<<16;
      shingle |= input[k+2];
      shingle = shingle<<16;
      shingle |= input[k+3];
      shingles.add(shingle);      
    }

    Int32List bitCounts = new Int32List(HASH_SIZE);

    for(int shingle in shingles.allKeys()) {
      int hash = hash(shingle);
      for(int i=0; i<HASH_SIZE; ++i ) {
        (hash & _setMasks[i]) ==0 ?  bitCounts[i]-- :  bitCounts[i]++;
      }
    }

    int result = 0;
    for(int i = 0; i<HASH_SIZE; ++i) {
      if(bitCounts[i]>0)
        result |= 1<<i;
    }

    return result;
  }

}
