import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MainView extends WatchUi.View {

  var _loadingAnim as LoadingAnimationController or Null = null;
  var _wasLoading as Boolean = false;

  function initialize() {
    View.initialize();
  }

  function onShow() as Void {
    WatchUi.requestUpdate();
  }

  function onHide() as Void {
    stopLoadingAnimation();
  }

  function stopLoadingAnimation() as Void {
    if (_loadingAnim != null) {
      (_loadingAnim as LoadingAnimationController).stop(self);
      _loadingAnim = null;
    }
    _wasLoading = false;
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var w = dc.getWidth();
    var h = dc.getHeight();
    var cx = w / 2;
    var cy = h / 2 - 10;

    if (UiState.loading) {
      if (!_wasLoading) {
        stopLoadingAnimation();
      }
      _wasLoading = true;
      if (_loadingAnim == null) {
        _loadingAnim = new LoadingAnimationController();
      }
      (_loadingAnim as LoadingAnimationController).ensure(self, dc);
      return;
    }

    if (_wasLoading) {
      stopLoadingAnimation();
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
      if (UiState.errorCode != 0) {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
          cx,
          cy + 30,
          Graphics.FONT_XTINY,
          "(" + UiState.errorCode.toString() + ")",
          Graphics.TEXT_JUSTIFY_CENTER
        );
      }
      RoundUi.drawMenuHint(dc);
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
    RoundUi.drawMenuHint(dc);
    drawSelectHint(dc);
  }

  function drawSelectHint(dc as Graphics.Dc) as Void {
    var w = dc.getWidth();
    var h = dc.getHeight();
    var cx = w / 2;
    var cy = h / 2;
    var r = w / 2 - 4;
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(3);
    dc.drawArc(cx, cy, r, Graphics.ARC_COUNTER_CLOCKWISE, 21, 39);
    dc.setPenWidth(1);
  }

  function drawUnknownGlyph(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      cx,
      cy,
      Graphics.FONT_LARGE,
      "?",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawLock(dc as Graphics.Dc, cx as Number, cy as Number, open as Boolean) as Void {
    var scale = 1.8;
    var bodyW = (16 * scale).toNumber();
    var bodyH = (12 * scale).toNumber();
    var bodyX = cx - bodyW / 2;
    var bodyY = cy;
    var cornerR = (3 * scale).toNumber();
    var shackleOuter = (7 * scale).toNumber();
    var shackleInner = (4 * scale).toNumber();
    var shackleTop = bodyY - (8 * scale).toNumber();

    if (open) {
      dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    }

    dc.fillRoundedRectangle(bodyX, bodyY, bodyW, bodyH, cornerR);

    if (!open) {
      var shackleCx = cx;
      var shackleBaseY = bodyY + 2;
      dc.fillRectangle(shackleCx - shackleOuter, shackleTop, shackleOuter - shackleInner, shackleBaseY - shackleTop);
      dc.fillRectangle(shackleCx + shackleInner, shackleTop, shackleOuter - shackleInner, shackleBaseY - shackleTop);
      dc.fillEllipse(shackleCx, shackleTop, shackleOuter, shackleOuter);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      dc.fillEllipse(shackleCx, shackleTop, shackleInner, shackleInner);
      dc.fillRectangle(shackleCx - shackleInner, shackleTop, shackleInner * 2, shackleBaseY - shackleTop - 2);
    } else {
      var shackleCx = cx - (2 * scale).toNumber();
      var shackleBaseY = bodyY + 2;
      var offsetY = -(4 * scale).toNumber();
      dc.fillRectangle(shackleCx - shackleOuter, shackleTop + offsetY, shackleOuter - shackleInner, shackleBaseY - shackleTop - offsetY);
      dc.fillEllipse(shackleCx, shackleTop + offsetY, shackleOuter, shackleOuter);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      dc.fillEllipse(shackleCx, shackleTop + offsetY, shackleInner, shackleInner);
      dc.fillRectangle(shackleCx - shackleInner, shackleTop + offsetY, shackleInner * 2 + shackleOuter, shackleBaseY - shackleTop);
    }

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    var keyholeY = bodyY + bodyH / 2 - 1;
    var keyholeR = (2 * scale).toNumber();
    dc.fillCircle(cx, keyholeY, keyholeR);
    dc.fillRectangle(cx - keyholeR / 2, keyholeY, keyholeR, (4 * scale).toNumber());
  }
}
