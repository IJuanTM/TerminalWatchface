import Toybox.Lang;

module FieldMeta {
    // Gradient domain can differ from the data's own min/max (e.g. HR always maps 40-200).
    function gradRange(
        field as Number,
        colorIdx as Number,
        dataMinV as Float,
        dataRange as Float
    ) as [Float, Float] {
        if (colorIdx >= COLOR_GRAD_TEMP_CUSTOM) {
            return [-20.0, 60.0];
        }
        if (colorIdx >= COLOR_GRAD_TRI) {
            var gMin = 0.0 as Float;
            var gMax = 0.0 as Float;
            if (field == FIELD_HR) {
                gMin = 40.0;
                gMax = 200.0;
            } else if (
                field == FIELD_BODY_BAT ||
                field == FIELD_STRESS ||
                field == FIELD_WX_FCST_PRECIP ||
                field == FIELD_WX_FCST_HUMIDITY ||
                field == FIELD_WX_FCST_CLOUD
            ) {
                gMin = 0.0;
                gMax = 100.0;
            } else if (field == FIELD_WX_FCST_UV) {
                gMin = 0.0;
                gMax = 11.0;
            } else if (field == FIELD_WX_NOWCAST) {
                gMin = 0.0;
                gMax = 10.0;
            } else if (field == FIELD_SPO2) {
                gMin = 85.0;
                gMax = 100.0;
            } else {
                return [dataMinV, dataRange];
            }
            var gRange = gMax - gMin;
            if (gRange < 1.0) {
                gRange = 1.0;
            }
            return [gMin, gRange];
        }
        return [dataMinV, dataRange];
    }

    function graphKey(field as Number) as String? {
        if (field == FIELD_HR) {
            return PP_HR;
        }
        if (field == FIELD_BODY_BAT) {
            return PP_BODY_BAT;
        }
        if (field == FIELD_STRESS) {
            return PP_STRESS;
        }
        if (field == FIELD_SPO2) {
            return PP_SPO2;
        }
        if (field == FIELD_WRIST_TEMP) {
            return PP_TEMP_WRIST;
        }
        if (field == FIELD_ELEVATION) {
            return PP_ELEVATION;
        }
        if (field == FIELD_PRESSURE) {
            return PP_PRESSURE;
        }
        return null;
    }

    function updateMin(field as Number) as Number {
        // SpO2's real device sample interval is ~60min (confirmed via each target device's SDK simulator.json), far sparser than the other batched fields below.
        if (field == FIELD_SPO2) {
            return 60;
        }
        if (field == FIELD_STRESS || field == FIELD_WRIST_TEMP) {
            return 3;
        }
        if (
            field == FIELD_BODY_BAT ||
            field == FIELD_ELEVATION ||
            field == FIELD_PRESSURE
        ) {
            return 5;
        }
        return 1;
    }

    // x6 (not x3) since real devices batch these fields' samples more irregularly than updateMin assumes.
    function pointStaleSec(field as Number) as Number {
        return updateMin(field) * SECS_PER_MIN * 6;
    }

    function graphStaleSec(field as Number) as Number {
        return pointStaleSec(field) / 2;
    }

    function slotField(pk as String, slotName as String) as Number {
        return Props.getNum(
            pk + slotName,
            FieldTables.lineSlotDefaultField(pk, slotName)
        );
    }
}
