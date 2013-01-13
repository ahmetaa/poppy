import 'package:poppy/trie.dart';
import 'package:unittest/unittest.dart';

class TrieTest {
  
  static testMain() {
    testEmpty(new SimpleTrie());
    testAddGetSimple(new SimpleTrie());
    testAddGetComplex(new SimpleTrie());
    testGetKeysByPrefix(new SimpleTrie());
    testGetKeysByPrefixComplex(new SimpleTrie());
    testGetValuesByPrefix(new SimpleTrie());
    testGetKeyValuesByPrefix(new SimpleTrie());
    testGetKeysByNullOrEmptyPrefix(new SimpleTrie());
    testForEach(new SimpleTrie());
    testForEachWithPrefix(new SimpleTrie());
  }

  static void testEmpty(Trie trie) {
    test('Empty', () {    
      expect(trie.isEmpty, isTrue);
      expect(trie.size, 0);
      expect(trie.getKeysWithPrefix(""),isNotNull);
      expect(trie.getKeysWithPrefix(""),isEmpty);
    });
  }

  static void testAddGetSimple(Trie trie) {
    
    test('AddGetSimple', () {        
      // Empty trie
      expect(trie.isEmpty, isTrue);
      expect(trie["Hello"], isNull);
      expect(trie[""], isNull);
  
      trie["Hello"] = "Hello-Value";
      expect(trie.isEmpty, isFalse);
      expect(trie.size, 1);
      expect(trie["Hello"],"Hello-Value");
  
      // Add same
      trie["Hello"] = "Hello";
      expect(trie.size, 1);
      expect(trie["Hello"],"Hello-Value");
  
      // Add another
      trie["Hell"] = "Hell-Value";
      expect(trie.size,2);
      expect(trie["Hell"],"Hell-Value");
  
      // Clear
      trie.clear();
      expect(trie.isEmpty, isTrue);
      expect(trie["Hello"], isNull);
      expect(trie[""], isNull);
    });    
  }

  static void testAddGetComplex(Trie trie) {
    
    test('AddGetComplex', () {      
      expect(trie.isEmpty, isTrue);
      num limit = 1000;
      for (num i=0; i < limit; i++) {
        trie[i.toString()] = i;
      }
      expect(trie.size, limit);
      for (num i=1; i < limit; i++) {
        expect(trie[i.toString()], i);
      }
  
      trie.clear();
      expect(trie.isEmpty, isTrue);
      for (num i= limit -1; i >= 0; i--) {
        trie[i.toString()] = i;
      }
      expect(trie.size,limit);
      for (num i=0; i < limit; i++) {
        expect(trie[i.toString()],i);        
      }
    });    
  }

  static void testGetKeysByPrefix(Trie trie) {
    test('GetKeysByPrefix', () {     
      expect(trie.isEmpty, isTrue);
      trie["Hello"] = "Hello-Value";
      trie["Hell"] = "Hell-Value";
      List<String> keys = new List.from(trie.getKeysWithPrefix("H"));
      List<String> expected = ["Hell", "Hello"];
      expect(keys, expected);
    });
  }

  static void testGetKeysByNullOrEmptyPrefix(Trie trie) {
    test('GetKeysByNullOrEmptyPrefix', () {    
      expect(trie.isEmpty, isTrue);
      trie["Hello"] = "Hello-Value";
      trie["Happy"] = "Happy-Value";
      trie["Apple"] = "Apple-Value";
      List<String> keysFromEmpty = new List.from(trie.getKeysWithPrefix(""));
      List<String> keysFromNull = new List.from(trie.getKeysWithPrefix(null));
      List<String> expected = ["Apple", "Happy", "Hello"];
      expect(keysFromNull, expected);
      expect(keysFromEmpty, expected);
    });
  }

  static void testGetKeysByPrefixComplex(Trie trie) {
    test('GetKeysByPrefixComplex', () {     
      expect(trie.isEmpty, isTrue);
      // Add 0-999 to trie
      for (num i=0; i < 1000; i++) {
        trie[i.toString()] = i;
      }
      List<String> keys = new List.from(trie.getKeysWithPrefix("1"));
      expect(keys.length, 111);
      keys = new List.from(trie.getKeysWithPrefix("12"));
      expect(keys.length, 11);
      keys = new List.from(trie.getKeysWithPrefix("9"));
      expect(keys.length, 111);
      keys = new List.from(trie.getKeysWithPrefix("99"));
      expect(keys.length, 11);
    });
  }

  static void testGetValuesByPrefix(Trie trie) {
    test('GetKeysByPrefixComplex', () {      
      expect(trie.isEmpty, isTrue);
      trie["Hello"] = "Hello-Value";
      trie["Help"] = "Help-Value";
      List<String> values = new List.from(trie.getValuesWithPrefix("H"));
      expect(values.length, 2);
      List<String> expected = ["Hello-Value", "Help-Value"];
      expect(values, expected);
    });
  }

  static void testGetKeyValuesByPrefix(Trie trie) {
    test('GetKeyValuesByPrefix', () {      
      expect(trie.isEmpty, isTrue);
      trie["Hello"] = "Hello-Value";
      trie["Hel"] = "Hel-Value";
      trie["Happy"] = "Happy-Value";
      Map <String, String> actual = trie.getKeyValuesWithPrefix("H");
      expect(actual.length, 3);
      // We expect results must be sorted by keys.
      LinkedHashMap<String, String> expected = {"Happy" : "Happy-Value",
                                                "Hel" : "Hel-Value",
                                                "Hello" : "Hello-Value", };
      expect(actual, expected);
    });
  }

  static void testForEach(Trie trie) {
    test('GetKeyValuesByPrefix', () {       
      expect(trie.isEmpty, isTrue);
      trie["Hello"] = "Hello-Value";
      trie["Happy"] = "Happy-Value";
      LinkedHashMap<String, String> expected = {"Happy" : "Happy-Value",
                                                "Hello" : "Hello-Value"};
      Map <String, String> actual = new Map<String, String>();
      trie.forEach((k ,v) => actual[k] = v);
      expect(actual, expected);
    });
  }
    

  static void testForEachWithPrefix(Trie trie) {
    test('ForEachWithPrefix', () {       
      expect(trie.isEmpty, isTrue);
      trie["Hello"] = "Hello-Value";
      trie["Happy"] = "Happy-Value";
      LinkedHashMap<String, String> expected = {"Happy" : "Happy-Value"};
      Map <String, String> actual = new Map<String, String>();
      trie.forEachWithPrefix("Hap", (k ,v) => actual[k] = v);
      expect(actual, expected);
    });
  }

}

main() {
  TrieTest.testMain();
}
