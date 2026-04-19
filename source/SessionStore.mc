import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;

module SessionStore {
  const KEY_TOKEN = "x28_token";
  const KEY_APP_ID = "x28_appId";
  const KEY_EXP = "x28_expUnix";
  const KEY_PARTITION = "x28_partitionId";

  function clearSession() as Void {
    safeDel(KEY_TOKEN);
    safeDel(KEY_APP_ID);
    safeDel(KEY_EXP);
    safeDel(KEY_PARTITION);
  }

  function safeDel(key as String) as Void {
    try {
      Storage.deleteValue(key);
    } catch (e) {
    }
  }

  function saveSession(token as String, appId as String, tokenExpiresIn as Number) as Void {
    var secs = tokenExpiresIn;
    if (secs == null || secs <= 0) {
      secs = 86400;
    }
    var exp = Time.now().add(new Time.Duration(secs));
    Storage.setValue(KEY_TOKEN, token);
    Storage.setValue(KEY_APP_ID, appId);
    Storage.setValue(KEY_EXP, exp.value());
  }

  function isTokenValid() as Boolean {
    try {
      var tok = Storage.getValue(KEY_TOKEN);
      var exp = Storage.getValue(KEY_EXP);
      if (tok == null || !(tok instanceof String) || (tok as String).length() == 0) {
        return false;
      }
      if (exp == null || !(exp instanceof Number)) {
        return false;
      }
      return Time.now().value() < (exp as Number);
    } catch (ex) {
      return false;
    }
  }

  function getToken() as String or Null {
    try {
      var tok = Storage.getValue(KEY_TOKEN);
      if (tok != null && tok instanceof String) {
        return tok as String;
      }
    } catch (ex) {
    }
    return null;
  }

  function getAppId() as String or Null {
    try {
      var v = Storage.getValue(KEY_APP_ID);
      if (v == null) {
        return null;
      }
      if (v instanceof String) {
        return v as String;
      }
      return v.toString();
    } catch (ex) {
    }
    return null;
  }

  function setPartitionId(id as String) as Void {
    Storage.setValue(KEY_PARTITION, id);
  }

  function getPartitionId() as String or Null {
    try {
      var v = Storage.getValue(KEY_PARTITION);
      if (v == null) {
        return null;
      }
      if (v instanceof String) {
        return v as String;
      }
      return v.toString();
    } catch (ex) {
    }
    return null;
  }
}
