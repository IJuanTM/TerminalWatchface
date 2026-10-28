import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;

(:background)
const NOWCAST_STEP_SEC = 300;

// Exits with [startUnixSec, mm/h per NOWCAST_STEP_SEC slot...], or the failing response code.
(:background)
class RainNowcastService extends System.ServiceDelegate {
    private var _lat as String = "";
    private var _lon as String = "";

    public function initialize() {
        ServiceDelegate.initialize();
    }

    public function onTemporalEvent() as Void {
        var loc = Storage.getValue("rnLoc");
        if (!(loc instanceof Lang.Array) || loc.size() != 2) {
            Background.exit(null);
            return;
        }
        var lat = loc[0] as Float;
        var lon = loc[1] as Float;
        // Buienradar redirects anything finer than 2 decimals.
        _lat = lat.format("%.2f");
        _lon = lon.format("%.2f");
        if (lat >= 49.4 && lat <= 53.7 && lon >= 2.5 && lon <= 7.3) {
            Communications.makeWebRequest(
                "https://gpsgadget.buienradar.nl/data/raintext",
                { "lat" => _lat, "lon" => _lon },
                {
                    :method => Communications.HTTP_REQUEST_METHOD_GET,
                    :responseType
                    =>
                    Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN,
                },
                method(:onBuienradar)
            );
        } else {
            _requestOpenMeteo();
        }
    }

    public function onBuienradar(
        code as Number,
        data as Communications.ContentType?
    ) as Void {
        if (code == 200 && data instanceof Lang.String) {
            var out = _parseBuienradar(data);
            if (out != null) {
                Background.exit(out);
                return;
            }
        }
        _requestOpenMeteo();
    }

    public function onOpenMeteo(
        code as Number,
        data as Communications.ContentType?
    ) as Void {
        if (code != 200 || !(data instanceof Lang.Dictionary)) {
            Background.exit(code);
            return;
        }
        var m = data["minutely_15"];
        if (!(m instanceof Lang.Dictionary)) {
            Background.exit(code);
            return;
        }
        var times = m["time"];
        var precip = m["precipitation"];
        if (
            !(times instanceof Lang.Array) ||
            !(precip instanceof Lang.Array) ||
            times.size() == 0 ||
            precip.size() != times.size()
        ) {
            Background.exit(code);
            return;
        }
        // Each value is the sum over the 15 minutes before its timestamp.
        var out =
            [(times[0] as Number) - 900] as Array<Number or Float or Null>;
        for (var i = 0; i < precip.size(); i++) {
            var p = precip[i];
            var rate = p != null ? (p as Numeric).toFloat() * 4.0 : null;
            for (var k = 0; k < 3; k++) {
                out.add(rate);
            }
        }
        Background.exit(out);
    }

    private function _requestOpenMeteo() as Void {
        Communications.makeWebRequest(
            "https://api.open-meteo.com/v1/forecast",
            {
                "latitude" => _lat,
                "longitude" => _lon,
                "minutely_15" => "precipitation",
                "forecast_minutely_15" => 11,
                "timeformat" => "unixtime",
            },
            {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            },
            method(:onOpenMeteo)
        );
    }

    // Lines are "NNN|HH:MM" in local time, one per 5 minutes.
    private function _parseBuienradar(
        text as String
    ) as Array<Number or Float>? {
        var out = [0] as Array<Number or Float>;
        var rest = text;
        while (rest.length() >= 9) {
            var bar = rest.find("|");
            if (bar == null) {
                break;
            }
            if (out.size() == 1) {
                if (rest.length() < bar + 6) {
                    return null;
                }
                var hh = rest.substring(bar + 1, bar + 3).toNumberWithBase(10);
                var mm = rest.substring(bar + 4, bar + 6).toNumberWithBase(10);
                if (hh == null || mm == null) {
                    return null;
                }
                var start = Time.today().value() + hh * 3600 + mm * 60;
                var now = Time.now().value();
                if (start - now > 43200) {
                    start -= 86400;
                } else if (now - start > 43200) {
                    start += 86400;
                }
                out[0] = start;
            }
            var v = rest.substring(0, bar).toNumberWithBase(10);
            out.add(
                v == null || v <= 0
                    ? 0.0
                    : Math.pow(10.0, (v - 109) / 32.0).toFloat()
            );
            var nl = rest.find("\n");
            if (nl == null) {
                break;
            }
            rest = rest.substring(nl + 1, rest.length()) as String;
        }
        return out.size() > 2 ? out : null;
    }
}
