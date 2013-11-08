library poppy;
import 'int_set.dart';

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

  static int hash(int input, int seed) {
    int h1 = seed;
    for (int i=0; i<8; ++i) {
      h1 += (input>>(i*8)) & 0xff;
      h1 += (h1 << 13) & 0x3fffffffffffffff;
      h1 ^= (h1 >> 6);
    }
    return h1 & 0x3fffffffffffffff;
  }  

  int getHashFromString(String input) {
    return getHash(input.codeUnits);
  }

  int getHash(List<int> input, [int hashSeed]) {
    int seed = hashSeed==null ? 0x14D41585 : hashSeed;
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

    var bitCounts = new List<int>.filled(HASH_SIZE, 0);

    for(int shingle in shingles.allKeys()) {
      int h = hash(shingle, seed);
      for(int i=0; i<HASH_SIZE; ++i ) {
        bitCounts[i] += (h & (1<<i)) ==0 ?  -1 :  1;
      }
    }

    int result = 0;
    for(int i = 0; i<HASH_SIZE; ++i) {
      if(bitCounts[i]>0) {
        result |= (1<<i);
      }
    }
    return result;
  }

}

final int zero = '0'.codeUnitAt(0);
final int one = '1'.codeUnitAt(0);

String binaryString (int i, int bitCount) {
  var codes = new List<int>(bitCount);
  for(int j = bitCount-1; j>=0; --j) {
    codes[j] = (i & (1<<j))==0 ? zero : one;
  }
  return new String.fromCharCodes(codes);
}


