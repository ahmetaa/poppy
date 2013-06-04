import 'dart:math';
import 'package:poppy/mphf.dart';

/*
 * - Generate [AMOUNT] [LENGTH] legth unique strings.
 * - Generate minimal perfect hash function for this string set.
 * - Query all strings to check speed. Use unchecked mode for speed.
 */

final num AMOUNT = 200000;
final num LENGTH = 7;

void main() {
  
  print("Generating $AMOUNT amount of $LENGTH length unique strings");

  for(int i=0; i<10;i++) {
    _randomStrings(10000,7);
    _randomStrings2(10000,7);    
  }
  var stopwatch = new Stopwatch()..start();  
  final testStrings = _randomStrings(AMOUNT,LENGTH);  
  print("String set generation time : ${stopwatch.elapsedMilliseconds} ms \n");
  stopwatch = new Stopwatch()..start(); 
  _randomStrings2(AMOUNT,LENGTH);  
  print("String set generation time2 : ${stopwatch.elapsedMilliseconds} ms \n");  

  for(int k=0; k<5; k++) {
    print("iteration: $k");
    stopwatch..reset()..start();
    var hash = new Mphf.fromStrings(testStrings);
    print("Hash generation time : ${stopwatch.elapsedMilliseconds} ms");
    print("Average bit per key: ${hash.averageBitsPerKey()}");

    List<String> l = new List.from(testStrings);
    stopwatch..reset()..start();
    for(int i = 0, length = l.length; i<length; ++i) {
      int k = hash.getValueStr(l[i]);
    }
    print("Hash query time : ${stopwatch.elapsedMilliseconds} ms \n");
  }
}

Set<String> _randomStrings(int amount, int length) {
  int a = 'a'.codeUnitAt(0);
  var rnd = new Random();
  var testVals = new Set<String>();
  while(testVals.length < amount) {
    var buffer = new StringBuffer();
    for(int k = 0; k<length; k++) {
      int randomChar = rnd.nextInt(26)+a;
      buffer.writeCharCode(randomChar);
    }
    testVals.add(buffer.toString());
  }
  return testVals;
}


_randomStrings2(int amount, int length) {
  int a = 'a'.codeUnitAt(0);
  var rnd = new Random();
  int j = 0;
  while(j < amount) {
    var buffer = new StringBuffer();
    for(int k = 0; k<length; k++) {
      int randomChar = k%32+a;
      buffer.writeCharCode(randomChar);
    }
    buffer.toString();
    j++;
  }  
}



