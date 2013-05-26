import 'dart:math';
import 'dart:typed_data';
import 'dart:collection';
import '../mphf.dart';
import 'bit_vector.dart';

class HashIndexes {
  int keyAmount;
  int bucketAmount;
  Uint8List bucketHashSeedValues;
  List<int> failedIndexes;
  HashIndexes(this.keyAmount, this.bucketAmount, this.bucketHashSeedValues, this.failedIndexes);
  int getSeed(int fingerPrint) => bucketHashSeedValues[fingerPrint % bucketAmount];
}

class BucketCalculator {

  KeyProvider keyProvider;
  int keyAmount;
  double averageKeysPerBucket;
  static final int HASH_SEED_LIMIT = 255;

  BucketCalculator(this.keyProvider){
    averageKeysPerBucket = 3.0; // average 3 keys per bucket gives good "bit per key" value.
  }

  List<HashIndexes> calculate() {
    keyAmount = keyProvider.keyAmount();

    int bucketAmount=(keyAmount / averageKeysPerBucket).toInt() + 1;

    var buckets = generateInitialBuckets(bucketAmount);

    // sort buckets larger to smaller.
    buckets.sort();

    var result = new List<HashIndexes>();

    calculateIndexes(buckets, keyAmount, result);

    return result;
  }

  List<_Bucket> generateInitialBuckets(int bucketAmount) {

    // Generating buckets
    var buckets = new List<_Bucket>(bucketAmount);
    for (int i = 0; i < buckets.length; i++) {
      buckets[i] = new _Bucket(i);
    }

    // add keys to buckets.
    for (int i = 0; i < keyAmount; i++) {
      int bucketIndex = initialHash(keyProvider.getKey(i)) % bucketAmount;
      buckets[bucketIndex].add(i);
    }

    return buckets;
  }

  void calculateIndexes(List<_Bucket> buckets, int keyAmount, List<HashIndexes> indexes) {

    // generate a long bit vector with size of hash target size.
    FixedBitVector bitVector = new FixedBitVector.bitCount(keyAmount);

    var hashSeedArray = new Uint8List(buckets.length);
    for(int k = 0; k<hashSeedArray.length;++k) {
      hashSeedArray[k]=1;
    }

    // we need to collect failed buckets (A failed bucket such that we cannot find empty slots for all bucket keys
    // after 255 trials. )
    var failedBuckets = new List<_Bucket>();

    // for each bucket, find a hash function that will map each key in it to an empty slot in bitVector.
    for (_Bucket bucket in buckets) {
      if (bucket.itemIndexes.length == 0) { // because buckets are sorted, we can finish here.
        break;
      }
      int hashSeedIndex = 1;
      bool loop = true;
      while (loop) {
        var slots = new List<int>();
        for (int keyIndex in bucket.itemIndexes) {
          var key = keyProvider.getKey(keyIndex);
          int bitIndex = hash(key, hashSeedIndex) % keyAmount;
          if (bitVector.getBit(bitIndex)) {
            break;
          } else {
            slots.add(bitIndex);
            bitVector.setBit(bitIndex);
          }
        }
        // if we fail to place all items in the bucket to the bitvector"s empty slots
        if (slots.length < bucket.itemIndexes.length) {
          // we reset the occupied slots from bitvector.
          for (int bitIndex in slots) {
            bitVector.clear(bitIndex);
          }
          // We reached the HASH_SEED_LIMIT.
          // We place a 0 for its hash index value to know later that bucket is left to secondary lookup.
          if (hashSeedIndex == HASH_SEED_LIMIT) {
            failedBuckets.add(bucket);
            hashSeedArray[bucket.id] = 0;
            loop = false;
          }

        } else { // sweet. We have found empty slots in bit vector for all keys of the bucket.
          hashSeedArray[bucket.id] = hashSeedIndex;
          loop = false;
        }
        hashSeedIndex++;
      }
    }

    if (failedBuckets.length == 0) {
      // we are done.
      indexes.add(new HashIndexes(keyAmount, buckets.length, hashSeedArray, new List(0)));
      return;
    }

    // we assign lower average per key per bucket after each iteration to avoid generation failure.
    if (averageKeysPerBucket > 1) {
      averageKeysPerBucket--;
    }

    // start calculation for failed buckets.
    int failedKeyCount = 0;
    for (_Bucket failedBucket in failedBuckets) {
      failedKeyCount += failedBucket.itemIndexes.length;
    }

    int failedBucketAmount = (failedKeyCount / averageKeysPerBucket).toInt() +1;

    // this is a worst case scenario. No empty slot find for any buckets and we are already using buckets where bucket Amount>=keyAmount
    // In this case we double the bucket size with the hope that it will have better bucket-key distribution.
    if (failedKeyCount == keyAmount && averageKeysPerBucket <= 1) {
      averageKeysPerBucket = averageKeysPerBucket / 2;
      failedBucketAmount *= 2;
    }

    if (failedBucketAmount == 0) {
      failedBucketAmount++;
    }

    // this time we generate item keyAmount of Buckets
    var nextLevelBuckets = new List<_Bucket>(failedBucketAmount);
    for (int i = 0; i < failedBucketAmount; i++) {
      nextLevelBuckets[i] = new _Bucket(i);
    }

    // generate secondary buckets with item indexes.
    for (_Bucket largeHashIndexBucket in failedBuckets) {
      for (int itemIndex in largeHashIndexBucket.itemIndexes) {
        int secondaryBucketIndex = initialHash(keyProvider.getKey(itemIndex)) % failedBucketAmount;
        nextLevelBuckets[secondaryBucketIndex].add(itemIndex);
      }
    }

    // sort buckets larger to smaller.
    nextLevelBuckets.sort();

    int currentLevel = indexes.length;
    var failedHashValues = new List<int>();
    
    for (int i = 0; i < bitVector.size; i++) {
      if (!bitVector.getBit(i)) {
        failedHashValues.add(currentLevel==0 ? i : indexes[currentLevel - 1].failedIndexes[i]);
      }
    }

    indexes.add(new HashIndexes(keyAmount, buckets.length, hashSeedArray, failedHashValues));

    // recurse for failed buckets.
    calculateIndexes(nextLevelBuckets, failedKeyCount, indexes);
  }
}

/** A bucket that holds keys. It contains a small array for keys. */
class _Bucket implements Comparable {
    int id;
    var itemIndexes = new List<int>();
    _Bucket(this.id);
    void add(int i) { itemIndexes.add(i); }
    int compareTo(_Bucket o) => o.itemIndexes.length.compareTo(itemIndexes.length);
}
