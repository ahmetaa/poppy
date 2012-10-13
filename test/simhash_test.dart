import 'package:unittest/unittest.dart';
import 'package:poppy/simhash.dart';

void main() {
  var sh = new SimHash();

  var l = ["Şirin tavşan çok üzgündü",
           "Şirin davşan çok üzgündü"
           ];
  for(String s in l) {
    print ('$s');
    int h1 = sh.getHash(s.charCodes(), 0x2D980ED);
    print('${binaryString(h1, 64)}');
    for(String ss in l) {
      if(s==ss)
        continue;
      int h2 = sh.getHash(ss.charCodes());
      print('${binaryString(h2, 64)}');
      print ("${hammingDistance(h1,h2)} : $ss");
    }
  }
}





