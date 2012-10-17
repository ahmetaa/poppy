import 'package:unittest/unittest.dart';
import 'package:poppy/simhash.dart';

void main() {
  
  var sh = new SimHash();

  var l = ["Şirin tavşan çok üzgündü Çünkü kardeşi karşısına geçmiş kahkahalarla gülüyordu.Ne kadar küçük dişlerin var.", 
           "Şirin davşan çok üzgündü Çünkü kardeşi karşısına geçmiş kahkahalarla gülüyordu.Ne kadar küçük dişlerin var.", 
           "Çünkü kardeşi karşısına geçmiş kahkahalarla gülüyordu.",
           "Ne kadar küçük dişlerin var.",
           "Ne kadar küçük kulakların var.",
           "Böyle tavşan olur mu?"];
  for(String s in l) {
    print ('$s');
    int h1 = sh.getHash(s.charCodes());
    for(String ss in l) {
      if(s==ss)
        continue;
      int h2 = sh.getHash(ss.charCodes());
      print ("${hammingDistance(h1,h2)} : $ss");
    }
  }
}





