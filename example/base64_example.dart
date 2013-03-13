import 'package:poppy/base64.dart';

main() {
  Base64 b = new Base64(urlSafe:false);
  var line =
    "Man is distinguished, not only by his reason, but by this singular "
    "passion from other animals, which is a lust of the mind, that by a "
    "perseverance of delight in the continued and indefatigable generation "
    "of knowledge, exceeds the short vehemence of any carnal pleasure.";
  print("Data= $line");  
  String encoded = b.encode(line.codeUnits);
  print("Encoded= $encoded");
  String decoded = b.decode(encoded);
  print("Decoded= $decoded"); 
}
  

