import 'package:poppy/simhash.dart';

void main() {

  var sh = new SimHash();

  var l = ["Small rabbit was very sad",
           "Small cute rabbit was very sad",
           "Because his brother was laughing at him",
           "What kind of rabbit are you?",
           "You have small teeth",
           "You have small ears."];
  for(String s in l) {
    print ('$s');
    int h1 = sh.getHashFromString(s);
    for(String ss in l) {
      if(s==ss) {
        continue;
      }
      int h2 = sh.getHashFromString(ss);
      print ("${hammingDistance(h1,h2)} : $ss");
    }
  }
}


