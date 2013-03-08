library bloom_test;

import 'package:unittest/unittest.dart';
import 'package:poppy/bloom_filter.dart';
import 'dart:math';

Set<String> randomStrings(num amount, num length) {
  var rnd = new Random();
  var testVals = new Set<String>();
  int a = 'a'.codeUnitAt(0);
  int k=0;
  while(testVals.length < amount) {
    var buffer = new StringBuffer();
    for(int k = 0; k<length; k++) {
      int randomChar = rnd.nextInt(26) + a;
      buffer.writeCharCode(randomChar);
    }
    String s = buffer.toString();
    testVals.add(s);
    k++;
    if(k%10000==0) {
      print('$k : ${testVals.length}');
    }
  }
  return testVals;
}

Set<List<int>> randomStrings2(num amount, num length) {
  var rnd = new Random();
  var testVals = new Set<List<int>>();
  int a = 'a'.codeUnitAt(0);  
  while(testVals.length < amount) {
    List<int> buffer = new List.fixedLength(length);
    for(int k = 0; k<length; k++) {
      int randomChar = rnd.nextInt(26) + a;
      buffer[k] = randomChar;
    }    
    testVals.add(buffer);
  }
  return testVals;
}

foo() {
  var rnd = new Random();
  int j=0;
  for(int i = 0; i<100000; i++) {
    j = j+ rnd.nextInt(26);
  }
  print(j);
}


main() {
  test('Random strings.', () {
    int size = 100000;
    Stopwatch sw = new Stopwatch()..start();
    print("Generating ${size} random 7 length string.");
    //foo();
    //var blah = randomStrings2(size, 7);    
    var strings = new List<String>()..addAll(randomStrings(size, 7));
    print(sw.elapsedMicroseconds);    
    var bloom = new BloomFilter(size);
    print("Amount of hash functions:${bloom.hashAmount}");

    sw..reset()..start();

    for(int i =0; i<strings.length;++i) {
      bloom.add(strings[i].codeUnits);
    }
    print("Adding ${size} key took ${sw.elapsedMilliseconds}");

    sw = new Stopwatch()..start();
    for(int i =0; i<strings.length;++i) {
      bloom.check(strings[i].codeUnits);
    }
    print("Checking ${size} existing key took ${sw.elapsedMilliseconds}");

    // check
    for(var str in strings) {
      expect(bloom.check(str.codeUnits), isTrue);
    }
    Set<String> notAllow = new Set()..addAll(strings);
    var strsNotExist = new List<String>()..addAll(randomStrings(size, 5));

    num falsePositive = 0;
    sw = new Stopwatch()..start();
    for(int i =0; i<strsNotExist.length;++i) {
      if(bloom.check(strsNotExist[i].codeUnits)) {
        falsePositive++;
      }
    }
    print("Checking ${size} non existing key took ${sw.elapsedMilliseconds}");

    print("${falsePositive} false positive in ${size} keys. Ratio = ${falsePositive/size}");
  });
}
