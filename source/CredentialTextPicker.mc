import Toybox.Lang;
import Toybox.WatchUi;

module CredentialFields {
  const MAIL = 0;
  const PASSWORD = 1;
  const PIN = 2;

  function initialValue(field as Number) as String {
    if (field == MAIL) {
      return Credentials.mail();
    }
    if (field == PASSWORD) {
      return Credentials.password();
    }
    return Credentials.pin();
  }

  function save(field as Number, value as String) as Void {
    if (field == MAIL) {
      Credentials.saveMail(value);
    } else if (field == PASSWORD) {
      Credentials.savePassword(value);
    } else {
      Credentials.savePin(value);
    }
    SessionStore.clearSession();
  }

  function openPicker(field as Number) as Void {
    WatchUi.pushView(
      new WatchUi.TextPicker(initialValue(field)),
      new CredentialTextPickerDelegate(field),
      WatchUi.SLIDE_LEFT
    );
  }
}

class CredentialTextPickerDelegate extends WatchUi.TextPickerDelegate {

  var _field as Number;

  function initialize(field as Number) {
    TextPickerDelegate.initialize();
    _field = field;
  }

  function onTextEntered(text as String, changed as Boolean) as Boolean {
    CredentialFields.save(_field, text);
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    WatchUi.requestUpdate();
    return true;
  }

  function onCancel() as Boolean {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    return true;
  }
}
