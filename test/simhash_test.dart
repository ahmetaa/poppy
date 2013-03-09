library simhash_test;

import 'package:unittest/unittest.dart';
import 'package:poppy/simhash.dart';

void main() {
  test('Constructor.', () {
    var simHasher = new SimHash();
    int h1 = simHasher.getHashFromString("Small rabbit was very sad");
    int h2 = simHasher.getHashFromString("Small cute rabbit was very sad");
    int h3 = simHasher.getHashFromString("Because his brother was laughing at him");
    expect(hammingDistance(h1,h2), lessThan(15));
    expect(hammingDistance(h1,h3), greaterThan(15));
  });
}





