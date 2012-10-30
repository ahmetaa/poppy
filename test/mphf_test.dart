import 'package:unittest/unittest.dart';
import 'package:poppy/mphf.dart';
import 'dart:math';

bool randomStringTest() {
  var nums = [1,2,3,4,5,7,10,100,1000,1001,10000,50000,100000];
  for(num size in nums) {
    Set<String> strings = randomStrings(size, 7);
    Mphf hash = new Mphf.fromStrings(strings);
    print ("For key set ${size} average memory per key = ${hash.averageBitsPerKey()} bits");
    var values = new Set<int>();
    for(String s in strings) {
      int value = hash.getValue(s.charCodes);
      if(values.contains(value)) {
        print("Duplicated value $value for key $s for set size $size");
        return false;
      }
      values.add(value);
    }
  }
  return true;
}

Set<String> randomStrings(num AMOUNT, num LENGTH) {
  var rnd = new Random();
  var testVals = new Set<String>();
  while(testVals.length < AMOUNT) {
    var buffer = new StringBuffer();
    for(int k = 0; k<LENGTH; k++) {
      int randomChar = rnd.nextInt(26)+'a'.charCodeAt(0);
      buffer.addCharCode(randomChar);
    }
    testVals.add(buffer.toString());
  }
  return testVals;
}

main() {
  test('Random strings.', () {
    expect(randomStringTest(), equals(true));
  });
}