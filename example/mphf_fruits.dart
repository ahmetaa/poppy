import 'package:poppy/mphf.dart';

void main() {
  var fruits = ["apple", "orange", "blueberry", "pomegranate"];
  var mphf = new Mphf.fromStrings(fruits);
  for(var fruit in fruits) {
    print("$fruit = ${mphf.getValue(fruit.codeUnits)}");
  }
}
