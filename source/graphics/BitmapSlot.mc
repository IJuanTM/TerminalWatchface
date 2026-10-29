import Toybox.Graphics;
import Toybox.Lang;

// A long-lived offscreen bitmap whose creation and drawing each back off for BITMAP_DRAW_RETRY_MIN after a failure, instead of latching it forever.
class BitmapSlot {
    public var bmp as Graphics.BufferedBitmap? = null;
    // -1 = no failed create attempt pending retry.
    private var _failMin as Number = -1;
    // Null until the first draw attempt.
    private var _drawOk as Boolean? = null;
    private var _drawOkMin as Number = -1;

    public function initialize() {}

    // Keeps the previous bitmap when creation fails.
    public function create(
        w as Number,
        h as Number,
        nowMin as Number
    ) as Graphics.BufferedBitmap? {
        if (
            _failMin >= 0 &&
            nowMin >= _failMin &&
            nowMin - _failMin < BITMAP_DRAW_RETRY_MIN
        ) {
            return null;
        }
        var created = Bitmaps.createLocked(w, h);
        if (created == null) {
            _failMin = nowMin;
            return null;
        }
        bmp = created[1];
        _failMin = -1;
        return bmp;
    }

    public function draw(
        dc as Dc,
        x as Number,
        y as Number,
        nowMin as Number
    ) as Void {
        var r = Bitmaps.tryDrawRetry(
            dc,
            x,
            y,
            bmp as Graphics.BufferedBitmap,
            _drawOk,
            _drawOkMin,
            nowMin
        );
        _drawOk = r[0];
        _drawOkMin = r[1];
    }

    public function drawBlocked(nowMin as Number) as Boolean {
        return (
            _drawOk == false && !Bitmaps.retryDue(_drawOk, _drawOkMin, nowMin)
        );
    }

    // Leaves the create back-off alone, it tracks pool pressure, not content.
    public function reset() as Void {
        bmp = null;
        _drawOk = null;
        _drawOkMin = -1;
    }
}
