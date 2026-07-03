# TerminalWatchface

A retro terminal-style watchface for Garmin AMOLED devices. All data is rendered as monospaced label/value pairs in a command-line aesthetic — complete with a blinking cursor, optional CRT scanlines, and inline sensor history graphs.

![TerminalWatchface hero](hero.png)

---

## Features

- Monospace terminal layout with shell prompt and blinking cursor
- **Fixed rows** for time and date; **3 configurable data rows** (lines 3–5)
- Each configurable line has **6 rotation slots** (Primary + 5 alternates) that cycle automatically
- Two independent rotation intervals — one for the primary slot, one for alternates
- **3 independent screens**, each switchable on-device via long-press, each with its own full set of line/field/color configuration
- **101 data fields** across activity, health, weather, navigation, and lifestyle categories
- **Inline sensor graphs** — line, bar, or area charts with configurable timeframe, color, and width
- **Dual-overlay graphs** — two sensor histories on the same chart, each with its own color and min/max labels
- **7 forecast graph types** — hourly temp, rain, wind, UV, humidity, cloud cover, and multi-day daily temp
- Progress bars for Steps, Floors, and Intensity Minutes with optional value overlay
- Battery footer with bolt icon while charging, percentage, and estimated days remaining
- Notification count badge in the header (also available as a data row)
- CRT scanline overlay (4 intensity levels)
- **4 font families** with independent line heights
- **20 color options** including 10 value-mapped gradients for independent label and value styling per slot
- Show seconds, optional year in date, 6 date formats, and 12/24-hour display
- 3 command styles (Windows, Linux, Bare) with optional version number in the header
- Metric and imperial unit support

---

## Layout

```text
           [2]                             <- notification count (hidden when 0)

~ > .\watch.bat

Time  : 14:32:08
Date  : Thu, 12 Jun

Heart : 72 bpm                            <- line 3 (rotates between up to 6 fields)
Steps : [========  ] 7823                 <- line 4 (steps bar + value)
Temp  : 18.5° [↓12] [↑24]                <- line 5

~ > _                                     <- blinking cursor

          ⚡ 74% [6d]                     <- battery footer
```

---

## Settings

Settings are grouped into submenus in the Garmin Connect IQ app. Groups prefixed **"Graph Config -"** hold the per-field chart settings (mode, timeframe, color, width); groups prefixed **"Bar Config -"** hold the Steps/Floors/Intensity Minutes progress bar settings. Each screen's line/field/color settings live together in one **"Screen N Configuration"** group rather than being split across several submenus.

### Appearance

| Setting   | Options                                                  |
| --------- | -------------------------------------------------------- |
| Font      | JetBrains Mono, Space Mono, Fira Code Mono, NB Architekt |
| Scanlines | Off, Subtle, Medium, Strong                              |

### Display

| Setting          | Options                                                                                                         |
| ---------------- | --------------------------------------------------------------------------------------------------------------- |
| Show Seconds     | On / Off                                                                                                        |
| Show Year        | On / Off — appends year to compatible date formats                                                              |
| Date Format      | Day Month _(Thu, 1 Jan)_, ISO _(2025-06-12)_, DD-MM-YYYY, MM-DD-YYYY, Day+Num _(Thu 14)_, Date+Month _(14 Jun)_ |
| Command Style    | Windows _(watch.bat)_, Linux _(watch.sh)_, Bare _(watch)_                                                       |
| Show Version     | On / Off — appends app version to the command _(watch@0.44.1)_                                                  |
| Left Padding     | Number of character-widths (0–8) the layout is offset from center                                               |
| Rotate Every     | Primary slot interval: 3s, 5s, 10s, 15s, 30s, 1 min                                                             |
| Rotate Alt Every | Alternate slot interval (Secondary–Senary); defaults to primary if unset                                        |

### Screens

Three independent screens are available; switch between them on-device via long-press. Screen 2 and 3 can each be fully disabled with a master toggle, and each screen has its own enabled toggle per line plus its own field rotations and colors — one screen can look completely different from another.

### Colors (Time and Date rows)

Label and value color can be set independently for the Time and Date rows.

### Lines 3–5 (Configurable, per screen)

Each line has **6 rotation slots** — **Primary**, **Secondary**, **Tertiary**, **Quaternary**, **Quinary**, and **Senary**. The active slot cycles on the rotate interval; slots set to _None_ are skipped. Each slot has its own field, label color, and value color.

---

## Data Fields

Fields that only populate during an actively recorded workout (elapsed time, in-activity speed/pace, in-activity calories/ascent/descent, activity-scoped average/max HR, training effect) are deliberately **not** included — the device shows the activity data screen during a recording, not the watchface, so those fields would never actually be seen by a user.

### Activity & Fitness

| Field                  | Example             |
| ---------------------- | ------------------- |
| Steps                  | `7823/10000 [GOAL]` |
| Heart Rate             | `72 bpm`            |
| Lactate Threshold HR   | `162 bpm`           |
| Calories (Daily)       | `1840 kcal`         |
| Daily Distance         | `4.32 km`           |
| Altitude               | `124 m`             |
| Floors                 | `↑8  ↓3`            |
| Move Bar               | `2/5`               |
| Active Minutes (Daily) | `38`                |
| Intensity Minutes      | `142`               |
| Climb Day              | `45 m`              |
| Descent Day            | `20 m`              |
| Climb + Descent Day    | `45 m \| 20 m`      |
| Solar Input            | `87%`               |
| Solar Input + Battery  | `87% \| 74%`        |

### Health & Recovery

| Field                 | Example         |
| --------------------- | --------------- |
| Body Battery          | `74%`           |
| Stress                | `32`            |
| Blood Oxygen (SpO2)   | `97%`           |
| Respiration Rate      | `14/m`          |
| Recovery Time         | `18h`           |
| Wrist Temperature     | `36.5°C`        |
| VO2 Max               | `52`            |
| Training Status       | `PRODUCTIVE`    |
| Sleep Score           | `78`            |
| Resting HR            | `52 bpm`        |
| Avg Resting HR        | `54 bpm`        |
| Resting HR + Avg      | `52 \| 54`      |
| HR + SpO2             | `72 bpm \| 97%` |
| Resp + SpO2           | `14/m \| 97%`   |
| Body Bat + Stress     | `74% \| 32`     |
| Body Bat + Recovery   | `74% \| 18h`    |
| Body Bat + Resting HR | `74% \| 52`     |
| Stress + Recovery     | `32 \| 18h`     |
| Sleep + Recovery      | `78 \| 18h`     |
| VO2 + Training Status | `52 PRODUCTIVE` |

### Navigation & Environment

| Field               | Example                  |
| ------------------- | ------------------------ |
| Elevation (Baro)    | `126 m`                  |
| Barometric Pressure | `1013.2 hPa [R]`         |
| Sea Level Pressure  | `1015.3 hPa`             |
| GPS Latitude        | `52.37020`               |
| GPS Longitude       | `4.89520`                |
| GPS Lat + Lon       | `52.37020, 4.89520`      |
| GPS (with Accuracy) | `52.3702, 4.8952 [FAIR]` |
| GPS Accuracy        | `FAIR`                   |
| Heading             | `247°`                   |

Barometric Pressure shows a trend tag: `[R]` rising, `[F]` falling. GPS Accuracy is color-coded and tagged `GOOD` / `FAIR` / `POOR` / `LAST` / `N/A` (green/yellow/orange/grey/red).

### Schedule & Lifestyle

| Field            | Example              |
| ---------------- | -------------------- |
| Sunrise          | `05:42`              |
| Sunset           | `22:08`              |
| Sunrise + Sunset | `05:42 / 22:08`      |
| Calendar Event   | `Meeting 14:00`      |
| Bedtime          | `23:00`              |
| Wake Time        | `07:00`              |
| Sleep Schedule   | `23:00 \| 07:00`     |
| Notifications    | `3`                  |
| Weather Data Age | `14m`                |
| Weekly Run       | `24.5 km`            |
| Weekly Bike      | `80.2 km`            |
| Run + Bike       | `24.5 km \| 80.2 km` |

### Race Predictors

| Field              | Example    |
| ------------------ | ---------- |
| Race 5K            | `24:12`    |
| Race 10K           | `50:18`    |
| Race Half Marathon | `1:52:40`  |
| Race Marathon      | `3:58:00`  |
| 5K Pace            | `4:51 /km` |
| 10K Pace           | `5:02 /km` |
| Half Marathon Pace | `5:20 /km` |
| Marathon Pace      | `5:39 /km` |

### Weather — Current

| Field            | Example                 |
| ---------------- | ----------------------- |
| Temperature      | `18.5°C`                |
| Feels Like       | `16.2°C`                |
| Condition        | `[PCLOUD]`              |
| Rain %           | `60%`                   |
| Wind Speed       | `14 km/h NW`            |
| UV Index         | `5 [AVG]`               |
| Cloud Cover      | `45%`                   |
| Humidity         | `72%`                   |
| Dew Point        | `11.2°C`                |
| Visibility       | `10 km`                 |
| Heat Index       | `22.0°C`                |
| Temp Hi/Lo       | `↑24°C / ↓12°C`         |
| Temp + Condition | `18.5°C \| [PCLOUD]`    |
| Temp + Wind      | `18.5°C \| 14 km/h NW`  |
| Temp + UV        | `18.5°C \| 5 [AVG]`     |
| Temp + Humidity  | `18.5°C 72%`            |
| Temp + Rain      | `18.5°C 60%`            |
| Temp + High/Low  | `18.5° [↑24] [↓12]`     |
| Cond + Rain      | `[PCLOUD] 60%`          |
| Wind + Rain      | `14 km/h NW \| 60%`     |
| UV + Rain        | `5 [AVG] \| 60%`        |
| UV + Wind        | `5 [AVG] \| 14 km/h NW` |
| Hum + Rain       | `72% \| 60%`            |
| Cloud + Rain     | `45% \| 60%`            |
| Hum + Dew Point  | `72% \| 11.2°C`         |
| Cond / +1d       | `[PCLOUD] \| [RAIN]`    |
| +1d / +2d        | `[RAIN] \| [CLEAR]`     |
| Forecast +1d     | `[RAIN]`                |
| Forecast +2d     | `[CLEAR]`               |
| Forecast +3d     | `[CLEAR]`               |

UV Index is shown with a color-coded level tag: `[LOW]` (green), `[AVG]` (yellow), `[HIGH]` (orange), `[MAX]` (red).

### Weather — Forecast Graphs

| Field             | Data source           |
| ----------------- | --------------------- |
| Temp Forecast     | Hourly temperature    |
| Rain % Forecast   | Hourly precipitation  |
| Wind Forecast     | Hourly wind speed     |
| Humidity Forecast | Hourly humidity       |
| UV Forecast       | Hourly UV index       |
| Cloud Forecast    | Hourly cloud cover    |
| Daily Forecast    | Multi-day temperature |

---

## Graphs

Seven sensor fields and seven forecast types can be displayed as **inline charts** instead of (or alongside) a plain value. The chart fills the value area of the row for the configured timeframe.

### Sensor graph fields

| Field             | History source |
| ----------------- | -------------- |
| Heart Rate        | SensorHistory  |
| Body Battery      | SensorHistory  |
| Stress            | SensorHistory  |
| Blood Oxygen      | SensorHistory  |
| Wrist Temp        | SensorHistory  |
| Elevation (Baro)  | SensorHistory  |
| Barometric Press. | SensorHistory  |

### Graph settings (per sensor field, in its own "Graph Config -" group)

| Setting         | Options                                                             |
| --------------- | ------------------------------------------------------------------- |
| Graph Mode      | Value, Line, Bar, Line+Value, Bar+Value, Area, Area+Value           |
| Time Frame      | 15m, 30m, 1h, 2h, 4h, 8h, 12h, 24h                                  |
| Graph Color     | Any of the 20 available colors                                      |
| Graph Width     | Width in character units (6, 8, 10, 12, 14, or 16)                  |
| Value Display   | Current, Average, Max/Min, Midpoint                                 |
| Secondary Type  | None, Line, Bar                                                     |
| Secondary Field | HR, Body Battery, Stress, Blood O2, Wrist Temp, Elevation, Pressure |
| Secondary Color | Any of the 20 available colors                                      |
| Area Opacity    | Fill transparency for area graphs (0–255)                           |
| Area Show Line  | On / Off — draw the line curve on top of the area fill              |

**Dual Graph** overlays a secondary sensor history on the same chart. Primary min/max labels appear on the left; secondary on the right. A short field name is shown below the right edge.

The graph caches rendered bitmaps and only re-renders when fresh sensor data arrives (not every minute), which keeps the update cost — and battery impact — low.

### Forecast graph settings (per forecast field, in its own "Graph Config -" group)

| Setting       | Options                                            |
| ------------- | -------------------------------------------------- |
| Graph Mode    | Value, Graph, Graph + Value                        |
| Graph Type    | Line, Bar                                          |
| Time Frame    | 3h, 6h, 12h, 24h (hourly); 3, 5, or 7 days (daily) |
| Graph Color   | Any of the 20 available colors                     |
| Graph Width   | Width in character units                           |
| Value Display | Current, Average, Max/Min                          |

### Progress bars (Steps, Floors, Intensity Minutes, in their own "Bar Config -" groups)

Steps, Floors, and Intensity Minutes each have their own bar display independent of the graph system:

| Mode         | Display                                     |
| ------------ | ------------------------------------------- |
| Value        | numeric value (+ `[GOAL]` tag when reached) |
| Progress Bar | filled bar scaled to today's goal           |
| Bar + Value  | bar with the count overlaid at center       |

Bar color and width are independently configurable for each field.

---

## Battery Footer

| State       | Display           |
| ----------- | ----------------- |
| Normal      | `74% [6d]`        |
| Charging    | `⚡ 74% [6d]`     |
| Low (≤ 10%) | percentage in red |

Days remaining is shown when the device can estimate it. The bolt icon is always shown while charging.

---

## Colors

20 colors are available for label, value, and graph styling on each slot:

| #   | Name                             |
| --- | -------------------------------- |
| 0   | White                            |
| 1   | Green                            |
| 2   | Cyan                             |
| 3   | Yellow                           |
| 4   | Orange                           |
| 5   | Red                              |
| 6   | Blue                             |
| 7   | Magenta                          |
| 8   | Light Grey                       |
| 9   | Purple                           |
| 10  | Gradient: Green → Orange → Red   |
| 11  | Gradient: Red → Orange → Green   |
| 12  | Temperature: Custom (cold→hot)   |
| 13  | Temperature: Custom (hot→cold)   |
| 14  | Temperature: Spectral (cold→hot) |
| 15  | Temperature: Spectral (hot→cold) |
| 16  | Temperature: Turbo (cold→hot)    |
| 17  | Temperature: Turbo (hot→cold)    |
| 18  | Temperature: Inferno (cold→hot)  |
| 19  | Temperature: Inferno (hot→cold)  |

Gradient colors (10–19) map the displayed value to a position along a color spectrum. For sensor graphs they use field-specific ranges (e.g. HR maps 40–200 bpm across the spectrum). For temperature gradients the range is −20 °C to +40 °C. These are most useful on graphs and for value coloring on fields like heart rate, stress, or temperature.

---

## Devices

Supported devices share a 454×454 AMOLED display and Connect IQ API level 6.0.2+:

- Garmin fēnix 8 47mm / 51mm / tactix 8 / quatix 8 (`fenix847mm`)
- Garmin fēnix 8 Pro 47mm / 51mm / MicroLED / quatix 8 Pro (`fenix8pro47mm`)
- Garmin Forerunner 570 47mm (`fr57047mm`)
- Garmin Forerunner 970 (`fr970`)
- Garmin Venu 4 45mm / D2 Air X15 (`venu445mm`)
