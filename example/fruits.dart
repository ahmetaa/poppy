import 'package:poppy/mphf.dart';
import 'packages/poppy/src/fixed_bit_vector.dart';

void main() {
  FixedBitVector bv = new FixedBitVector.bitCount(1000000);
  Stopwatch sv = new Stopwatch()..start();
  for (int i = 0; i < 1000000; i++) {
    bv.setBit(i);
    bv.getBit(i);
    bv.clear(i);
  }
  print("Time: ${sv.elapsedInMs()}");
  var fruits = ["apple", "orange", "blueberry", "cherry", "pomegranate", "plum", "pear"];
  var mphf = new Mphf.fromStrings(fruits);
  for(var fruit in fruits) {
    print("$fruit = ${mphf.getValue(fruit.charCodes())}");
  }
}
