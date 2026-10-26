import Toybox.Lang;

module NumUtils {
    function fracClamp(
        v as Float,
        gradMinV as Float,
        gradRange as Float
    ) as Float {
        var frac = (v - gradMinV) / gradRange;
        if (frac < 0.0) {
            return 0.0;
        }
        if (frac > 1.0) {
            return 1.0;
        }
        return frac;
    }

    function numToFloat(v as Numeric) as Float {
        return v instanceof Lang.Float ? v as Float : (v as Number).toFloat();
    }

    function floatsEqual(a as Array<Float>?, b as Array<Float>) as Boolean {
        if (a == null || a.size() != b.size()) {
            return false;
        }
        for (var i = 0; i < b.size(); i++) {
            var av = a[i];
            if (av == null ? b[i] != null : !(av as Float).equals(b[i])) {
                return false;
            }
        }
        return true;
    }
}
