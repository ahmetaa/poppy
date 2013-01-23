library int_set_test;

import 'package:unittest/unittest.dart';
import 'package:poppy/int_set.dart';
import 'dart:math';

void main() {

  test('Random nums.', () {
     IntSet set = new IntSet();
     expect(set.length, equals(0));

     var uniques = new Set<int>();
     var rnd = new Random();
     int amount = 10000;
     while(uniques.length<amount){
       uniques.add(rnd.nextInt(amount*5));
     }

     for(int i in uniques) {
       set.add(i);
     }

     expect(set.length, equals(amount));

     for(int i in uniques) {
       expect(set.contains(i), true);
     }

     var outOfSet = new Set<int>();

     while(outOfSet.length<amount){
       int r = rnd.nextInt(amount*5);
       if(!uniques.contains(r)) {
         outOfSet.add(r);
       }
     }

     for(int i in outOfSet) {
       expect(set.contains(i), false);
     }

  });

}