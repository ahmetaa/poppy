#import ("dart:math");
#import ('dart:scalarlist');
#import("package:poppy/src/beans.dart");


/** modified - shortened Jenkins 32 */
int _hash(List<int> key, int seed) {
  int h1 = seed;
  for (int i=0, length=key.length; i<length;++i) {
    h1 += key[i];
    h1 += (h1 << 10) & 0xfffffff;
    h1 ^= (h1 >> 6);
  }
  return h1 & 0x7fffffff;
}

int fingerPrint(List<int> key) => _hash(key, 0x9747b28c);

/**
 * A Minimal Perfect Hash function which accepts keys that can be represented as List<int>.
 * uses modified implementation of CHD algorithm. It is optimized for fast query of hash values.
 * it uses about 3.2 bits memory per key for large amount of keys.
 */
class Mphf {

  List<_HashIndexes> hashLevelData;

  Mphf.generate(KeyProvider keyProvider) {
      _BucketCalculator bc = new _BucketCalculator(keyProvider);
      this.hashLevelData = bc.calculate();
  }

  Mphf.fromStrings(Collection<String> strings) {
      _BucketCalculator bc = new _BucketCalculator(new KeyProvider.fromStrings(strings));
      this.hashLevelData = bc.calculate();
  }

  Mphf.fromIntLists(List<List<int>> intLists) {
      _BucketCalculator bc = new _BucketCalculator(new KeyProvider(intLists));
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
          return _hash(key, seed) % hashLevelData[0].keyAmount;
        } else {
          return hashLevelData[i - 1].failedIndexes[_hash(key, seed) % hashLevelData[i].keyAmount];
        }
      }
    }
    throw new ExpectException("Cannot be here.");
  }

  num totalBytesUsed() {
    num result = 0;
    for (_HashIndexes data in hashLevelData) {
      result += data.bucketHashSeedValues.length;
      result += data.failedIndexes.length * 4;
    }
    return result;
  }

  double averageBitsPerKey() => (totalBytesUsed() * 8).toDouble() / hashLevelData[0].keyAmount;
}

class _HashIndexes {
  int keyAmount;
  int bucketAmount;
  Uint8List bucketHashSeedValues;
  List<int> failedIndexes;

  _HashIndexes(this.keyAmount, this.bucketAmount, this.bucketHashSeedValues, this.failedIndexes);

  int getSeed(int fingerPrint) => (bucketHashSeedValues[fingerPrint % bucketAmount]) & 0xff;

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

void main() {

  var testStrings = randomStrings();
  
  for(int k=0; k<5; k++) {
    var stopWatch = new Stopwatch();
    stopWatch.start();
    var hash = new Mphf.fromStrings(testStrings);
    print("Hash generation time : ${stopWatch.elapsedInMs()} ms");
    print("Average bit per key: ${hash.averageBitsPerKey()}");
  
    List<List<int>> l = new List();
    for(String s in testStrings) {
      l.add(s.charCodes());
    }
    stopWatch..reset()..start();    
    for(int i = 0, length = l.length; i<length; ++i) {
      int k = hash.hashValue(l[i]);
    }
    print("Hash query time : ${stopWatch.elapsedInMs()} ms");
  }
}

Set<String> randomStrings() {
  var rnd = new Random();
  var testVals = new Set<String>();
  while(testVals.length<100000) {
    var buffer = new StringBuffer();
    for(int k = 0; k<7; k++) {
      int randomChar = rnd.nextInt(26)+'a'.charCodeAt(0);
      buffer.addCharCode(randomChar);
    }
    testVals.add(buffer.toString());
  }
  return testVals;
}

void fruitTest() {
  var fruits = ["apple", "orange", "blueberry", "cherry", "pomegranate", "plum", "pear"];
  var mphf = new Mphf.fromStrings(fruits);
  for(var fruit in fruits) {
    print("$fruit = ${mphf.hashValue(fruit.charCodes())}");
  }
}
