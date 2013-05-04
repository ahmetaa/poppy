library poppy;

import 'dart:io';

// A fast RFC 2045 compliant base64 decoder with URL safe option.
// Performance is close to Java version. 
// Encode to String: ~40MB/s
// Encode to List<int>: ~80MB/s
// Decode from String: ~60MB/s
// Code is based on Mig Base64 with modifications and minor improvements.
// Mig Base64 project: http://migbase64.sourceforge.net/
class Base64 {

static final List<int> alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".codeUnits;
static final List<int> alphabetUrlSafe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".codeUnits;
static const List<int> decodeTable = const [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, 62, -1, 62, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, 0,
    -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
    23, 24, 25, -1, -1, -1, -1, 63, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];

final int PAD = 61; // '='
final int CR = '\r'.codeUnitAt(0);
final int LF = '\n'.codeUnitAt(0);

bool _addLineSeparator;
bool _urlSafe;

  Base64({bool urlSafe : false, bool addLineSeparator : true})
      : _urlSafe = urlSafe, _addLineSeparator = addLineSeparator;

  String encode(List<int> input) {
    return new String.fromCharCodes(encodeToList(input));
  }

  List<int> encodeToList(List<int> input) {
    int len = input != null ? input.length : 0;
    if (len == 0) {
      return new List<int>(0);
    }
    final List<int> lookup = _urlSafe ? alphabetUrlSafe : alphabet;
    // Size of 24 bit chunks
    final int cLen = len ~/ 3 * 3;
    final int padLen = len - cLen;
    // Size of base output
    int oLen = ((len ~/ 3) * 4) + (padLen > 0 ? 4 : 0);
    // Add extra for line separators.
    oLen += _addLineSeparator ? (oLen - 1) ~/ 76 << 1 : 0;
    List<int> out = new List<int>(oLen);
    // Encode the even 24 bit part.
    int j = 0, i = 0, cc = 0;
    while (i < cLen) {
      int x = input[i++] << 16 | input[i++] << 8 | input[i++];
      out[j++] = lookup[x >> 18];
      out[j++] = lookup[(x >> 12) & 0x3F];
      out[j++] = lookup[(x >> 6)  & 0x3F];
      out[j++] = lookup[x & 0x3f];
      // Add optional line separator for each 76 char output.
      if (_addLineSeparator && ++cc == 19 && j < oLen - 2) {
          out[j++] = CR;
          out[j++] = LF;
          cc = 0;
      }
    }
    // If input length if not divisible by 3, encode remaining and add padding.
    if (padLen > 0) {
      int x = input[cLen] << 10  | (padLen == 2 ? input[len - 1] << 2 : 0);
      out[j++] = lookup[(x >> 12) & 0x3F];
      out[j++] = lookup[(x >> 6) & 0x3F];
      out[j++] = padLen == 2 ? lookup[x & 0x3f] : PAD;
      out[j++] = PAD;
    }
    return out;
  }

  /**
   * Decoder ignores \r \n and all illegal chars.
   * Returns empty list if [input] is null.
   * Returns null if cleaned input size is not multiple of 4.
  */
  List<int> decode(String input) {
    int len = input != null ? input.length : 0;
    if (len == 0) {
      return new List<int>(0);
    }
    int extrasLen = 0;
    for (int i = 0; i < len; i++)
      if (decodeTable[input.codeUnitAt(i)] < 0) {
        extrasLen++;
      }
    if ((len - extrasLen) % 4 != 0) {
      return null;
    }
    int pad = 0;
    for (int i = len; i > 1 && decodeTable[input.codeUnitAt(--i)] <= 0;) {
      if (input.codeUnitAt(i) == PAD) {
        pad++;
      }
    }
    int oLen = ((len - extrasLen) * 6 >> 3) - pad;
    List<int> out = new List<int>(oLen);
    for (int i = 0, d = 0; d < oLen;) {
      int x = 0;
      int j = 18;
      // Accumulate 4 valid 6 bit base64 characters into an int.
      while (j >= 0) {
        int c = decodeTable[input.codeUnitAt(i++)];
        if (c >= 0) {
          x |= c << j;
          j -= 6;
        }
      }
      out[d++] = (x >> 16);
      if (d < oLen) {
        out[d++] = (x >> 8) & 0xFF;
        if (d < oLen)
          out[d++] = x & 0xFF;
      }
    }
    return out;
  }

  /**
   * If input has no \r \n and no illegal chars this is a faster decoder (2-3x faster).
   * Warning: Does not check if input has anything outside Base64 alphabet.
   * Returns empty list if [input] is null.
   * Returns null if input size is not multiple of 4.
  */
  List<int> decodeUnsafe(String input) {
    int len = input != null ? input.length : 0;
    // Basic validity check.
    if (len % 4 != 0) return null;
    if (len == 0) return new List<int>(0);
    // Find pad chars
    int pad = decodeTable[input.codeUnitAt(len - 1)] == 0 ? 1 : 0;
    pad += decodeTable[input.codeUnitAt(len - 2)] == 0 ? 1 : 0;
    int oLen = (len * 6 >> 3) - pad;
    List<int> out = new List<int>(oLen);
    for (int i = 0, d = 0; d < oLen;) {
      int x = decodeTable[input.codeUnitAt(i++)] << 18 |
              decodeTable[input.codeUnitAt(i++)] << 12 |
              decodeTable[input.codeUnitAt(i++)] << 6  |
              decodeTable[input.codeUnitAt(i++)];
      out[d++] = (x >> 16);
      if (d < oLen) {
        out[d++] = (x >> 8) & 0xFF;
        if (d < oLen)
          out[d++] = x & 0xFF;
      }
    }
    return out;
  }  
  
  List<int> decodeToList(List<int> input) {
    return decode(new String.fromCharCodes(input));
  }

}
