import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;

module Credentials {
  const KEY_MAIL = "cfg_mail";
  const KEY_PASSWORD = "cfg_password";
  const KEY_PIN = "cfg_pin";

  function hasAll() as Boolean {
    return nonempty(mail()) && nonempty(password()) && nonempty(pin());
  }

  function mail() as String {
    return readValue(KEY_MAIL, "mail");
  }

  function password() as String {
    return readValue(KEY_PASSWORD, "password");
  }

  function pin() as String {
    return readValue(KEY_PIN, "pin");
  }

  function saveMail(value as String) as Void {
    Storage.setValue(KEY_MAIL, value);
  }

  function savePassword(value as String) as Void {
    Storage.setValue(KEY_PASSWORD, value);
  }

  function savePin(value as String) as Void {
    Storage.setValue(KEY_PIN, value);
  }

  function clearStored() as Void {
    safeDel(KEY_MAIL);
    safeDel(KEY_PASSWORD);
    safeDel(KEY_PIN);
  }

  function readValue(storageKey as String, propKey as String) as String {
    try {
      var stored = Storage.getValue(storageKey);
      if (stored != null && stored instanceof String) {
        var ss = stored as String;
        if (ss.length() > 0) {
          return ss;
        }
      }
    } catch (ex) {
    }
    return getStringProp(propKey);
  }

  function nonempty(s as String) as Boolean {
    return s != null && s.length() > 0;
  }

  (:typecheck(false))
  function getStringProp(key as String) as String {
    try {
      var v = Properties.getValue(key);
      if (v == null) {
        return "";
      }
      if (v instanceof String) {
        return v as String;
      }
      return v.toString();
    } catch (e) {
      return "";
    }
  }

  function safeDel(key as String) as Void {
    try {
      Storage.deleteValue(key);
    } catch (e) {
    }
  }
}
