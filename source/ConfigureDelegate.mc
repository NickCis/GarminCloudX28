import Toybox.Lang;
import Toybox.WatchUi;

class ConfigureDelegate extends WatchUi.InputDelegate {

  function initialize() {
    InputDelegate.initialize();
  }

  function onKey(keyEvent as KeyEvent) as Boolean {
    if (keyEvent.getKey() == WatchUi.KEY_START) {
      if (Credentials.hasAll()) {
        WatchUi.switchToView(new MainView(), new MainDelegate(), WatchUi.SLIDE_LEFT);
        return true;
      }
    }
    return false;
  }
}
