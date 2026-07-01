import Toybox.Lang;
import Toybox.Position;

// Pure color lookup and gradient math shared by row and graph drawing code.
module ColorUtils {
    function colorFromIdx(idx as Number) as Number {
        return idx >= 0 && idx < 10 ? COLORS[idx] : 0xffffff;
    }

    function gpsQualityColor(acc as Number) as Number {
        if (acc == Position.QUALITY_GOOD) {
            return colorFromIdx(1);
        }
        if (acc == Position.QUALITY_USABLE) {
            return colorFromIdx(3);
        }
        if (acc == Position.QUALITY_POOR) {
            return colorFromIdx(4);
        }
        if (acc == Position.QUALITY_LAST_KNOWN) {
            return colorFromIdx(8);
        }
        if (acc == Position.QUALITY_NOT_AVAILABLE) {
            return colorFromIdx(5);
        }
        return 0xffffff;
    }

    function gradFromStops(
        stops as Array<Number>,
        fraction as Float
    ) as Number {
        var n = stops.size();
        if (fraction <= 0.0) {
            return stops[0] as Number;
        }
        if (fraction >= 1.0) {
            return stops[n - 1] as Number;
        }
        var scaled = fraction * (n - 1).toFloat();
        var i = scaled.toNumber();
        if (i >= n - 1) {
            return stops[n - 1] as Number;
        }
        var t = scaled - i.toFloat();
        var ca = stops[i] as Number;
        var cb = stops[i + 1] as Number;
        var r =
            ((ca >> 16) & 0xff) +
            (t * (((cb >> 16) & 0xff) - ((ca >> 16) & 0xff))).toNumber();
        var g =
            ((ca >> 8) & 0xff) +
            (t * (((cb >> 8) & 0xff) - ((ca >> 8) & 0xff))).toNumber();
        var b = (ca & 0xff) + (t * ((cb & 0xff) - (ca & 0xff))).toNumber();
        return ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff);
    }

    function withAlpha(color as Number, alpha as Number) as Number {
        return (alpha << 24) | (color & 0xffffff);
    }

    function gradColor(colorIdx as Number, fraction as Float) as Number {
        switch (colorIdx) {
            case COLOR_GRAD_TRI:
                return gradFromStops(TRI_GRAD, fraction);
            case COLOR_GRAD_TRI_REV:
                return gradFromStops(TRI_GRAD, 1.0 - fraction);
            case COLOR_GRAD_TEMP_CUSTOM:
                return gradFromStops(TEMP_GRADS[0] as Array<Number>, fraction);
            case COLOR_GRAD_TEMP_CUSTOM_REV:
                return gradFromStops(
                    TEMP_GRADS[0] as Array<Number>,
                    1.0 - fraction
                );
            case COLOR_GRAD_TEMP_SPECTRAL:
                return gradFromStops(TEMP_GRADS[1] as Array<Number>, fraction);
            case COLOR_GRAD_TEMP_SPECTRAL_REV:
                return gradFromStops(
                    TEMP_GRADS[1] as Array<Number>,
                    1.0 - fraction
                );
            case COLOR_GRAD_TEMP_TURBO:
                return gradFromStops(TEMP_GRADS[2] as Array<Number>, fraction);
            case COLOR_GRAD_TEMP_TURBO_REV:
                return gradFromStops(
                    TEMP_GRADS[2] as Array<Number>,
                    1.0 - fraction
                );
            case COLOR_GRAD_TEMP_INFERNO:
                return gradFromStops(TEMP_GRADS[3] as Array<Number>, fraction);
            case COLOR_GRAD_TEMP_INFERNO_REV:
                return gradFromStops(
                    TEMP_GRADS[3] as Array<Number>,
                    1.0 - fraction
                );
            default:
                return colorFromIdx(colorIdx);
        }
    }
}
