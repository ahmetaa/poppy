class Bits {
  /**
   * Returns the number of bits set for 32 bit integer [x].
   * Algorithm taken from:
   * http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel
   * I also tried lookup technique, it seems this is beating the 8 bit lookup
   * table. 16 bit lookup would be faster, but certainly an overkill.
   */
  static int popCount32(int x) {
    x = x - ((x >> 1) & 0x55555555);
    x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
    return (((x + (x >> 4) & 0xF0F0F0F) * 0x1010101) >> 24) & 0xff;
  }

  // 64 bit version of popCount32
  static int popCount64(int x) =>
      popCount32(x & 0xffffffff) + popCount32(x >> 32 & 0xffffffff);

  /**
   * Returns the rank of a bit for [x]; Number of 1 bits from most significant
   * bit down to the bit at position [n]. For example rank of 0xf00000ff for
   * n = 10 is 4
   */
  static int bitRank32(int x, int n) =>  popCount32(x >> (32 - n));

  static int bitRank64(int x, int n) =>
      n > 32 ? popCount64(x >> (64 - n)) : popCount32(x >> (64 - n));
}
