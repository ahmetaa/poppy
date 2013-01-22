import 'package:unittest/unittest.dart';
import 'package:poppy/sparse_vector.dart';
import 'dart:math';

main() {

  test('Constructor.', () {
    var sv = new SparseVector();
    expect(0, sv.length);
    expect(SparseVector.INITIAL_SIZE, sv.slotSize);
    sv = new SparseVector(10);
    expect(0, sv.length);
    expect(16, sv.slotSize);
    sv = new SparseVector(16);
    expect(0, sv.length);
    expect(16, sv.slotSize);
    sv = new SparseVector(17);
    expect(0, sv.length);
    expect(32, sv.slotSize);
  });
  
  test('Iterator Test.', () {
    var sv = new SparseVector();
    expect(0, sv.length);
    var keys = [1,2,5,6];
    var vals = [1,3,7,-10];   
    for(int k = 0; k<keys.length; ++k) {
      sv[keys[k]]= vals[k];
    }
    int j = 0;    
    for(TableEntry entry in sv) {
      expect(keys[j], entry.key);
      expect(vals[j], entry.value);        
      j++;
    }    
  });  

  test('Stress Test.', () {
    Random rand = new Random();
    Stopwatch sw = new Stopwatch()..start();
    for (int i = 0; i < 20; i++) {
      SparseVector siv = new SparseVector();
      int kc = 0;
      for (int j = 0; j < 20000; j++) {
        int key = rand.nextInt(10000);
        bool exist = siv[key] != 0;
        int operation = rand.nextInt(8);
        switch (operation) {
          case 0: // insert
            int value = rand.nextInt(10) + 1;
            if (!exist) {
              siv[key]=value;
              kc++;
            }
            break;
          case 1:
            if (exist) {
              siv.remove(key);
              kc--;
            }
            break;
          case 2:
            siv.increment(key);
            if (siv[key] == 1)
              kc++;
            if (siv[key] == 0)
              kc--;
            break;
          case 3:
            siv[key];
            break;
          case 4:
            if (siv[key] == 0)
              kc++;
            if (siv[key] == 1)
              kc--;
            siv.decrement(key);
            break;
          case 6:
            int value = rand.nextInt(10) + 1;
            siv.incrementByAmount(key, value);
            if (!exist && siv[key] != 0)
              kc++;
            if (siv[key] == 0)
              kc--;
            break;
          case 7:
            int value = rand.nextInt(10) + 1;
            siv.incrementByAmount(key, -value);
            if (!exist && siv[key] != 0)
              kc++;
            if (siv[key] == 0)
              kc--;
            break;
        }
      }
      expect(kc, siv.keyCount);
    }
    print("Stress Test Elapsed:${sw.elapsedMilliseconds}");
  });

  Random r = new Random(5);
  var keyVals = new List<KeyVal>(10000);
  final int itCount = 1000;
  for (int i = 0; i < keyVals.length; i++) {
    keyVals[i] = new KeyVal(r.nextInt(20000), r.nextInt(5000) + 1);
  }

  test('Performance Test.', () {

    Stopwatch sw = new Stopwatch()..start();
    for (int j = 0; j < itCount; j++) {

      var map = new MapBasedSparseVector();

      for (int k = 0; k<keyVals.length; ++k) {
        map[keyVals[k].key]= keyVals[k].val;
      }

      for (int k = 0; k<keyVals.length; ++k) {
        map[keyVals[k].key];
      }

      for (int k = 0; k<keyVals.length; ++k) {
        map.increment(keyVals[k].key);
      }

      for (int k = 0; k<keyVals.length; ++k) {
        map.decrement(keyVals[k].key);
      }
    }
    print("Map Elapsed:${sw.elapsedMilliseconds}");

    SparseVector sv = new SparseVector();
    sw = new Stopwatch()..start();

    for (int j = 0; j < itCount; j++) {

      for (int k = 0; k<keyVals.length; ++k) {
        sv[keyVals[k].key]=keyVals[k].val;
      }
      for (int k = 0; k<keyVals.length; ++k) {
        sv[keyVals[k].key];
      }

      for (int k = 0; k<keyVals.length; ++k) {
        sv.increment(keyVals[k].key);
      }

      for (int k = 0; k<keyVals.length; ++k) {
        sv.decrement(keyVals[k].key);
      }
    }
    print("Sparse Vector elapsed:${sw.elapsedMilliseconds}");
  });

}

class KeyVal {
  final int key;
  final int val;

  KeyVal(this.key, this.val);
}

class MapBasedSparseVector {
  var map = new Map<int,num>();

  num operator [] (int key) => map[key];

  void operator []=(int key, num value) {
    map[key]=value;
  }

  void remove(int key) {
    map.remove(key);
  }

  num decrement(int key) {
    int val = map[key];
    if(val==null){
      map[key]=-1;
      return -1;
    } else if(val==1) {
      map.remove(key);
      return 0;
    } else {
      map[key]=val - 1;
      return val-1;
    }
  }

  num increment(int key) {
    int val = map[key];
    if(val==null){
      map[key]=1;
      return 1;
    } else if(val==-1) {
      map.remove(key);
      return 0;
    } else {
      map[key]=val + 1;
      return val+1;
    }
  }
}


