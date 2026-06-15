# TerminalWatchface

A retro terminal-style watchface for the **Garmin Fenix 8 47mm AMOLED**. Displays data as monospaced label/value pairs in a command-line aesthetic, complete with a blinking cursor, optional scanlines, and a battery footer.

---

## Features

- Monospace terminal layout with a blinking cursor and shell prompt
- 5 configurable data rows: time and date are always shown, lines 3-5 are fully customizable
- Each configurable line supports up to 3 rotation slots that cycle automatically on a set interval
- Battery footer with a bolt icon while charging, percentage and estimated days remaining
- Notification count badge in the header
- CRT scanline overlay effect (4 intensity levels)
- 3 font families in 3 sizes each

---

## Layout

```
         [2]                 <- notification count (hidden when 0)

~ > .\watch.bat

Time : 14:32
Date : Thu, 12 Jun

Temp : 18.5°C [↓12] [↑24]    <- line 3 (rotates)
Step : 007823 [GOAL]         <- line 4 (rotates)
Rate : 72                    <- line 5 (rotates)

~ > _                        <- blinking cursor

        ⚡ 74% [6d]          <- battery footer
```

---

## Settings

### Appearance
| Setting | Options |
|---|---|
| Font | JetBrains Mono, Space Mono, Fira Code Mono |
| Font Size | Small, Medium, Large |
| Scanlines | Off, Subtle, Medium, Strong |

### Display
| Setting | Options |
|---|---|
| Date Format | Day Month (Mon, 1 Jan), ISO (YYYY-MM-DD), DD-MM-YYYY, MM-DD-YYYY |
| Rotate Every | 3s, 5s, 10s, 15s, 30s, 1 min |

### Lines 1-2 (Time & Date)
Label and value color can be set independently.

### Lines 3-5 (Configurable)
Each line has three rotation slots — Primary, R2, and R3. The active slot cycles through on the rotate interval. If R2 or R3 are set to None, those slots are skipped. Each slot has its own field, label color, and value color.

#### Available data fields
| Field | Label | Example |
|---|---|---|
| Steps | `Step` | `007823 [GOAL]` |
| Heart Rate | `Rate` | `72` |
| Calories | `Kcal` | `1840` |
| Distance | `Dist` | `4.32km` |
| Altitude | `Alti` | `124m` |
| Stairs | `Strs` | `↑8  ↓3` |
| Blood Oxygen | `SpO2` | `97%` |
| Intensity Mins | `Intv` | `142` |
| Weather: Temperature | `Temp` | `18.5°C` |
| Weather: Feels Like | `Feel` | `16.2°C` |
| Weather: Precipitation | `Rain` | `20%` |
| Weather: Wind | `Wind` | `14km/h NW` |
| Weather: UV Index | `UVIn` | `3` |
| Weather: Condition | `Cond` | `[PCLOUD]` |
| Weather: Temp + Condition | `Temp` | `18.5°C [CLEAR]` |
| Weather: Temp + Min/Max | `Temp` | `18.5°C [↓12] [↑24]` |
| Weather: Condition + Rain | `Cond` | `[RAIN] 60%` |
| Weather: Temp + Wind | `Temp` | `18.5°C 14km/h NW` |

#### Available colors
White, Green, Cyan, Yellow, Orange, Red, Blue, Magenta, Light Grey, Pink, Lime, Teal, Purple, Dark Grey, Sky Blue

---

## Battery Footer

| State | Display |
|---|---|
| Charging | bolt icon + `74% [6d]` |
| Normal | `74% [6d]` |
| Low (≤10%) | `8%` in red |
| Full (100%) | `100%` in green |

Days remaining is shown when the device can estimate it. The bolt icon is always shown while charging regardless of percentage.

---

## Device

- **Garmin Fenix 8 47mm AMOLED**
- Connect IQ API level 6.0.0+
- Built with Connect IQ SDK 9.2.0
