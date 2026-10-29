import Toybox.Graphics;
import Toybox.Lang;

module Bitmaps {
    function tryDraw(
        dc as Dc,
        x as Number,
        y as Number,
        bmp as Graphics.BufferedBitmap
    ) as Boolean {
        try {
            dc.drawBitmap(x, y, bmp);
            return true;
        } catch (e instanceof Lang.Exception) {
            return false;
        }
    }

    function tryDrawRetry(
        dc as Dc,
        x as Number,
        y as Number,
        bmp as Graphics.BufferedBitmap,
        lastOk as Boolean?,
        lastMin as Number,
        nowMin as Number
    ) as [Boolean, Number] {
        if (retryDue(lastOk, lastMin, nowMin)) {
            return [tryDraw(dc, x, y, bmp), nowMin];
        }
        if (lastOk as Boolean) {
            if (!tryDraw(dc, x, y, bmp)) {
                return [false, nowMin];
            }
        }
        return [lastOk, lastMin];
    }

    function retryDue(
        lastOk as Boolean?,
        lastMin as Number,
        nowMin as Number
    ) as Boolean {
        // nowMin < lastMin means the clock moved backward - retry now rather than trust stale elapsed-time math.
        return (
            lastOk == null ||
            nowMin < lastMin ||
            nowMin - lastMin >= BITMAP_DRAW_RETRY_MIN
        );
    }

    // .get() can throw or silently return a pool-reclaimed bitmap; isCached() catches the latter.
    function resolveRef(
        ref as Graphics.BufferedBitmapReference?
    ) as Graphics.BufferedBitmap? {
        if (ref == null) {
            return null;
        }
        try {
            var bmp = ref.get() as Graphics.BufferedBitmap?;
            return bmp != null && bmp.isCached() ? bmp : null;
        } catch (e instanceof Lang.Exception) {
            return null;
        }
    }

    // A fresh bitmap reports isCached() false, so resolveRef would reject it; get() locks it in the pool while the object is held.
    function createLocked(
        w as Number,
        h as Number
    ) as [Graphics.BufferedBitmapReference, Graphics.BufferedBitmap]? {
        var ref = tryCreate(w, h);
        if (ref == null) {
            return null;
        }
        try {
            var bmp = ref.get() as Graphics.BufferedBitmap?;
            return bmp != null ? [ref, bmp] : null;
        } catch (e instanceof Lang.Exception) {
            return null;
        }
    }

    // Graphics.createBufferedBitmap() can also throw under memory pressure.
    function tryCreate(
        w as Number,
        h as Number
    ) as Graphics.BufferedBitmapReference? {
        try {
            return Graphics.createBufferedBitmap({ :width => w, :height => h });
        } catch (e instanceof Lang.Exception) {
            return null;
        }
    }
}
