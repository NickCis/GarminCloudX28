import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;

// HTTP trace via System.println — appears in the Connect IQ Simulator / VS Code
// "Monkey C" output when debugging. Set ENABLED false to silence in release builds.
module HttpDebug {
  const ENABLED = true;

  // When true, sensitive fields and Bearer headers are masked. The login JSON field
  // named "password" is the MD5+Base64 transform (not Garmin Connect plaintext), so
  // it is logged when REDACT_SECRETS is true so you can verify encoding.
  const REDACT_SECRETS = true;

  // Value already produced by PasswordUtil.encodeLoginPassword (not Connect plaintext).
  function logLoginEncodedPassword(enc as String) as Void {
    if (!ENABLED) {
      return;
    }
    System.println("[HTTP]     loginPasswordTransformed(MD5+Base64, '=' trimmed)=" + enc);
  }

  function logRequest(url as String, body as Lang.Dictionary or Null, opts as Lang.Dictionary or Null) as Void {
    if (!ENABLED) {
      return;
    }
    System.println("[HTTP] >>> " + url);
    if (opts != null) {
      var m = opts.get(:method);
      if (m != null) {
        System.println("[HTTP]     method: " + m.toString());
      }
      var hdrs = opts.get(:headers);
      if (hdrs != null && hdrs instanceof Lang.Dictionary) {
        System.println("[HTTP]     headers: " + formatHeadersForLog(hdrs as Lang.Dictionary));
      }
      var rt = opts.get(:responseType);
      if (rt != null) {
        System.println("[HTTP]     responseType: " + rt.toString());
      }
    }
    if (body == null) {
      System.println("[HTTP]     body: null");
    } else {
      System.println("[HTTP]     body: " + formatDictForLog(body));
    }
  }

  function communicationsErrorLabel(code as Number) as String {
    if (code == Communications.INVALID_HTTP_HEADER_FIELDS_IN_REQUEST) {
      return "INVALID_HTTP_HEADER_FIELDS_IN_REQUEST (use Communications.REQUEST_CONTENT_TYPE_* for Content-Type)";
    }
    if (code == Communications.INVALID_HTTP_BODY_IN_REQUEST) {
      return "INVALID_HTTP_BODY_IN_REQUEST";
    }
    if (code == Communications.INVALID_HTTP_METHOD_IN_REQUEST) {
      return "INVALID_HTTP_METHOD_IN_REQUEST";
    }
    if (code == Communications.NETWORK_REQUEST_TIMED_OUT) {
      return "NETWORK_REQUEST_TIMED_OUT";
    }
    if (code == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
      return "INVALID_HTTP_BODY_IN_NETWORK_RESPONSE";
    }
    if (code == Communications.INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE) {
      return "INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE";
    }
    if (code == Communications.NETWORK_RESPONSE_TOO_LARGE) {
      return "NETWORK_RESPONSE_TOO_LARGE";
    }
    return "Communications error " + code.toString();
  }

  (:typecheck(false))
  function logResponse(url as String, code as Number, data) as Void {
    if (!ENABLED) {
      return;
    }
    System.println("[HTTP] <<< " + url + " responseCode=" + code.toString());
    if (code < 0) {
      System.println("[HTTP]     " + communicationsErrorLabel(code));
    }
    if (data == null) {
      System.println("[HTTP]     body: null");
      return;
    }
    var s = responseBodyToString(data);
    System.println("[HTTP]     body: " + s);
  }

  (:typecheck(false))
  function responseBodyToString(data) as String {
    if (data == null) {
      return "null";
    }
    var s = data.toString();
    var maxLen = 1200;
    if (s.length() > maxLen) {
      return s.substring(0, maxLen) + "...<truncated>";
    }
    return s;
  }

  function formatDictForLog(d as Lang.Dictionary) as String {
    var keys = d.keys();
    var out = "{";
    for (var i = 0; i < keys.size(); i++) {
      if (i > 0) {
        out += ",";
      }
      var k = keys[i];
      var keyStr = k != null ? k.toString() : "?";
      var v = d.get(k);
      out += keyStr + "=" + valueChunkForLog(keyStr, v);
    }
    out += "}";
    return out;
  }

  function formatHeadersForLog(h as Lang.Dictionary) as String {
    var keys = h.keys();
    var out = "{";
    for (var i = 0; i < keys.size(); i++) {
      if (i > 0) {
        out += ",";
      }
      var k = keys[i];
      var keyStr = k != null ? k.toString() : "?";
      if (REDACT_SECRETS && keyStr.equals("Authorization")) {
        out += keyStr + "=Bearer ***";
      } else {
        var v = h.get(k);
        out += keyStr + "=" + (v != null ? v.toString() : "null");
      }
    }
    out += "}";
    return out;
  }

  function sensitiveFieldKey(keyStr as String) as Boolean {
    if (!REDACT_SECRETS) {
      return false;
    }
    if (keyStr.equals("code")) {
      return true;
    }
    if (keyStr.equals("pin")) {
      return true;
    }
    if (keyStr.equals("token")) {
      return true;
    }
    if (keyStr.equals("accessToken")) {
      return true;
    }
    return false;
  }

  function valueChunkForLog(keyStr as String, v as Lang.Object or Null) as String {
    if (sensitiveFieldKey(keyStr)) {
      return "***";
    }
    if (v == null) {
      return "null";
    }
    return v.toString();
  }
}
