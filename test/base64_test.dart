library base64_test;

import 'package:unittest/unittest.dart';
import 'package:poppy/base64.dart';
import 'dart:math';

fillRandom(List<int> l) {
  var random = new Random(0xBABE);
  for(int j=0; j < l.length; j++) {
    l[j] = random.nextInt(256);
  }
}

String encodeTest(List<int> l, int iterations) {
  String enc;
  var b = new Base64();
  for( int i = 0; i < iterations; ++i ) {
    enc = b.encode(l);
  }
  return enc;
}

List<int> decodeTest(String input, int iterations) {
  List<int> dec;
  var b = new Base64();
  for( int i = 0; i < iterations; ++i ) {
    dec = b.decode(input);
  }
  return dec;
}

void testEncodeDecode(String expected, String input) {
  Base64 b = new Base64(urlSafe:false);
  String encoded = b.encode(input == null ? null : input.codeUnits);
  expect(expected, encoded);
  List<int> decoded = b.decode(encoded);
  expect(input == null ? '' : input, new String.fromCharCodes(decoded));
}

void runAll() {
  test('Null input', (){
    testEncodeDecode("", null);
  });

  test('Small encode no padding', (){
    testEncodeDecode("TWFu", "Man");
  });

  test('Small encode 1 padding', (){
    testEncodeDecode("bGVhc3VyZS4=", "leasure.");
  });

  test('Small encode 2 padding', (){
    testEncodeDecode("ZWFzdXJlLg==", "easure.");
  });

  test('Output >76 chars', (){
    Base64 b = new Base64(urlSafe:false);
    var line =
        "Man is distinguished, not only by his reason, but by this singular "
        "passion from other animals, which is a lust of the mind, that by a "
        "perseverance of delight in the continued and indefatigable generation "
        "of knowledge, exceeds the short vehemence of any carnal pleasure.";
    var expected =
        "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbm"
        "x5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz\r\n"
        "IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlci"
        "BhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg\r\n"
        "dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcm"
        "FuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu\r\n"
        "dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYX"
        "Rpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo\r\n"
        "ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm"
        "5hbCBwbGVhc3VyZS4=";
    testEncodeDecode(expected, line);
  });

  test('Encode Performance', (){
    var l = new List<int>(4096);
    var iters = 20000;
    fillRandom(l);
    String enc;
    var b = new Base64();
    var w = new Stopwatch()..start();
    for( int i = 0; i < iters; ++i ) {
      enc = b.encode(l);
    }
    int ms = w.elapsedMilliseconds;
    int perSec = (iters * l.length) * 1000 ~/ ms;
    print("Encode 1024 bytes for $iters times: $ms msec. $perSec b/s");
  });

  test('Decode Performance', (){
    var l = new List<int>(4096);
    var iters = 20000;
    fillRandom(l);
    String enc;
    var b = new Base64();
    enc = b.encode(l);
    var w = new Stopwatch()..start();
    for( int i = 0; i < iters; ++i ) {
      b.decode(enc);
    }
    int ms = w.elapsedMilliseconds;
    int perSec = (iters * enc.length) * 1000 ~/ ms;
    print("Decode ${enc.length} chars for $iters times: $ms msec. $perSec b/s");
  });

}

void main() {
  runAll();
}
