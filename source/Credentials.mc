import Toybox.Application.Properties;
import Toybox.Lang;

module Credentials {
  function hasAll() as Boolean {
    return nonempty(mail()) && nonempty(password()) && nonempty(pin());
  }

  function mail() as String {
    return getStringProp("mail");
  }

  function password() as String {
    return getStringProp("password");
  }

  function pin() as String {
    return getStringProp("pin");
  }

  function nonempty(s as String) as Boolean {
    return s != null && s.length() > 0;
  }

  function getStringProp(key as String) as String {
    var v = Properties.getValue(key);
    if (v instanceof String) {
      return v as String;
    }
    return v.toString();
  }
}
