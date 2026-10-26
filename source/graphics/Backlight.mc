import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

class Backlight {
    private var _bright as BitmapSlot;
    private var _dim as BitmapSlot;
    private var _dimGray as Number = -1;

    public function initialize() {
        _bright = new BitmapSlot();
        _dim = new BitmapSlot();
    }

    // Full bright range, taller than the screen so a flicker shift has room.
    public function render(w as Number, h as Number, nowMin as Number) as Void {
        var bmpH = h + BG_BACKLIGHT_PAD * 2;
        var bmp = _bright.create(w, bmpH, nowMin);
        if (bmp == null) {
            return;
        }
        var bdc = bmp.getDc();
        var hue = _activeColors[1];
        var cr = ((hue >> 16) & 0xff).toFloat() / 255.0;
        var cg = ((hue >> 8) & 0xff).toFloat() / 255.0;
        var cb = (hue & 0xff).toFloat() / 255.0;
        var by = 0;
        while (by < bmpH) {
            var brightness =
                _fraction((by - BG_BACKLIGHT_PAD + 0.5) / h.toFloat()) * 255.0;
            var r = ColorUtils.quantizeBits(cr * brightness, 5);
            var g = ColorUtils.quantizeBits(cg * brightness, 6);
            var b = ColorUtils.quantizeBits(cb * brightness, 5);
            bdc.setColor((r << 16) | (g << 8) | b, Graphics.COLOR_TRANSPARENT);
            bdc.fillRectangle(0, by, w, 1);
            by += 1;
        }
    }

    public function draw(
        dc as Dc,
        w as Number,
        h as Number,
        nowMin as Number,
        shiftY as Number,
        gray as Number
    ) as Void {
        if (_bright.bmp == null) {
            render(w, h, nowMin);
        }
        if (_bright.bmp != null) {
            _bright.draw(dc, 0, shiftY - BG_BACKLIGHT_PAD, nowMin);
        }
        if (_dim.bmp == null) {
            _dim.create(w, h, nowMin);
        }
        if (_dim.bmp != null) {
            // gray is a pure function of the clock second, so a same-second redraw would otherwise refill this bitmap for nothing.
            if (gray != _dimGray) {
                _dimGray = gray;
                var dimBdc = (_dim.bmp as Graphics.BufferedBitmap).getDc();
                dimBdc.setColor(
                    (gray << 16) | (gray << 8) | gray,
                    Graphics.COLOR_TRANSPARENT
                );
                dimBdc.fillRectangle(0, 0, w, h);
            }
            dc.setBlendMode(Graphics.BLEND_MODE_MULTIPLY);
            _dim.draw(dc, 0, 0, nowMin);
            dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
        }
    }

    // Only the bright bitmap bakes in a palette color permanently.
    public function resetColor() as Void {
        _bright.reset();
    }

    private function _fraction(pos as Float) as Float {
        return Math.pow(
            2.718281828459045,
            -(pos - 0.5).abs() / BG_BACKLIGHT_SIGMA
        ).toFloat();
    }
}
