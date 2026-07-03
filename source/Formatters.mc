import Toybox.Lang;
import Toybox.Weather;

// Pure string formatting helpers shared by row and graph drawing code.
module Formatters {
    function fieldShortName(field as Number) as String {
        if (field == FIELD_HR) {
            return "HR";
        }
        if (field == FIELD_BODY_BAT) {
            return "BB";
        }
        if (field == FIELD_STRESS) {
            return "Str";
        }
        if (field == FIELD_SPO2) {
            return "O2";
        }
        if (field == FIELD_WRIST_TEMP) {
            return "Tmp";
        }
        if (field == FIELD_ELEVATION) {
            return "Elv";
        }
        if (field == FIELD_PRESSURE) {
            return "hPa";
        }
        return "?";
    }

    function secsToTime(secs as Number) as String {
        var h = secs / SECS_PER_HOUR;
        var m = (secs % SECS_PER_HOUR) / SECS_PER_MIN;
        return h.format("%d") + ":" + m.format("%02d");
    }

    function secsToRace(secs as Number) as String {
        var h = secs / SECS_PER_HOUR;
        var m = (secs % SECS_PER_HOUR) / SECS_PER_MIN;
        var s = secs % SECS_PER_MIN;
        if (h > 0) {
            return (
                h.format("%d") + ":" + m.format("%02d") + ":" + s.format("%02d")
            );
        }
        return m.format("%d") + ":" + s.format("%02d");
    }

    function periodLabel(periodMin as Number) as String {
        return periodMin < 60
            ? "-" + periodMin.toString() + "m"
            : "-" + (periodMin / 60).toString() + "h";
    }

    function formatAge(ageSec as Number) as String {
        if (ageSec < SECS_PER_MIN) {
            return ">" + ageSec.toString() + "s";
        }
        if (ageSec < SECS_PER_HOUR) {
            return ">" + (ageSec / SECS_PER_MIN).toString() + "m";
        }
        return ">" + (ageSec / SECS_PER_HOUR).toString() + "h";
    }

    function celsiusToF(tempC as Float) as Float {
        return (tempC * 9.0) / 5.0 + 32.0;
    }

    (:extendedCode)
    function trainingStatusStr(s as String) as String {
        if (s.equals("Productive")) {
            return "[PRODUCTIVE]";
        }
        if (s.equals("Maintaining")) {
            return "[MAINT]";
        }
        if (s.equals("Peaking")) {
            return "[PEAKING]";
        }
        if (s.equals("Recovery")) {
            return "[RECOVERY]";
        }
        if (s.equals("Overreaching")) {
            return "[OVERREACH]";
        }
        if (s.equals("Detraining")) {
            return "[DETRAIN]";
        }
        if (s.equals("Ready")) {
            return "[READY]";
        }
        if (s.equals("Not Ready")) {
            return "[NOT READY]";
        }
        if (s.equals("No Status")) {
            return "-";
        }
        return "[" + s + "]";
    }

    (:extendedCode)
    function condStr(cond as Number) as String {
        switch (cond) {
            case Weather.CONDITION_CLEAR:
            case Weather.CONDITION_MOSTLY_CLEAR:
            case Weather.CONDITION_FAIR:
                return "[CLEAR]";
            case Weather.CONDITION_PARTLY_CLOUDY:
            case Weather.CONDITION_PARTLY_CLEAR:
                return "[PCLOUD]";
            case Weather.CONDITION_MOSTLY_CLOUDY:
            case Weather.CONDITION_CLOUDY:
            case Weather.CONDITION_THIN_CLOUDS:
                return "[CLOUDY]";
            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_HEAVY_RAIN:
            case Weather.CONDITION_SCATTERED_SHOWERS:
            case Weather.CONDITION_SHOWERS:
            case Weather.CONDITION_LIGHT_SHOWERS:
            case Weather.CONDITION_HEAVY_SHOWERS:
            case Weather.CONDITION_DRIZZLE:
            case Weather.CONDITION_UNKNOWN_PRECIPITATION:
            case Weather.CONDITION_CHANCE_OF_SHOWERS:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
                return "[RAIN]";
            case Weather.CONDITION_SNOW:
            case Weather.CONDITION_LIGHT_SNOW:
            case Weather.CONDITION_HEAVY_SNOW:
            case Weather.CONDITION_FLURRIES:
            case Weather.CONDITION_CHANCE_OF_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
                return "[SNOW]";
            case Weather.CONDITION_WINDY:
                return "[WINDY]";
            case Weather.CONDITION_THUNDERSTORMS:
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
            case Weather.CONDITION_SQUALL:
            case Weather.CONDITION_HURRICANE:
            case Weather.CONDITION_TROPICAL_STORM:
                return "[STORM]";
            case Weather.CONDITION_WINTRY_MIX:
            case Weather.CONDITION_LIGHT_RAIN_SNOW:
            case Weather.CONDITION_HEAVY_RAIN_SNOW:
            case Weather.CONDITION_RAIN_SNOW:
            case Weather.CONDITION_FREEZING_RAIN:
            case Weather.CONDITION_ICE:
            case Weather.CONDITION_SLEET:
            case Weather.CONDITION_ICE_SNOW:
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:
                return "[MIX]";
            case Weather.CONDITION_FOG:
            case Weather.CONDITION_MIST:
                return "[FOG]";
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_HAZE:
            case Weather.CONDITION_SMOKE:
            case Weather.CONDITION_DUST:
            case Weather.CONDITION_SAND:
            case Weather.CONDITION_SANDSTORM:
            case Weather.CONDITION_VOLCANIC_ASH:
                return "[HAZY]";
            case Weather.CONDITION_HAIL:
                return "[HAIL]";
            case Weather.CONDITION_TORNADO:
                return "[TORN]";
            default:
                return "[?]";
        }
    }
}
