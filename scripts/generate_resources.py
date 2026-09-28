#!/usr/bin/env python3
import os
from typing import NamedTuple, Optional

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_PROPERTIES = os.path.join(ROOT, "resources", "properties.xml")
OUT_STRINGS = os.path.join(ROOT, "resources", "strings", "strings.xml")
OUT_SETTINGS = os.path.join(ROOT, "resources", "settings.xml")
OUT_FIELD_IDS = os.path.join(ROOT, "source", "FieldIds.mc")

# Solid colors (0-9) are listed in hue-wheel order, not value order.
COLORS_FULL = [
    (0, "ColorWhite", "White"),
    (5, "ColorRed", "Red"),
    (4, "ColorOrange", "Orange"),
    (3, "ColorYellow", "Yellow"),
    (1, "ColorGreen", "Green"),
    (2, "ColorCyan", "Cyan"),
    (6, "ColorBlue", "Blue"),
    (9, "ColorPurple", "Purple"),
    (7, "ColorMagenta", "Magenta"),
    (8, "ColorLightGrey", "Light Grey"),
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

COLORS_TEXT = COLORS_FULL[:10]

FIELD_CATEGORY_WIDTH = 50

CACHE_KEY_LO_SHIFT = 11
CACHE_KEY_HI_SHIFT = 21
CACHE_KEY_MASK = (1 << (CACHE_KEY_HI_SHIFT - CACHE_KEY_LO_SHIFT)) - 1
CACHE_KEY_FIELD_BUDGET = CACHE_KEY_MASK + 1
CACHE_KEY_PERIOD_BUDGET = 1 << CACHE_KEY_LO_SHIFT

BAR_CONFIG_PREFIX = "Bar Config - "
GRAPH_CONFIG_PREFIX = "Graph Config - "

FIELD_CATEGORIES = [
    (
        "Fitness / Health",
        [
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
        ],
    ),
    (
        "Calories / Distance / Speed",
        [
            ("CALORIES", "FieldCalories", "Calories (Daily)"),
            ("DISTANCE", "FieldDistance", "Distance (Daily)"),
            ("ACTIVE_MIN_DAY", "FieldActiveMinDay", "Active Minutes (Daily)"),
            ("INTENSITY_MIN", "FieldIntensityMin", "Intensity Minutes (Weekly)"),
        ],
    ),
    (
        "Altitude / Pressure",
        [
            ("ALTITUDE", "FieldAltitude", "Altitude"),
            ("ELEVATION", "FieldElevation", "Elevation (Baro)"),
            ("PRESSURE", "FieldPressure", "Pressure"),
        ],
    ),
    (
        "Race Predictors",
        [
            ("RACE_5K", "FieldRace5k", "Race Predictor: 5K"),
            ("RACE_10K", "FieldRace10k", "Race Predictor: 10K"),
            ("RACE_HALF", "FieldRaceHalf", "Race Predictor: Half Marathon"),
            ("RACE_MARATHON", "FieldRaceMarathon", "Race Predictor: Marathon"),
            ("RACE_PACE_5K", "FieldRacePace5k", "Race Pace: 5K"),
            ("RACE_PACE_10K", "FieldRacePace10k", "Race Pace: 10K"),
            ("RACE_PACE_HALF", "FieldRacePaceHalf", "Race Pace: Half Marathon"),
            ("RACE_PACE_MARATHON", "FieldRacePaceMarathon", "Race Pace: Marathon"),
        ],
    ),
    (
        "Ascent / Descent",
        [
            ("CLIMB_DAY", "FieldClimbDay", "Climb (Daily)"),
            ("DESCENT_DAY", "FieldDescentDay", "Descent (Daily)"),
            ("CLIMB_DESCEND_DAY", "FieldClimbDescendDay", "Climb + Descent (Daily)"),
        ],
    ),
    (
        "Weekly",
        [
            ("WEEKLY_RUN", "FieldWeeklyRun", "Distance (Weekly Run)"),
            ("WEEKLY_BIKE", "FieldWeeklyBike", "Distance (Weekly Bike)"),
            (
                "WEEKLY_DISTANCES",
                "FieldWeeklyDistances",
                "Distance (Weekly Run + Bike)",
            ),
        ],
    ),
    (
        "Time / Calendar",
        [
            ("SUNRISE", "FieldSunrise", "Sunrise"),
            ("SUNSET", "FieldSunset", "Sunset"),
            ("SUNRISE_SUNSET", "FieldSunriseSunset", "Sunrise + Sunset"),
            ("CALENDAR", "FieldCalendar", "Calendar Event"),
            ("SLEEP_TIME", "FieldSleepTime", "Bedtime"),
            ("WAKE_TIME", "FieldWakeTime", "Wake Time"),
            ("SLEEP_SCHEDULE", "FieldSleepSchedule", "Sleep Schedule (Bed + Wake)"),
        ],
    ),
    (
        "Weather: current",
        [
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
        ],
    ),
    (
        # Ordered/named by each field's rank in "Weather: current" above.
        "Weather: combos",
        [
            ("WX_TEMP_COND", "FieldWxTempCond", "Weather: Temp + Condition"),
            ("WX_TEMP_PRECIP", "FieldWxTempPrecip", "Weather: Temp + Rain"),
            ("WX_TEMP_WIND", "FieldWxTempWind", "Weather: Temp + Wind"),
            ("WX_TEMP_UV", "FieldWxTempUV", "Weather: Temp + UV"),
            ("WX_TEMP_HUMIDITY", "FieldWxTempHumidity", "Weather: Temp + Humidity"),
            ("WX_TEMP_HIGH_LOW", "FieldWxTempHighLow", "Weather: Temp + High/Low"),
            ("WX_COND_PRECIP", "FieldWxCondPrecip", "Weather: Condition + Rain"),
            ("WX_WIND_PRECIP", "FieldWxWindPrecip", "Weather: Rain + Wind"),
            # UV stays first - _drawUvRow always renders it first regardless of naming.
            ("WX_UV_PRECIP", "FieldWxUVPrecip", "Weather: UV + Rain"),
            ("WX_CLOUD_PRECIP", "FieldWxCloudPrecip", "Weather: Rain + Cloud"),
            ("WX_HUMIDITY_PRECIP", "FieldWxHumidityPrecip", "Weather: Rain + Humidity"),
            ("WX_UV_WIND", "FieldWxUVWind", "Weather: UV + Wind"),
            ("WX_HUMIDITY_DEW", "FieldWxHumidityDew", "Weather: Humidity + Dew Point"),
            ("WX_COND_CLOUD", "FieldWxCondCloud", "Weather: Condition + Cloud"),
        ],
    ),
    (
        "Weather: forecast",
        [
            ("WX_FCST_TEMP", "FieldWxFcstTemp", "Forecast: Temp (Hourly)"),
            ("WX_FCST_DAILY", "FieldWxFcstDaily", "Forecast: Temp (Daily)"),
            ("WX_FCST_PRECIP", "FieldWxFcstPrecip", "Forecast: Rain (Hourly)"),
            ("WX_FCST_WIND", "FieldWxFcstWind", "Forecast: Wind (Hourly)"),
            ("WX_FCST_UV", "FieldWxFcstUv", "Forecast: UV (Hourly)"),
            ("WX_FCST_CLOUD", "FieldWxFcstCloud", "Forecast: Cloud (Hourly)"),
            ("WX_FCST_HUMIDITY", "FieldWxFcstHumidity", "Forecast: Humidity (Hourly)"),
        ],
    ),
    (
        "Weather: forecast conditions",
        [
            ("WX_FCST_COND_1D", "FieldWxFcstCond1d", "Forecast: Condition (+1 day)"),
            ("WX_FCST_COND_2D", "FieldWxFcstCond2d", "Forecast: Condition (+2 days)"),
            ("WX_FCST_COND_3D", "FieldWxFcstCond3d", "Forecast: Condition (+3 days)"),
            ("WX_COND_FCST_1D", "FieldWxCondFcst1d", "Weather: Condition + Tomorrow"),
            ("WX_FCST_COND_12D", "FieldWxFcstCond12d", "Forecast: +1d + +2d Condition"),
        ],
    ),
    (
        "Weather: station",
        [
            ("WX_SEA_PRESS", "FieldWxSeaPress", "Weather: Sea Level Pressure"),
            ("WX_OBS_TIME", "FieldWxObsTime", "Weather: Data Age"),
        ],
    ),
    (
        "Watch / System",
        [
            ("NOTIFICATIONS", "FieldNotifications", "Notifications"),
            ("SOLAR", "FieldSolar", "Solar Input"),
            ("SOLAR_BATTERY", "FieldSolarBattery", "Solar Input + Watch Battery"),
        ],
    ),
]


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


class GraphField(NamedTuple):
    key: str
    skey: str
    display: str
    mode: int  # 0=value 1=line 2=bar 3=line+cur 4=bar+cur 5=area 6=area+cur
    sec_type: int
    sec_field: int  # indexes GRAPH_SEC_FIELDS
    time_frame: int
    graph_color: int
    sec_color: int
    value_mode: int
    # Caps the TimeFrame option list to the field's real on-device SensorHistory buffer (minutes); None = no cap.
    max_time_frame: Optional[int] = None


GRAPH_FIELDS = [
    GraphField("hr", "HR", "Heart Rate", 3, 0, 2, 60, 5, 0, 0, 360),
    GraphField("spo2", "SpO2", "Blood O2", 6, 0, 0, 60, 6, 0, 2),
    GraphField("bodyBat", "BodyBat", "Body Battery", 6, 0, 3, 240, 11, 0, 0),
    GraphField("stress", "Stress", "Stress", 3, 0, 0, 120, 10, 0, 1),
    GraphField("tempWrist", "TempWrist", "Wrist Temp", 3, 0, 0, 60, 16, 0, 1, 360),
    GraphField("elevation", "Elevation", "Elevation", 6, 0, 6, 360, 1, 0, 0, 360),
    GraphField("pressure", "Pressure", "Pressure", 3, 0, 5, 120, 2, 0, 1, 360),
]


class BarField(NamedTuple):
    key: str
    group_title: str
    label: str
    show_bar_default: bool
    color_default: int
    width_default: int
    # goal_default None means the goal comes from ActivityMonitor.Info, not a user-set property.
    goal_default: Optional[int]
    goal_min: Optional[int]
    goal_max: Optional[int]
    goal_label_suffix: Optional[str]


BAR_FIELDS = [
    BarField("steps", "Steps", "Steps", True, 1, 10, None, None, None, None),
    BarField("floors", "Floors", "Floors", False, 5, 8, None, None, None, None),
    BarField(
        "calories", "Calories (Daily)", "Calories", False, 4, 10, 2000, 500, 9000, None
    ),
    BarField(
        "distance",
        "Distance (Daily)",
        "Distance",
        False,
        6,
        10,
        5,
        1,
        200,
        " (km or mi - matches your device's distance unit)",
    ),
    BarField(
        "activeMinDay",
        "Active Minutes (Daily)",
        "Active Min",
        False,
        9,
        10,
        30,
        5,
        480,
        None,
    ),
    BarField(
        "intensityMin",
        "Intensity Minutes (Weekly)",
        "Intensity Min",
        True,
        5,
        8,
        None,
        None,
        None,
        None,
    ),
]

# Positional: the index is the SecondaryField property value, mirrored by the view's GRAPH_SEC_FIELDS.
GRAPH_SEC_FIELDS = [
    "FieldHR",
    "FieldSpO2",
    "FieldBodyBat",
    "FieldStress",
    "FieldWristTemp",
    "FieldElevation",
    "FieldPressure",
]

GRAPH_TIME_FRAMES = [
    (15, "TimeFrame15m", "15 minutes"),
    (30, "TimeFrame30m", "30 minutes"),
    (60, "TimeFrame1h", "1 hour"),
    (120, "TimeFrame2h", "2 hours"),
    (240, "TimeFrame4h", "4 hours"),
    (360, "TimeFrame6h", "6 hours"),
    (480, "TimeFrame8h", "8 hours"),
    (720, "TimeFrame12h", "12 hours"),
    (1440, "TimeFrame24h", "24 hours"),
]

FORECAST_TIME_FRAMES = [
    (3, "TimeFrameForecast3h", "3 hours ahead"),
    (6, "TimeFrameForecast6h", "6 hours ahead"),
    (12, "TimeFrameForecast12h", "12 hours ahead"),
    (24, "TimeFrameForecast24h", "24 hours ahead"),
]

FORECAST_DAY_OPTIONS = [
    (3, "TimeFrameForecastDays3", "3 days"),
    (5, "TimeFrameForecastDays5", "5 days"),
    (7, "TimeFrameForecastDays7", "7 days"),
]

GRAPH_WIDTH_OPTIONS = [
    (6, "GraphWidth6", "6 chars"),
    (8, "GraphWidth8", "8 chars"),
    (10, "GraphWidth10", "10 chars (default)"),
    (12, "GraphWidth12", "12 chars"),
    (14, "GraphWidth14", "14 chars"),
    (16, "GraphWidth16", "16 chars"),
]

# _packGraphKey masks periodMin to this budget, so a longer frame would alias to a shorter one's cache key.
_max_period_min = max(m for m, *_ in GRAPH_TIME_FRAMES + FORECAST_TIME_FRAMES)
if _max_period_min >= CACHE_KEY_PERIOD_BUDGET:
    raise ValueError(
        f"GRAPH_TIME_FRAMES/FORECAST_TIME_FRAMES has a value of "
        f"{_max_period_min} minutes, exceeds the {CACHE_KEY_PERIOD_BUDGET}-value "
        "cache key period budget (CACHE_KEY_PERIOD_BUDGET) - _packGraphKey's "
        "periodMin bits need widening before adding a longer time frame"
    )
if any(m % 15 for m, *_ in GRAPH_TIME_FRAMES) or [
    w for w, *_ in GRAPH_WIDTH_OPTIONS
] != list(range(6, 18, 2)):
    raise ValueError(
        "_drawDualGraphRow's dual cache key packs (periodMin / 15) * 6 + "
        "(width - 6) / 2 into one slot, so every GRAPH_TIME_FRAMES value must be "
        "a multiple of 15 and GRAPH_WIDTH_OPTIONS must be exactly 6-16 in steps "
        "of 2 - update that key before changing either list"
    )


class LineSlot(NamedTuple):
    line_num: int
    slot: str
    field_default: int


_fv = FIELD_VALUE

# Ordered most-glanced-at first, since R1 is what shows on every wake.
LINE_SLOTS = [
    LineSlot(3, "Primary", _fv["FieldWxFcstTemp"]),
    LineSlot(4, "Primary", _fv["FieldSteps"]),
    LineSlot(5, "Primary", _fv["FieldHR"]),
    LineSlot(3, "Secondary", _fv["FieldWxCondCloud"]),
    LineSlot(4, "Secondary", _fv["FieldElevation"]),
    LineSlot(5, "Secondary", _fv["FieldStress"]),
    LineSlot(3, "Tertiary", _fv["FieldWxUVWind"]),
    LineSlot(4, "Tertiary", _fv["FieldDistance"]),
    LineSlot(5, "Tertiary", _fv["FieldBodyBat"]),
    LineSlot(3, "Quaternary", _fv["FieldWxHumidityPrecip"]),
    LineSlot(4, "Quaternary", _fv["FieldFloors"]),
    LineSlot(5, "Quaternary", _fv["FieldActiveMinDay"]),
    LineSlot(3, "Quinary", _fv["FieldWxFcstDaily"]),
    LineSlot(4, "Quinary", _fv["FieldClimbDescendDay"]),
    LineSlot(5, "Quinary", _fv["FieldIntensityMin"]),
    LineSlot(3, "Senary", _fv["FieldNone"]),
    LineSlot(4, "Senary", _fv["FieldNone"]),
    LineSlot(5, "Senary", _fv["FieldNone"]),
    LineSlot(3, "Septenary", _fv["FieldNone"]),
    LineSlot(4, "Septenary", _fv["FieldNone"]),
    LineSlot(5, "Septenary", _fv["FieldNone"]),
    LineSlot(3, "Octonary", _fv["FieldNone"]),
    LineSlot(4, "Octonary", _fv["FieldNone"]),
    LineSlot(5, "Octonary", _fv["FieldNone"]),
    LineSlot(3, "Nonary", _fv["FieldNone"]),
    LineSlot(4, "Nonary", _fv["FieldNone"]),
    LineSlot(5, "Nonary", _fv["FieldNone"]),
]

LINE_LABEL_COLOR_DEFAULTS = {3: 6, 4: 1, 5: 5}


def line_slots(ln):
    return [r for r in LINE_SLOTS if r.line_num == ln]


GRAPH_MODE_OPTIONS = [
    (0, "GraphModeValue", "Value only"),
    (1, "GraphModeLineGraph", "Line graph"),
    (3, "GraphModeLineCurrent", "Line + value"),
    (2, "GraphModeBarGraph", "Bar graph"),
    (4, "GraphModeBarCurrent", "Bar + value"),
    (5, "GraphModeAreaGraph", "Area graph"),
    (6, "GraphModeAreaCurrent", "Area + value"),
]

GRAPH_VALUE_MODE_OPTIONS = [
    (0, "GraphValueCurrent", "Current value"),
    (1, "GraphValueAvg", "Average"),
    (2, "GraphValueMaxMin", "Max / Min"),
    (3, "GraphValueMean", "Midpoint"),
]

# Forecasts always draw a graph, so this drops GRAPH_MODE_OPTIONS' "value only".
FORECAST_GRAPH_MODE_OPTIONS = GRAPH_MODE_OPTIONS[1:]

FORECAST_VIEW_MODE_OPTIONS = [
    (1, "ViewModeGraph", "Graph"),
    (2, "ViewModeGraphCurrent", "Graph + Value"),
]

BAR_GROUP_OPTIONS = [
    (0, "BarGroupOff", "Off (full detail)"),
    (1, "BarGroupTight", "Tight"),
    (2, "BarGroupNormal", "Normal"),
    (3, "BarGroupLoose", "Loose"),
]

BAR_GROUP_AGG_OPTIONS = [
    (0, "BarGroupAggMean", "Mean"),
    (1, "BarGroupAggMax", "Max"),
    (2, "BarGroupAggLast", "Last value"),
]

SEC_TYPE_OPTIONS = [
    (0, "SecTypeNone", "None (hidden)"),
    (1, "SecTypeLine", "Line"),
    (2, "SecTypeBar", "Bar"),
]


class HourlyForecast(NamedTuple):
    key: str
    skey: str
    display: str
    value_mode_default: int
    graph_color_default: int


HOURLY_FORECASTS = [
    HourlyForecast("wxForecast", "WxForecast", "Temp Hourly", 0, 16),
    HourlyForecast("wxForecastPrecip", "WxForecastPrecip", "Rain Hourly", 1, 6),
    HourlyForecast("wxForecastWind", "WxForecastWind", "Wind Hourly", 1, 6),
    HourlyForecast("wxForecastUv", "WxForecastUv", "UV Hourly", 2, 3),
    HourlyForecast("wxForecastCloud", "WxForecastCloud", "Cloud Hourly", 1, 8),
    HourlyForecast("wxForecastHumidity", "WxForecastHumidity", "Humidity Hourly", 1, 2),
]


def ind(n):
    return "  " * n


# Abbreviated to keep properties.xml under Connect IQ's size ceiling; mirrored by hand in TerminalWatchfaceView.mc.
SUF = {
    "GraphMode": "Gm",
    "GraphValueMode": "Gvm",
    "ValueMode": "Vm",
    "SecondaryType": "St",
    "SecondaryField": "Sf",
    "SecondaryColor": "Se",
    "TimeFrame": "Tf",
    "GraphColor": "Gc",
    "GraphWidth": "Gw",
    "ShowBar": "Sb",
    "ShowBarValue": "Sv",
    "BarColor": "Bc",
    "BarWidth": "Bw",
    "BarGoal": "Bg",
    "Enabled": "En",
    "LabelColor": "Lc",
    "ValueColor": "Vc",
    "ViewMode": "Vw",
    "Days": "Dy",
    "BarGroup": "Bn",
    "BarGroupAgg": "Ba",
}
ROT = {
    "Primary": "R1",
    "Secondary": "R2",
    "Tertiary": "R3",
    "Quaternary": "R4",
    "Quinary": "R5",
    "Senary": "R6",
    "Septenary": "R7",
    "Octonary": "R8",
    "Nonary": "R9",
}
PFX = {
    "wxForecast": "wxf",
    "wxForecastPrecip": "wxfp",
    "wxForecastWind": "wxfw",
    "wxForecastUv": "wxfu",
    "wxForecastCloud": "wxfc",
    "wxForecastHumidity": "wxfh",
    "wxForecastDaily": "wxfd",
    "bodyBat": "bb",
    "tempWrist": "tw",
    "activeMinDay": "aMin",
    "intensityMin": "iMin",
    "steps": "stp",
    "floors": "flr",
    "calories": "cal",
    "distance": "dist",
    "stress": "str",
    "elevation": "elev",
    "pressure": "pres",
}

STANDALONE_KEYS = {
    "fontChoice": "font",
    "colorTheme": "theme",
    "scanlines": "scan",
    "glowIntensity": "glow",
    "bgBacklight": "bgLt",
    "flickerEnabled": "flick",
    "leftPadding": "lPad",
    "areaOpacity": "aOpac",
    "areaShowLine": "aLine",
    "showBatteryDays": "batD",
    "showSeconds": "shSec",
    "showYear": "shYr",
    "dateFormat": "dFmt",
    "watchCommandStyle": "cmdSty",
    "rotateInterval": "rotI",
    "rotateIntervalAlt": "rotA",
    "rotationMode": "rotMode",
    "line1LabelColor": "l1Lc",
    "line1ValueColor": "l1Vc",
    "line2LabelColor": "l2Lc",
    "line2ValueColor": "l2Vc",
    "showVersion": "shVer",
    "debugGraphGaps": "dbgGG",
}


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


def setting_numeric(prop_key, title_key, min_val, max_val, indent=1):
    i = ind(indent)
    return (
        f'{i}<setting propertyKey="@Properties.{prop_key}" title="@Strings.{title_key}">\n'
        f'{i}  <settingConfig type="numeric" min="{min_val}" max="{max_val}" />\n'
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


def entries(options):
    return [(v, f"@Strings.{s}") for v, s, *_ in options]


def option_strings(options):
    return [string(sid, text) for _v, sid, text in options]


def color_setting(prop_key, title_key, colors=COLORS_FULL, indent=1):
    return setting_list(prop_key, title_key, entries(colors), indent)


def field_setting(prop_key, title_key, fields=FIELDS_ALL, indent=1):
    return setting_list(prop_key, title_key, entries(fields), indent)


def group(gid, title_key, *blocks):
    i = ind(1)
    lines = [f'{i}<group id="{gid}" title="@Strings.{title_key}">']
    for b in blocks:
        lines.append(b)
    lines.append(f"{i}</group>")
    return "\n".join(lines)


def gen_field_ids():
    lines = [
        "// GENERATED FILE - DO NOT EDIT. Regenerate with `python scripts/generate_resources.py`.",
        "",
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


def gen_properties():
    lines = ["<properties>"]

    sk = STANDALONE_KEYS
    lines.append("\n  <!-- Appearance -->")
    lines.append(prop(sk["fontChoice"], "number", 0))
    lines.append(prop(sk["colorTheme"], "number", 0))
    lines.append(prop(sk["scanlines"], "number", 2))
    lines.append(prop(sk["glowIntensity"], "number", 2))
    lines.append(prop(sk["bgBacklight"], "number", 0))
    lines.append(prop(sk["flickerEnabled"], "boolean", "true"))

    lines.append("\n  <!-- Display options -->")
    lines.append(prop(sk["leftPadding"], "number", 4))
    lines.append(prop(sk["areaOpacity"], "number", 64))
    lines.append(prop(sk["areaShowLine"], "boolean", "true"))
    lines.append(prop(sk["showBatteryDays"], "boolean", "true"))
    lines.append(prop(sk["showSeconds"], "boolean", "false"))
    lines.append(prop(sk["showYear"], "boolean", "false"))
    lines.append(prop(sk["dateFormat"], "number", 0))
    lines.append(prop(sk["watchCommandStyle"], "number", 2))
    lines.append(prop(sk["rotateInterval"], "number", 5))
    lines.append(prop(sk["rotateIntervalAlt"], "number", 0))
    lines.append(prop(sk["rotationMode"], "number", 2))

    lines.append("\n  <!-- Time row (always visible) -->")
    lines.append(prop(sk["line1LabelColor"], "number", 8))
    lines.append(prop(sk["line1ValueColor"], "number", 0))

    lines.append("\n  <!-- Date row (always visible) -->")
    lines.append(prop(sk["line2LabelColor"], "number", 8))
    lines.append(prop(sk["line2ValueColor"], "number", 0))

    for ln, slot, fd in LINE_SLOTS:
        pk = f"l{ln}"
        if slot == "Primary":
            lines.append(f"\n  <!-- Line {ln} -->")
            lines.append(prop(f"{pk}{SUF['Enabled']}", "boolean", "true"))
            lines.append(
                prop(
                    f"{pk}{SUF['LabelColor']}", "number", LINE_LABEL_COLOR_DEFAULTS[ln]
                )
            )
            lines.append(prop(f"{pk}{SUF['ValueColor']}", "number", 0))
        lines.append(prop(f"{pk}{ROT[slot]}", "number", fd))

    for bf in BAR_FIELDS:
        pk = PFX.get(bf.key, bf.key)
        lines.append(f"\n  <!-- {bf.group_title} -->")
        lines.append(
            prop(
                f"{pk}{SUF['ShowBar']}",
                "boolean",
                "true" if bf.show_bar_default else "false",
            )
        )
        lines.append(prop(f"{pk}{SUF['ShowBarValue']}", "boolean", "true"))
        lines.append(prop(f"{pk}{SUF['BarColor']}", "number", bf.color_default))
        lines.append(prop(f"{pk}{SUF['BarWidth']}", "number", bf.width_default))
        if bf.goal_default is not None:
            lines.append(prop(f"{pk}{SUF['BarGoal']}", "number", bf.goal_default))

    lines.append("\n  <!-- Graph settings per supported field type -->")
    for gf in GRAPH_FIELDS:
        pk = PFX.get(gf.key, gf.key)
        lines.append(f"\n  <!-- {gf.skey} -->")
        lines.append(prop(f"{pk}{SUF['GraphMode']}", "number", gf.mode))
        lines.append(prop(f"{pk}{SUF['GraphValueMode']}", "number", gf.value_mode))
        lines.append(prop(f"{pk}{SUF['SecondaryType']}", "number", gf.sec_type))
        lines.append(prop(f"{pk}{SUF['SecondaryField']}", "number", gf.sec_field))
        lines.append(prop(f"{pk}{SUF['TimeFrame']}", "number", gf.time_frame))
        lines.append(prop(f"{pk}{SUF['GraphColor']}", "number", gf.graph_color))
        lines.append(prop(f"{pk}{SUF['SecondaryColor']}", "number", gf.sec_color))
        lines.append(prop(f"{pk}{SUF['GraphWidth']}", "number", 10))
        lines.append(prop(f"{pk}{SUF['BarGroup']}", "number", 0))
        lines.append(prop(f"{pk}{SUF['BarGroupAgg']}", "number", 0))

    for hf in HOURLY_FORECASTS:
        lines.append(hourly_forecast_props(hf))

    lines.append("\n  <!-- Day Forecast -->")
    lines.append(prop(f"{PFX['wxForecastDaily']}{SUF['ViewMode']}", "number", 2))
    lines.append(prop(f"{PFX['wxForecastDaily']}{SUF['ValueMode']}", "number", 2))
    lines.append(prop(f"{PFX['wxForecastDaily']}{SUF['Days']}", "number", 5))
    lines.append(prop(f"{PFX['wxForecastDaily']}{SUF['GraphColor']}", "number", 16))
    lines.append(prop(f"{PFX['wxForecastDaily']}{SUF['GraphWidth']}", "number", 8))

    lines.append("\n  <!-- Debug -->")
    lines.append(prop(sk["showVersion"], "boolean", "false"))
    lines.append(prop(sk["debugGraphGaps"], "boolean", "false"))

    lines.append("\n</properties>")
    return "\n".join(lines) + "\n"


def gen_strings():
    lines = ["<strings>"]
    s = string

    lines.append(s("AppName", "TerminalWatchface"))

    lines.append("\n  <!-- Appearance -->")
    lines.append(s("AppearanceGroup", "Appearance"))
    lines.append(s("FontChoice", "Font"))
    lines.append(s("FontJetBrainsMono", "JetBrains Mono"))
    lines.append(s("FontSpaceMono", "Space Mono"))
    lines.append(s("NBArchitekt", "NB Architekt"))
    lines.append(s("ColorTheme", "Color Theme"))
    lines.append(s("ColorThemeCustom", "Custom (per-field colors)"))
    lines.append(s("ColorThemeAmber", "Amber CRT"))
    lines.append(s("ColorThemeGreen", "Green Phosphor"))
    lines.append(s("ColorThemeBlue", "Blue Terminal"))
    lines.append(s("Scanlines", "Scanlines"))
    lines.append(s("ScanlinesOff", "Off"))
    lines.append(s("ScanlinesSubtle", "Subtle"))
    lines.append(s("ScanlinesMedium", "Medium"))
    lines.append(s("ScanlinesStrong", "Strong"))
    lines.append(s("GlowIntensity", "Glow Intensity"))
    lines.append(s("GlowIntensityOff", "Off"))
    lines.append(s("GlowIntensitySubtle", "Subtle"))
    lines.append(s("GlowIntensityMedium", "Medium"))
    lines.append(s("GlowIntensityStrong", "Strong"))
    lines.append(s("BgBacklight", "Backlight"))
    lines.append(s("BgBacklightOff", "Off"))
    lines.append(s("BgBacklightSubtle", "Subtle"))
    lines.append(s("BgBacklightMedium", "Medium"))
    lines.append(s("BgBacklightStrong", "Strong"))
    lines.append(s("FlickerEnabled", "CRT Flicker"))
    lines.append(s("LeftPadding", "Left Padding"))
    lines.append(s("AreaOpacity", "Area Graph: Opacity"))
    lines.append(s("AreaOpacity25", "25%"))
    lines.append(s("AreaOpacity50", "50%"))
    lines.append(s("AreaOpacity75", "75%"))
    lines.append(s("AreaOpacity100", "100%"))
    lines.append(s("AreaShowLine", "Area Graph: Show Line"))
    lines.append(s("ShowBatteryDays", "Show Battery Days Remaining"))
    lines.append(s("WatchCommandStyle", "Command Style"))
    lines.append(s("WatchCommandWindows", "Windows (watch.bat)"))
    lines.append(s("WatchCommandLinux", "Linux (watch.sh)"))
    lines.append(s("WatchCommandBare", "Bare (watch)"))

    lines.append("\n  <!-- Fixed rows -->")
    lines.append(s("TimeRowGroup", "Time Row"))
    lines.append(s("ShowSeconds", "Show Seconds"))
    lines.append(s("Line1LabelColor", "Time: Label Color"))
    lines.append(s("Line1ValueColor", "Time: Value Color"))
    lines.append(s("DateRowGroup", "Date Row"))
    lines.append(s("ShowYear", "Show Year in Date"))
    lines.append(s("DateFormat", "Date Format"))
    lines.append(s("DateFormatDayMon", "Day Month (Mon, 1 Jan)"))
    lines.append(s("DateFormatYMD", "ISO (YYYY-MM-DD)"))
    lines.append(s("DateFormatDMY", "DD-MM-YYYY"))
    lines.append(s("DateFormatMDY", "MM-DD-YYYY"))
    lines.append(s("DateFormatDayNum", "Day Name + Number (Mon 14)"))
    lines.append(s("DateFormatDMon", "Date + Month (14 Jun)"))
    lines.append(s("Line2LabelColor", "Date: Label Color"))
    lines.append(s("Line2ValueColor", "Date: Value Color"))

    lines.append("\n  <!-- Rotation -->")
    lines.append(s("RotationGroup", "Rotation"))
    lines.append(s("RotateInterval", "Rotation: Main Duration"))
    lines.append(s("RotateIntervalAlt", "Rotation: Alt Duration"))
    lines.append(s("RotationMode", "Rotation Mode"))
    lines.append(s("RotationModeAutomatic", "Automatic"))
    lines.append(s("RotationModeManual", "Manual (long-press only)"))
    lines.append(s("RotationModeHybrid", "Hybrid (automatic + long-press)"))
    lines.append(s("RotateSameAsMain", "Same as main"))
    lines.append(s("Rotate3s", "3 seconds"))
    lines.append(s("Rotate5s", "5 seconds"))
    lines.append(s("Rotate10s", "10 seconds"))
    lines.append(s("Rotate15s", "15 seconds"))
    lines.append(s("Rotate30s", "30 seconds"))
    lines.append(s("Rotate1min", "1 minute"))

    lines.append("\n  <!-- Lines 3-5: configurable, R1-R9 = rotation slots 1 to 9 -->")
    for ln in (3, 4, 5):
        pk = f"Line{ln}"
        ptitle = f"Line {ln}"
        lines.append(s(f"{pk}ConfigGroup", f"{ptitle} Configuration"))
        for _ln, slot, _fd in line_slots(ln):
            if slot == "Primary":
                lines.append(s(f"{pk}Enabled", f"{ptitle}: Enabled"))
                lines.append(s(f"{pk}LabelColor", f"{ptitle}: Label Color"))
                lines.append(s(f"{pk}ValueColor", f"{ptitle}: Value Color"))
            lines.append(s(f"{pk}{slot}", f"{ptitle}: Field ({ROT[slot]})"))

    lines.append("\n  <!-- Shared: color options -->")
    for _v, sid, text in COLORS_FULL:
        lines.append(s(sid, text))

    lines.append("\n  <!-- Shared: field options -->")
    for _v, sid, text in FIELDS_ALL:
        lines.append(s(sid, text))

    lines.append("\n  <!-- Shared: graph mode options (sensor graphs) -->")
    lines.extend(option_strings(GRAPH_MODE_OPTIONS))

    lines.append("\n  <!-- Shared: graph value mode options -->")
    lines.extend(option_strings(GRAPH_VALUE_MODE_OPTIONS))

    lines.append("\n  <!-- Shared: forecast view mode options (daily) -->")
    lines.extend(option_strings(FORECAST_VIEW_MODE_OPTIONS))

    lines.append("\n  <!-- Shared: graph width options -->")
    lines.extend(option_strings(GRAPH_WIDTH_OPTIONS))

    lines.append("\n  <!-- Shared: bar grouping options -->")
    lines.extend(option_strings(BAR_GROUP_OPTIONS))
    lines.extend(option_strings(BAR_GROUP_AGG_OPTIONS))

    for bf in BAR_FIELDS:
        id_prefix = bf.key[0].upper() + bf.key[1:]
        label = bf.label
        lines.append(f"\n  <!-- {bf.group_title} -->")
        lines.append(s(f"{id_prefix}Group", BAR_CONFIG_PREFIX + bf.group_title))
        lines.append(s(f"{id_prefix}ShowBar", f"{label}: Show Progress Bar"))
        lines.append(s(f"{id_prefix}ShowBarValue", f"{label}: Show Value in Bar"))
        lines.append(s(f"{id_prefix}BarColor", f"{label}: Bar Color"))
        lines.append(s(f"{id_prefix}BarWidth", f"{label}: Bar Width"))
        if bf.goal_default is not None:
            suffix = bf.goal_label_suffix or ""
            lines.append(s(f"{id_prefix}BarGoal", f"{label}: Daily Goal{suffix}"))

    lines.append("\n  <!-- Shared: secondary graph type options -->")
    lines.extend(option_strings(SEC_TYPE_OPTIONS))

    lines.append("\n  <!-- Shared: graph time frame options -->")
    lines.extend(option_strings(GRAPH_TIME_FRAMES))

    for gf in GRAPH_FIELDS:
        display = gf.display
        skey = gf.skey
        lines.append(f"\n  <!-- Graph settings: {display} -->")
        lines.append(s(f"{skey}GraphGroup", f"{GRAPH_CONFIG_PREFIX}{display}"))
        lines.append(s(f"{skey}GraphMode", f"{display}: Graph Mode"))
        lines.append(s(f"{skey}GraphValueMode", f"{display}: Graph Value Mode"))
        lines.append(s(f"{skey}BarGroup", f"{display}: Bar Grouping"))
        lines.append(s(f"{skey}BarGroupAgg", f"{display}: Bar Grouping Aggregation"))
        lines.append(s(f"{skey}SecondaryType", f"{display}: 2nd Graph Type"))
        lines.append(s(f"{skey}SecondaryField", f"{display}: 2nd Graph Field"))
        lines.append(s(f"{skey}TimeFrame", f"{display}: Time Frame"))
        lines.append(s(f"{skey}GraphColor", f"{display}: Graph Color"))
        lines.append(s(f"{skey}SecondaryColor", f"{display}: 2nd Graph Color"))
        lines.append(s(f"{skey}GraphWidth", f"{display}: Graph Width"))

    lines.append("\n  <!-- Shared: forecast time frame options -->")
    lines.extend(option_strings(FORECAST_TIME_FRAMES))

    for hf in HOURLY_FORECASTS:
        lines.append(hourly_forecast_strings(hf))

    lines.append("\n  <!-- Graph settings: Temp Daily Forecast -->")
    lines.append(s("WxForecastDailyGroup", GRAPH_CONFIG_PREFIX + "Temp Daily Forecast"))
    lines.append(s("WxForecastDailyViewMode", "Temp Daily: View Mode"))
    lines.append(s("WxForecastDailyValueMode", "Temp Daily: Value Mode"))
    lines.append(s("WxForecastDailyDays", "Temp Daily: Days"))
    lines.append(s("WxForecastDailyGraphColor", "Temp Daily: Graph Color"))
    lines.append(s("WxForecastDailyGraphWidth", "Temp Daily: Graph Width"))
    lines.extend(option_strings(FORECAST_DAY_OPTIONS))

    lines.append("\n  <!-- Debug -->")
    lines.append(s("DebugGroup", "Debug"))
    lines.append(s("ShowVersion", "Show App Version (testing)"))
    lines.append(s("DebugGraphGaps", "Show Graph Gaps (testing)"))

    lines.append("\n</strings>")
    return "\n".join(lines) + "\n"


def width_setting(prop_key, title_key, indent=1):
    return setting_list(prop_key, title_key, entries(GRAPH_WIDTH_OPTIONS), indent)


def graph_section(gf, indent=1):
    pk = PFX.get(gf.key, gf.key)
    skey = gf.skey
    blocks = []

    blocks.append(
        setting_list(
            f"{pk}{SUF['GraphMode']}",
            f"{skey}GraphMode",
            entries(GRAPH_MODE_OPTIONS),
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{pk}{SUF['GraphValueMode']}",
            f"{skey}GraphValueMode",
            entries(GRAPH_VALUE_MODE_OPTIONS),
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{pk}{SUF['BarGroup']}",
            f"{skey}BarGroup",
            entries(BAR_GROUP_OPTIONS),
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{pk}{SUF['BarGroupAgg']}",
            f"{skey}BarGroupAgg",
            entries(BAR_GROUP_AGG_OPTIONS),
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{pk}{SUF['SecondaryType']}",
            f"{skey}SecondaryType",
            entries(SEC_TYPE_OPTIONS),
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{pk}{SUF['SecondaryField']}",
            f"{skey}SecondaryField",
            [(i, f"@Strings.{sid}") for i, sid in enumerate(GRAPH_SEC_FIELDS)],
            indent,
        )
    )
    blocks.append(
        setting_list(
            f"{pk}{SUF['TimeFrame']}",
            f"{skey}TimeFrame",
            entries(
                o
                for o in GRAPH_TIME_FRAMES
                if gf.max_time_frame is None or o[0] <= gf.max_time_frame
            ),
            indent,
        )
    )
    blocks.append(
        color_setting(f"{pk}{SUF['GraphColor']}", f"{skey}GraphColor", indent=indent)
    )
    blocks.append(
        color_setting(
            f"{pk}{SUF['SecondaryColor']}", f"{skey}SecondaryColor", indent=indent
        )
    )
    blocks.append(
        width_setting(f"{pk}{SUF['GraphWidth']}", f"{skey}GraphWidth", indent)
    )

    return "\n".join(blocks)


def hourly_forecast_props(hf):
    pk = PFX.get(hf.key, hf.key)
    return "\n".join(
        [
            f"\n  <!-- {hf.display} Forecast -->",
            prop(f"{pk}{SUF['GraphMode']}", "number", 4),
            prop(f"{pk}{SUF['ValueMode']}", "number", hf.value_mode_default),
            prop(f"{pk}{SUF['TimeFrame']}", "number", 12),
            prop(f"{pk}{SUF['GraphColor']}", "number", hf.graph_color_default),
            prop(f"{pk}{SUF['GraphWidth']}", "number", 10),
        ]
    )


def hourly_forecast_strings(hf):
    display = hf.display
    skey = hf.skey
    return "\n".join(
        [
            f"\n  <!-- Graph settings: {display} Forecast -->",
            string(f"{skey}Group", f"{GRAPH_CONFIG_PREFIX}{display} Forecast"),
            string(f"{skey}GraphMode", f"{display}: Graph Mode"),
            string(f"{skey}ValueMode", f"{display}: Value Mode"),
            string(f"{skey}TimeFrame", f"{display}: Hours Ahead"),
            string(f"{skey}GraphColor", f"{display}: Graph Color"),
            string(f"{skey}GraphWidth", f"{display}: Graph Width"),
        ]
    )


def hourly_forecast_settings(hf, indent=1):
    pk = PFX.get(hf.key, hf.key)
    skey = hf.skey
    return "\n".join(
        [
            setting_list(
                f"{pk}{SUF['GraphMode']}",
                f"{skey}GraphMode",
                entries(FORECAST_GRAPH_MODE_OPTIONS),
                indent,
            ),
            setting_list(
                f"{pk}{SUF['ValueMode']}",
                f"{skey}ValueMode",
                entries(GRAPH_VALUE_MODE_OPTIONS),
                indent,
            ),
            setting_list(
                f"{pk}{SUF['TimeFrame']}",
                f"{skey}TimeFrame",
                entries(FORECAST_TIME_FRAMES),
                indent,
            ),
            color_setting(
                f"{pk}{SUF['GraphColor']}", f"{skey}GraphColor", indent=indent
            ),
            width_setting(f"{pk}{SUF['GraphWidth']}", f"{skey}GraphWidth", indent),
        ]
    )


def gen_settings():
    parts = ["<settings>"]
    sk = STANDALONE_KEYS

    parts.append(
        group(
            "appearance",
            "AppearanceGroup",
            setting_list(
                sk["fontChoice"],
                "FontChoice",
                [
                    (0, "@Strings.FontJetBrainsMono"),
                    (1, "@Strings.FontSpaceMono"),
                    (2, "@Strings.NBArchitekt"),
                ],
                indent=2,
            ),
            setting_list(
                sk["colorTheme"],
                "ColorTheme",
                [
                    (0, "@Strings.ColorThemeCustom"),
                    (1, "@Strings.ColorThemeAmber"),
                    (2, "@Strings.ColorThemeGreen"),
                    (3, "@Strings.ColorThemeBlue"),
                ],
                indent=2,
            ),
            setting_list(
                sk["scanlines"],
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
                sk["glowIntensity"],
                "GlowIntensity",
                [
                    (0, "@Strings.GlowIntensityOff"),
                    (1, "@Strings.GlowIntensitySubtle"),
                    (2, "@Strings.GlowIntensityMedium"),
                    (3, "@Strings.GlowIntensityStrong"),
                ],
                indent=2,
            ),
            setting_list(
                sk["bgBacklight"],
                "BgBacklight",
                [
                    (0, "@Strings.BgBacklightOff"),
                    (1, "@Strings.BgBacklightSubtle"),
                    (2, "@Strings.BgBacklightMedium"),
                    (3, "@Strings.BgBacklightStrong"),
                ],
                indent=2,
            ),
            setting_bool(sk["flickerEnabled"], "FlickerEnabled", indent=2),
            setting_numeric(sk["leftPadding"], "LeftPadding", 0, 8, indent=2),
            setting_list(
                sk["areaOpacity"],
                "AreaOpacity",
                [
                    (0x40, "@Strings.AreaOpacity25"),
                    (0x80, "@Strings.AreaOpacity50"),
                    (0xC0, "@Strings.AreaOpacity75"),
                    (0xFF, "@Strings.AreaOpacity100"),
                ],
                indent=2,
            ),
            setting_bool(sk["areaShowLine"], "AreaShowLine", indent=2),
            setting_bool(sk["showBatteryDays"], "ShowBatteryDays", indent=2),
            setting_list(
                sk["watchCommandStyle"],
                "WatchCommandStyle",
                [
                    (0, "@Strings.WatchCommandWindows"),
                    (1, "@Strings.WatchCommandLinux"),
                    (2, "@Strings.WatchCommandBare"),
                ],
                indent=2,
            ),
        )
    )

    parts.append(
        group(
            "timeRow",
            "TimeRowGroup",
            setting_bool(sk["showSeconds"], "ShowSeconds", indent=2),
            color_setting(
                sk["line1LabelColor"], "Line1LabelColor", COLORS_TEXT, indent=2
            ),
            color_setting(
                sk["line1ValueColor"], "Line1ValueColor", COLORS_TEXT, indent=2
            ),
        )
    )

    parts.append(
        group(
            "dateRow",
            "DateRowGroup",
            setting_bool(sk["showYear"], "ShowYear", indent=2),
            setting_list(
                sk["dateFormat"],
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
            color_setting(
                sk["line2LabelColor"], "Line2LabelColor", COLORS_TEXT, indent=2
            ),
            color_setting(
                sk["line2ValueColor"], "Line2ValueColor", COLORS_TEXT, indent=2
            ),
        )
    )

    rotate_options = [
        (0, "@Strings.RotateSameAsMain"),
        (3, "@Strings.Rotate3s"),
        (5, "@Strings.Rotate5s"),
        (10, "@Strings.Rotate10s"),
        (15, "@Strings.Rotate15s"),
        (30, "@Strings.Rotate30s"),
        (60, "@Strings.Rotate1min"),
    ]
    parts.append(
        group(
            "rotation",
            "RotationGroup",
            setting_list(
                sk["rotateInterval"], "RotateInterval", rotate_options[1:], indent=2
            ),
            setting_list(
                sk["rotateIntervalAlt"], "RotateIntervalAlt", rotate_options, indent=2
            ),
            setting_list(
                sk["rotationMode"],
                "RotationMode",
                [
                    (0, "@Strings.RotationModeAutomatic"),
                    (1, "@Strings.RotationModeManual"),
                    (2, "@Strings.RotationModeHybrid"),
                ],
                indent=2,
            ),
        )
    )

    for ln in (3, 4, 5):
        pk = f"l{ln}"
        lsk = f"Line{ln}"
        line_blocks = [
            setting_bool(f"{pk}{SUF['Enabled']}", f"{lsk}Enabled", indent=2),
            color_setting(
                f"{pk}{SUF['LabelColor']}", f"{lsk}LabelColor", COLORS_TEXT, indent=2
            ),
            color_setting(
                f"{pk}{SUF['ValueColor']}", f"{lsk}ValueColor", COLORS_TEXT, indent=2
            ),
        ]
        line_blocks.extend(
            field_setting(f"{pk}{ROT[r.slot]}", f"{lsk}{r.slot}", indent=2)
            for r in line_slots(ln)
        )
        parts.append(group(f"line{ln}", f"{lsk}ConfigGroup", *line_blocks))

    for bf in BAR_FIELDS:
        id_prefix = bf.key[0].upper() + bf.key[1:]
        pk = PFX.get(bf.key, bf.key)
        blocks = [
            setting_bool(f"{pk}{SUF['ShowBar']}", f"{id_prefix}ShowBar", indent=2),
            setting_bool(
                f"{pk}{SUF['ShowBarValue']}", f"{id_prefix}ShowBarValue", indent=2
            ),
            color_setting(
                f"{pk}{SUF['BarColor']}", f"{id_prefix}BarColor", COLORS_TEXT, indent=2
            ),
            width_setting(f"{pk}{SUF['BarWidth']}", f"{id_prefix}BarWidth", indent=2),
        ]
        if bf.goal_default is not None:
            blocks.append(
                setting_numeric(
                    f"{pk}{SUF['BarGoal']}",
                    f"{id_prefix}BarGoal",
                    bf.goal_min,
                    bf.goal_max,
                    indent=2,
                )
            )
        parts.append(group(bf.key, f"{id_prefix}Group", *blocks))

    for gf in GRAPH_FIELDS:
        parts.append(
            group(
                f"graph_{gf.key}", f"{gf.skey}GraphGroup", graph_section(gf, indent=2)
            )
        )

    for hf in HOURLY_FORECASTS:
        parts.append(
            group(hf.key, f"{hf.skey}Group", hourly_forecast_settings(hf, indent=2))
        )

    parts.append(
        group(
            "wxForecastDaily",
            "WxForecastDailyGroup",
            setting_list(
                f"{PFX['wxForecastDaily']}{SUF['ViewMode']}",
                "WxForecastDailyViewMode",
                entries(FORECAST_VIEW_MODE_OPTIONS),
                indent=2,
            ),
            setting_list(
                f"{PFX['wxForecastDaily']}{SUF['ValueMode']}",
                "WxForecastDailyValueMode",
                entries(GRAPH_VALUE_MODE_OPTIONS),
                indent=2,
            ),
            setting_list(
                f"{PFX['wxForecastDaily']}{SUF['Days']}",
                "WxForecastDailyDays",
                entries(FORECAST_DAY_OPTIONS),
                indent=2,
            ),
            color_setting(
                f"{PFX['wxForecastDaily']}{SUF['GraphColor']}",
                "WxForecastDailyGraphColor",
                indent=2,
            ),
            width_setting(
                f"{PFX['wxForecastDaily']}{SUF['GraphWidth']}",
                "WxForecastDailyGraphWidth",
                indent=2,
            ),
        )
    )

    parts.append(
        group(
            "debug",
            "DebugGroup",
            setting_bool(STANDALONE_KEYS["showVersion"], "ShowVersion", indent=2),
            setting_bool(STANDALONE_KEYS["debugGraphGaps"], "DebugGraphGaps", indent=2),
        )
    )

    parts.append("\n</settings>")
    return "\n".join(parts) + "\n"


def write(path, content):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)
    print(f"  wrote {os.path.relpath(path, ROOT)}")


if __name__ == "__main__":
    print("Generating resources...")
    write(OUT_FIELD_IDS, gen_field_ids())
    write(OUT_PROPERTIES, gen_properties())
    write(OUT_STRINGS, gen_strings())
    write(OUT_SETTINGS, gen_settings())
    print("Done.")
