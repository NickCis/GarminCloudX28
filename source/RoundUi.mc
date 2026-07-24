import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module RoundUi {
  const MENU_HINT_X = 10;

  function drawMenuHint(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    var cy = dc.getHeight() / 2;
    var x = MENU_HINT_X;
    dc.fillCircle(x, cy - 7, 2);
    dc.fillCircle(x, cy, 2);
    dc.fillCircle(x, cy + 7, 2);
  }

  function centerX(dc as Graphics.Dc) as Number {
    return dc.getWidth() / 2;
  }

  function centerY(dc as Graphics.Dc) as Number {
    return dc.getHeight() / 2;
  }
}
