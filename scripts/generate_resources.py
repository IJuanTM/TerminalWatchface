#!/usr/bin/env python3
"""
Generates resources/properties.xml, resources/strings/strings.xml,
and resources/settings.xml from a single source of truth.

Run from the project root:
    python scripts/generate_resources.py
"""

import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_PROPERTIES = os.path.join(ROOT, "resources", "properties.xml")
OUT_STRINGS    = os.path.join(ROOT, "resources", "strings", "strings.xml")
OUT_SETTINGS   = os.path.join(ROOT, "resources", "settings.xml")

# ---------------------------------------------------------------------------
# Shared data definitions
# ---------------------------------------------------------------------------

COLORS_FULL = [  # 0-13, includes gradient options — used for lines and graphs
    (0,  "ColorWhite"),       (1,  "ColorGreen"),    (2,  "ColorCyan"),
    (3,  "ColorYellow"),      (4,  "ColorOrange"),   (5,  "ColorRed"),
    (6,  "ColorBlue"),        (7,  "ColorMagenta"),  (8,  "ColorLightGrey"),
    (9,  "ColorPurple"),      (10, "ColorGrad"),     (11, "ColorGradRev"),
    (12, "ColorGradTemp"),    (13, "ColorGradTempRev"),
]

# All fields available on the configurable lines (3/4/5)
FIELDS_ALL = [
    (7,  "FieldNone"),         (0,  "FieldSteps"),       (4,  "FieldDistance"),
    (2,  "FieldCalories"),     (25, "FieldCalAct"),       (10, "FieldActiveMin"),
    (29, "FieldActiveMinDay"), (6,  "FieldFloors"),       (27, "FieldMoveBar"),
    (35, "FieldSpeed"),        (1,  "FieldHR"),           (24, "FieldHRMean"),
    (30, "FieldHRMax"),        (9,  "FieldSpO2"),         (23, "FieldResp"),
    (22, "FieldBodyBat"),      (21, "FieldStress"),       (26, "FieldRecovery"),
    (36, "FieldSleep"),        (34, "FieldVo2Max"),       (5,  "FieldAltitude"),
    (32, "FieldElevation"),    (28, "FieldTempWrist"),    (31, "FieldPressure"),
    (37, "FieldSunrise"),      (38, "FieldSunset"),       (39, "FieldSunriseSunset"),
    (40, "FieldCalendar"),     (41, "FieldWeeklyRun"),    (42, "FieldWeeklyBike"),
    (43, "FieldGpsLat"),       (44, "FieldGpsLon"),       (45, "FieldGpsAccuracy"),
    (46, "FieldHeading"),      (48, "FieldTrainingStatus"),
    (49, "FieldRace5k"),       (50, "FieldRace10k"),      (51, "FieldRaceHalf"),
    (52, "FieldRaceMarathon"), (53, "FieldSleepTime"),    (54, "FieldWakeTime"),
    (11, "FieldWxTemp"),       (12, "FieldWxFeels"),
    (16, "FieldWxCond"),       (13, "FieldWxPrecip"),     (14, "FieldWxWind"),
    (15, "FieldWxUV"),         (17, "FieldWxTempCond"),   (18, "FieldWxTempMinMax"),
    (19, "FieldWxCondPrecip"), (20, "FieldWxTempWind"),   (33, "FieldWxForecast"),
]

# Graph-capable sensor fields.
# Each entry: (camelKey, StringPrefix, view_default, graph_type_default,
#              sec_type_default, sec_field_default, time_frame_default,
#              graph_color_default, sec_color_default)
# sec_field_default is an index into GRAPH_SEC_FIELDS below.
GRAPH_FIELDS = [
    ("hr",        "HR",           2, 0, 0, 1,  60,  5, 0),
    ("bodyBat",   "BodyBat",      0, 0, 0, 2,  60,  0, 0),
    ("stress",    "Stress",       1, 0, 0, 0,  60, 10, 0),  # gradient low→high line
    ("spo2",      "SpO2",         0, 0, 0, 0,  60,  0, 0),
    ("tempWrist", "TempWrist",    0, 0, 0, 0,  60,  0, 0),
    ("elevation", "Elevation",    2, 0, 0, 6,  480, 1, 0),
    ("pressure",  "Pressure",     2, 0, 0, 5,  30,  0, 0),
]

# Secondary field options shared by all graph secondary-field pickers
GRAPH_SEC_FIELDS = [
    (0, "FieldHR"), (1, "FieldBodyBat"), (2, "FieldStress"),
    (3, "FieldSpO2"), (4, "FieldTempWrist"), (5, "FieldElevation"),
    (6, "FieldPressure"),
]

GRAPH_TIME_FRAMES = [
    (15, "TimeFrame15m"), (30, "TimeFrame30m"), (60, "TimeFrame1h"),
    (120, "TimeFrame2h"), (240, "TimeFrame4h"), (480, "TimeFrame8h"),
    (1440, "TimeFrame24h"),
]

FORECAST_TIME_FRAMES = [
    (3, "TimeFrameForecast3h"), (6, "TimeFrameForecast6h"),
    (12, "TimeFrameForecast12h"), (24, "TimeFrameForecast24h"),
]

# Line 3/4/5 defaults: (line_num, slot, field_default, label_color_default, value_color_default)
LINE_SLOTS = [
    (3, "Primary",   18, 6, 0),  # Temp+MinMax, blue label
    (3, "Secondary", 19, 6, 0),  # Cond+Rain, blue label
    (3, "Tertiary",  33, 6, 0),  # Forecast, blue label
    (4, "Primary",    0, 1, 0),  # Steps, green label, white value text
    (4, "Secondary", 32, 1, 0),  # Elevation, green label
    (4, "Tertiary",   4, 1, 0),  # Distance day, green label
    (5, "Primary",    1, 5, 0),  # HR, red label
    (5, "Secondary", 21, 5, 0),  # Stress, red label
    (5, "Tertiary",  2, 5, 0),   # Calories day, red label
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

def setting_bool(prop_key, title_key):
    return (
        f'  <setting propertyKey="@Properties.{prop_key}" title="@Strings.{title_key}">\n'
        f'    <settingConfig type="boolean" />\n'
        f'  </setting>'
    )

def setting_list(prop_key, title_key, entries, indent=1):
    i = ind(indent)
    lines = [
        f'{i}<setting propertyKey="@Properties.{prop_key}" title="@Strings.{title_key}">',
        f'{i}  <settingConfig type="list">',
    ]
    for val, label in entries:
        lines.append(f'{i}    <listEntry value="{val}">{label}</listEntry>')
    lines.append(f'{i}  </settingConfig>')
    lines.append(f'{i}</setting>')
    return "\n".join(lines)

def color_entries(colors):
    return [(v, f"@Strings.{s}") for v, s in colors]

def field_entries(fields):
    return [(v, f"@Strings.{s}") for v, s in fields]

def color_setting(prop_key, title_key, colors=COLORS_FULL):
    return setting_list(prop_key, title_key, color_entries(colors))

def field_setting(prop_key, title_key, fields=FIELDS_ALL):
    return setting_list(prop_key, title_key, field_entries(fields))

def section(title, *blocks):
    parts = [f"\n  <!-- {title} -->"]
    for b in blocks:
        parts.append(b)
    return "\n".join(parts)

# ---------------------------------------------------------------------------
# properties.xml
# ---------------------------------------------------------------------------

def gen_properties():
    lines = ["<properties>"]

    lines.append("\n  <!-- Appearance -->")
    lines.append(prop("fontChoice", "number", 0))
    lines.append(prop("scanlines",  "number", 2))

    lines.append("\n  <!-- Display options -->")
    lines.append(prop("showSeconds",    "boolean", "false"))
    lines.append(prop("showYear",       "boolean", "false"))
    lines.append(prop("dateFormat",         "number",  0))
    lines.append(prop("watchCommandStyle", "number",  2))
    lines.append(prop("rotateInterval",    "number",  5))

    lines.append("\n  <!-- Time row (always visible) -->")
    lines.append(prop("line1LabelColor", "number", 8))
    lines.append(prop("line1ValueColor", "number", 0))

    lines.append("\n  <!-- Date row (always visible) -->")
    lines.append(prop("line2LabelColor", "number", 8))
    lines.append(prop("line2ValueColor", "number", 0))

    for ln, slot, fd, lc, vc in LINE_SLOTS:
        if slot == "Primary":
            lines.append(f"\n  <!-- Line {ln} -->")
        k = f"line{ln}{slot}"
        lines.append(prop(f"{k}",           "number", fd))
        lines.append(prop(f"{k}LabelColor", "number", lc))
        lines.append(prop(f"{k}ValueColor", "number", vc))

    lines.append("\n  <!-- Steps -->")
    lines.append(prop("stepsViewMode", "number", 2))
    lines.append(prop("stepsBarColor",  "number", 1))  # green

    lines.append("\n  <!-- Graph settings per supported field type -->")
    for key, skey, vd, gtd, std, sfd, tfd, gcd, scd in GRAPH_FIELDS:
        lines.append(f"\n  <!-- {skey} -->")
        lines.append(prop(f"{key}ViewMode",       "number", vd))
        lines.append(prop(f"{key}GraphType",      "number", gtd))
        lines.append(prop(f"{key}SecondaryType",  "number", std))
        lines.append(prop(f"{key}SecondaryField", "number", sfd))
        lines.append(prop(f"{key}TimeFrame",      "number", tfd))
        lines.append(prop(f"{key}GraphColor",     "number", gcd))
        lines.append(prop(f"{key}SecondaryColor", "number", scd))

    lines.append("\n  <!-- Weather Forecast -->")
    lines.append(prop("wxForecastViewMode",   "number", 2))  # graph+value
    lines.append(prop("wxForecastGraphType",  "number", 1))  # bar
    lines.append(prop("wxForecastTimeFrame",  "number", 12))  # 12h
    lines.append(prop("wxForecastGraphColor", "number", 12))  # ColorGradTemp (cold→hot)

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
    lines.append(s("FontChoice",        "Font"))
    lines.append(s("FontJetBrainsMono", "JetBrains Mono"))
    lines.append(s("FontSpaceMono",     "Space Mono"))
    lines.append(s("FontFiraCodeMono",  "Fira Code Mono"))
    lines.append(s("NBArchitekt",       "NB Architekt"))
    lines.append(s("Scanlines",         "Scanlines"))
    lines.append(s("ScanlinesOff",      "Off"))
    lines.append(s("ScanlinesSubtle",   "Subtle"))
    lines.append(s("ScanlinesMedium",   "Medium"))
    lines.append(s("ScanlinesStrong",   "Strong"))

    lines.append("\n  <!-- Display options -->")
    lines.append(s("ShowSeconds",         "Show Seconds"))
    lines.append(s("ShowYear",            "Show Year in Date"))
    lines.append(s("DateFormat",          "Date Format"))
    lines.append(s("DateFormatDayMon",    "Day Month (Mon, 1 Jan)"))
    lines.append(s("DateFormatYMD",       "ISO (YYYY-MM-DD)"))
    lines.append(s("DateFormatDMY",       "DD-MM-YYYY"))
    lines.append(s("DateFormatMDY",       "MM-DD-YYYY"))
    lines.append(s("DateFormatDayNum",    "Day Name + Number (Mon 14)"))
    lines.append(s("DateFormatDMon",      "Date + Month (14 Jun)"))
    lines.append(s("RotateInterval",      "Rotate Every"))

    lines.append(s("WatchCommandStyle",   "Command Style"))
    lines.append(s("WatchCommandWindows", "Windows (watch.bat)"))
    lines.append(s("WatchCommandLinux",   "Linux (watch.sh)"))
    lines.append(s("WatchCommandBare",    "Bare (watch)"))

    lines.append("\n  <!-- Fixed rows -->")
    lines.append(s("Line1LabelColor", "Time: Label Color"))
    lines.append(s("Line1ValueColor", "Time: Value Color"))
    lines.append(s("Line2LabelColor", "Date: Label Color"))
    lines.append(s("Line2ValueColor", "Date: Value Color"))

    lines.append("\n  <!-- Configurable lines (R2/R3 = rotation slots 2 and 3) -->")
    for ln, slot, *_ in LINE_SLOTS:
        suffix = "" if slot == "Primary" else f" (R{'2' if slot=='Secondary' else '3'})"
        k = f"Line{ln}{slot}"
        lines.append(s(f"{k}",            f"Line {ln}: Field{suffix}"))
        lines.append(s(f"{k}LabelColor",  f"Line {ln}: Label Color{suffix}"))
        lines.append(s(f"{k}ValueColor",  f"Line {ln}: Value Color{suffix}"))

    lines.append("\n  <!-- Shared: color options -->")
    color_labels = [
        ("ColorWhite",       "White"),               ("ColorGreen",   "Green"),
        ("ColorCyan",        "Cyan"),                ("ColorYellow",  "Yellow"),
        ("ColorOrange",      "Orange"),              ("ColorRed",     "Red"),
        ("ColorBlue",        "Blue"),                ("ColorMagenta", "Magenta"),
        ("ColorLightGrey",   "Light Grey"),          ("ColorPurple",  "Purple"),
        ("ColorGrad",        "Gradient (low→high)"),
        ("ColorGradRev",     "Gradient (high→low)"),
        ("ColorGradTemp",    "Temp (cold→hot)"),
        ("ColorGradTempRev", "Temp (hot→cold)"),
    ]
    for sid, text in color_labels:
        lines.append(s(sid, text))

    lines.append("\n  <!-- Shared: field options -->")
    field_labels = [
        ("FieldNone",          "None (hidden)"),
        ("FieldSteps",         "Steps"),
        ("FieldHR",            "Heart Rate"),
        ("FieldCalories",      "Calories (Daily)"),
        ("FieldCalAct",        "Calories (Activity)"),
        ("FieldDistance",      "Distance (Daily)"),
        ("FieldAltitude",      "Altitude"),
        ("FieldFloors",        "Stairs"),
        ("FieldSpO2",          "Blood Oxygen"),
        ("FieldActiveMin",     "Intensity Mins"),
        ("FieldStress",        "Stress Score"),
        ("FieldBodyBat",       "Body Battery"),
        ("FieldResp",          "Respiration Rate"),
        ("FieldHRMean",        "Heart Rate (Mean)"),
        ("FieldWxTemp",        "Weather: Temperature"),
        ("FieldWxFeels",       "Weather: Feels Like"),
        ("FieldWxPrecip",      "Weather: Precipitation"),
        ("FieldWxWind",        "Weather: Wind"),
        ("FieldWxUV",          "Weather: UV Index"),
        ("FieldWxCond",        "Weather: Condition"),
        ("FieldWxTempCond",    "Weather: Temp + Condition"),
        ("FieldWxTempMinMax",  "Weather: Temp + Min/Max"),
        ("FieldWxCondPrecip",  "Weather: Condition + Rain"),
        ("FieldWxTempWind",    "Weather: Temp + Wind"),
        ("FieldRecovery",      "Recovery Time"),
        ("FieldMoveBar",       "Move Bar"),
        ("FieldTempWrist",     "Wrist Temperature"),
        ("FieldActiveMinDay",  "Active Mins (Daily)"),
        ("FieldHRMax",         "Heart Rate (Max)"),
        ("FieldPressure",      "Pressure"),
        ("FieldElevation",     "Elevation (Baro)"),
        ("FieldWxForecast",    "Weather: Forecast"),
        ("FieldVo2Max",        "VO2 Max"),
        ("FieldSpeed",         "Speed"),
        ("FieldSleep",         "Sleep"),
        ("FieldSunrise",       "Sunrise"),
        ("FieldSunset",        "Sunset"),
        ("FieldSunriseSunset", "Sunrise + Sunset"),
        ("FieldCalendar",      "Calendar Event"),
        ("FieldWeeklyRun",     "Distance (Wk. Run)"),
        ("FieldWeeklyBike",    "Distance (Wk. Bike)"),
        ("FieldGpsLat",        "GPS Latitude"),
        ("FieldGpsLon",        "GPS Longitude"),
        ("FieldGpsAccuracy",   "GPS Accuracy"),
        ("FieldHeading",            "Heading"),
        ("FieldTrainingStatus",     "Training Status"),
        ("FieldRace5k",             "Race Predictor: 5K"),
        ("FieldRace10k",            "Race Predictor: 10K"),
        ("FieldRaceHalf",           "Race Predictor: Half Marathon"),
        ("FieldRaceMarathon",       "Race Predictor: Marathon"),
        ("FieldSleepTime",          "Bedtime"),
        ("FieldWakeTime",           "Wake Time"),
    ]
    for sid, text in field_labels:
        lines.append(s(sid, text))

    lines.append("\n  <!-- Shared: graph view mode options -->")
    lines.append(s("ViewModeValue",       "Value"))
    lines.append(s("ViewModeGraph",       "Graph"))
    lines.append(s("ViewModeGraphCurrent",  "Graph + Current"))
    lines.append(s("ViewModeGraphMinMax", "Graph + Min/Max"))

    lines.append("\n  <!-- Steps view mode -->")
    lines.append(s("StepsViewMode",         "Steps: View Mode"))
    lines.append(s("StepsViewModeText",     "Value"))
    lines.append(s("StepsViewModeBar",      "Progress Bar"))
    lines.append(s("StepsViewModeBarValue", "Bar + Value"))
    lines.append(s("StepsBarColor",         "Steps: Bar Color"))

    lines.append("\n  <!-- Shared: graph type options -->")
    lines.append(s("GraphTypeLine", "Line"))
    lines.append(s("GraphTypeBar",  "Bar"))

    lines.append("\n  <!-- Shared: secondary graph type options -->")
    lines.append(s("SecTypeNone", "None (hidden)"))
    lines.append(s("SecTypeLine", "Line"))
    lines.append(s("SecTypeBar",  "Bar"))

    lines.append("\n  <!-- Shared: graph time frame options -->")
    lines.append(s("TimeFrame15m", "15 minutes"))
    lines.append(s("TimeFrame30m", "30 minutes"))
    lines.append(s("TimeFrame1h",  "1 hour"))
    lines.append(s("TimeFrame2h",  "2 hours"))
    lines.append(s("TimeFrame4h",  "4 hours"))
    lines.append(s("TimeFrame8h",  "8 hours"))
    lines.append(s("TimeFrame24h", "24 hours"))

    # Graph settings strings — one block per graph field
    graph_display_names = {
        "hr":        ("HR",        "Heart Rate"),
        "bodyBat":   ("BodyBat",   "Body Battery"),
        "stress":    ("Stress",    "Stress"),
        "spo2":      ("SpO2",      "Blood O2"),
        "tempWrist": ("TempWrist", "Wrist Temp"),
        "elevation": ("Elevation", "Elevation"),
        "pressure":  ("Pressure",  "Pressure"),
    }
    for key, skey, *_ in GRAPH_FIELDS:
        _, display = graph_display_names[key]
        lines.append(f"\n  <!-- Graph settings: {display} -->")
        lines.append(s(f"{skey}ViewMode",       f"{display}: View Mode"))
        lines.append(s(f"{skey}GraphType",      f"{display}: Graph Type"))
        lines.append(s(f"{skey}SecondaryType",  f"{display}: 2nd Graph Type"))
        lines.append(s(f"{skey}SecondaryField", f"{display}: 2nd Graph Field"))
        lines.append(s(f"{skey}TimeFrame",      f"{display}: Time Frame"))
        lines.append(s(f"{skey}GraphColor",     f"{display}: Graph Color"))
        lines.append(s(f"{skey}SecondaryColor", f"{display}: 2nd Graph Color"))

    lines.append("\n  <!-- Graph settings: Weather Forecast -->")
    lines.append(s("WxForecastViewMode",   "Forecast: View Mode"))
    lines.append(s("WxForecastGraphType",  "Forecast: Graph Type"))
    lines.append(s("WxForecastTimeFrame",  "Forecast: Time Frame"))
    lines.append(s("WxForecastGraphColor", "Forecast: Graph Color"))
    lines.append(s("TimeFrameForecast3h",  "3 hours ahead"))
    lines.append(s("TimeFrameForecast6h",  "6 hours ahead"))
    lines.append(s("TimeFrameForecast12h", "12 hours ahead"))
    lines.append(s("TimeFrameForecast24h", "24 hours ahead"))

    lines.append("\n  <!-- Debug -->")
    lines.append(s("ShowVersion", "Show App Version (testing)"))

    lines.append("\n</strings>")
    return "\n".join(lines) + "\n"

# ---------------------------------------------------------------------------
# settings.xml
# ---------------------------------------------------------------------------

def graph_section(key, skey, vd, gtd, std, sfd, tfd, gcd, scd):
    display_map = {
        "hr": "Heart Rate", "bodyBat": "Body Battery", "stress": "Stress",
        "spo2": "Blood O2", "tempWrist": "Wrist Temp",
        "elevation": "Elevation", "pressure": "Pressure",
    }
    display = display_map[key]
    blocks = [f"\n  <!-- {display} -->"]

    blocks.append(setting_list(f"{key}ViewMode", f"{skey}ViewMode", [
        (0, "@Strings.ViewModeValue"),
        (1, "@Strings.ViewModeGraph"),
        (2, "@Strings.ViewModeGraphCurrent"),
    ]))
    blocks.append(setting_list(f"{key}GraphType", f"{skey}GraphType", [
        (0, "@Strings.GraphTypeLine"), (1, "@Strings.GraphTypeBar"),
    ]))
    blocks.append(setting_list(f"{key}SecondaryType", f"{skey}SecondaryType", [
        (0, "@Strings.SecTypeNone"),
        (1, "@Strings.SecTypeLine"),
        (2, "@Strings.SecTypeBar"),
    ]))
    blocks.append(setting_list(f"{key}SecondaryField", f"{skey}SecondaryField",
                               [(v, f"@Strings.{s}") for v, s in GRAPH_SEC_FIELDS]))
    blocks.append(setting_list(f"{key}TimeFrame", f"{skey}TimeFrame",
                               [(v, f"@Strings.{s}") for v, s in GRAPH_TIME_FRAMES]))
    blocks.append(color_setting(f"{key}GraphColor",     f"{skey}GraphColor"))
    blocks.append(color_setting(f"{key}SecondaryColor", f"{skey}SecondaryColor"))

    return "\n".join(blocks)


def gen_settings():
    parts = ["<settings>"]

    # Appearance
    parts.append("\n  <!-- Appearance -->")
    parts.append(setting_list("fontChoice", "FontChoice", [
        (0, "@Strings.FontJetBrainsMono"), (1, "@Strings.FontSpaceMono"),
        (2, "@Strings.FontFiraCodeMono"),  (3, "@Strings.NBArchitekt"),
    ]))
    parts.append(setting_list("scanlines", "Scanlines", [
        (0, "@Strings.ScanlinesOff"),   (1, "@Strings.ScanlinesSubtle"),
        (2, "@Strings.ScanlinesMedium"),(3, "@Strings.ScanlinesStrong"),
    ]))

    # Display options
    parts.append("\n  <!-- Display options -->")
    parts.append(setting_bool("showSeconds", "ShowSeconds"))
    parts.append(setting_bool("showYear",    "ShowYear"))
    parts.append(setting_list("watchCommandStyle", "WatchCommandStyle", [
        (0, "@Strings.WatchCommandWindows"),
        (1, "@Strings.WatchCommandLinux"),
        (2, "@Strings.WatchCommandBare"),
    ]))
    parts.append(setting_list("dateFormat", "DateFormat", [
        (0, "@Strings.DateFormatDayMon"), (1, "@Strings.DateFormatYMD"),
        (2, "@Strings.DateFormatDMY"),    (3, "@Strings.DateFormatMDY"),
        (4, "@Strings.DateFormatDayNum"), (5, "@Strings.DateFormatDMon"),
    ]))
    parts.append(setting_list("rotateInterval", "RotateInterval", [
        (3, "3 seconds"), (5, "5 seconds"), (10, "10 seconds"),
        (15, "15 seconds"), (30, "30 seconds"), (60, "1 minute"),
    ]))

    # Fixed rows (time & date)
    for ln, lbl in [(1, "Time"), (2, "Date")]:
        parts.append(f"\n  <!-- {lbl} row -->")
        parts.append(color_setting(f"line{ln}LabelColor", f"Line{ln}LabelColor"))
        parts.append(color_setting(f"line{ln}ValueColor", f"Line{ln}ValueColor"))

    # Configurable lines 3/4/5
    prev_ln = None
    for ln, slot, fd, lc, vc in LINE_SLOTS:
        if ln != prev_ln:
            parts.append(f"\n  <!-- Line {ln} -->")
            prev_ln = ln
        k = f"line{ln}{slot}"
        parts.append(field_setting(k, f"Line{ln}{slot}"))
        parts.append(color_setting(f"{k}LabelColor", f"Line{ln}{slot}LabelColor"))
        parts.append(color_setting(f"{k}ValueColor", f"Line{ln}{slot}ValueColor"))

    # Steps
    parts.append("\n  <!-- Steps -->")
    parts.append(setting_list("stepsViewMode", "StepsViewMode", [
        (0, "@Strings.StepsViewModeText"),
        (1, "@Strings.StepsViewModeBar"),
        (2, "@Strings.StepsViewModeBarValue"),
    ]))
    parts.append(color_setting("stepsBarColor", "StepsBarColor"))

    # Graph fields
    parts.append("\n  <!-- Graph settings per supported field type -->")
    for row in GRAPH_FIELDS:
        parts.append(graph_section(*row))

    # Forecast
    parts.append("\n  <!-- Weather Forecast -->")
    parts.append(setting_list("wxForecastViewMode", "WxForecastViewMode", [
        (1, "@Strings.ViewModeGraph"),
        (2, "@Strings.ViewModeGraphCurrent"),
        (3, "@Strings.ViewModeGraphMinMax"),
    ]))
    parts.append(setting_list("wxForecastGraphType", "WxForecastGraphType", [
        (0, "@Strings.GraphTypeLine"), (1, "@Strings.GraphTypeBar"),
    ]))
    parts.append(setting_list("wxForecastTimeFrame", "WxForecastTimeFrame",
                               [(v, f"@Strings.{s}") for v, s in FORECAST_TIME_FRAMES]))
    parts.append(color_setting("wxForecastGraphColor", "WxForecastGraphColor"))

    # Debug
    parts.append("\n  <!-- Debug -->")
    parts.append(setting_bool("showVersion", "ShowVersion"))

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
    # Fix up strings gen — remove the bad placeholder hack and redo it cleanly
    print("Generating resources...")
    write(OUT_PROPERTIES, gen_properties())
    write(OUT_STRINGS,    gen_strings())
    write(OUT_SETTINGS,   gen_settings())
    print("Done.")
