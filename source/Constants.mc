import Toybox.Lang;

const APP_VERSION = "0.59.3";

// FIELD_* constants live in generated source/FieldIds.mc - never hand-edit that file.

const VIEW_VALUE = 0;
const VIEW_GRAPH = 1;
const VIEW_GRAPH_VALUE = 2;

const GRAPH_LINE = 0;
const GRAPH_BAR = 1;
const GRAPH_AREA = 2;

const SEC_NONE = 0;
const SEC_BAR = 2;

const ROTATION_AUTOMATIC = 0;
const ROTATION_MANUAL = 1;
const ROTATION_HYBRID = 2;

const COLOR_GRAD_TRI = 10;
const COLOR_GRAD_TRI_REV = 11;
const COLOR_GRAD_TEMP_CUSTOM = 12;
const COLOR_GRAD_TEMP_CUSTOM_REV = 13;
const COLOR_GRAD_TEMP_SPECTRAL = 14;
const COLOR_GRAD_TEMP_SPECTRAL_REV = 15;
const COLOR_GRAD_TEMP_TURBO = 16;
const COLOR_GRAD_TEMP_TURBO_REV = 17;
const COLOR_GRAD_TEMP_INFERNO = 18;
const COLOR_GRAD_TEMP_INFERNO_REV = 19;

// CACHE_KEY_*, ROTATE_SLOT_NAMES and GRAPH_SEC_FIELDS also live in generated FieldIds.mc.

// Index 0 = white (value default), 8 = light grey (label default). Colon matches label color.
const COLORS =
    [
        0xffffff, 0x55ff77, 0x55ffff, 0xffee55, 0xff9944, 0xff5555, 0x6699ff,
        0xff55ff, 0x777777, 0xaa77ff,
    ] as Array<Number>;

const COLORS_AMBER =
    [
        0xffe0b3, 0xffa833, 0xffb84d, 0xffc966, 0xff9900, 0xcc6600, 0xdb7f00,
        0xe68a00, 0x995200, 0xd97d00,
    ] as Array<Number>;

const COLORS_GREEN =
    [
        0xccffcc, 0x66ff66, 0x88ff88, 0xaaff99, 0x55dd55, 0x22aa33, 0x33bb44,
        0x44cc55, 0x117722, 0x33bd46,
    ] as Array<Number>;

const COLORS_BLUE =
    [
        0xccddff, 0x77aaff, 0x99bbff, 0xaaccff, 0x6699ee, 0x3366bb, 0x4477cc,
        0x5588dd, 0x224488, 0x4478cd,
    ] as Array<Number>;

const COLOR_THEMES =
    [COLORS, COLORS_AMBER, COLORS_GREEN, COLORS_BLUE] as Array<Array<Number> >;

// Must stay in the same file as COLORS, globals in different files have no guaranteed init order.
var _activeColors as Array<Number> = COLORS;

const TEMP_GRADS =
    [
        [
            0x192041, 0x263061, 0x1c5594, 0x4398c2, 0x8ca73a, 0xe8d130,
            0xea8313, 0xf35827, 0xc9101f, 0x8f0002,
        ],
        [
            0x5e4fa2, 0x388eba, 0x75c8a5, 0xbfe5a0, 0xf1f9a9, 0xfeeea2,
            0xfdbf6f, 0xf67b4a, 0xd8434e, 0x9e0142,
        ],
        [
            0x30123b, 0x4f48ae, 0x5892d8, 0x2cd1c8, 0x40f872, 0xbced22,
            0xfab00a, 0xfa8009, 0xe74a08, 0x7a0402,
        ],
        [
            0x000003, 0x150222, 0x330446, 0x59114f, 0x7f2148, 0xa6372d,
            0xca5d12, 0xe78d06, 0xf9be25, 0xfbfea4,
        ],
    ] as Array<Array<Number> >;

const TRI_GRAD = [0x55ff77, 0xff9944, 0xff5555] as Array<Number>;

const SCANLINE_SPACING = 3;
// White overlay alpha per intensity (0=off/1=subtle/2=medium/3=strong) - black has no headroom over this near-always-black display.
const SCANLINE_ALPHA = [0, 15, 25, 35] as Array<Number>;
const FLICKER_MAGNITUDE = 10;
const FLICKER_CHANCE_PCT = 20;
// PAD must exceed SHIFT_MAX so the flicker shift never clips.
const BG_BACKLIGHT_SHIFT_MAX = 20;
const BG_BACKLIGHT_PAD = 22;

const BG_BACKLIGHT_SIGMA = 0.26;
const BG_BACKLIGHT_DIM_LEVEL = [0, 25, 50, 75] as Array<Number>;

const GLOW_FRACTION = [0.0, 0.08, 0.14, 0.2] as Array<Float>;

// Glow offset (px); diagonal everywhere except the line-ribbon glow (self-intersection risk).
const GLOW_SPREAD = 1;

// Small cap - shares the constrained graphics memory pool with graph/halo bitmaps.
const GLOW_GLYPH_CACHE_CAP = 16;

const DASH_ALPHA = 0x80;

// Forecast graphs are one entry per hour; bridge a single missing hour, not more.
const FORECAST_GAP_HOURS = 2;
const NOWCAST_RAIN_MMH = 0.1;

const GRAYS =
    [
        0x111111, // 0  shadow
        0x333333, // 1  unfilled Move Bar blocks
        0x555555, // 2  DebugGraphGaps gap marker only
        0x777777, // 3  text separators, no-data text, graph axes, progress bar border
    ] as Array<Number>;

const DAY_NAMES =
    ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] as Array<String>;
const MONTH_NAMES =
    [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
    ] as Array<String>;

const WIND_DIRS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"] as Array<String>;

// 0=Sun-indexed, matches Gregorian.Info.day_of_week - 1 under FORMAT_SHORT.
const DAY_NAMES_SHORT = ["S", "M", "T", "W", "T", "F", "S"] as Array<String>;

const ARROW_PAD = 2;

const FEET_PER_METER = 3.28084;
const METERS_PER_MILE = 1609.344;
const PA_PER_INHG = 3386.39;
const MM_PER_INCH = 25.4;
const KMH_PER_MPS = 3.6;
const MPH_PER_MPS = 2.23694;

const MIN_SPEED_MPS = 0.05;

const SECS_PER_HOUR = 3600;
const SECS_PER_MIN = 60;

const SETTINGS_RELOAD_MIN = 15;

// Minutes between retrying a previously-failed bitmap draw, instead of assuming a transient failure is permanent.
const BITMAP_DRAW_RETRY_MIN = 10;

// FieldTables.needs() bits: which data sources a displayed field pulls from.
const NEED_LIVE_ACTIVITY = 1;
const NEED_AM = 2;
const NEED_FORECAST = 4;
const NEED_WX_CURRENT = 8;
const NEED_NOWCAST = 32;

const ICON_ARROW_UP = 0;
const ICON_ARROW_DN = 1;
const ICON_DEG = 2;
const ICON_BOLT = 3;
