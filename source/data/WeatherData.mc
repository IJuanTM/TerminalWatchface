import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Toybox.Weather;

// Display-ready current conditions plus the raw hourly/daily forecast series the graphs draw from.
class WeatherData {
    public var temp as String = "-";
    public var feels as String = "-";
    public var low as String = "-";
    public var high as String = "-";
    public var precip as String = "-";
    public var wind as String = "-";
    public var uv as String = "-";
    public var uvNum as Number = -1;
    public var cond as String = "-";
    public var humidity as String = "-";
    public var humidityNum as Number = -1;
    public var dewPoint as String = "-";
    public var visibility as String = "-";
    public var cloudCover as String = "-";
    public var heatIndex as String = "-";
    public var obsAge as String = "-";

    public var fcstTemp as Array<Float>? = null;
    public var fcstPrecip as Array<Float>? = null;
    public var fcstWind as Array<Float>? = null;
    public var fcstHumidity as Array<Float>? = null;
    public var fcstUv as Array<Float>? = null;
    public var fcstCloud as Array<Float>? = null;
    public var dailyHigh as Array<Float>? = null;
    public var dailyLow as Array<Float>? = null;

    public var lastMin as Number = -1;
    public var fetchedMin as Number = -1;
    public var fcstFetchedMin as Number = -1;

    public function initialize() {}

    (:extendedCode)
    public function refreshCurrent(
        c as Weather.CurrentConditions,
        units as Units
    ) as Void {
        humidityNum = -1;
        uvNum = -1;
        temp = units.optTempStr(c.temperature);
        feels = units.optTempStr(c.feelsLikeTemperature);
        low =
            c.lowTemperature != null
                ? units.tempStr0(
                      NumUtils.numToFloat(c.lowTemperature as Numeric)
                  )
                : "-";
        high =
            c.highTemperature != null
                ? units.tempStr0(
                      NumUtils.numToFloat(c.highTemperature as Numeric)
                  )
                : "-";
        precip =
            c.precipitationChance != null
                ? (c.precipitationChance as Number).toString() + "%"
                : "-";
        wind = "-";
        if (c.windSpeed != null) {
            var spd = NumUtils.numToFloat(c.windSpeed as Numeric);
            wind = units.distMetric
                ? (spd * KMH_PER_MPS).format("%.0f") + "km/h"
                : (spd * MPH_PER_MPS).format("%.0f") + "mph";
            if (c.windBearing != null) {
                var dirIdx = (((c.windBearing as Number) + 22) / 45) % 8;
                if (dirIdx < 0) {
                    dirIdx += 8;
                }
                wind += " " + WIND_DIRS[dirIdx];
            }
        }
        uv = "-";
        if (c.uvIndex != null) {
            uvNum = Math.round(
                NumUtils.numToFloat(c.uvIndex as Numeric)
            ).toNumber();
            uv = uvNum.toString() + uvTag();
        }
        cond =
            c.condition != null
                ? Formatters.condStr(c.condition as Number)
                : "-";
        if (c.relativeHumidity != null) {
            humidityNum = c.relativeHumidity as Number;
            humidity = humidityNum.toString() + "%";
        } else {
            humidity = "-";
        }
        dewPoint = units.optTempStr(c.dewPoint);
        visibility =
            c.visibility != null
                ? units.distStr(NumUtils.numToFloat(c.visibility as Numeric))
                : "-";
        cloudCover =
            c.cloudCover != null
                ? (c.cloudCover as Number).toString() + "%"
                : "-";
        if (c has :observationTime && c.observationTime != null) {
            var ageS =
                Time.now().value() - (c.observationTime as Time.Moment).value();
            if (ageS < 0) {
                ageS = 0;
            }
            obsAge = Formatters.formatAge(ageS);
        } else {
            obsAge = "-";
        }
        if (c.temperature != null && humidityNum >= 0) {
            heatIndex = units.calcHeatIndex(
                NumUtils.numToFloat(c.temperature as Numeric),
                humidityNum
            );
        } else {
            heatIndex = "-";
        }
    }

    (:extendedCode)
    public function refreshForecast(nowMin as Number) as Array<Number> {
        // Mark attempted even if the APIs return null so onUpdate's rotate-in force-refresh fires at most once per minute.
        fcstFetchedMin = nowMin;
        var changed = [] as Array<Number>;
        var forecast = Weather.getHourlyForecast();
        if (forecast != null && forecast.size() > 0) {
            var cnt = forecast.size() < 24 ? forecast.size() : 24;
            var arr = new Array<Float>[cnt];
            var precipArr = new Array<Float>[cnt];
            var windArr = new Array<Float>[cnt];
            var humArr = new Array<Float>[cnt];
            var uvArr = new Array<Float>[cnt];
            var cloudArr = new Array<Float>[cnt];
            for (var i = 0; i < cnt; i++) {
                var h = forecast[i];
                if (h.temperature != null) {
                    arr[i] = NumUtils.numToFloat(h.temperature as Numeric);
                }
                if (h.precipitationChance != null) {
                    precipArr[i] = (h.precipitationChance as Number).toFloat();
                }
                if (h.windSpeed != null) {
                    windArr[i] = NumUtils.numToFloat(h.windSpeed as Numeric);
                }
                if (h.relativeHumidity != null) {
                    humArr[i] = (h.relativeHumidity as Number).toFloat();
                }
                if (h.uvIndex != null) {
                    uvArr[i] = NumUtils.numToFloat(h.uvIndex as Numeric);
                }
                if (h.cloudCover != null) {
                    cloudArr[i] = (h.cloudCover as Number).toFloat();
                }
            }
            // Unchanged data keeps the old array refs so identity-keyed caches and graph bitmaps survive the per-minute refresh.
            if (!NumUtils.floatsEqual(fcstTemp, arr)) {
                fcstTemp = arr;
                changed.add(FIELD_WX_FCST_TEMP);
            }
            if (!NumUtils.floatsEqual(fcstPrecip, precipArr)) {
                fcstPrecip = precipArr;
                changed.add(FIELD_WX_FCST_PRECIP);
            }
            if (!NumUtils.floatsEqual(fcstWind, windArr)) {
                fcstWind = windArr;
                changed.add(FIELD_WX_FCST_WIND);
            }
            if (!NumUtils.floatsEqual(fcstHumidity, humArr)) {
                fcstHumidity = humArr;
                changed.add(FIELD_WX_FCST_HUMIDITY);
            }
            if (!NumUtils.floatsEqual(fcstUv, uvArr)) {
                fcstUv = uvArr;
                changed.add(FIELD_WX_FCST_UV);
            }
            if (!NumUtils.floatsEqual(fcstCloud, cloudArr)) {
                fcstCloud = cloudArr;
                changed.add(FIELD_WX_FCST_CLOUD);
            }
        }
        var daily = Weather.getDailyForecast();
        if (daily != null && daily.size() >= 2) {
            var dcnt = daily.size() < 7 ? daily.size() : 7;
            var dhigh = new Array<Float>[dcnt];
            var dlow = new Array<Float>[dcnt];
            for (var i = 0; i < dcnt; i++) {
                var dfc = daily[i];
                if (dfc.highTemperature != null) {
                    dhigh[i] = NumUtils.numToFloat(
                        dfc.highTemperature as Numeric
                    );
                }
                if (dfc.lowTemperature != null) {
                    dlow[i] = NumUtils.numToFloat(
                        dfc.lowTemperature as Numeric
                    );
                }
            }
            if (
                !NumUtils.floatsEqual(dailyHigh, dhigh) ||
                !NumUtils.floatsEqual(dailyLow, dlow)
            ) {
                dailyHigh = dhigh;
                dailyLow = dlow;
                changed.add(FIELD_WX_FCST_DAILY);
            }
        }
        return changed;
    }

    public function uvColorIdx() as Number {
        return uvNum <= 2 ? 1 : uvNum <= 5 ? 3 : uvNum <= 7 ? 4 : 5;
    }

    public function uvTag() as String {
        return uvNum <= 2
            ? " [LOW]"
            : uvNum <= 5
              ? " [AVG]"
              : uvNum <= 7
                ? " [HIGH]"
                : " [MAX]";
    }
}
