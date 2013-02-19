import 'dart:math';
import 'package:poppy/mphf.dart';

/*
 * - Generate [AMOUNT] [LENGTH] legth unique strings.
 * - Generate minimal perfect hash function for this string set.
 * - Query all strings to check speed. Use unchecked mode for speed.
 */

final num AMOUNT = 100000;
final num LENGTH = 7;

void main() {

  print("Generating $AMOUNT amount of $LENGTH length unique strings");
  var stopWatch = new Stopwatch()..start();
  var testStrings = _randomStrings();
  print("String set generation time : ${stopWatch.elapsedMilliseconds} ms \n");

  for(int k=0; k<5; k++) {
    print("iteration: $k");
    stopWatch..reset()..start();
    var hash = new Mphf.fromStrings(testStrings);
    print("Hash generation time : ${stopWatch.elapsedMilliseconds} ms");
    print("Average bit per key: ${hash.averageBitsPerKey()}");

    var l = new List<List<int>>();
    for(String s in testStrings) {
      l.add(s.charCodes);
    }
    stopWatch..reset()..start();
    for(int i = 0, length = l.length; i<length; ++i) {
      int k = hash.getValue(l[i]);
    }
    print("Hash query time : ${stopWatch.elapsedMilliseconds} ms \n");
  }
}

Set<String> _randomStrings() {
  var rnd = new Random();
  var testVals = new Set<String>();
  while(testVals.length < AMOUNT) {
    var buffer = new StringBuffer();
    for(int k = 0; k<LENGTH; k++) {
      int randomChar = rnd.nextInt(26)+'a'.codeUnitAt(0);
      buffer.addCharCode(randomChar);
    }
    testVals.add(buffer.toString());
  }
  return testVals;
}



