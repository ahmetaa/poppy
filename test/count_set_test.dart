library count_set_test;
import 'package:unittest/unittest.dart';
import 'package:poppy/count_set.dart';

main() {
  test('Constructor.', () {
    var sv = new CountSet<int>();
    expect(0, sv.length);
    expect(CountSet.INITIAL_SIZE, sv.slotSize);
    sv = new CountSet<int>(10);
    expect(0, sv.length);
    expect(16, sv.slotSize);
    sv = new CountSet<int>(10);
    expect(0, sv.length);
    expect(16, sv.slotSize);
    sv = new CountSet<int>(17);
    expect(0, sv.length);
    expect(32, sv.slotSize);
  });

  test('Iterator Test.', () {
    var sv = new CountSet<int>();
    expect(0, sv.length);
    var keys = [1,2,5,6];
    var vals = [1,3,7,-10];
    for(int k = 0; k<keys.length; ++k) {
      sv[keys[k]]= vals[k];
    }
    int j = 0;
    for(int i in sv) {
      expect(keys[j], i);
      expect(vals[j], sv[i]);
      j++;
    }
  });
  
}