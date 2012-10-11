library poppy;

import 'int_set.dart';
import 'dart:fixnum';

int hash(int input) {
  int h1 = 0x14D41585;
  for (int i=0, i<8; ++i) {
    h1 += input>>(i*8) & 0xff;
    h1 += (h1 << 10) & 0xfffffffffffffff;
    h1 ^= (h1 >> 6);
  }
  return h1 & 0xfffffffffffffff;
}  

class SimHash {
  
  static final int HASH_SIZE = 64;
  static final int GRAM_SIZE = 4;
  
  int64 getHash(List<int> input) {
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
    }
    shingles.add(shingle);
    
    List<int> bitCounts = new List<int>(HASH_SIZE);
    
    for(int shingle in shingles.allKeys()) {
      int hash = hash(shingle);
      
    }          
    
  }
  
}
