library bloom_test;

import 'package:unittest/unittest.dart';
import 'package:poppy/bloom_filter.dart';
import 'dart:math';

Set<String> randomStrings(num amount, num length, [Set<String> notAllowed]) {
  var rnd = new Random();
  var testVals = new Set<String>();
  while(testVals.length < amount) {
    var buffer = new StringBuffer();
    for(int k = 0; k<length; k++) {
      int randomChar = rnd.nextInt(26)+'a'.charCodeAt(0);
      buffer.addCharCode(randomChar);
    }
    String s = buffer.toString();
    if(?notAllowed && notAllowed.contains(s)) {
      continue;
    }
    testVals.add(s);
  }
  return testVals;
}

main() {
  test('Random strings.', () {
    int size = 100000;
    print("Generating ${size} random 7 length string.");
    var strings = new List<String>()..addAll(randomStrings(size, 7));
    var bloom = new BloomFilter(size);
    print("Amount of hash functions:${bloom.hashAmount}");

    var sw = new Stopwatch()..start();

    for(int i =0; i<strings.length;++i) {
      bloom.add(strings[i].charCodes);
    }
    print("Adding ${size} key took ${sw.elapsedMilliseconds}");

    sw = new Stopwatch()..start();
    for(int i =0; i<strings.length;++i) {
      bloom.check(strings[i].charCodes);
    }
    print("Checking ${size} existing key took ${sw.elapsedMilliseconds}");

    // check
    for(var str in strings) {
      expect(bloom.check(str.charCodes), isTrue);
    }
    Set<String> notAllow = new Set()..addAll(strings);
    var strsNotExist = new List<String>()..addAll(randomStrings(size, 5, notAllow));

    num falsePositive = 0;
    sw = new Stopwatch()..start();
    for(int i =0; i<strsNotExist.length;++i) {
      if(bloom.check(strsNotExist[i].charCodes)) {
        falsePositive++;
      }
    }
    print("Checking ${size} non existing key took ${sw.elapsedMilliseconds}");

    print("${falsePositive} false positive in ${size} keys. Ratio = ${falsePositive/size}");
  });
}
