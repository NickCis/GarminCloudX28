import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class CloudX28App extends Application.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  function onSettingsChanged() as Void {
    WatchUi.requestUpdate();
    try {
      var cur = WatchUi.getCurrentView();
      if (cur != null && cur instanceof Lang.Array) {
        var arr = cur as Lang.Array;
        if (arr.size() > 0) {
          var v = arr[0];
          if (v instanceof ConfigureView && Credentials.hasAll()) {
            WatchUi.switchToView(new MainView(), new MainDelegate(), WatchUi.SLIDE_LEFT);
          }
        }
      }
    } catch (ex) {
    }
  }

  function getInitialView() {
    if (!Credentials.hasAll()) {
      return [ new ConfigureView(), new ConfigureDelegate() ];
    }
    return [ new MainView(), new MainDelegate() ];
  }
}
