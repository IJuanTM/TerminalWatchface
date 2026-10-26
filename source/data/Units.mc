import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

// Unit settings resolved against the watch's own units once a minute, plus every formatter that depends on them.
class Units {
    public var distMetric as Boolean = false;
    public var tempMetric as Boolean = false;
    public var elevMetric as Boolean = false;
    public var paceMetric as Boolean = false;
    public var pressMetric as Boolean = false;
    public var tempUnit as String = "C";

    public function initialize() {}

    // Pressure has no watch setting, so 0 follows the resolved distance unit.
    public function resolve(ds as System.DeviceSettings) as Void {
        distMetric = _metric(P_UNIT_DISTANCE, ds.distanceUnits);
        tempMetric = _metric(P_UNIT_TEMPERATURE, ds.temperatureUnits);
        elevMetric = _metric(P_UNIT_ELEVATION, ds.elevationUnits);
        paceMetric = _metric(P_UNIT_PACE, ds.paceUnits);
        var pressUnit = Props.getNum(P_UNIT_PRESSURE, 0);
        pressMetric = pressUnit == 0 ? distMetric : pressUnit == 1;
        tempUnit = tempMetric ? "C" : "F";
    }

    public function tempStrFmt(v as Float, fmt as String) as String {
        return tempMetric
            ? v.format(fmt)
            : Formatters.celsiusToF(v).format(fmt);
    }

    public function tempStr(v as Float) as String {
        return tempStrFmt(v, "%.1f");
    }

    public function tempStr0(v as Float) as String {
        return tempStrFmt(v, "%.0f");
    }

    public function altStr(m as Float) as String {
        return elevMetric
            ? m.format("%.0f") + "m"
            : (m * FEET_PER_METER).format("%.0f") + "ft";
    }

    public function pressureStr(pa as Float) as String {
        return pressMetric
            ? (pa / 100.0).format("%.1f") + "hPa"
            : (pa / PA_PER_INHG).format("%.2f") + "inHg";
    }

    public function distStr(d as Float) as String {
        return distMetric
            ? (d / 1000.0).format("%.1f") + "km"
            : (d / METERS_PER_MILE).format("%.1f") + "mi";
    }

    public function formatGraphLabel(field as Number, v as Float) as String {
        if (field == FIELD_WRIST_TEMP || field == FIELD_WX_FCST_TEMP) {
            return tempStr0(v);
        }
        if (field == FIELD_ELEVATION) {
            return elevMetric
                ? v.format("%.0f")
                : (v * FEET_PER_METER).format("%.0f");
        }
        if (field == FIELD_PRESSURE) {
            return pressMetric
                ? (v / 100.0).format("%.0f")
                : (v / PA_PER_INHG).format("%.1f");
        }
        if (
            field == FIELD_WX_FCST_PRECIP ||
            field == FIELD_WX_FCST_HUMIDITY ||
            field == FIELD_WX_FCST_CLOUD
        ) {
            return v.format("%.0f") + "%";
        }
        if (field == FIELD_WX_FCST_WIND) {
            return distMetric
                ? (v * KMH_PER_MPS).format("%.0f")
                : (v * MPH_PER_MPS).format("%.0f");
        }
        if (field == FIELD_WX_NOWCAST) {
            return distMetric
                ? v.format("%.1f")
                : (v / MM_PER_INCH).format("%.2f");
        }
        if (field == FIELD_WX_FCST_UV) {
            return v.format("%.1f");
        }
        return Math.round(v).toNumber().toString();
    }

    public function graphFieldUnit(field as Number) as String {
        if (field == FIELD_HR) {
            return " bpm";
        }
        if (field == FIELD_BODY_BAT || field == FIELD_SPO2) {
            return "%";
        }
        if (field == FIELD_WX_FCST_WIND) {
            return distMetric ? "km/h" : "mph";
        }
        if (field == FIELD_ELEVATION) {
            return elevMetric ? "m" : "ft";
        }
        if (field == FIELD_WX_NOWCAST) {
            return distMetric ? "mm/h" : "in/h";
        }
        if (field == FIELD_PRESSURE) {
            return pressMetric ? "hPa" : "inHg";
        }
        return "";
    }

    public function optDistStr(v as Float?) as String {
        return v != null ? distStr(v) : "-";
    }

    public function optTempStr(v as Numeric?) as String {
        return v != null ? tempStr(NumUtils.numToFloat(v)) : "-";
    }

    public function formatPace(speedMps as Float) as String {
        if (speedMps <= MIN_SPEED_MPS) {
            return "-";
        }
        var totalSec = Math.round(
            (paceMetric ? 1000.0 : METERS_PER_MILE) / speedMps
        ).toNumber();
        return (
            (totalSec / SECS_PER_MIN).format("%d") +
            ":" +
            (totalSec % SECS_PER_MIN).format("%02d") +
            (paceMetric ? "/km" : "/mi")
        );
    }

    public function calcHeatIndex(
        tempC as Float,
        humidity as Number
    ) as String {
        var T = Formatters.celsiusToF(tempC);
        var RH = humidity.toFloat();
        if (T < 80.0 || RH < 40.0) {
            return tempStr(tempC);
        }
        var T2 = T * T;
        var RH2 = RH * RH;
        var HI =
            -42.379 +
            2.04901523 * T +
            10.14333127 * RH -
            0.22475541 * T * RH -
            0.00683783 * T2 -
            0.05481717 * RH2 +
            0.00122874 * T2 * RH +
            0.00085282 * T * RH2 -
            0.00000199 * T2 * RH2;
        return tempMetric
            ? (((HI - 32.0) * 5.0) / 9.0).format("%.1f")
            : HI.format("%.1f");
    }

    private function _metric(
        key as String,
        deviceUnits as System.UnitsSystem
    ) as Boolean {
        var choice = Props.getNum(key, 0);
        return choice == 0 ? deviceUnits == System.UNIT_METRIC : choice == 1;
    }
}
