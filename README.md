# Hash algorithms and functions for Dart 

## Minimal Perfect Hash (Mphf)

*Mphf* class in *lib/mphf.dart* is a Minimal Perfect Hash Function (MPHF) implementation.

A Mphf (http://en.wikipedia.org/wiki/Perfect_hash_function#Minimal_perfect_hash_function) is generated from a defined set of unique keys. It produces a distinct integer for each key in the range of [0..keycount-1].

Such as for a set of 7 strings it generates integers 0..6:
	apple = 3
	orange = 0
	blueberry = 1
	cherry = 6
	pomegranate = 5
	plum = 4
	pear = 2

Generated hash function does not store key data in the structure therefore they are very compact. 
This particular implementation uses around 3.2 bits per key. 
 
Mphfs may be useful for very large look-up structures such as language model compression. 
Mphf generation is a very slow operation, therefore it is generally suggested storing the hash data once it is generated and using it from the storage afterwards. 
Dart implementation does not provide this functionality.

This implementation is a variant of "Hash, displace, and compress" - CHD algorithm (http://cmph.sourceforge.net/papers/esa09.pdf). 
The novelty of this variant is that it does not apply integer array compression. Instead it stores the hash seed values in a byte array and uses layered structure for failed buckets.
It uses slightly more space than it could (typically a Mphf can use only 2.5 bits), but generally this implementation is faster to generate and query. 

### Usage example:

	main() {
	  var fruits = ["apple", "orange", "blueberry", "cherry", "pomegranate", "plum", "pear"];
	  var mphf = new Mphf.fromStrings(fruits);
	  for(var fruit in fruits) {
	    print("$fruit = ${mphf.getValue(fruit.charCodes())}");
	  }
	}

## Sparse Vector (SparseVector)
*SparseVector* class in sparse_vector.dart can be used for representing large sparse vectors where most of its values are zero. 
This structure only hold non-zero elements in it. Therefore it is compact.   
Internally it is actually a hash table that uses linear probing. It is more efficient than using Map<int,num> structure. Most vector arithmetic operations are not yet added to the code.

  
