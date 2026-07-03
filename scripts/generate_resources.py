#!/usr/bin/env python3
"""
Generates resources/properties.xml, resources/strings/strings.xml,
resources/settings.xml, and source/FieldIds.mc from a single source of truth.

Run from the project root:
    python scripts/generate_resources.py
"""

import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_PROPERTIES = os.path.join(ROOT, "resources", "properties.xml")
OUT_STRINGS = os.path.join(ROOT, "resources", "strings", "strings.xml")
OUT_SETTINGS = os.path.join(ROOT, "resources", "settings.xml")
OUT_FIELD_IDS = os.path.join(ROOT, "source", "FieldIds.mc")

# ---------------------------------------------------------------------------
# Shared data definitions
# ---------------------------------------------------------------------------

# (value, StringId, display text) — single source for both listEntries and strings.
COLORS_FULL = [  # 0-19, includes gradient options — used for graph lines
    (0, "ColorWhite", "White"),
    (1, "ColorGreen", "Green"),
    (2, "ColorCyan", "Cyan"),
    (3, "ColorYellow", "Yellow"),
    (4, "ColorOrange", "Orange"),
    (5, "ColorRed", "Red"),
    (6, "ColorBlue", "Blue"),
    (7, "ColorMagenta", "Magenta"),
    (8, "ColorLightGrey", "Light Grey"),
    (9, "ColorPurple", "Purple"),
    (10, "GradTriColor", "Tri-color (low->high)"),
    (11, "GradTriColorRev", "Tri-color (high->low)"),
    (12, "GradTempCustom", "Temp: Custom (cold->hot)"),
    (13, "GradTempCustomRev", "Temp: Custom (hot->cold)"),
    (14, "GradTempSpectral", "Temp: Spectral (cold->hot)"),
    (15, "GradTempSpectralRev", "Temp: Spectral (hot->cold)"),
    (16, "GradTempTurbo", "Temp: Turbo (cold->hot)"),
    (17, "GradTempTurboRev", "Temp: Turbo (hot->cold)"),
    (18, "GradTempInferno", "Temp: Inferno (cold->hot)"),
    (19, "GradTempInfernoRev", "Temp: Inferno (hot->cold)"),
]

COLORS_TEXT = COLORS_FULL[:10]  # 0-9, solid colors only — used for text labels/values

# All fields available on the configurable lines (3/4/5), grouped into
# categories. Each category owns a reserved 50-wide numeric block
# (category 0 -> values 1-50, category 1 -> 51-100, ...), so a field's
# value alone hints at its category, and adding a new field to a category
# never requires renumbering any other field. FieldNone is the one
# reserved value outside the blocks (0).
#
# Each entry is (const_suffix, StringId, display text). The Monkey C
# constant name is "FIELD_" + const_suffix. This table is the single
# source of truth for field values, field settings/strings, AND the
# generated source/FieldIds.mc - never hand-edit that file or hardcode a
# field's numeric value anywhere else (see FIELD_VALUE below for lookups).
FIELD_CATEGORY_WIDTH = 50

# Graph cache key bit layout (see _packGraphKey/_graphKeyHi/_graphKeyLo in
# TerminalWatchfaceView.mc): generated into source/FieldIds.mc below so the
# Monkey C side never hand-maintains a separate copy of these numbers.
CACHE_KEY_LO_SHIFT = 11
CACHE_KEY_HI_SHIFT = 21
CACHE_KEY_MASK = (1 << (CACHE_KEY_HI_SHIFT - CACHE_KEY_LO_SHIFT)) - 1
CACHE_KEY_FIELD_BUDGET = CACHE_KEY_MASK + 1
CACHE_KEY_PERIOD_BUDGET = 1 << CACHE_KEY_LO_SHIFT

# Settings group title prefixes, so the Connect IQ app's submenu list makes
# clear at a glance which groups are bar-progress settings vs graph settings.
BAR_CONFIG_PREFIX = "Bar Config - "
GRAPH_CONFIG_PREFIX = "Graph Config - "

FIELD_CATEGORIES = [
    ("Fitness / Health", [
        ("STEPS", "FieldSteps", "Steps"),
        ("FLOORS", "FieldFloors", "Floors (Up / Down)"),
        ("MOVE_BAR", "FieldMoveBar", "Move Bar"),
        ("HR", "FieldHR", "Heart Rate"),
        ("SPO2", "FieldSpO2", "Blood Oxygen (SpO2)"),
        ("RESP", "FieldResp", "Respiration Rate"),
        ("BODY_BAT", "FieldBodyBat", "Body Battery"),
        ("STRESS", "FieldStress", "Stress Score"),
        ("RECOVERY", "FieldRecovery", "Recovery Time"),
        ("SLEEP", "FieldSleep", "Sleep Score"),
        ("VO2_MAX", "FieldVo2Max", "VO2 Max"),
        ("LACTATE_HR", "FieldLactateHR", "Lactate Threshold HR"),
        ("TRAINING_STATUS", "FieldTrainingStatus", "Training Status"),
        ("WRIST_TEMP", "FieldWristTemp", "Wrist Temperature"),
        ("HR_RESTING", "FieldHrResting", "Resting HR"),
        ("HR_RESTING_AVG", "FieldHrRestingAvg", "Resting HR (7-day Avg)"),
        ("HR_RESTING_BOTH", "FieldHrRestingBoth", "Resting HR + 7-day Avg"),
        ("HR_SPO2", "FieldHrSpo2", "HR + SpO2"),
        ("RESP_SPO2", "FieldRespSpo2", "Respiration + SpO2"),
        ("BODY_BAT_STRESS", "FieldBodyBatStress", "Body Battery + Stress"),
        ("BODY_BAT_RECOVERY", "FieldBodyBatRecovery", "Body Battery + Recovery"),
        ("STRESS_RECOVERY", "FieldStressRecovery", "Stress + Recovery"),
        ("VO2_TRAINING", "FieldVo2Training", "VO2 Max + Training"),
        ("BODY_BAT_REST_HR", "FieldBodyBatRestHR", "Body Battery + Resting HR"),
        ("SLEEP_RECOVERY", "FieldSleepRecovery", "Sleep Score + Recovery"),
    ]),
    ("Calories / Distance / Speed", [
        ("CALORIES", "FieldCalories", "Calories (Daily)"),
        ("DISTANCE", "FieldDistance", "Distance (Daily)"),
        ("ACTIVE_MIN_DAY", "FieldActiveMinDay", "Active Minutes (Daily)"),
        ("INTENSITY_MIN", "FieldIntensityMin", "Intensity Minutes (Weekly)"),
    ]),
    ("Altitude / Pressure", [
        ("ALTITUDE", "FieldAltitude", "Altitude"),
        ("ELEVATION", "FieldElevation", "Elevation (Baro)"),
        ("PRESSURE", "FieldPressure", "Pressure"),
    ]),
    ("Race Predictors", [
        ("RACE_5K", "FieldRace5k", "Race Predictor: 5K"),
        ("RACE_10K", "FieldRace10k", "Race Predictor: 10K"),
        ("RACE_HALF", "FieldRaceHalf", "Race Predictor: Half Marathon"),
        ("RACE_MARATHON", "FieldRaceMarathon", "Race Predictor: Marathon"),
        ("RACE_PACE_5K", "FieldRacePace5k", "Race Pace: 5K"),
        ("RACE_PACE_10K", "FieldRacePace10k", "Race Pace: 10K"),
        ("RACE_PACE_HALF", "FieldRacePaceHalf", "Race Pace: Half Marathon"),
        ("RACE_PACE_MARATHON", "FieldRacePaceMarathon", "Race Pace: Marathon"),
    ]),
    ("Ascent / Descent", [
        ("CLIMB_DAY", "FieldClimbDay", "Climb (Daily)"),
        ("DESCENT_DAY", "FieldDescentDay", "Descent (Daily)"),
        ("CLIMB_DESCEND_DAY", "FieldClimbDescendDay", "Climb + Descent (Daily)"),
    ]),
    ("Weekly", [
        ("WEEKLY_RUN", "FieldWeeklyRun", "Distance (Weekly Run)"),
        ("WEEKLY_BIKE", "FieldWeeklyBike", "Distance (Weekly Bike)"),
        ("WEEKLY_DISTANCES", "FieldWeeklyDistances", "Distance (Weekly Run + Bike)"),
    ]),
    ("GPS / Navigation", [
        ("GPS_LAT", "FieldGpsLat", "GPS: Latitude"),
        ("GPS_LON", "FieldGpsLon", "GPS: Longitude"),
        ("GPS_ACCURACY", "FieldGpsAccuracy", "GPS: Accuracy"),
        ("GPS_LAT_LON", "FieldGpsLatLon", "GPS: Lat + Lon"),
        ("GPS_LAT_LON_ACC", "FieldGpsLatLonAcc", "GPS: Lat + Lon + Accuracy"),
        ("HEADING", "FieldHeading", "Heading"),
    ]),
    ("Time / Calendar", [
        ("SUNRISE", "FieldSunrise", "Sunrise"),
        ("SUNSET", "FieldSunset", "Sunset"),
        ("SUNRISE_SUNSET", "FieldSunriseSunset", "Sunrise + Sunset"),
        ("CALENDAR", "FieldCalendar", "Calendar Event"),
        ("SLEEP_TIME", "FieldSleepTime", "Bedtime"),
        ("WAKE_TIME", "FieldWakeTime", "Wake Time"),
        ("SLEEP_SCHEDULE", "FieldSleepSchedule", "Sleep Schedule (Bed + Wake)"),
    ]),
    ("Weather: current", [
        ("WX_TEMP", "FieldWxTemp", "Weather: Temperature"),
        ("WX_FEELS", "FieldWxFeels", "Weather: Feels Like"),
        ("WX_COND", "FieldWxCond", "Weather: Condition"),
        ("WX_PRECIP", "FieldWxPrecip", "Weather: Rain Chance"),
        ("WX_WIND", "FieldWxWind", "Weather: Wind Speed"),
        ("WX_UV", "FieldWxUV", "Weather: UV Index"),
        ("WX_CLOUD", "FieldWxCloud", "Weather: Cloud Cover"),
        ("WX_HUMIDITY", "FieldWxHumidity", "Weather: Humidity"),
        ("WX_DEW_POINT", "FieldWxDewPoint", "Weather: Dew Point"),
        ("WX_VISIBILITY", "FieldWxVisibility", "Weather: Visibility"),
        ("WX_HEAT_INDEX", "FieldWxHeatIndex", "Weather: Heat Index"),
        ("WX_HIGH_LOW", "FieldWxHighLow", "Weather: High / Low Temp"),
    ]),
    ("Weather: combos", [
        ("WX_TEMP_COND", "FieldWxTempCond", "Weather: Temp + Condition"),
        ("WX_TEMP_WIND", "FieldWxTempWind", "Weather: Temp + Wind"),
        ("WX_TEMP_UV", "FieldWxTempUV", "Weather: Temp + UV"),
        ("WX_TEMP_HUMIDITY", "FieldWxTempHumidity", "Weather: Temp + Humidity"),
        ("WX_TEMP_PRECIP", "FieldWxTempPrecip", "Weather: Temp + Rain"),
        ("WX_TEMP_HIGH_LOW", "FieldWxTempHighLow", "Weather: Temp + High/Low"),
        ("WX_COND_PRECIP", "FieldWxCondPrecip", "Weather: Condition + Rain"),
        ("WX_WIND_PRECIP", "FieldWxWindPrecip", "Weather: Wind + Rain"),
        ("WX_UV_WIND", "FieldWxUVWind", "Weather: UV + Wind"),
        ("WX_UV_PRECIP", "FieldWxUVPrecip", "Weather: UV + Rain"),
        ("WX_HUMIDITY_PRECIP", "FieldWxHumidityPrecip", "Weather: Humidity + Rain"),
        ("WX_HUMIDITY_DEW", "FieldWxHumidityDew", "Weather: Humidity + Dew Point"),
        ("WX_CLOUD_PRECIP", "FieldWxCloudPrecip", "Weather: Cloud + Rain"),
    ]),
    ("Weather: forecast", [
        ("WX_FCST_TEMP", "FieldWxFcstTemp", "Forecast: Temp (Hourly)"),
        ("WX_FCST_DAILY", "FieldWxFcstDaily", "Forecast: Temp (Daily)"),
        ("WX_FCST_PRECIP", "FieldWxFcstPrecip", "Forecast: Rain (Hourly)"),
        ("WX_FCST_WIND", "FieldWxFcstWind", "Forecast: Wind (Hourly)"),
        ("WX_FCST_UV", "FieldWxFcstUv", "Forecast: UV (Hourly)"),
        ("WX_FCST_HUMIDITY", "FieldWxFcstHumidity", "Forecast: Humidity (Hourly)"),
        ("WX_FCST_CLOUD", "FieldWxFcstCloud", "Forecast: Cloud (Hourly)"),
    ]),
    ("Weather: forecast conditions", [
        ("WX_FCST_COND_1D", "FieldWxFcstCond1d", "Forecast: Condition (+1 day)"),
        ("WX_FCST_COND_2D", "FieldWxFcstCond2d", "Forecast: Condition (+2 days)"),
        ("WX_FCST_COND_3D", "FieldWxFcstCond3d", "Forecast: Condition (+3 days)"),
        ("WX_COND_FCST_1D", "FieldWxCondFcst1d", "Weather: Condition + Tomorrow"),
        ("WX_FCST_COND_12D", "FieldWxFcstCond12d", "Forecast: +1d + +2d Condition"),
    ]),
    ("Weather: station", [
        ("WX_SEA_PRESS", "FieldWxSeaPress", "Weather: Sea Level Pressure"),
        ("WX_OBS_TIME", "FieldWxObsTime", "Weather: Data Age"),
    ]),
    ("Watch / System", [
        ("NOTIFICATIONS", "FieldNotifications", "Notifications"),
        ("SOLAR", "FieldSolar", "Solar Input"),
        ("SOLAR_BATTERY", "FieldSolarBattery", "Solar Input + Watch Battery"),
    ]),
]

# Computed from FIELD_CATEGORIES: (value, StringId, display text) for every
# field including FieldNone - same shape the rest of this script already
# expects from FIELDS_ALL. FIELD_VALUE is a StringId -> value lookup, used
# by LINE_SLOTS (and anything else) that needs to refer to a specific field
# by name instead of hardcoding its numeric value.
def _build_fields():
    total_span = FIELD_CATEGORY_WIDTH * len(FIELD_CATEGORIES)
    if total_span >= CACHE_KEY_FIELD_BUDGET:
        raise ValueError(
            f"FIELD_CATEGORIES spans {total_span} field IDs, exceeds the "
            f"{CACHE_KEY_FIELD_BUDGET}-value cache key budget "
            "(CACHE_KEY_FIELD_BUDGET). The hi/lo/periodMin slots already use "
            "all 31 usable bits of a signed 32-bit Number, so there are no "
            "spare bits to widen into - shrink another category first, or "
            "redesign _packGraphKey's key scheme before adding more categories"
        )
    fields_all = [(0, "FieldNone", "None (hidden)")]
    field_value = {"FieldNone": 0}
    for cat_idx, (cat_name, cat_fields) in enumerate(FIELD_CATEGORIES):
        if len(cat_fields) > FIELD_CATEGORY_WIDTH:
            raise ValueError(
                f"category '{cat_name}' has {len(cat_fields)} fields, "
                f"exceeds the {FIELD_CATEGORY_WIDTH}-wide block"
            )
        base = cat_idx * FIELD_CATEGORY_WIDTH
        for pos, (_suffix, string_id, display) in enumerate(cat_fields, start=1):
            value = base + pos
            fields_all.append((value, string_id, display))
            field_value[string_id] = value
    return fields_all, field_value


FIELDS_ALL, FIELD_VALUE = _build_fields()

# Graph-capable sensor fields.
# Each entry: (camelKey, StringPrefix, graph_mode_default,
#              sec_type_default, sec_field_default, time_frame_default,
#              graph_color_default, sec_color_default, value_mode_default)
# graph_mode_default: 0=value only, 1=line graph, 2=bar graph,
#                     3=line+current value, 4=bar+current value,
#                     5=area graph, 6=area+current value
# sec_field_default is an index into GRAPH_SEC_FIELDS below.
GRAPH_FIELDS = [
    # key skey mode std sfd tfd gcd scd vmd
    ("hr", "HR", 3, 0, 1, 60, 5, 0, 0),  # line+current, 1h; red
    ("bodyBat", "BodyBat", 6, 0, 2, 240, 11, 0, 0),  # area+current, 4h; tri-color rev
    ("stress", "Stress", 3, 0, 0, 120, 10, 0, 1),  # line+current, 2h; tri-color
    ("spo2", "SpO2", 0, 0, 0, 60, 2, 0, 2),  # value only; cyan
    ("tempWrist", "TempWrist", 3, 0, 0, 60, 16, 0, 1),  # line+current, 1h; turbo
    ("elevation", "Elevation", 6, 0, 6, 480, 1, 0, 0),  # area+current, 8h; green
    ("pressure", "Pressure", 3, 0, 5, 120, 2, 0, 1),  # line+current, 2h; cyan
]

# Secondary field options shared by all graph secondary-field pickers
GRAPH_SEC_FIELDS = [
    (0, "FieldHR"),
    (1, "FieldBodyBat"),
    (2, "FieldStress"),
    (3, "FieldSpO2"),
    (4, "FieldWristTemp"),
    (5, "FieldElevation"),
    (6, "FieldPressure"),
]

GRAPH_TIME_FRAMES = [
    (15, "TimeFrame15m"),
    (30, "TimeFrame30m"),
    (60, "TimeFrame1h"),
    (120, "TimeFrame2h"),
    (240, "TimeFrame4h"),
    (480, "TimeFrame8h"),
    (720, "TimeFrame12h"),
    (1440, "TimeFrame24h"),
]

FORECAST_TIME_FRAMES = [
    (3, "TimeFrameForecast3h"),
    (6, "TimeFrameForecast6h"),
    (12, "TimeFrameForecast12h"),
    (24, "TimeFrameForecast24h"),
]

# _packGraphKey ORs periodMin straight into the low CACHE_KEY_LO_SHIFT bits of
# the cache key with no mask, so any minute value here that reached the
# CACHE_KEY_PERIOD_BUDGET ceiling would bleed into the adjacent field bits.
_max_period_min = max(
    [m for m, _ in GRAPH_TIME_FRAMES] + [h for h, _ in FORECAST_TIME_FRAMES]
)
if _max_period_min >= CACHE_KEY_PERIOD_BUDGET:
    raise ValueError(
        f"GRAPH_TIME_FRAMES/FORECAST_TIME_FRAMES has a value of "
        f"{_max_period_min} minutes, exceeds the {CACHE_KEY_PERIOD_BUDGET}-value "
        "cache key period budget (CACHE_KEY_PERIOD_BUDGET) - _packGraphKey's "
        "periodMin bits need widening before adding a longer time frame"
    )

GRAPH_WIDTH_OPTIONS = [
    (6, "GraphWidth6"),
    (8, "GraphWidth8"),
    (10, "GraphWidth10"),
    (12, "GraphWidth12"),
    (14, "GraphWidth14"),
    (16, "GraphWidth16"),
]

# Display names for GRAPH_FIELDS entries — used in both strings.xml and settings.xml
GRAPH_DISPLAY_NAMES = {
    "hr": "Heart Rate",
    "bodyBat": "Body Battery",
    "stress": "Stress",
    "spo2": "Blood O2",
    "tempWrist": "Wrist Temp",
    "elevation": "Elevation",
    "pressure": "Pressure",
}

# Line 3/4/5 defaults: (line_num, slot, field_default, label_color_default, value_color_default)
# field_default is looked up by name via FIELD_VALUE so these stay correct
# no matter how FIELD_CATEGORIES gets renumbered.
_fv = FIELD_VALUE
LINE_SLOTS = [
    # R1 (Primary) - shown longest; at-a-glance essentials
    (3, "Primary", _fv["FieldWxFcstTemp"], 6, 0),  # Temp Hourly forecast graph, blue
    (4, "Primary", _fv["FieldSteps"], 1, 0),  # Steps, green
    (5, "Primary", _fv["FieldHR"], 5, 0),  # HR, red
    # R2 (Secondary)
    (3, "Secondary", _fv["FieldWxHumidityPrecip"], 6, 0),  # Humidity + Rain, blue
    (4, "Secondary", _fv["FieldElevation"], 1, 0),  # Elevation, green
    (5, "Secondary", _fv["FieldStress"], 5, 0),  # Stress, red
    # R3 (Tertiary)
    (3, "Tertiary", _fv["FieldWxUVWind"], 6, 0),  # UV + Wind, blue
    (4, "Tertiary", _fv["FieldDistance"], 1, 0),  # Distance (daily), green
    (5, "Tertiary", _fv["FieldBodyBat"], 5, 0),  # Body Battery, red
    # R4 (Quaternary)
    (3, "Quaternary", _fv["FieldWxFcstDaily"], 6, 0),  # Temp Daily forecast, blue
    (4, "Quaternary", _fv["FieldFloors"], 1, 0),  # Floors, green
    (5, "Quaternary", _fv["FieldIntensityMin"], 5, 0),  # Intensity Minutes (weekly), red
    # R5 (Quinary)
    (3, "Quinary", _fv["FieldNone"], 6, 0),  # None, blue
    (4, "Quinary", _fv["FieldNone"], 1, 0),  # None, green
    (5, "Quinary", _fv["FieldNone"], 5, 0),  # None, red
    # R6 (Senary)
    (3, "Senary", _fv["FieldNone"], 6, 0),  # None, blue
    (4, "Senary", _fv["FieldNone"], 1, 0),  # None, green
    (5, "Senary", _fv["FieldNone"], 5, 0),  # None, red
]

SCREEN_COUNT = 3


def screen_line_slots(screen_idx):
    """(line_num, slot, field_default, label_color_default, value_color_default)
    rows for one screen. Screen 1 keeps today's curated defaults; screens 2/3
    start blank (all fields None, default gray label / white value)."""
    if screen_idx == 1:
        return LINE_SLOTS
    return [
        (ln, slot, _fv["FieldNone"], 8, 0)
        for ln, slot, _fd, _lc, _vc in LINE_SLOTS
    ]


# Graph mode options shared by all sensor graph fields
GRAPH_MODE_OPTIONS = [
    (0, "@Strings.GraphModeValue"),
    (1, "@Strings.GraphModeLineGraph"),
    (2, "@Strings.GraphModeBarGraph"),
    (3, "@Strings.GraphModeLineCurrent"),
    (4, "@Strings.GraphModeBarCurrent"),
    (5, "@Strings.GraphModeAreaGraph"),
    (6, "@Strings.GraphModeAreaCurrent"),
]

GRAPH_VALUE_MODE_OPTIONS = [
    (0, "@Strings.GraphValueCurrent"),
    (1, "@Strings.GraphValueAvg"),
    (2, "@Strings.GraphValueMaxMin"),
    (3, "@Strings.GraphValueMean"),
]

# Forecast graph mode reuses the sensor graph-mode encoding minus "value only"
# (forecasts always draw a graph): 1=line, 2=bar, 3=line+current, 4=bar+current,
# 5=area, 6=area+current.
FORECAST_GRAPH_MODE_OPTIONS = GRAPH_MODE_OPTIONS[1:]

# Two-option view mode for the daily forecast (graph vs graph + current).
FORECAST_VIEW_MODE_OPTIONS = [
    (1, "@Strings.ViewModeGraph"),
    (2, "@Strings.ViewModeGraphCurrent"),
]

# Hourly forecast graphs that share an identical control layout (view mode,
# value mode, graph type, hours-ahead time frame, color, width). Temp-hourly
# and the daily forecast differ in shape and stay as explicit blocks.
# (camelKey, StringPrefix, display, value_mode_default, graph_color_default)
HOURLY_FORECASTS = [
    ("wxForecastPrecip", "WxForecastPrecip", "Rain Hourly", 1, 6),
    ("wxForecastWind", "WxForecastWind", "Wind Hourly", 1, 6),
    ("wxForecastUv", "WxForecastUv", "UV Hourly", 2, 3),
    ("wxForecastHumidity", "WxForecastHumidity", "Humidity Hourly", 1, 2),
    ("wxForecastCloud", "WxForecastCloud", "Cloud Hourly", 1, 8),
]

# ---------------------------------------------------------------------------
# XML helpers
# ---------------------------------------------------------------------------


def ind(n):
    return "  " * n


def prop(pid, ptype, default):
    return f'  <property id="{pid}" type="{ptype}">{default}</property>'


def string(sid, text):
    return f'  <string id="{sid}">{text}</string>'


def setting_bool(prop_key, title_key, indent=1):
    i = ind(indent)
    return (
        f'{i}<setting propertyKey="@Properties.{prop_key}" title="@Strings.{title_key}">\n'
        f'{i}  <settingConfig type="boolean" />\n'
        f"{i}</setting>"
    )


def setting_list(prop_key, title_key, entries, indent=1):
    i = ind(indent)
    lines = [
        f'{i}<setting propertyKey="@Properties.{prop_key}" title="@Strings.{title_key}">',
        f'{i}  <settingConfig type="list">',
    ]
    for val, label in entries:
        lines.append(f'{i}    <listEntry value="{val}">{label}</listEntry>')
    lines.append(f"{i}  </settingConfig>")
    lines.append(f"{i}</setting>")
    return "\n".join(lines)


def color_entries(colors):
    return [(v, f"@Strings.{s}") for v, s, *_ in colors]


def field_entries(fields):
    return [(v, f"@Strings.{s}") for v, s, *_ in fields]


def width_entries():
    return [(v, f"@Strings.{s}") for v, s in GRAPH_WIDTH_OPTIONS]


def color_setting(prop_key, title_key, colors=COLORS_FULL, indent=1):
    return setting_list(prop_key, title_key, color_entries(colors), indent)


def field_setting(prop_key, title_key, fields=FIELDS_ALL, indent=1):
    return setting_list(prop_key, title_key, field_entries(fields), indent)


def section(title, *blocks):
    parts = [f"\n  <!-- {title} -->"]
    for b in blocks:
        parts.append(b)
    return "\n".join(parts)


def group(gid, title_key, *blocks):
    i = ind(1)
    lines = [f'{i}<group id="{gid}" title="@Strings.{title_key}">']
    for b in blocks:
        lines.append(b)
    lines.append(f"{i}</group>")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# source/FieldIds.mc
# ---------------------------------------------------------------------------


def gen_field_ids():
    lines = [
        "// GENERATED FILE - DO NOT EDIT.",
        "// Run `python scripts/generate_resources.py` to regenerate from",
        "// FIELD_CATEGORIES in scripts/generate_resources.py.",
        "",
        "// Graph cache key bit layout, used by _packGraphKey/_graphKeyHi/",
        f"// _graphKeyLo. The high slot and low slot each get "
        f"{CACHE_KEY_HI_SHIFT - CACHE_KEY_LO_SHIFT} bits (0-{CACHE_KEY_MASK}),",
        f"// periodMin gets the low {CACHE_KEY_LO_SHIFT} bits (0-"
        f"{CACHE_KEY_PERIOD_BUDGET - 1}). Field IDs currently span 1-"
        f"{FIELD_CATEGORY_WIDTH * len(FIELD_CATEGORIES)}.",
        f"const CACHE_KEY_HI_SHIFT = {CACHE_KEY_HI_SHIFT};",
        f"const CACHE_KEY_LO_SHIFT = {CACHE_KEY_LO_SHIFT};",
        f"const CACHE_KEY_MASK = 0x{CACHE_KEY_MASK:x};",
        f"const CACHE_KEY_PERIOD_MASK = 0x{CACHE_KEY_PERIOD_BUDGET - 1:x};",
        "",
        "const FIELD_NONE = 0;",
    ]
    for cat_idx, (cat_name, cat_fields) in enumerate(FIELD_CATEGORIES):
        base = cat_idx * FIELD_CATEGORY_WIDTH
        lines.append("")
        lines.append(
            f"// --- {cat_name} ({base + 1}-{base + FIELD_CATEGORY_WIDTH}) ---"
        )
        for suffix, string_id, _display in cat_fields:
            lines.append(f"const FIELD_{suffix} = {FIELD_VALUE[string_id]};")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# properties.xml
# ---------------------------------------------------------------------------


def gen_properties():
    lines = ["<properties>"]

    lines.append("\n  <!-- Appearance -->")
    lines.append(prop("fontChoice", "number", 0))
    lines.append(prop("scanlines", "number", 2))

    lines.append("\n  <!-- Display options -->")
    lines.append(prop("leftPadding", "number", 4))
    lines.append(prop("areaOpacity", "number", 64))
    lines.append(prop("areaShowLine", "boolean", "true"))
    lines.append(prop("showSeconds", "boolean", "false"))
    lines.append(prop("showYear", "boolean", "false"))
    lines.append(prop("dateFormat", "number", 0))
    lines.append(prop("watchCommandStyle", "number", 2))
    lines.append(prop("screen2Enabled", "boolean", "true"))
    lines.append(prop("screen3Enabled", "boolean", "true"))
    lines.append(prop("rotateInterval", "number", 10))
    lines.append(prop("rotateIntervalAlt", "number", 5))
    lines.append(prop("activeScreen", "number", 0))

    lines.append("\n  <!-- Time row (always visible) -->")
    lines.append(prop("line1LabelColor", "number", 8))
    lines.append(prop("line1ValueColor", "number", 0))

    lines.append("\n  <!-- Date row (always visible) -->")
    lines.append(prop("line2LabelColor", "number", 8))
    lines.append(prop("line2ValueColor", "number", 0))

    # 3 screens, each with its own label/value color per line (shared across
    # that line's rotation slots) and a field picker per slot.
    for screen_idx in range(1, SCREEN_COUNT + 1):
        for ln, slot, fd, lc, vc in screen_line_slots(screen_idx):
            pk = f"screen{screen_idx}_line{ln}"
            if slot == "Primary":
                lines.append(f"\n  <!-- Screen {screen_idx} - Line {ln} -->")
                lines.append(prop(f"{pk}Enabled", "boolean", "true"))
                lines.append(prop(f"{pk}LabelColor", "number", lc))
                lines.append(prop(f"{pk}ValueColor", "number", vc))
            lines.append(prop(f"{pk}{slot}", "number", fd))

    lines.append("\n  <!-- Steps -->")
    lines.append(prop("stepsShowBar", "boolean", "true"))
    lines.append(prop("stepsShowBarValue", "boolean", "true"))
    lines.append(prop("stepsBarColor", "number", 1))  # green
    lines.append(prop("stepsBarWidth", "number", 10))

    lines.append("\n  <!-- Floors -->")
    lines.append(prop("floorsShowBar", "boolean", "false"))
    lines.append(prop("floorsShowBarValue", "boolean", "true"))
    lines.append(prop("floorsBarColor", "number", 5))  # red
    lines.append(prop("floorsBarWidth", "number", 8))

    lines.append("\n  <!-- Intensity Minutes (Weekly) -->")
    lines.append(prop("intensityMinShowBar", "boolean", "true"))
    lines.append(prop("intensityMinShowBarValue", "boolean", "true"))
    lines.append(prop("intensityMinBarColor", "number", 5))  # red
    lines.append(prop("intensityMinBarWidth", "number", 8))

    lines.append("\n  <!-- Graph settings per supported field type -->")
    for key, skey, mode, std, sfd, tfd, gcd, scd, vmd in GRAPH_FIELDS:
        lines.append(f"\n  <!-- {skey} -->")
        lines.append(prop(f"{key}GraphMode", "number", mode))
        lines.append(prop(f"{key}GraphValueMode", "number", vmd))
        lines.append(prop(f"{key}SecondaryType", "number", std))
        lines.append(prop(f"{key}SecondaryField", "number", sfd))
        lines.append(prop(f"{key}TimeFrame", "number", tfd))
        lines.append(prop(f"{key}GraphColor", "number", gcd))
        lines.append(prop(f"{key}SecondaryColor", "number", scd))
        lines.append(prop(f"{key}GraphWidth", "number", 10))

    lines.append("\n  <!-- Weather Forecast -->")
    lines.append(prop("wxForecastGraphMode", "number", 4))  # bar + current
    lines.append(prop("wxForecastValueMode", "number", 0))  # current
    lines.append(prop("wxForecastTimeFrame", "number", 12))  # 12h
    lines.append(
        prop("wxForecastGraphColor", "number", 16)
    )  # GradTempTurbo (cold->hot)
    lines.append(prop("wxForecastGraphWidth", "number", 10))

    lines.append("\n  <!-- Day Forecast -->")
    lines.append(prop("wxForecastDailyViewMode", "number", 2))  # graph+value
    lines.append(prop("wxForecastDailyValueMode", "number", 2))  # max/min
    lines.append(prop("wxForecastDailyDays", "number", 5))  # 5 days
    lines.append(prop("wxForecastDailyGraphColor", "number", 16))  # GradTempTurbo
    lines.append(prop("wxForecastDailyGraphWidth", "number", 8))

    for row in HOURLY_FORECASTS:
        lines.append(hourly_forecast_props(*row))

    lines.append("\n  <!-- Debug -->")
    lines.append(prop("showVersion", "boolean", "false"))

    lines.append("\n</properties>")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# strings.xml
# ---------------------------------------------------------------------------


def gen_strings():
    lines = ["<strings>"]
    s = string

    lines.append(s("AppName", "TerminalWatchface"))

    lines.append("\n  <!-- Appearance -->")
    lines.append(s("AppearanceGroup", "Appearance"))
    lines.append(s("FontChoice", "Font"))
    lines.append(s("FontJetBrainsMono", "JetBrains Mono"))
    lines.append(s("FontSpaceMono", "Space Mono"))
    lines.append(s("FontFiraCodeMono", "Fira Code Mono"))
    lines.append(s("NBArchitekt", "NB Architekt"))
    lines.append(s("Scanlines", "Scanlines"))
    lines.append(s("ScanlinesOff", "Off"))
    lines.append(s("ScanlinesSubtle", "Subtle"))
    lines.append(s("ScanlinesMedium", "Medium"))
    lines.append(s("ScanlinesStrong", "Strong"))

    lines.append("\n  <!-- Display options -->")
    lines.append(s("LeftPadding", "Left Padding"))
    lines.append(s("AreaOpacity", "Area Graph: Opacity"))
    lines.append(s("AreaOpacity25", "25%"))
    lines.append(s("AreaOpacity50", "50%"))
    lines.append(s("AreaOpacity75", "75%"))
    lines.append(s("AreaOpacity100", "100%"))
    lines.append(s("AreaShowLine", "Area Graph: Show Line"))
    lines.append(s("ShowSeconds", "Show Seconds"))
    lines.append(s("ShowYear", "Show Year in Date"))
    lines.append(s("DateFormat", "Date Format"))
    lines.append(s("DateFormatDayMon", "Day Month (Mon, 1 Jan)"))
    lines.append(s("DateFormatYMD", "ISO (YYYY-MM-DD)"))
    lines.append(s("DateFormatDMY", "DD-MM-YYYY"))
    lines.append(s("DateFormatMDY", "MM-DD-YYYY"))
    lines.append(s("DateFormatDayNum", "Day Name + Number (Mon 14)"))
    lines.append(s("DateFormatDMon", "Date + Month (14 Jun)"))
    lines.append(s("ScreenGroup", "Screens"))
    lines.append(s("Screen2Enabled", "Screen 2: Enabled"))
    lines.append(s("Screen3Enabled", "Screen 3: Enabled"))
    lines.append(s("RotationGroup", "Rotation"))
    lines.append(s("RotateInterval", "Rotation: Main Duration"))
    lines.append(s("RotateIntervalAlt", "Rotation: Alt Duration"))
    lines.append(s("ActiveScreen", "Active Screen"))
    lines.append(s("Screen1", "Screen 1"))
    lines.append(s("Screen2", "Screen 2"))
    lines.append(s("Screen3", "Screen 3"))

    lines.append(s("WatchCommandStyle", "Command Style"))
    lines.append(s("WatchCommandWindows", "Windows (watch.bat)"))
    lines.append(s("WatchCommandLinux", "Linux (watch.sh)"))
    lines.append(s("WatchCommandBare", "Bare (watch)"))

    lines.append("\n  <!-- Fixed rows -->")
    lines.append(s("TimeRowGroup", "Time Row"))
    lines.append(s("Line1LabelColor", "Time: Label Color"))
    lines.append(s("Line1ValueColor", "Time: Value Color"))
    lines.append(s("DateRowGroup", "Date Row"))
    lines.append(s("Line2LabelColor", "Date: Label Color"))
    lines.append(s("Line2ValueColor", "Date: Value Color"))

    _slot_r = {
        "Primary": " (R1)",
        "Secondary": " (R2)",
        "Tertiary": " (R3)",
        "Quaternary": " (R4)",
        "Quinary": " (R5)",
        "Senary": " (R6)",
    }
    lines.append(
        "\n  <!-- Screens: configurable lines (R1-R6 = rotation slots 1 to 6) -->"
    )
    for screen_idx in range(1, SCREEN_COUNT + 1):
        lines.append(
            s(f"Screen{screen_idx}ConfigGroup", f"Screen {screen_idx} Configuration")
        )
        for ln, slot, *_ in screen_line_slots(screen_idx):
            pk = f"Screen{screen_idx}Line{ln}"
            ptitle = f"Screen {screen_idx} - Line {ln}"
            if slot == "Primary":
                lines.append(s(f"{pk}Enabled", f"{ptitle}: Enabled"))
                lines.append(s(f"{pk}LabelColor", f"{ptitle}: Label Color"))
                lines.append(s(f"{pk}ValueColor", f"{ptitle}: Value Color"))
            lines.append(s(f"{pk}{slot}", f"{ptitle}: Field{_slot_r[slot]}"))

    lines.append("\n  <!-- Shared: color options -->")
    for _v, sid, text in COLORS_FULL:
        lines.append(s(sid, text))

    lines.append("\n  <!-- Shared: field options -->")
    for _v, sid, text in FIELDS_ALL:
        lines.append(s(sid, text))

    lines.append("\n  <!-- Shared: graph mode options (sensor graphs) -->")
    lines.append(s("GraphModeValue", "Value only"))
    lines.append(s("GraphModeLineGraph", "Line graph"))
    lines.append(s("GraphModeBarGraph", "Bar graph"))
    lines.append(s("GraphModeLineCurrent", "Line + current value"))
    lines.append(s("GraphModeBarCurrent", "Bar + current value"))
    lines.append(s("GraphModeAreaGraph", "Area graph"))
    lines.append(s("GraphModeAreaCurrent", "Area + current value"))

    lines.append("\n  <!-- Shared: graph value mode options -->")
    lines.append(s("GraphValueCurrent", "Current value"))
    lines.append(s("GraphValueAvg", "Average"))
    lines.append(s("GraphValueMaxMin", "Max / Min"))
    lines.append(s("GraphValueMean", "Mean (midpoint)"))

    lines.append("\n  <!-- Shared: forecast view mode options (daily) -->")
    lines.append(s("ViewModeGraph", "Graph"))
    lines.append(s("ViewModeGraphCurrent", "Graph + Current"))

    lines.append("\n  <!-- Shared: graph width options -->")
    lines.append(s("GraphWidth6", "6 chars"))
    lines.append(s("GraphWidth8", "8 chars"))
    lines.append(s("GraphWidth10", "10 chars (default)"))
    lines.append(s("GraphWidth12", "12 chars"))
    lines.append(s("GraphWidth14", "14 chars"))
    lines.append(s("GraphWidth16", "16 chars"))

    lines.append("\n  <!-- Steps -->")
    lines.append(s("StepsGroup", BAR_CONFIG_PREFIX + "Steps"))
    lines.append(s("StepsShowBar", "Steps: Show Progress Bar"))
    lines.append(s("StepsShowBarValue", "Steps: Show Value in Bar"))
    lines.append(s("StepsBarColor", "Steps: Bar Color"))
    lines.append(s("StepsBarWidth", "Steps: Bar Width"))

    lines.append("\n  <!-- Floors -->")
    lines.append(s("FloorsGroup", BAR_CONFIG_PREFIX + "Floors"))
    lines.append(s("FloorsShowBar", "Floors: Show Progress Bar"))
    lines.append(s("FloorsShowBarValue", "Floors: Show Value in Bar"))
    lines.append(s("FloorsBarColor", "Floors: Bar Color"))
    lines.append(s("FloorsBarWidth", "Floors: Bar Width"))

    lines.append("\n  <!-- Intensity Minutes (Weekly) -->")
    lines.append(s("IntensityMinGroup", BAR_CONFIG_PREFIX + "Intensity Minutes (Weekly)"))
    lines.append(s("IntensityMinShowBar", "Intensity Min: Show Progress Bar"))
    lines.append(s("IntensityMinShowBarValue", "Intensity Min: Show Value in Bar"))
    lines.append(s("IntensityMinBarColor", "Intensity Min: Bar Color"))
    lines.append(s("IntensityMinBarWidth", "Intensity Min: Bar Width"))

    lines.append("\n  <!-- Shared: secondary graph type options -->")
    lines.append(s("SecTypeNone", "None (hidden)"))
    lines.append(s("SecTypeLine", "Line"))
    lines.append(s("SecTypeBar", "Bar"))

    lines.append("\n  <!-- Shared: graph time frame options -->")
    lines.append(s("TimeFrame15m", "15 minutes"))
    lines.append(s("TimeFrame30m", "30 minutes"))
    lines.append(s("TimeFrame1h", "1 hour"))
    lines.append(s("TimeFrame2h", "2 hours"))
    lines.append(s("TimeFrame4h", "4 hours"))
    lines.append(s("TimeFrame8h", "8 hours"))
    lines.append(s("TimeFrame12h", "12 hours"))
    lines.append(s("TimeFrame24h", "24 hours"))

    # Graph settings strings — one block per graph field
    for key, skey, *_ in GRAPH_FIELDS:
        display = GRAPH_DISPLAY_NAMES[key]
        lines.append(f"\n  <!-- Graph settings: {display} -->")
        lines.append(s(f"{skey}GraphGroup", f"{GRAPH_CONFIG_PREFIX}{display}"))
        lines.append(s(f"{skey}GraphMode", f"{display}: Graph Mode"))
        lines.append(s(f"{skey}GraphValueMode", f"{display}: Graph Value Mode"))
        lines.append(s(f"{skey}SecondaryType", f"{display}: 2nd Graph Type"))
        lines.append(s(f"{skey}SecondaryField", f"{display}: 2nd Graph Field"))
        lines.append(s(f"{skey}TimeFrame", f"{display}: Time Frame"))
        lines.append(s(f"{skey}GraphColor", f"{display}: Graph Color"))
        lines.append(s(f"{skey}SecondaryColor", f"{display}: 2nd Graph Color"))
        lines.append(s(f"{skey}GraphWidth", f"{display}: Graph Width"))

    lines.append("\n  <!-- Graph settings: Temp Hourly Forecast -->")
    lines.append(s("WxForecastGroup", GRAPH_CONFIG_PREFIX + "Temp Hourly Forecast"))
    lines.append(s("WxForecastGraphMode", "Temp Hourly: Graph Mode"))
    lines.append(s("WxForecastValueMode", "Temp Hourly: Value Mode"))
    lines.append(s("WxForecastTimeFrame", "Temp Hourly: Time Frame"))
    lines.append(s("WxForecastGraphColor", "Temp Hourly: Graph Color"))
    lines.append(s("WxForecastGraphWidth", "Temp Hourly: Graph Width"))
    lines.append(s("TimeFrameForecast3h", "3 hours ahead"))
    lines.append(s("TimeFrameForecast6h", "6 hours ahead"))
    lines.append(s("TimeFrameForecast12h", "12 hours ahead"))
    lines.append(s("TimeFrameForecast24h", "24 hours ahead"))

    lines.append("\n  <!-- Graph settings: Temp Daily Forecast -->")
    lines.append(s("WxForecastDailyGroup", GRAPH_CONFIG_PREFIX + "Temp Daily Forecast"))
    lines.append(s("WxForecastDailyViewMode", "Temp Daily: View Mode"))
    lines.append(s("WxForecastDailyValueMode", "Temp Daily: Value Mode"))
    lines.append(s("WxForecastDailyDays", "Temp Daily: Days"))
    lines.append(s("WxForecastDailyGraphColor", "Temp Daily: Graph Color"))
    lines.append(s("WxForecastDailyGraphWidth", "Temp Daily: Graph Width"))
    lines.append(s("TimeFrameForecastDays3", "3 days"))
    lines.append(s("TimeFrameForecastDays5", "5 days"))
    lines.append(s("TimeFrameForecastDays7", "7 days"))

    for row in HOURLY_FORECASTS:
        lines.append(hourly_forecast_strings(*row))

    lines.append("\n  <!-- Debug -->")
    lines.append(s("DebugGroup", "Debug"))
    lines.append(s("ShowVersion", "Show App Version (testing)"))

    lines.append("\n</strings>")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# settings.xml
# ---------------------------------------------------------------------------


def width_setting(prop_key, title_key, indent=1):
    return setting_list(prop_key, title_key, width_entries(), indent)


def graph_section(key, skey, mode, std, sfd, tfd, gcd, scd, vmd, indent=1):
    blocks = []

    blocks.append(
        setting_list(f"{key}GraphMode", f"{skey}GraphMode", GRAPH_MODE_OPTIONS, indent)
    )
    blocks.append(
        setting_list(
            f"{key}GraphValueMode",
            f"{skey}GraphValueMode",
            GRAPH_VALUE_MODE_OPTIONS,
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{key}SecondaryType",
            f"{skey}SecondaryType",
            [
                (0, "@Strings.SecTypeNone"),
                (1, "@Strings.SecTypeLine"),
                (2, "@Strings.SecTypeBar"),
            ],
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{key}SecondaryField",
            f"{skey}SecondaryField",
            [(v, f"@Strings.{s}") for v, s in GRAPH_SEC_FIELDS],
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{key}TimeFrame",
            f"{skey}TimeFrame",
            [(v, f"@Strings.{s}") for v, s in GRAPH_TIME_FRAMES],
            indent,
        )
    )
    blocks.append(color_setting(f"{key}GraphColor", f"{skey}GraphColor", indent=indent))
    blocks.append(
        color_setting(f"{key}SecondaryColor", f"{skey}SecondaryColor", indent=indent)
    )
    blocks.append(width_setting(f"{key}GraphWidth", f"{skey}GraphWidth", indent))

    return "\n".join(blocks)


def forecast_tf_entries():
    return [(v, f"@Strings.{sid}") for v, sid in FORECAST_TIME_FRAMES]


# Per-generator block builders for the shape-identical hourly forecasts. value
# mode and color vary per field; the section comment uses the first display
# word (e.g. "Rain Forecast") for properties/settings.
def hourly_forecast_props(key, skey, display, vmode, color):
    return "\n".join(
        [
            f"\n  <!-- {display.split()[0]} Forecast -->",
            prop(f"{key}GraphMode", "number", 4),  # bar + current
            prop(f"{key}ValueMode", "number", vmode),
            prop(f"{key}TimeFrame", "number", 12),
            prop(f"{key}GraphColor", "number", color),
            prop(f"{key}GraphWidth", "number", 10),
        ]
    )


def hourly_forecast_strings(key, skey, display, vmode, color):
    return "\n".join(
        [
            f"\n  <!-- Graph settings: {display} Forecast -->",
            string(f"{skey}Group", f"{GRAPH_CONFIG_PREFIX}{display.split()[0]} Forecast"),
            string(f"{skey}GraphMode", f"{display}: Graph Mode"),
            string(f"{skey}ValueMode", f"{display}: Value Mode"),
            string(f"{skey}TimeFrame", f"{display}: Hours Ahead"),
            string(f"{skey}GraphColor", f"{display}: Graph Color"),
            string(f"{skey}GraphWidth", f"{display}: Graph Width"),
        ]
    )


def hourly_forecast_settings(key, skey, display, vmode, color, indent=1):
    return "\n".join(
        [
            setting_list(
                f"{key}GraphMode",
                f"{skey}GraphMode",
                FORECAST_GRAPH_MODE_OPTIONS,
                indent,
            ),
            setting_list(
                f"{key}ValueMode",
                f"{skey}ValueMode",
                GRAPH_VALUE_MODE_OPTIONS,
                indent,
            ),
            setting_list(
                f"{key}TimeFrame", f"{skey}TimeFrame", forecast_tf_entries(), indent
            ),
            color_setting(f"{key}GraphColor", f"{skey}GraphColor", indent=indent),
            width_setting(f"{key}GraphWidth", f"{skey}GraphWidth", indent),
        ]
    )


def gen_settings():
    parts = ["<settings>"]

    # Appearance
    parts.append(
        group(
            "appearance",
            "AppearanceGroup",
            setting_list(
                "fontChoice",
                "FontChoice",
                [
                    (0, "@Strings.FontJetBrainsMono"),
                    (1, "@Strings.FontSpaceMono"),
                    (2, "@Strings.FontFiraCodeMono"),
                    (3, "@Strings.NBArchitekt"),
                ],
                indent=2,
            ),
            setting_list(
                "scanlines",
                "Scanlines",
                [
                    (0, "@Strings.ScanlinesOff"),
                    (1, "@Strings.ScanlinesSubtle"),
                    (2, "@Strings.ScanlinesMedium"),
                    (3, "@Strings.ScanlinesStrong"),
                ],
                indent=2,
            ),
            setting_list(
                "watchCommandStyle",
                "WatchCommandStyle",
                [
                    (0, "@Strings.WatchCommandWindows"),
                    (1, "@Strings.WatchCommandLinux"),
                    (2, "@Strings.WatchCommandBare"),
                ],
                indent=2,
            ),
            setting_list(
                "leftPadding",
                "LeftPadding",
                [(i, str(i)) for i in range(9)],
                indent=2,
            ),
            setting_list(
                "areaOpacity",
                "AreaOpacity",
                [
                    (0x40, "@Strings.AreaOpacity25"),
                    (0x80, "@Strings.AreaOpacity50"),
                    (0xC0, "@Strings.AreaOpacity75"),
                    (0xFF, "@Strings.AreaOpacity100"),
                ],
                indent=2,
            ),
            setting_bool("areaShowLine", "AreaShowLine", indent=2),
        )
    )

    # Time row
    parts.append(
        group(
            "timeRow",
            "TimeRowGroup",
            setting_bool("showSeconds", "ShowSeconds", indent=2),
            color_setting("line1LabelColor", "Line1LabelColor", COLORS_TEXT, indent=2),
            color_setting("line1ValueColor", "Line1ValueColor", COLORS_TEXT, indent=2),
        )
    )

    # Date row
    parts.append(
        group(
            "dateRow",
            "DateRowGroup",
            setting_bool("showYear", "ShowYear", indent=2),
            setting_list(
                "dateFormat",
                "DateFormat",
                [
                    (0, "@Strings.DateFormatDayMon"),
                    (1, "@Strings.DateFormatYMD"),
                    (2, "@Strings.DateFormatDMY"),
                    (3, "@Strings.DateFormatMDY"),
                    (4, "@Strings.DateFormatDayNum"),
                    (5, "@Strings.DateFormatDMon"),
                ],
                indent=2,
            ),
            color_setting("line2LabelColor", "Line2LabelColor", COLORS_TEXT, indent=2),
            color_setting("line2ValueColor", "Line2ValueColor", COLORS_TEXT, indent=2),
        )
    )

    # Screens: one master toggle per alternate screen (2/3), independent of
    # the per-line toggles below - a quick way to turn a whole screen off.
    parts.append(
        group(
            "screens",
            "ScreenGroup",
            setting_bool("screen2Enabled", "Screen2Enabled", indent=2),
            setting_bool("screen3Enabled", "Screen3Enabled", indent=2),
        )
    )

    # Rotation + active screen - moved above the screen/field settings they
    # control, so the phone app shows "what/when to rotate" before "what's in
    # each screen".
    rotate_options = [
        (0, "Same as main"),
        (3, "3 seconds"),
        (5, "5 seconds"),
        (10, "10 seconds"),
        (15, "15 seconds"),
        (30, "30 seconds"),
        (60, "1 minute"),
    ]
    parts.append(
        group(
            "rotation",
            "RotationGroup",
            setting_list(
                "rotateInterval", "RotateInterval", rotate_options[1:], indent=2
            ),
            setting_list(
                "rotateIntervalAlt", "RotateIntervalAlt", rotate_options, indent=2
            ),
            setting_list(
                "activeScreen",
                "ActiveScreen",
                [
                    (0, "@Strings.Screen1"),
                    (1, "@Strings.Screen2"),
                    (2, "@Strings.Screen3"),
                ],
                indent=2,
            ),
        )
    )

    # Screens: one group per screen with all 3 lines' toggle/colors and field
    # rotations together, instead of a separate group per line - fewer
    # submenus in the Garmin Connect IQ app.
    for screen_idx in range(1, SCREEN_COUNT + 1):
        line_blocks = []
        for ln in (3, 4, 5):
            rows = [r for r in screen_line_slots(screen_idx) if r[0] == ln]
            pk = f"screen{screen_idx}_line{ln}"
            sk = f"Screen{screen_idx}Line{ln}"
            line_blocks.append(setting_bool(f"{pk}Enabled", f"{sk}Enabled", indent=2))
            line_blocks.append(
                color_setting(f"{pk}LabelColor", f"{sk}LabelColor", COLORS_TEXT, indent=2)
            )
            line_blocks.append(
                color_setting(f"{pk}ValueColor", f"{sk}ValueColor", COLORS_TEXT, indent=2)
            )
            line_blocks.extend(
                field_setting(f"{pk}{slot}", f"{sk}{slot}", indent=2)
                for _ln, slot, _fd, _lc, _vc in rows
            )
        parts.append(
            group(f"screen{screen_idx}", f"Screen{screen_idx}ConfigGroup", *line_blocks)
        )

    # Steps
    parts.append(
        group(
            "steps",
            "StepsGroup",
            setting_bool("stepsShowBar", "StepsShowBar", indent=2),
            setting_bool("stepsShowBarValue", "StepsShowBarValue", indent=2),
            color_setting("stepsBarColor", "StepsBarColor", COLORS_TEXT, indent=2),
            width_setting("stepsBarWidth", "StepsBarWidth", indent=2),
        )
    )

    # Floors
    parts.append(
        group(
            "floors",
            "FloorsGroup",
            setting_bool("floorsShowBar", "FloorsShowBar", indent=2),
            setting_bool("floorsShowBarValue", "FloorsShowBarValue", indent=2),
            color_setting("floorsBarColor", "FloorsBarColor", COLORS_TEXT, indent=2),
            width_setting("floorsBarWidth", "FloorsBarWidth", indent=2),
        )
    )

    # Intensity Minutes
    parts.append(
        group(
            "intensityMin",
            "IntensityMinGroup",
            setting_bool("intensityMinShowBar", "IntensityMinShowBar", indent=2),
            setting_bool(
                "intensityMinShowBarValue", "IntensityMinShowBarValue", indent=2
            ),
            color_setting(
                "intensityMinBarColor", "IntensityMinBarColor", COLORS_TEXT, indent=2
            ),
            width_setting("intensityMinBarWidth", "IntensityMinBarWidth", indent=2),
        )
    )

    # Graph fields - one group per sensor graph
    for row in GRAPH_FIELDS:
        key, skey = row[0], row[1]
        parts.append(
            group(f"graph_{key}", f"{skey}GraphGroup", graph_section(*row, indent=2))
        )

    # Weather Forecast (temp hourly)
    parts.append(
        group(
            "wxForecast",
            "WxForecastGroup",
            setting_list(
                "wxForecastGraphMode",
                "WxForecastGraphMode",
                FORECAST_GRAPH_MODE_OPTIONS,
                indent=2,
            ),
            setting_list(
                "wxForecastValueMode",
                "WxForecastValueMode",
                GRAPH_VALUE_MODE_OPTIONS,
                indent=2,
            ),
            setting_list(
                "wxForecastTimeFrame",
                "WxForecastTimeFrame",
                forecast_tf_entries(),
                indent=2,
            ),
            color_setting("wxForecastGraphColor", "WxForecastGraphColor", indent=2),
            width_setting("wxForecastGraphWidth", "WxForecastGraphWidth", indent=2),
        )
    )

    # Day Forecast
    parts.append(
        group(
            "wxForecastDaily",
            "WxForecastDailyGroup",
            setting_list(
                "wxForecastDailyViewMode",
                "WxForecastDailyViewMode",
                FORECAST_VIEW_MODE_OPTIONS,
                indent=2,
            ),
            setting_list(
                "wxForecastDailyValueMode",
                "WxForecastDailyValueMode",
                GRAPH_VALUE_MODE_OPTIONS,
                indent=2,
            ),
            setting_list(
                "wxForecastDailyDays",
                "WxForecastDailyDays",
                [
                    (3, "@Strings.TimeFrameForecastDays3"),
                    (5, "@Strings.TimeFrameForecastDays5"),
                    (7, "@Strings.TimeFrameForecastDays7"),
                ],
                indent=2,
            ),
            color_setting(
                "wxForecastDailyGraphColor", "WxForecastDailyGraphColor", indent=2
            ),
            width_setting(
                "wxForecastDailyGraphWidth", "WxForecastDailyGraphWidth", indent=2
            ),
        )
    )

    # Hourly forecasts (precip/wind/UV/humidity/cloud) share an identical
    # layout - one group each
    for row in HOURLY_FORECASTS:
        key, skey = row[0], row[1]
        parts.append(
            group(key, f"{skey}Group", hourly_forecast_settings(*row, indent=2))
        )

    # Debug
    parts.append(
        group(
            "debug", "DebugGroup", setting_bool("showVersion", "ShowVersion", indent=2)
        )
    )

    parts.append("\n</settings>")
    return "\n".join(parts) + "\n"


# ---------------------------------------------------------------------------
# Write output
# ---------------------------------------------------------------------------


def write(path, content):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)
    rel = os.path.relpath(path, ROOT)
    print(f"  wrote {rel}")


if __name__ == "__main__":
    print("Generating resources...")
    write(OUT_FIELD_IDS, gen_field_ids())
    write(OUT_PROPERTIES, gen_properties())
    write(OUT_STRINGS, gen_strings())
    write(OUT_SETTINGS, gen_settings())
    print("Done.")
