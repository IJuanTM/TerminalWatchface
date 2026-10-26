import Toybox.Lang;

// Graph data and bitmap caches; every bitmap entry has a drawOk twin, so removal goes through removeBmp/removeBmpDual.
class GraphCache {
    // Value keyed by GraphUtils.packKey(...), each entry [value, lastCheckedMin].
    public var history as Dictionary = {};
    // Keyed by the same cacheKey as the data itself; entry is [minV, maxV, dataRef].
    public var minMax as Dictionary = {};
    public var bmp as Dictionary = {};
    public var bmpDual as Dictionary = {};
    // Keyed by cacheKey (like bmp) so one row's failure can't affect another; value [lastOk, lastCheckedMin].
    public var bmpDrawOk as Dictionary = {};
    // Separate dict because dual-graph cache keys can collide numerically with single-graph keys.
    public var bmpDualDrawOk as Dictionary = {};
    private var _groupedBar as Dictionary = {};
    private var _dualAlign as Dictionary = {};
    private var _effPeriod as Dictionary = {};

    public function initialize() {}

    public function clear() as Void {
        history = {};
        minMax = {};
        _groupedBar = {};
        _dualAlign = {};
        _effPeriod = {};
        clearBitmaps();
    }

    public function clearBitmaps() as Void {
        bmp = {};
        bmpDual = {};
        bmpDrawOk = {};
        bmpDualDrawOk = {};
    }

    public function removeBmp(key as Number) as Void {
        bmp.remove(key);
        bmpDrawOk.remove(key);
    }

    public function removeBmpDual(key as Number) as Void {
        bmpDual.remove(key);
        bmpDualDrawOk.remove(key);
    }

    // Forecast bitmap cache keys don't change on refresh, so purge them here instead.
    public function invalidateField(field as Number) as Void {
        var keys = bmp.keys();
        for (var i = 0; i < keys.size(); i++) {
            var k = keys[i] as Number;
            if (GraphUtils.keyLo(k) == field) {
                removeBmp(k);
            }
        }
    }

    public function store(
        cacheKey as Number,
        field as Number,
        r as Array<Float>?,
        nowMin as Number,
        effPeriod as Number
    ) as Void {
        history.put(cacheKey, [r, nowMin] as [Array<Float>?, Number]);
        removeBmp(cacheKey);
        var dualKeys = bmpDual.keys();
        for (var i = 0; i < dualKeys.size(); i++) {
            var k = dualKeys[i] as Number;
            if (GraphUtils.keyHi(k) == field || GraphUtils.keyLo(k) == field) {
                removeBmpDual(k);
            }
        }
        if (effPeriod > 0) {
            _effPeriod.put(cacheKey, effPeriod);
        }
    }

    public function resolveEffPeriod(
        key as Number,
        periodMin as Number
    ) as Number {
        return _effPeriod.hasKey(key)
            ? _effPeriod.get(key) as Number
            : periodMin;
    }

    // Entries are [crispRef, glowRef?, style]; style covers per-slot settings the cache key has no bits left for.
    public function pairGet(
        cache as Dictionary,
        cacheKey as Number,
        style as Number
    ) as Array {
        var pair = cache.get(cacheKey) as Array?;
        return pair != null && pair[2] == style ? pair : [null, null] as Array;
    }

    // Regroups only when history shows the data actually refreshed, not every frame - settings changes wipe this via clear().
    public function groupBarData(
        cacheKey as Number,
        storeKey as Number,
        data as Array<Float>,
        barCount as Number,
        agg as Number
    ) as Array<Float> {
        var lastMin = (history.get(cacheKey) as [Array<Float>?, Number])[1];
        if (_groupedBar.hasKey(storeKey)) {
            var entry =
                _groupedBar.get(storeKey) as
                [Array<Float>, Number, Number, Number];
            // barCount/agg can differ per caller even when lastMin matches (shared secondary field, different primaries).
            if (
                entry[1] == lastMin &&
                entry[2] == barCount &&
                entry[3] == agg
            ) {
                return entry[0];
            }
        }
        var grouped = GraphUtils.groupBarData(data, barCount, agg);
        _groupedBar.put(
            storeKey,
            [grouped, lastMin, barCount, agg] as
                [Array<Float>, Number, Number, Number]
        );
        return grouped;
    }

    // Data reads stretch each series over its own effective span, so a dual row re-slots the secondary onto the primary's.
    public function alignSecondary(
        cacheKey as Number,
        src as Array<Float>,
        effSecondary as Number,
        effPrimary as Number
    ) as Array<Float> {
        if (effSecondary == effPrimary) {
            return src;
        }
        var entry =
            _dualAlign.get(cacheKey) as
            [Array<Float>, Number, Number, Array<Float>]?;
        if (
            entry != null &&
            entry[0] == src &&
            entry[1] == effSecondary &&
            entry[2] == effPrimary
        ) {
            return entry[3];
        }
        var n = src.size();
        var out = new Array<Float>[n];
        for (var j = 0; j < n; j++) {
            var i = (j * effPrimary) / effSecondary;
            if (i < n) {
                out[j] = src[i];
            }
        }
        _dualAlign.put(
            cacheKey,
            [src, effSecondary, effPrimary, out] as
                [Array<Float>, Number, Number, Array<Float>]
        );
        return out;
    }
}
