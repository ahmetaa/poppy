import 'package:poppy/mphf.dart';
import 'packages/poppy/src/fixed_bit_vector.dart';

void main() {
  var fruits = ["apple", "orange", "blueberry", "cherry", "pomegranate", "plum", "pear"];
  var mphf = new Mphf.fromStrings(fruits);
  for(var fruit in fruits) {
    print("$fruit = ${mphf.getValue(fruit.charCodes())}");
  }
}
