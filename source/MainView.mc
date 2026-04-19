import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MainView extends WatchUi.View {

  function initialize() {
    View.initialize();
  }

  function onShow() as Void {
    WatchUi.requestUpdate();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var w = dc.getWidth();
    var h = dc.getHeight();
    var cx = w / 2;
    var cy = h / 2 - 10;

    if (UiState.loading) {
      drawLoading(dc, cx, cy);
      dc.drawText(
        cx,
        h - 40,
        Graphics.FONT_SMALL,
        L10n.t(Rez.Strings.LoadingLabel),
        Graphics.TEXT_JUSTIFY_CENTER
      );
      return;
    }

    if (UiState.error != null) {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        cx,
        cy,
        Graphics.FONT_SMALL,
        UiState.error,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
      return;
    }

    var iy = cy - 30;
    if (UiState.lockGlyph == UiState.LOCK_GLYPH_UNKNOWN) {
      drawUnknownGlyph(dc, cx, iy);
    } else {
      drawLock(dc, cx, iy, UiState.lockGlyph == UiState.LOCK_GLYPH_OPEN);
    }
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      cx,
      cy + 40,
      Graphics.FONT_SMALL,
      UiState.statusLine,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawLoading(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    var t = System.getTimer();
    var sweep = 60;
    var start = (t / 20) % 360;
    dc.drawArc(cx, cy, 28, Graphics.ARC_COUNTER_CLOCKWISE, start, start + sweep);
    dc.drawArc(cx, cy, 22, Graphics.ARC_COUNTER_CLOCKWISE, start + 180, start + 180 + sweep);
  }

  function drawUnknownGlyph(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      cx,
      cy,
      Graphics.FONT_MEDIUM,
      "?",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  // Material-inspired lock: rounded body + semicircular shackle (0° = 3 o'clock, 90° = top).
  function drawLock(dc as Graphics.Dc, cx as Number, cy as Number, open as Boolean) as Void {
    var bodyW = 22;
    var bodyH = 15;
    var bodyX = cx - bodyW / 2;
    var bodyY = cy + 4;
    var cornerR = 3;
    var shackleR = 11;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);
    dc.fillRoundedRectangle(bodyX, bodyY, bodyW, bodyH, cornerR);

    dc.setPenWidth(3);
    if (!open) {
      dc.drawArc(cx, bodyY, shackleR, Graphics.ARC_COUNTER_CLOCKWISE, 0, 180);
    } else {
      // Open shackle: partial top arc (gap on upper-left) + line to body corner, like lock_open.
      dc.drawArc(cx, bodyY, shackleR, Graphics.ARC_COUNTER_CLOCKWISE, 0, 125);
      dc.drawLine(cx - 8, cy - 2, bodyX + 2, bodyY + 4);
    }
    dc.setPenWidth(1);
  }
}
