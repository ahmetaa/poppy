library poppy;

import 'src/mphf_generator.dart';

/** modified - shortened Jenkins 32 */
int hash(List<int> key, int seed) {
  int h1 = seed;
  for (int i=0, length=key.length; i<length;++i) {
    h1 = ((h1 ^ key[i]) * 16777619) & 0x3fffffff;
  }
  return h1;
}

int hashStr(String key, int seed) {
  int h1 = seed;
  for (int i=0, length=key.length; i<length;++i) {
    h1 = ((h1 ^ key.codeUnitAt(i)) * 16777619) & 0x3fffffff;
  }
  return h1;
}

int initialHash(List<int> key) => hash(key, 0x811C9DC5);
int initialHashStr(String key) => hashStr(key, 0x811C9DC5);

/**
 * A Minimal Perfect Hash function which accepts keys that can be represented as List<int>.
 * Initial steps of this implementation is similar to 
 * Fox, Heath, Chen, and Daoud's Practical minimal perfect hash functions for large databases (1992)
 * and Belazzougui, Botelho and Dietzfelbinger. Hash, Displace and Compress (2009) papers.
 * However, it is different in displace step and it does not use integer array compression.
 * This structure is optimized for fast MPHF generation and query.
 * it uses about 3.2 bits memory per key for large amount of keys.
 */
class Mphf {

  static const int MAX_KEY_AMOUNT = 0x3fffffff;

  List<HashIndexes> hashLevelData;

  Mphf.generate(KeyProvider keyProvider) {
      if(keyProvider==null) {
        throw new ArgumentError("key Provider cannot be null");
      }
      _checkArguments(keyProvider.list);
      BucketCalculator bc = new BucketCalculator(keyProvider);
      this.hashLevelData = bc.calculate();
  }

  Mphf.fromStrings(Iterable<String> strings) {
    _checkArguments(strings);
    BucketCalculator bc = new BucketCalculator(new KeyProvider.fromStrings(strings));
    this.hashLevelData = bc.calculate();
  }

  Mphf.fromIntLists(List<List<int>> intLists) {
    _checkArguments(intLists);
    BucketCalculator bc = new BucketCalculator(new KeyProvider(intLists));
    this.hashLevelData = bc.calculate();
  }

  _checkArguments(Iterable c) {
    if(c==null) {
      throw new ArgumentError("Input cannot be null");
    }
    if(c.length<=0 || c.length>MAX_KEY_AMOUNT) {
      throw new ArgumentError("Amount of keys must be in range of 1..$MAX_KEY_AMOUNT but it is: ${c.length}");
    }
  }

  Mphf(this.hashLevelData);

  int get size => hashLevelData[0].keyAmount;

  int get levelCount => hashLevelData.length;

  /**
   * returns the minimal perfect hash value for the given input [key].
   * hash values is between 0-keycount, keycount excluded.
   * sometimes initial hash value for MPHF calculation is
   * already calculated. So [initialHashValue] value is used instead of re-calculation.
   * This provides a small performance enhancement.
   */
  int getValue(List<int> key, [int initialHashValue]) {
    int k = initialHashValue==null ? initialHash(key) : initialHashValue;

    for (int i = 0; i < hashLevelData.length; i++) {
      int seed = hashLevelData[i].getSeed(k);
      if (seed != 0) {
        if (i == 0) {
          return hash(key, seed) % hashLevelData[0].keyAmount;
        } else {
          return hashLevelData[i - 1].failedIndexes[hash(key, seed) % hashLevelData[i].keyAmount];
        }
      }
    }
    throw new StateError("Cannot be here.");
  }
  
  /**
   * returns the minimal perfect hash value for the given input String [key].
   * hash values is between 0-keycount, keycount excluded.
   * sometimes initial hash value for MPHF calculation is
   * already calculated. So [initialHashValue] value is used instead of re-calculation.
   * This provides a small performance enhancement.
   */
  int getValueStr(String key, [int initialHashValue]) {
    int k = initialHashValue==null ? initialHashStr(key) : initialHashValue;

    for (int i = 0; i < hashLevelData.length; i++) {
      int seed = hashLevelData[i].getSeed(k);
      if (seed != 0) {
        if (i == 0) {
          return hashStr(key, seed) % hashLevelData[0].keyAmount;
        } else {
          return hashLevelData[i - 1].failedIndexes[hashStr(key, seed) % hashLevelData[i].keyAmount];
        }
      }
    }
    throw new StateError("Cannot be here.");
  }  

  num totalBytesUsed() {
    num result = 0;
    for (HashIndexes data in hashLevelData) {
      result += data.bucketHashSeedValues.length;
      result += data.failedIndexes.length * 4;
    }
    return result;
  }

  double averageBitsPerKey() => totalBytesUsed() * 8 / hashLevelData[0].keyAmount;
}

class KeyProvider {
   List<List<int>> list = new List();
   KeyProvider(this.list);

   KeyProvider.fromStrings(Iterable<String> vals) {
     for(String s in vals) {
       list.add(s.codeUnits);
     }
   }

   List<int> getKey(int index) => list[index];

   int keyAmount() => list.length;
}
