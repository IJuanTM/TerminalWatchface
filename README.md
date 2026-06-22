# TerminalWatchface

A retro terminal-style watchface for the **Garmin Fenix 8 47mm AMOLED**. All data is rendered as monospaced label/value pairs in a command-line aesthetic — complete with a blinking cursor, optional CRT scanlines, and inline sensor history graphs.

![TerminalWatchface hero](hero.png)

---

## Features

- Monospace terminal layout with shell prompt and blinking cursor
- **5 data rows** — time and date are always shown; lines 3-5 are fully configurable
- Each configurable line has **3 rotation slots** that cycle automatically on a set interval
- **51 data fields** across activity, health, weather, navigation, and lifestyle categories
- **Inline sensor graphs** — line, bar, or dual-overlay charts with configurable timeframe and color
- Steps progress bar with optional value overlay
- Battery footer with bolt icon while charging, percentage, and estimated days remaining
- Notification count badge in the header
- CRT scanline overlay (4 intensity levels)
- **4 font families** with independent line heights
- **14 colors** including value-mapped gradients for independent label and value styling per slot
- Show seconds toggle, optional year in date, and 6 date formats
- 3 command styles (Windows, Linux, Bare)
- Metric and imperial unit support

---

## Layout

```text
           [2]                        <- notification count (hidden when 0)

~ > .\watch.bat

Time  : 14:32:08
Date  : Thu, 12 Jun

Heart : 72 bpm                        <- line 3 (rotates between up to 3 fields)
Steps : [========  ] 7823             <- line 4 (steps bar + value)
Temp  : 18.5° [↓12] [↑24]            <- line 5

~ > _                                 <- blinking cursor

          ⚡ 74% [6d]                <- battery footer
```

---

## Settings

### Appearance

| Setting    | Options                                                    |
|------------|------------------------------------------------------------|
| Font       | JetBrains Mono, Space Mono, Fira Code Mono, NB Architekt   |
| Scanlines  | Off, Subtle, Medium, Strong                                |

### Display

| Setting        | Options                                                                                                         |
|----------------|-----------------------------------------------------------------------------------------------------------------|
| Show Seconds   | On / Off                                                                                                        |
| Show Year      | On / Off — appends year to compatible date formats                                                              |
| Date Format    | Day Month *(Thu, 1 Jan)*, ISO *(2025-06-12)*, DD-MM-YYYY, MM-DD-YYYY, Day+Num *(Thu 14)*, Date+Month *(14 Jun)* |
| Command Style  | Windows *(watch.bat)*, Linux *(watch.sh)*, Bare *(watch)*                                                       |
| Rotate Every   | 3s, 5s, 10s, 15s, 30s, 1 min                                                                                    |

### Colors (Time and Date rows)

Label and value color can be set independently for the Time and Date rows.

### Lines 3-5 (Configurable)

Each line has three rotation slots — **Primary**, **R2**, and **R3**. The active slot cycles on the rotate interval; slots set to *None* are skipped. Each slot has its own field, label color, and value color.

---

## Data Fields

### Activity

| Field                | Example              |
|----------------------|----------------------|
| Steps                | `7823 [GOAL]`        |
| Heart Rate           | `72 bpm`             |
| Heart Rate (Mean)    | `68 bpm`             |
| Heart Rate (Max)     | `185 bpm`            |
| Calories (Daily)     | `1840 kcal`          |
| Calories (Activity)  | `620 kcal`           |
| Distance (Daily)     | `4.32 km`            |
| Stairs               | `↑8  ↓3`             |
| Altitude             | `124 m`              |
| Speed                | `8.4 km/h`           |
| Move Bar             | `2/5`                |
| Intensity Mins       | `142`                |
| Active Mins (Daily)  | `38`                 |
| Sleep                | `7h 24m`             |

### Health & Recovery

| Field              | Example       |
|--------------------|---------------|
| Body Battery       | `74%`         |
| Stress             | `32`          |
| Blood Oxygen       | `97%`         |
| Respiration Rate   | `14/m`        |
| Recovery Time      | `18h`         |
| Wrist Temperature  | `36.5°C`      |
| VO2 Max            | `52`          |
| Training Status    | `PRODUCTIVE`  |

### Navigation & Environment

| Field              | Example         |
|--------------------|-----------------|
| Elevation (Baro)   | `126 m`         |
| Barometric Pressure| `1013.2 hPa`    |
| GPS Latitude       | `52.3702°N`     |
| GPS Longitude      | `4.8952°E`      |
| GPS Accuracy       | `GOOD`          |
| Heading            | `NNW`           |

### Schedule & Lifestyle

| Field              | Example              |
|--------------------|----------------------|
| Sunrise            | `05:42`              |
| Sunset             | `22:08`              |
| Sunrise + Sunset   | `05:42 / 22:08`      |
| Calendar Event     | `Meeting 14:00`      |
| Distance (Wk. Run) | `24.5 km`            |
| Distance (Wk. Bike)| `80.2 km`            |
| Bedtime            | `23:00`              |
| Wake Time          | `07:00`              |

### Race Predictors

| Field              | Example    |
|--------------------|------------|
| 5K                 | `24:12`    |
| 10K                | `50:18`    |
| Half Marathon      | `1:52:40`  |
| Marathon           | `3:58:00`  |

### Weather

| Field                   | Example                 |
|-------------------------|-------------------------|
| Temperature             | `18.5°C`                |
| Feels Like              | `16.2°C`                |
| Condition               | `[PCLOUD]`              |
| Precipitation           | `60%`                   |
| Wind                    | `14 km/h NW`            |
| UV Index                | `3`                     |
| Temp + Condition        | `18.5° [CLEAR]`         |
| Temp + Min/Max          | `18.5° [↓12] [↑24]`     |
| Condition + Rain        | `[RAIN] 60%`            |
| Temp + Wind             | `18.5° 14 km/h NW`      |
| Forecast (graph)        | *(hourly temp chart)*   |

---

## Graphs

Seven sensor fields and the weather forecast can be displayed as **inline history charts** instead of (or alongside) a plain value. The chart is drawn to the right of the label for the configured timeframe, with min/max labels at the corners.

### Graph-capable fields

| Field            | History source      |
|------------------|---------------------|
| Heart Rate       | SensorHistory       |
| Body Battery     | SensorHistory       |
| Stress           | SensorHistory       |
| Blood Oxygen     | SensorHistory       |
| Wrist Temp       | SensorHistory       |
| Elevation (Baro) | SensorHistory       |
| Barometric Press.| SensorHistory       |
| Weather Forecast | Hourly weather data |

### Graph settings (per field)

| Setting          | Options                                                             |
|------------------|---------------------------------------------------------------------|
| View Mode        | Value, Graph, Graph + Current                                       |
| Graph Type       | Line, Bar                                                           |
| Secondary Type   | None, Line, Bar                                                     |
| Secondary Field  | HR, Body Battery, Stress, Blood O2, Wrist Temp, Elevation, Pressure |
| Time Frame       | 15m, 30m, 1h, 2h, 4h, 8h, 24h                                       |
| Graph Color      | Any of the 14 available colors                                      |
| Secondary Color  | Any of the 14 available colors                                      |

**Dual Graph** overlays a secondary sensor history on the same chart. Each series has its own color and min/max labels on opposite sides.

**Weather Forecast** pulls up to 24 hours of hourly temperature data and renders it as a line or bar graph. Time frame options are 3h, 6h, 12h, or 24h ahead. No dual graph for forecast.

### Steps display

Steps has its own display setting independent of the graph system:

| Mode           | Display                         |
|----------------|---------------------------------|
| Value          | `7823 [GOAL]`                   |
| Progress Bar   | filled bar across the row       |
| Bar + Value    | bar with step count overlaid    |

Bar color is configurable independently.

---

## Battery Footer

| State       | Display           |
|-------------|-------------------|
| Normal      | `74% [6d]`        |
| Charging    | `⚡ 74% [6d]`     |
| Low (≤ 10%) | percentage in red |

Days remaining is shown when the device can estimate it. The bolt icon is always shown while charging.

---

## Colors

14 colors are available for label and value styling on each rotation slot:

| #  | Name                       |
|----|----------------------------|
| 0  | White                      |
| 1  | Green                      |
| 2  | Cyan                       |
| 3  | Yellow                     |
| 4  | Orange                     |
| 5  | Red                        |
| 6  | Blue                       |
| 7  | Magenta                    |
| 8  | Light Grey                 |
| 9  | Purple                     |
| 10 | Gradient (low → high)      |
| 11 | Gradient (high → low)      |
| 12 | Temp gradient (cold → hot) |
| 13 | Temp gradient (hot → cold) |

Gradient colors map the displayed value to a color along a spectrum — useful for things like heart rate, stress, or temperature where the value itself communicates urgency.

---

## Device

- **Garmin Fenix 8 47mm AMOLED**
- Connect IQ API level 6.0.2+
