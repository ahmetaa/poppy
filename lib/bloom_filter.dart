library poppy;

import 'src/fixed_bit_vector.dart';
import 'dart:math';

class BloomFilter {
  FixedBitVector bitVector;
  List<_BloomHash> hashFunctions; 
  var seeds = [0xEC4BA7, 0x222B3A25, 0x3A8F057B]; // three prime numbers. could be something else.
  final int DEFAULT_SIZE = 10000;
  int modulo;
  
  BloomFilter([int approximateKeySize]) {
    hashFunctions = new List<_BloomHash>();   
    int size = approximateKeySize==null ? DEFAULT_SIZE : approximateKeySize;
    size = size*12; 
    if(size>0x7fffffff)
      throw new ArgumentError("Cannot have $approximateKeySize elements.");    
    modulo = size;
    bitVector = new FixedBitVector.bitCount(size);    
    for(var seed in seeds) {
      hashFunctions.add(new _BloomHash(seed, modulo));
    }    
  }
  
  /// adds key to the filter.
  void add(List<int> key) {
    for(var hashFunc in hashFunctions) {
      bitVector.setBit(hashFunc.hash(key));
    }
  }
  
  /// returns false if key definitely does not exist. true when key *may* exist
  bool check(List<int> key) {
    for(var hashFunc in hashFunctions) {
      if(!bitVector.getBit(hashFunc.hash(key)))
        return false;
    }    
    return true;
  }
}


class _BloomHash {
  final int seed; 
  final int modulo;

  _BloomHash(this.seed, this.modulo);
  
  /** modified - shortened Jenkins 32 */
  int hash(List<int> key) {
    int h1 = seed;
    for (int i=0, length=key.length; i<length;++i) {
      h1 += key[i];
      h1 += (h1 << 10) & 0xfffffff;
      h1 ^= (h1 >> 6);
    } 
    return h1 % modulo;
  }  
}