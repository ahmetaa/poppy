library poppy;

// A fast RFC 2045 compliant base64 decoder with URL safe option.
// Performance is ~40MB/s for both encoding and decoding.
// Code is based on Mig Base64 (BSD licensed) with modifications.
// Mig Base64 project: http://migbase64.sourceforge.net/
class Base64 {

static final List<int> alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".codeUnits;
static final List<int> alphabetUrlSafe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".codeUnits;
static final List<int> decodeTable = new List<int>.filled(256, -1);

final int PAD = 61; // '='
final int CR = '\r'.codeUnitAt(0);
final int LF = '\n'.codeUnitAt(0);

bool _addLineSeparator;
bool _urlSafe;

  Base64({bool urlSafe : false, bool addLineSeparator : true}) 
      : _urlSafe = urlSafe, _addLineSeparator = addLineSeparator {
    // Build DECODE table.
    for (int i = 0; i < alphabet.length; i++) {
      decodeTable[alphabet[i]] = i;
      decodeTable[alphabetUrlSafe[i]] = i;
    }
    decodeTable[PAD] = 0;
  }

  String encode(List<int> input) {
    return new String.fromCharCodes(encodeToList(input));
  }
  
  List<int> encodeToList(List<int> input) {
    int len = input != null ? input.length : 0;
    if (len == 0) {
      return new List<int>.fixedLength(0);
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
      // Add optional line separator
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
  
  List<int> decodeToList(List<int> input) {
    int len = input != null ? input.length : 0;
    if (len == 0) {
      return new List<int>.fixedLength(0);
    }
    int extrasLen = 0;
    for (int i = 0; i < len; i++)
      if (decodeTable[input[i]] < 0) {
        extrasLen++;
      }
    if ((len - extrasLen) % 4 != 0) {
      return null;
    }
    int pad = 0;
    for (int i = len; i > 1 && decodeTable[input[--i]] <= 0;) {
      if (input[i] == PAD) {
        pad++;
      }
    }
    int oLen = ((len - extrasLen) * 6 >> 3) - pad;
    List<int> out = new List<int>(oLen);
    for (int i = 0, d = 0; d < oLen;) {
      int x = 0;
      int j = 18;
      // Accumulate 4 valid 6 bit base64 chars into an int.
      while (j >= 0) {
        int c = decodeTable[input[i++]];
        if (c >= 0) {
          x |= c << j; 
          j -= 6;
        }
      }
      out[d++] = (x >> 16);
      if (d < oLen) {
        out[d++]= (x >> 8) & 0xFF;
        if (d < oLen)
          out[d++] = x & 0xFF;
      }
    }
    return out;   
  }
  
  String decode(String input) {
    return new String.fromCharCodes(decodeToList(input.codeUnits));
  }
}
