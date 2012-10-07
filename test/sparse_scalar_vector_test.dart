import 'package:unittest/unittest.dart';
import 'package:poppy/sparse_vector.dart';
import 'dart:math';

main() {
  test('Constructor.', () {
    var table = new SparseVector();
    expect(0, equals(table.length));
    expect(SparseVector.INITIAL_SIZE, equals(table.slotSize));
    table = new SparseVector(10);
    expect(0, equals(table.length));
    expect(16, equals(table.slotSize));
    table = new SparseVector(16);
    expect(0, equals(table.length));
    expect(16, equals(table.slotSize));
    table = new SparseVector(17);
    expect(0, equals(table.length));
    expect(32, equals(table.slotSize));
  });

  test('Stress Test.', () {
    Random rand = new Random();
    for (int i = 0; i < 20; i++) {
      SparseVector siv = new SparseVector();
      int kc = 0;
      for (int j = 0; j < 200000; j++) {
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
      expect( kc , equals(siv.keyCount));
    }
    });

}

  void perf() {
    Random r = new Random();
    var keyVals = new List<List<int>>(10000);
    final int itCount = 1000;
    for (int i = 0; i < keyVals.length; i++) {
      keyVals[i][0] = r.nextInt(500000);
      keyVals[i][1] = r.nextInt(5000) + 1;
    }
    Stopwatch sw = new Stopwatch()..start();
    for (int j = 0; j < itCount; j++) {

    var map = new Map<int, num>();

    for (List<int> keyVal in keyVals) {
      map[keyVal[0]]= keyVal[1];
    }


    for (List<int> keyVal in keyVals) {
      map[keyVal[0]];
    }

    for (List<int> keyVal in keyVals) {
      if (map.containsKey(keyVal[0])) {
        map[keyVal[0]]=map[keyVal[0]] + 1;
      }
    }

    for (List<int> keyVal in keyVals) {
      if (map.containsKey(keyVal[0])) {
        int count = map[keyVal[0]];
        if (count == 1)
          map.remove(keyVal[0]);
        else
          map[keyVal[0]]=count - 1;
      }
    }

    print("Map Elapsed:${sw.elapsedInMs()}");


    SparseVector countTable = new SparseVector();
    sw = new Stopwatch()..start();

    for (int j = 0; j < itCount; j++) {

      for (List<int> keyVal in keyVals) {
        countTable[keyVal[0]]=keyVal[1];
      }
      for (List<int> keyVal in keyVals) {
        countTable[keyVal[0]];
      }

      for (List<int> keyVal in keyVals) {
        countTable.increment(keyVal[0]);
      }

      for (List<int> keyVal in keyVals) {
        countTable.decrement(keyVal[0]);
      }
    }
    print("Sparse Vector elapsed:${sw.elapsedInMs()}");
  }

}
