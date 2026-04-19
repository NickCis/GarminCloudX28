import Toybox.Cryptography;
import Toybox.Lang;
import Toybox.StringUtil;

module PasswordUtil {
  function encodeLoginPassword(raw as String) as String {
    if (raw == null || raw.length() == 0) {
      return "";
    }
    var utf8 = StringUtil.convertEncodedString(raw, {
      :fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
      :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
      :encoding => StringUtil.CHAR_ENCODING_UTF8
    });
    if (!(utf8 instanceof Lang.ByteArray)) {
      return "";
    }
    var hash = new Cryptography.Hash({ :algorithm => Cryptography.HASH_MD5 });
    hash.update(utf8 as Lang.ByteArray);
    var digest = hash.digest();
    var b64 = StringUtil.convertEncodedString(digest, {
      :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
      :toRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
      :encoding => StringUtil.CHAR_ENCODING_UTF8
    }) as String;
    return stripTrailingEquals(b64);
  }

  function stripTrailingEquals(s as String) as String {
    if (s == null || s.length() == 0) {
      return "";
    }
    var n = s.length();
    while (n > 0) {
      var ch = s.substring(n - 1, n);
      if (!ch.equals("=")) {
        break;
      }
      n--;
    }
    return s.substring(0, n);
  }
}
