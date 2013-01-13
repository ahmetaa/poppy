import 'package:poppy/trie.dart';

main() {
  var words = ["april", "apron", "apricot", "hello", "goodbye"];
  Trie<String> trie = new SimpleTrie();
  for(var str in words) {
    trie[str]= str; // we put the string itself as the value. But this could be some other object.    
  } 
  print(trie.getValuesWithPrefix("apr"));   
}
