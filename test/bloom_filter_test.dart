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
    if(?notAllowed && notAllowed.contains(s))
      continue;
    testVals.add(s);
  }
  return testVals;
}

main() {
  test('Random strings.', () {
    int size = 100000;
    Set<String> strings = randomStrings(size, 5);
    var bloom = new BloomFilter(size);
    
    for(var str in strings) {
      bloom.add(str.charCodes());
    }
    
    for(var str in strings) {
      expect(bloom.check(str.charCodes()), equals(true));      
    }
    
    Set<String> strsNotExist = randomStrings(size, 5, strings);  
    num falsePositive = 0;
    for(var str in strsNotExist) {
      if(bloom.check(str.charCodes()))
        falsePositive++;
    }
    print("${falsePositive} false positive in ${size} keys. Ratio = ${falsePositive/size}");
  });
}
