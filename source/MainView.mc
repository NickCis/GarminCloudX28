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
        "Cargando...",
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

  function drawLock(dc as Graphics.Dc, cx as Number, cy as Number, open as Boolean) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var bodyW = 28;
    var bodyH = 22;
    var x0 = cx - bodyW / 2;
    var y0 = cy - bodyH / 2 + 8;
    dc.fillRoundedRectangle(x0, y0, bodyW, bodyH, 4);
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(x0 + 6, y0 + 6, bodyW - 12, bodyH - 10);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    if (!open) {
      dc.drawArc(cx, cy - 4, 14, Graphics.ARC_COUNTER_CLOCKWISE, 180, 360);
    } else {
      dc.drawArc(cx - 6, cy - 4, 14, Graphics.ARC_COUNTER_CLOCKWISE, 200, 360);
    }
  }
}
