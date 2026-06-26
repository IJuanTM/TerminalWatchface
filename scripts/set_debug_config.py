#!/usr/bin/env python3
"""
Applies a debug config to properties.xml so the next build picks it up.

Usage:
    python scripts/set_debug_config.py                  # list available configs
    python scripts/set_debug_config.py config_graphs_bar
    python scripts/set_debug_config.py reset            # restore original defaults
"""

import json
import re
import sys
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "scripts"))

from generate_resources import gen_properties, write, OUT_PROPERTIES, GRAPH_FIELDS, FIELDS_ALL

OUT_DEBUG_DIR = os.path.join(ROOT, "debug")

# ---------------------------------------------------------------------------
# Debug config definitions
# ---------------------------------------------------------------------------

# Line slot assignments for graph test configs
# Line 3: all 6 hourly forecast graph fields (each has a GraphType setting)
_DBG_LINE3 = [33, 61, 64, 86, 73, 85]   # temp, precip, wind, cloud, humidity, UV hourly
# Line 4: first 6 sensor graph fields
_DBG_LINE4 = [1, 22, 21, 9, 28, 32]     # HR, BodyBat, Stress, SpO2, TempWrist, Elevation
# Line 5: remaining sensor graph field + repeats to fill all 6 slots
_DBG_LINE5 = [31, 1, 22, 21, 9, 28]     # Pressure, then repeats from line 4

_FORECAST_GRAPH_KEYS = [
    "wxForecast", "wxForecastPrecip", "wxForecastWind",
    "wxForecastHumidity", "wxForecastUv", "wxForecastCloud",
]

_SLOT_NAMES = ["Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary"]

# Field IDs and sensor keys that don't support continuous (line/area) rendering:
# - SpO2 (9): sensor history is too sparse (manual/sleep-only readings)
_DBG_BAR_ONLY_FIELD_IDS = {9}
_DBG_BAR_ONLY_SENSOR_KEYS = {"spo2"}


def _graph_config(sensor_mode, forecast_type):
    p = {}
    is_continuous = sensor_mode not in (0, 2, 4)  # true for line (1,3) and area (5,6) modes
    for key, *_ in GRAPH_FIELDS:
        p[f"{key}GraphMode"] = 0 if (key in _DBG_BAR_ONLY_SENSOR_KEYS and is_continuous) else sensor_mode
    for fkey in _FORECAST_GRAPH_KEYS:
        p[f"{fkey}GraphType"] = forecast_type
        p[f"{fkey}ViewMode"] = 2
    p["wxForecastDailyViewMode"] = 2
    p["rotateInterval"] = 5
    p["rotateIntervalAlt"] = 0
    for slot, fid in zip(_SLOT_NAMES, _DBG_LINE3):
        p[f"line3{slot}"] = 7 if (is_continuous and fid in _DBG_BAR_ONLY_FIELD_IDS) else fid
    for slot, fid in zip(_SLOT_NAMES, _DBG_LINE4):
        p[f"line4{slot}"] = 7 if (is_continuous and fid in _DBG_BAR_ONLY_FIELD_IDS) else fid
    for slot, fid in zip(_SLOT_NAMES, _DBG_LINE5):
        p[f"line5{slot}"] = 7 if (is_continuous and fid in _DBG_BAR_ONLY_FIELD_IDS) else fid
    return p


def gen_debug_configs():
    configs = {
        "config_graphs_line": _graph_config(3, 0),   # sensor: line+current, forecast: line
        "config_graphs_bar":  _graph_config(4, 1),   # sensor: bar+current,  forecast: bar
        "config_graphs_area": _graph_config(6, 2),   # sensor: area+current, forecast: area
    }

    # Value configs: cycle all non-None fields across 3 lines x 6 slots = 18 per config
    fields = [v for v, _ in FIELDS_ALL if v != 7]
    chunk_size = len(_SLOT_NAMES) * 3
    for i, start in enumerate(range(0, len(fields), chunk_size), 1):
        chunk = fields[start : start + chunk_size]
        p = {}
        for key, *_ in GRAPH_FIELDS:
            p[f"{key}GraphMode"] = 0  # value only
        p["rotateInterval"] = 5
        p["rotateIntervalAlt"] = 0
        idx = 0
        for ln in (3, 4, 5):
            for slot in _SLOT_NAMES:
                p[f"line{ln}{slot}"] = chunk[idx] if idx < len(chunk) else 7
                idx += 1
        configs[f"config_values_{i}"] = p

    return configs


def _write_debug_jsons(configs):
    os.makedirs(OUT_DEBUG_DIR, exist_ok=True)
    for name, props in configs.items():
        path = os.path.join(OUT_DEBUG_DIR, f"{name}.json")
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            json.dump(props, f, indent=2)

# ---------------------------------------------------------------------------
# Apply logic
# ---------------------------------------------------------------------------

def apply_overrides(xml, overrides):
    for pid, val in overrides.items():
        xml, n = re.subn(
            rf'(<property id="{re.escape(pid)}" type="[^"]+">)[^<]*(</property>)',
            rf'\g<1>{val}\2',
            xml,
        )
        if n == 0:
            print(f"  warning: property '{pid}' not found in properties.xml")
    return xml


def main():
    configs = gen_debug_configs()
    _write_debug_jsons(configs)

    if len(sys.argv) < 2:
        print("Available configs:")
        for name in sorted(configs):
            print(f"  {name}")
        print("  reset")
        print(f"\nUsage: python scripts/set_debug_config.py <config_name>")
        return

    name = sys.argv[1]

    if name == "reset":
        write(OUT_PROPERTIES, gen_properties())
        print("Reset to default properties.")
        print("Rebuild to apply (Ctrl+Shift+B in VS Code).")
        return

    if name not in configs:
        print(f"Unknown config '{name}'.")
        print(f"Available: {', '.join(sorted(configs))}")
        sys.exit(1)

    xml = apply_overrides(gen_properties(), configs[name])
    write(OUT_PROPERTIES, xml)
    print(f"Applied '{name}' to properties.xml.")
    print("Rebuild to apply (Ctrl+Shift+B in VS Code).")


if __name__ == "__main__":
    main()
