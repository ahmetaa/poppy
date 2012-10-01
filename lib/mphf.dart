library poppy;

import 'dart:math';
import 'dart:scalarlist';
import 'src/mphf_generator.dart';


/** modified - shortened Jenkins 32 */
int hash(List<int> key, int seed) {
  int h1 = seed;
  for (int i=0, length=key.length; i<length;++i) {
    h1 += key[i];
    h1 += (h1 << 10) & 0xfffffff;
    h1 ^= (h1 >> 6);
  }
  return h1 & 0x7fffffff;
}

int fingerPrint(List<int> key) => hash(key, 0x9747b28c);

/**
 * A Minimal Perfect Hash function which accepts keys that can be represented as List<int>.
 * uses modified implementation of CHD algorithm. It is optimized for fast query of hash values.
 * it uses about 3.2 bits memory per key for large amount of keys.
 */
class Mphf {

  List<HashIndexes> hashLevelData;

  Mphf.generate(KeyProvider keyProvider) {
      BucketCalculator bc = new BucketCalculator(keyProvider);
      this.hashLevelData = bc.calculate();
  }

  Mphf.fromStrings(Collection<String> strings) {
      BucketCalculator bc = new BucketCalculator(new KeyProvider.fromStrings(strings));
      this.hashLevelData = bc.calculate();
  }

  Mphf.fromIntLists(List<List<int>> intLists) {
      BucketCalculator bc = new BucketCalculator(new KeyProvider(intLists));
      this.hashLevelData = bc.calculate();
  }

  Mphf(this.hashLevelData);

  int get size => hashLevelData[0].keyAmount;

  int get levelCount => hashLevelData.length;

  /** returns the minimal perfect hash value for the given input [key].
   * Returning number is between [0-keycount] keycount excluded.  */
  int hashValue(List<int> key) => hashValueWithInitialHash(key, fingerPrint(key));

  /**
   * returns the minimal perfect hash value for the given input [key].
   * hash values is between [0-keycount] keycount excluded.
   * sometimes initial hash value for MPHF calculation is
   * already calculated. So [fingerprint] value is used instead of re-calculation.
   * This provides a small performance enhancement.
   */
  int hashValueWithInitialHash(List<int> key, int fingerPrint) {
    for (int i = 0; i < hashLevelData.length; i++) {
      int seed = hashLevelData[i].getSeed(fingerPrint);
      if (seed != 0) {
        if (i == 0) {
          return hash(key, seed) % hashLevelData[0].keyAmount;
        } else {
          return hashLevelData[i - 1].failedIndexes[hash(key, seed) % hashLevelData[i].keyAmount];
        }
      }
    }
    throw new ExpectException("Cannot be here.");
  }

  num totalBytesUsed() {
    num result = 0;
    for (HashIndexes data in hashLevelData) {
      result += data.bucketHashSeedValues.length;
      result += data.failedIndexes.length * 4;
    }
    return result;
  }

  double averageBitsPerKey() => (totalBytesUsed() * 8).toDouble() / hashLevelData[0].keyAmount;
}

class KeyProvider {
   List<List<int>> list = new List();
   KeyProvider(this.list);

   KeyProvider.fromStrings(Collection<String> vals) {
     for(String s in vals) {
       list.add(s.charCodes());
     }
   }

   List<int> getKey(int index) => list[index];

   int keyAmount() => list.length;
}