# Minimal Perfect Hash for Dart

*mphf.dart* is a Minimal Perfect Hash Function (MPHF) implementation.

A Mphf (http://en.wikipedia.org/wiki/Perfect_hash_function#Minimal_perfect_hash_function) is generated from a defined set of unique keys. It produces a distinct integer for each key in the range of [0..keycount-1].

Such as for a set of 7 strings it generates integers 0..6:
	apple = 3
	orange = 0
	blueberry = 1
	cherry = 6
	pomegranate = 5
	plum = 4
	pear = 2

Generated hash does not store key data in the structure therefore they are very compact. They may be useful for very large look-up structures (such as language model compression). Mphf generation is a very slow operation, therefore it is generally suggested storing the hash data once it is generated and using it from the storage afterwards. Dart implementation does not provide this functionality.

This implementation is a variant of "Hash, displace, and compress" - CHD algorithm (http://cmph.sourceforge.net/papers/esa09.pdf). The differences from the original algorithm:
-	It does not apply integer compression. It stores the hash seed values in a byte array instead
-	When a seed value is larger than 256 it ignores the related bucket and process it later as a new hash.

Implmentation uses around 3.2 bits per key but my guess is it is faster than original algorithm because it does not use integer compression.

## Usage example:

	main() {
	  var fruits = ["apple", "orange", "blueberry", "cherry", "pomegranate", "plum", "pear"];
	  var mphf = new Mphf.fromStrings(fruits);
	  for(var fruit in fruits) {
	    print("$fruit = ${mphf.hashValue(fruit.charCodes())}");
	  }
	}


