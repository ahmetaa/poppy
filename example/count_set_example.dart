import 'package:poppy/count_set.dart';

main() {
  var fruits = ["apple","apple","orange","apple","pear","orange"];
  var set = new CountSet<String>()..addAll(fruits);
  for(String fruit in new Set()..addAll(fruits)) {
    print("Count of $fruit is ${set[fruit]}");
  }
  print("Non existing item papaya's count:${set['papaya']}");
}

