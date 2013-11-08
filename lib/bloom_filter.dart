library poppy;

import 'src/bit_vector.dart';

class BloomFilter {

  FixedBitVector _bitVector;

  List<_BloomHash> _hashFunctions;

  int get hashAmount => _hashFunctions.length;

  //  Eight prime numbers to use as hash seeds. could be other numbers.
  var _seeds = [0xEC4BA7, 0x222B3A25, 0x3A8F057B, 0x51CD6295, 0x14D41585, 0x2D980ED, 0x1118DEA5, 0x28E75F97];

  BloomFilter(int approximateKeyAmount, {int bucketsPerKey:10}) {
    int hashCount = BloomParameterEstimation.computeBestK(bucketsPerKey);
    _initialize(approximateKeyAmount, bucketsPerKey, hashCount);
  }

  BloomFilter.maxFalsePosProb(int approximateKeyAmount, double maxFalsePosProb) {
    var params = BloomParameterEstimation.fromMaxFalsePosProb(maxFalsePosProb);
    _initialize(approximateKeyAmount, params.bucketsPerElement, params.K);
  }

  _initialize(int approximateKeySize, int bucketsPerKey, int hashCount) {

    int bucketAmount = bucketsPerKey*approximateKeySize;
    if(bucketAmount > 0x3fffffff) {
      throw new ArgumentError("Cannot have $approximateKeySize elements.");
    }

    _hashFunctions = new List<_BloomHash>(hashCount);
    _bitVector = new FixedBitVector.bitCount(bucketAmount);

    for(int i = 0; i<hashCount; ++i) {
      _hashFunctions[i]= new _BloomHash(_seeds[i], bucketAmount);
    }
  }

  /// adds key to the filter.
  void add(List<int> key) {
    for(var hashFunc in _hashFunctions) {
      _bitVector.setBit(hashFunc.hash(key));
    }
  }
  
  /// adds a String key to the filter.
  void addString(String key) {
    for(var hashFunc in _hashFunctions) {
      _bitVector.setBit(hashFunc.hashStr(key));
    }
  }  

  /// adds a String keys to the filter.
  void addStrings(Iterable<String> keys) {
    for(var hashFunc in _hashFunctions) {
      for(String key in keys) _bitVector.setBit(hashFunc.hashStr(key));
    }
  }    
  
  /// returns false if key definitely does not exist. true when key *may* exist
  bool check(List<int> key) {
    for(var hashFunc in _hashFunctions) {
      if(!_bitVector.getBit(hashFunc.hash(key))) return false;      
    }
    return true;
  }

  /// returns false if key definitely does not exist. true when key *may* exist
  bool checkString(String key) {
    for(var hashFunc in _hashFunctions) {
      if(!_bitVector.getBit(hashFunc.hashStr(key))) return false;      
    }
    return true;
  }  
  
}

class _BloomHash {
  final int seed;
  final int modulo;

  _BloomHash(this.seed, this.modulo);

  int hash(List<int> key) {
    int h1 = seed;
    for (int i=0, length=key.length; i<length;++i) {
      h1 = ((h1 ^ key[i]) * 16777619) & 0x3fffffff;
    }
    return h1 % modulo;
  }
  
  int hashStr(String key) {
    int h1 = seed;
    for (int i=0, length=key.length; i<length;++i) {
      h1 = ((h1 ^ key.codeUnitAt(i)) * 16777619) & 0x3fffffff;
    }
    return h1 % modulo;
  }  
}

class _BloomParameters {

  int K;                // number of hash functions.
  int bucketsPerElement;

  _BloomParameters(this.K, this.bucketsPerElement);
}

/**
 * This class below is converted from commoncrawl project's BloomCalculations class.
 * Below is the documentation from there.
 *
 * The following calculations are taken from:
 * http://www.cs.wisc.edu/~cao/papers/summary-cache/node8.html
 * "Bloom Filters - the math"
 *
 * This class's static methods are meant to facilitate the use of the Bloom
 * Filter class by helping to choose correct values of 'bits per element' and
 * 'number of hash functions, k'. Author : Avinash Lakshman (
 * alakshman@facebook.com) & Prashant Malik ( pmalik@facebook.com )
 */

class BloomParameterEstimation {


  static final int maxBuckets = 15;
  static final int minBuckets = 2;
  static final int minK = 1;
  static final int maxK = 8;

  /**
   * In the following table, the row 'i' shows false positive rates if i buckets
   * per element are used. Column 'j' shows false positive rates if j hash
   * functions are used. The first row is 'i=0', the first column is 'j=0'. Each
   * cell (i,j) the false positive rate determined by using i buckets per
   * element and j hash functions.
   */
  static final List<List<double>> probs  = [
    [ 1.0 ], // dummy row representing 0 buckets per element
    [ 1.0, 1.0 ], // dummy row representing 1 buckets per element
    [ 1.0, 0.393, 0.400 ],
    [ 1.0, 0.283, 0.237, 0.253 ],
    [ 1.0, 0.221, 0.155, 0.147, 0.160 ],
    [ 1.0, 0.181, 0.109, 0.092, 0.092, 0.101 ], // 5
    [ 1.0, 0.154, 0.0804, 0.0609, 0.0561, 0.0578, 0.0638 ],
    [ 1.0, 0.133, 0.0618, 0.0423, 0.0359, 0.0347, 0.0364 ],
    [ 1.0, 0.118, 0.0489, 0.0306, 0.024, 0.0217, 0.0216, 0.0229 ],
    [ 1.0, 0.105, 0.0397, 0.0228, 0.0166, 0.0141, 0.0133, 0.0135, 0.0145 ], // 9
    [ 1.0, 0.0952, 0.0329, 0.0174, 0.0118, 0.00943, 0.00844, 0.00819, 0.00846 ],
    [ 1.0, 0.0869, 0.0276, 0.0136, 0.00864, 0.0065, 0.00552, 0.00513, 0.00509 ],
    [ 1.0, 0.08, 0.0236, 0.0108, 0.00646, 0.00459, 0.00371, 0.00329, 0.00314 ],
    [ 1.0, 0.074, 0.0203, 0.00875, 0.00492, 0.00332, 0.00255, 0.00217, 0.00199 ],
    [ 1.0, 0.0689, 0.0177, 0.00718, 0.00381, 0.00244, 0.00179, 0.00146, 0.00129 ],
    [ 1.0, 0.0645, 0.0156, 0.00596, 0.003, 0.00183, 0.00128, 0.001, 0.000852 ] // 15
    ];   // the first column is a dummy column representing K=0.

  /**
   * Given the number of buckets that can be used per element, return the
   * optimal number of hash functions in order to minimize the false positive
   * rate.
   */
  static final List<int> optKPerBuckets = const [
    1, // dummy K for 0 buckets per element
    1, // dummy K for 1 buckets per element
    1, 2, 3, 3, 4, 5, 5, 6, 7, 8, 8, 8, 8, 8 ];

  static int computeBestK(int bucketsPerElement) {
    if (bucketsPerElement >= optKPerBuckets.length) {
      return optKPerBuckets[optKPerBuckets.length - 1];
    }
    return optKPerBuckets[bucketsPerElement];
  }

  /**
   * Given a maximum tolerable false positive probability, compute a Bloom
   * specification which will give less than the specified false positive rate,
   * but minimize the number of buckets per element and the number of hash
   * functions used. Because bandwidth (and therefore total bitvector size) is
   * considered more expensive than computing power, preference is given to
   * minimizing buckets per element rather than number of hash funtions.
   */
  static _BloomParameters fromMaxFalsePosProb(double maxFalsePosProb) {
    // Handle the trivial cases
    if (maxFalsePosProb >= probs[minBuckets][minK]) {
      return new _BloomParameters(2, optKPerBuckets[2]);
    }
    if (maxFalsePosProb < probs[maxBuckets][maxK]) {
      return new _BloomParameters(maxK, maxBuckets);
    }

    // First find the minimal required number of buckets:
    int bucketsPerElement = 2;
    int K = optKPerBuckets[2];
    while (probs[bucketsPerElement][K] > maxFalsePosProb) {
      bucketsPerElement++;
      K = optKPerBuckets[bucketsPerElement];
    }
    // Now that the number of buckets is sufficient, see if we can relax K
    // without losing too much precision.
    while (probs[bucketsPerElement][K - 1] <= maxFalsePosProb) {
      K--;
    }
    return new _BloomParameters(K, bucketsPerElement);
  }

}



