import Toybox.Lang;

module GraphUtils {
    function packKey(
        hi as Number,
        lo as Number,
        periodMin as Number
    ) as Number {
        return (
            ((hi & CACHE_KEY_MASK) << CACHE_KEY_HI_SHIFT) |
            ((lo & CACHE_KEY_MASK) << CACHE_KEY_LO_SHIFT) |
            (periodMin & CACHE_KEY_PERIOD_MASK)
        );
    }

    function keyHi(k as Number) as Number {
        return (k >> CACHE_KEY_HI_SHIFT) & CACHE_KEY_MASK;
    }

    function keyLo(k as Number) as Number {
        return (k >> CACHE_KEY_LO_SHIFT) & CACHE_KEY_MASK;
    }

    function style(
        graphType as Number,
        lineColor as Number,
        dataSize as Number,
        barAgg as Number
    ) as Number {
        return (
            (graphType & 0x3) |
            ((lineColor & 0x7f) << 2) |
            ((dataSize & 0x3ff) << 9) |
            ((barAgg & 0x3) << 19)
        );
    }

    function labelPad(a as String, b as String) as Number {
        var len = a.length() > b.length() ? a.length() : b.length();
        var pad = (len + 1) / 2;
        return pad < 1 ? 1 : pad;
    }

    // agg: 0=mean, 1=max, 2=last (most recent non-null in the group; index 0 is "now", per _readIter's age->slot mapping).
    function groupBarData(
        data as Array<Float>,
        barCount as Number,
        agg as Number
    ) as Array<Float> {
        var n = data.size();
        var out = new Array<Float>[barCount];
        for (var j = 0; j < barCount; j++) {
            var lo = (j * n) / barCount;
            var hi = ((j + 1) * n) / barCount;
            if (hi <= lo) {
                hi = lo + 1;
            }
            if (hi > n) {
                hi = n;
            }
            if (agg == 1) {
                var best = 0.0 as Float;
                var found = false;
                for (var i = lo; i < hi; i++) {
                    if (data[i] != null) {
                        var v = data[i] as Float;
                        if (!found || v > best) {
                            best = v;
                            found = true;
                        }
                    }
                }
                if (found) {
                    out[j] = best;
                }
            } else if (agg == 2) {
                for (var i2 = lo; i2 < hi; i2++) {
                    if (data[i2] != null) {
                        out[j] = data[i2] as Float;
                        break;
                    }
                }
            } else {
                var sum = 0.0;
                var cnt = 0;
                for (var i3 = lo; i3 < hi; i3++) {
                    if (data[i3] != null) {
                        sum += data[i3] as Float;
                        cnt++;
                    }
                }
                if (cnt > 0) {
                    out[j] = sum / cnt.toFloat();
                }
            }
        }
        return out;
    }
}
