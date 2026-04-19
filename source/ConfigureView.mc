import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ConfigureView extends WatchUi.View {

  function initialize() {
    View.initialize();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var w = dc.getWidth();
    var h = dc.getHeight();
    var msg = "Por favor configura\nla cuenta en el\ncelular (Garmin\nConnect)";
    dc.drawText(
      w / 2,
      h / 2,
      Graphics.FONT_SMALL,
      msg,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}
