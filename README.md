#  Algorithms for Dart 

## Trie
Trie implementation for Dart. Tries are especially good for prefix searches. This implementation is copied from mdakin's TrieDart library. 

### Usage example:

	import 'package:poppy/trie.dart';
	...
	var words = ["april", "apron", "apricot", "hello", "goodbye"];
	Trie<String> trie = new SimpleTrie();
	for(var str in words) {
	  trie[str]= str; // we put the key as the value. could be something else 
	} 
	print(trie.getValuesWithPrefix("apr"));
		
	Output:	
	[apricot, april, apron]	

## Minimal Perfect Hash Function (Mphf)

*Mphf* class is a Minimal Perfect Hash Function (MPHF) implementation.

A Mphf (http://en.wikipedia.org/wiki/Perfect_hash_function#Minimal_perfect_hash_function) is generated from a defined set of unique keys. It produces a distinct integer for each key in the range of [0..keycount-1].

Generated hash function does not store key data in the structure therefore they are very compact. 
This particular implementation uses around 3.2 bits per key. 
 
Mphfs may be useful for very large look-up structures such as the ones used in language model compression. 
Mphf generation is a very slow operation, therefore it is generally suggested storing the hash data once it is generated and using it from the storage afterwards. 
Dart implementation does not provide this functionality.

### Usage example:
	import 'package:poppy/mphf.dart';
	...
	var fruits = ["apple", "orange", "blueberry", "pomegranate"];
	var mphf = new Mphf.fromStrings(fruits);
	for(var fruit in fruits) {
	  print("$fruit = ${mphf.getValue(fruit.charCodes)}");
	}

	Output:
	apple = 3
	orange = 2
	blueberry = 1
	pomegranate = 0	

## Bloom Filter
*BloomFilter* is a simple Bloom Filter (http://en.wikipedia.org/wiki/Bloom_filter) implementation. 
This structure guarantess if a key was "not" added to it. However it cannot guarantee if a key really added before.
A Bloom filter can be constructed with number of keys to add, bits per bucket or maximum expected false positive ratio. Parameter estimation code is 
converted from commoncrawl project.

### Usage example:
    import 'package:poppy/bloom_filter.dart';
    ...
	var fruits = ["apple", "orange", "blueberry", "pomegranate"];
	var bloom = new BloomFilter(fruits.length);
	
	for(var fruit in fruits) {
	  bloom.add(fruit);
	}
		  
	var newFruits = ["apple", "orange", "guava"];  
	for(var fruit in newFruits) {
	  if(bloom.check(fruit.charCodes))
	    print("$fruit may exist in bloom filter.");
	  else
	    print("$fruit does not exist in bloom filter.");
	}

	Output:	
	apple may exist in bloom filter.
	orange may exist in bloom filter.
	guava does not exist in bloom filter.

## SimHash
This is a special hash function that generates similar hash values for similar items. This means
bit positions of two hash values matches better for similar items (smaller Hamming distance).  For example:  
	
	import 'package:poppy/simhash.dart';
	...	
	var simHasher = new SimHash();
	int h1 = simHasher.getHashFromString("Small rabbit was very sad");
	int h2 = simHasher.getHashFromString("Small cute rabbit was very sad");
	int h3 = simHasher.getHashFromString("Because his brother was laughing at him");
	print ("h1-h2 Hamming distance: ${hammingDistance(h1,h2)}");
	print ("h1-h3 Hamming distance: ${hammingDistance(h1,h3)}");
	
	output:
	h1-h2 Hamming distance: 9
	h1-h3 Hamming distance: 31
	
For each input a 64 bit hash is generated. This hash can be used in tasks like near duplicate detection and clustering of documents.
This idea is represented in Charikar's "Similarity Estimation Techniques from Rounding Algorithms" paper. 

## CountSet
*CountSet* class in count_set.dart is used for counting objects. Similar structures are also known as MultiSet or Bag.
This structure is possibly more compact than using a map structure. It also provides count related methods.

	import 'package:poppy/count_set.dart';
	...
	var fruits = ["apple","apple","orange","apple","pear","orange"];
	var set = new CountSet<String>()..addAll(fruits);
	for(String fruit in new Set()..addAll(fruits)) {
	  print("Count of $fruit is ${set[fruit]}");
	}
	print("Non existing item papaya's count:${set['papaya']}");
	
	Output:
	Count of apple is 3
	Count of orange is 2
	Count of pear is 1
	Non existing item papaya's count:0	  
 
## Sparse Vector 
*SparseVector* class in sparse_vector.dart can be used for representing large sparse vectors where most of its values are zero. 
This structure only hold non-zero elements in it. Therefore it is compact.
  
Internally it is actually a hash table that uses linear probing. It is more efficient than using Map&lt;int,num&gt; structure. Most vector arithmetic operations are not yet added to the code.

## Integer Set  
A simple implementation of an integer set. This is actually similar to SparseVector class. It is suppose to be
sligthly faster and memory efficient than Set&lt;int&gt; structure.

## Change List
*0.1.11* Dart M4 changes. Use 0x3fffffff for MPHF and BloomFilter bounds. Remove Base64 since there is a full
Base64 codec available in Dart. Trie returns an Iterable instead of Collection.  
*0.1.10* Add decodeUnsafe method Base64. Also it is faster now.  
*0.1.9* Base64 api change  
*0.1.8* Introduce Base64 codec. Add String methods to BloomFilter.  
*0.1.7* Fix an error slipped to 0.1.6 in mphf lib definition. Some cleanup  
*0.1.6* CountSet is introduced. Dart M3 changes. 
