import 'package:poppy/trie.dart';

main() {
  var words = ["ab", "aba", "abanoz", "abartmak", "acı", "baba", "baca"];
  Trie<String> trie = new SimpleTrie();
  for(var str in words) {
    trie[str]= str; // we put the string itself as the value. But this could be some other object.    
  } 
  print(trie.getValuesWithPrefix("aba"));   
}
