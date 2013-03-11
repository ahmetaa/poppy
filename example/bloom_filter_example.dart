import 'package:poppy/bloom_filter.dart';

main() {
  var fruits = ["apple", "orange", "blueberry", "cherry", "pomegranate", "plum", "pear"];
  var bloom = new BloomFilter(fruits.length);
  print("Amount of hash functions:${bloom.hashAmount}");

  for(var fruit in fruits) {
    bloom.add(fruit.codeUnits);
  }

  var newFruits = ["apple", "orange", "watermelon", "papaya", "mango", "guava"];
  for(var fruit in newFruits) {
    if(bloom.check(fruit.codeUnits)) {
      print("$fruit may exist in bloom filter.");
    } else {
      print("$fruit does not exist in bloom filter.");
    }
  }
}
