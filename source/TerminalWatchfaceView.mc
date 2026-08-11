import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.SensorHistory;
import Toybox.UserProfile;
import Toybox.Complications;

const APP_VERSION = "0.55.6";

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

// CACHE_KEY_* (graph cache key bit layout) also lives in generated FieldIds.mc.

// Must match ROT in scripts/generate_resources.py.
const ROTATE_SLOT_NAMES =
    ["R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9"] as Array<String>;

// Indices into this array are used as the SecondaryField property value
const GRAPH_SEC_FIELDS =
    [
        FIELD_HR,
        FIELD_SPO2,
        FIELD_BODY_BAT,
        FIELD_STRESS,
        FIELD_WRIST_TEMP,
        FIELD_ELEVATION,
        FIELD_PRESSURE,
    ] as Array<Number>;

// Index 0 = white (value default), 8 = light grey (label default). Colon matches label color.
const COLORS =
    [
        0xffffff, // 0  white
        0x55ff77, // 1  green
        0x55ffff, // 2  cyan
        0xffee55, // 3  yellow
        0xff9944, // 4  orange
        0xff5555, // 5  red
        0x6699ff, // 6  blue
        0xff55ff, // 7  magenta
        0x777777, // 8  light grey
        0xaa77ff, // 9  purple
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

// Active palette, repointed by _applyColorTheme().
var _activeColors as Array<Number> = COLORS;

const TEMP_GRADS =
    [
        [
            // Custom
            0x192041, 0x263061, 0x1c5594, 0x4398c2, 0x8ca73a, 0xe8d130,
            0xea8313, 0xf35827, 0xc9101f, 0x8f0002,
        ],
        [
            // Spectral
            0x5e4fa2, 0x388eba, 0x75c8a5, 0xbfe5a0, 0xf1f9a9, 0xfeeea2,
            0xfdbf6f, 0xf67b4a, 0xd8434e, 0x9e0142,
        ],
        [
            // Turbo
            0x30123b, 0x4f48ae, 0x5892d8, 0x2cd1c8, 0x40f872, 0xbced22,
            0xfab00a, 0xfa8009, 0xe74a08, 0x7a0402,
        ],
        [
            // Inferno
            0x000003, 0x150222, 0x330446, 0x59114f, 0x7f2148, 0xa6372d,
            0xca5d12, 0xe78d06, 0xf9be25, 0xfbfea4,
        ],
    ] as Array<Array<Number> >;

// green → orange → red, using COLORS[1], COLORS[4], COLORS[5]
const TRI_GRAD = [0x55ff77, 0xff9944, 0xff5555] as Array<Number>;

const SCANLINE_SPACING = 3;
// White overlay alpha per intensity (0=off/1=subtle/2=medium/3=strong) - black has no headroom over this near-always-black display.
const SCANLINE_ALPHA = [0, 15, 25, 35] as Array<Number>;
const FLICKER_MAGNITUDE = 10;
const FLICKER_CHANCE_PCT = 20;
// PAD must exceed SHIFT_MAX so the flicker shift never clips.
const BG_BACKLIGHT_SHIFT_MAX = 20;
const BG_BACKLIGHT_PAD = 22;

// Exponential falloff width for the backlight glow - smaller = tighter peak.
const BG_BACKLIGHT_SIGMA = 0.26;
// Gray level multiplied over the bright gradient (BLEND_MODE_MULTIPLY) to dim it.
const BG_BACKLIGHT_DIM_LEVEL = [0, 25, 50, 75] as Array<Number>;

// Halo blend fraction toward a shape's own color, per glowIntensity level (0=off).
const GLOW_FRACTION = [0.0, 0.08, 0.14, 0.2] as Array<Float>;

// Glow offset (px); diagonal everywhere except the line-ribbon glow (self-intersection risk).
const GLOW_SPREAD = 1;

// Small cap - shares the constrained graphics memory pool with graph/halo bitmaps.
const GLOW_GLYPH_CACHE_CAP = 16;

// Dim factor for dashed lines (progress bar ticks, HR zones, mean line, daily dividers).
const DASH_ALPHA = 0x80;

// Forecast graphs are one entry per hour; bridge a single missing hour, not more.
const FORECAST_GAP_HOURS = 2;

// 0=shadow, 1=bar bg, 2=unused, 3=separators/no-data/axes/progress-bar-border
const GRAYS =
    [
        0x111111, // 0  shadow
        0x333333, // 1  unfilled Move Bar blocks
        0x555555, // 2  unused - dashed lines/mean line now use a dimmed color instead
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
const KMH_PER_MPS = 3.6;
const MPH_PER_MPS = 2.23694;

const MIN_SPEED_MPS = 0.05;

const SECS_PER_HOUR = 3600;
const SECS_PER_MIN = 60;

// Minutes between retrying a previously-failed bitmap draw, instead of
// assuming a one-time failure (e.g. a transient low-memory moment) is permanent.
const BITMAP_DRAW_RETRY_MIN = 10;

const ICON_ARROW_UP = 0;
const ICON_ARROW_DN = 1;
const ICON_DEG = 2;
const ICON_BOLT = 3;

class TerminalWatchfaceView extends WatchUi.WatchFace {
    private var _screenW as Number = 0;
    private var _screenH as Number = 0;
    private var _lastPhase as Number = -1;
    private var _lastFontChoice as Number = -1;
    private var _font as Graphics.FontType = Graphics.FONT_SMALL;
    private var _fontSmall as Graphics.FontType = Graphics.FONT_TINY;
    private var _fontTiny as Graphics.FontType = Graphics.FONT_XTINY;
    // Value keyed by _packGraphKey(...), each entry [value, lastCheckedMin].
    private var _graphCache as Dictionary = {};
    private var _groupedBarCache as Dictionary = {};
    // Keyed by the same cacheKey as the data itself; entry is [minV, maxV, dataRef].
    private var _minMaxCache as Dictionary = {};
    private var _graphEffPeriod as Dictionary = {};
    private var _pendingEffPeriod as Number = 0;
    private var _graphCacheMin as Number = -1;
    private var _cursorOn as Boolean = true;
    private var _cursorX as Number = 0;
    private var _cursorY as Number = 0;
    private var _cursorCharW as Number = 12;
    private var _cursorFh as Number = 20;
    private var _timeValueX as Number = 0;
    private var _timeValueY as Number = 0;
    private var _splitPad as Number = 0;
    private var _arrowW as Number = 0;
    private var _wxTemp as String = "-";
    private var _wxFeels as String = "-";
    private var _wxPrecip as String = "-";
    private var _wxWind as String = "-";
    private var _wxUv as String = "-";
    private var _wxUvNum as Number = -1;
    private var _wxCond as String = "-";
    private var _wxForecastData as Array<Float>? = null;
    private var _wxLow as String = "-";
    private var _wxHigh as String = "-";
    private var _fontVariant as Number = 0; // 0 = lineHeight 28 (default), 1 = lineHeight 30 (SpaceMono)
    private var _arrowH as Number = 16;
    private var _bmpArrowW as Number = 14;
    private var _boltH as Number = 16;
    private var _bmpBoltW as Number = 16;
    private var _degW as Number = 8;
    private var _degWSmall as Number = 5;
    private var _wxUnit as String = "C";
    private var _fh as Number = 20;
    private var _charW as Number = 12;
    private var _tinyFh as Number = 10;
    private var _smallFh as Number = 16;
    private var _amInfo as ActivityMonitor.Info? = null;
    private var _acInfo as Activity.Info? = null;
    private var _wxLastMin as Number = -1;
    private var _forecastFetched as Boolean = false;
    private var _needsWeatherCurrent as Boolean = true;
    private var _wxCurrentFetched as Boolean = false;
    private var _metric as Boolean = false;
    private var _notifCount as Number = 0;
    private var _notifLabel as String = "";
    private var _phoneConnected as Boolean = true;
    private var _dndOn as Boolean = false;
    private var _notifLastMs as Number = -3000;
    private var _compSleepScore as Number? = null;
    private var _compSunrise as Number? = null;
    private var _compSunset as Number? = null;
    private var _compCalendar as String? = null;
    private var _compWeeklyRun as Float? = null;
    private var _compWeeklyBike as Float? = null;
    private var _compTrainingStatus as String? = null;
    private var _compRace5k as Number? = null;
    private var _compRace10k as Number? = null;
    private var _compRaceHalf as Number? = null;
    private var _compRaceMarathon as Number? = null;
    private var _graphBmpCache as Dictionary = {};
    private var _graphBmpDualCache as Dictionary = {};
    // _glowText halo-copy cache, round-robin evicted so repeat-hit labels survive high-cardinality live-value churn.
    private var _glowGlyphCache as Dictionary = {};
    private var _glowGlyphKeys as Array<String?> = new [GLOW_GLYPH_CACHE_CAP];
    private var _glowGlyphIdx as Number = 0;
    // Offscreen surface every halo is drawn onto, then additively composited.
    private var _haloBmp as Graphics.BufferedBitmap? = null;
    // Null until first drawBitmap attempt; caches whether it worked. Retried
    // every BITMAP_DRAW_RETRY_MIN via _tryDrawBitmapRetry, not latched forever.
    private var _haloDrawOk as Boolean? = null;
    private var _haloDrawOkMin as Number = -1;
    // True while rendering a graph bitmap offscreen (halo coords would be bitmap-local, not screen-space).
    private var _haloSuppressed as Boolean = false;
    // Non-null while baking a graph's cached glow bitmap - redirects every _glow*Shape
    // call's target dc here instead of the shared per-frame _haloBmp, bypassing
    // _haloSuppressed/_haloActive() (bake is a rare cache-miss event, not a per-frame cost).
    private var _haloBakeDc as Dc? = null;
    private var _bgBacklightBmp as Graphics.BufferedBitmap? = null;
    private var _bgBacklightDrawOk as Boolean? = null;
    private var _bgBacklightDrawOkMin as Number = -1;
    private var _bgBacklightDimBmp as Graphics.BufferedBitmap? = null;
    private var _bgBacklightDimGray as Number = -1;
    private var _bgBacklightDimDrawOk as Boolean? = null;
    private var _bgBacklightDimDrawOkMin as Number = -1;
    // Keyed by cacheKey (like _graphBmpCache) so one row's failure can't affect another; value [lastOk, lastCheckedMin].
    private var _graphBmpDrawOk as Dictionary = {};
    // Separate dict because dual-graph cache keys can collide numerically with single-graph keys.
    private var _graphBmpDualDrawOk as Dictionary = {};
    private var _is24Hour as Boolean = true;
    private var _firstDow as Number = 1;
    private var _showSeconds as Boolean = false;
    private var _lowPower as Boolean = false;
    private var _alwaysOn as Boolean = false;
    private var _justWoke as Boolean = true;
    private var _deferThisFrame as Boolean = false;
    private var _deferredWorkPending as Boolean = false;
    private var _leftPad as Number = 4;
    private var _areaOpacity as Number = 64;
    private var _areaShowLine as Boolean = true;
    private var _debugGraphGaps as Boolean = false;
    private var _scanlineIntensity as Number = 2;
    private var _glowIntensity as Number = 2;
    private var _bgBacklight as Number = 0;
    private var _lastColorTheme as Number = -1;
    private var _flickerEnabled as Boolean = true;
    private var _rotateMainMs as Number = 5000;
    private var _rotateAltMs as Number = 5000;
    private var _rotateMaxPhase as Number = 8;
    private var _rotationMode as Number = ROTATION_HYBRID;
    private var _manualPhase as Number = 0;
    private var _phaseAnchorSec as Number = -1;
    private var _metricsValid as Boolean = false;
    private var _graphW as Number = 0;
    private var _graphX as Number = 0;
    private var _graphBaseX as Number = 0;
    private var _graphH as Number = 0;
    private var _clockInfo as Gregorian.Info? = null;
    private var _watchCmd as String = "watch";
    private var _cachedBodyBat as String = "-";
    private var _cachedTempWrist as String = "-";
    private var _cachedPressure as String = "-";
    private var _cachedElevation as String = "-";
    private var _cachedStress as String = "-";
    private var _cachedVo2Max as String = "-";
    private var _cachedRestingHR as String = "-";
    private var _cachedAvgRestingHR as String = "-";
    private var _cachedSleepTime as String = "-";
    private var _cachedWakeTime as String = "-";
    private var _wxForecastPrecipData as Array<Float>? = null;
    private var _wxDailyForecastHigh as Array<Float>? = null;
    private var _wxDailyForecastLow as Array<Float>? = null;
    private var _hrZones as Array<Number>? = null;
    private var _batText as String = "-";
    private var _batDaysText as String = "";
    private var _batW as Number = 0;
    private var _batDaysW as Number = 0;
    private var _spacedBatText as String = "";
    // Lazily filled ":SS" strings, indexed by second - avoids reformatting every tick in the onPartialUpdate hot path.
    private var _secStrs as Array<String?> = new [60];
    private var _spacedBatW as Number = 0;
    private var _charging as Boolean = false;
    private var _batLow as Boolean = false;
    private var _showBatteryDays as Boolean = true;
    private var _resolvedPhase as Number = -1;
    private var _resolvedFields as Array<Number> = [7, 7, 7] as Array<Number>;
    private var _needsLiveActivity as Boolean = true;
    private var _needsAm as Boolean = true;
    private var _needsForecast as Boolean = true;
    private var _needsComplications as Boolean = true;
    private var _resolvedLabelC as Array<Number> = [8, 8, 8] as Array<Number>;
    private var _resolvedValueC as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _rowBuf as Array<String> = ["", ""] as Array<String>;
    private var _timeBuf as Array<String> = ["Time", ""] as Array<String>;
    private var _dateBuf as Array<String> = ["Date", ""] as Array<String>;
    private var _lastDateDay as Number = -1;
    private var _cachedTimeMin as Number = -1;
    private var _cachedTimeStr as String = "";
    private var _cachedTimeStrW as Number = 0;
    private var _dateFormat as Number = 0;
    private var _showYear as Boolean = false;
    private var _line1LabelC as Number = 8;
    private var _line1ValueC as Number = 0;
    private var _line2LabelC as Number = 8;
    private var _line2ValueC as Number = 0;
    private var _lineViewMode as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineValueMode as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _linePeriodMin as Array<Number> = [60, 60, 60] as Array<Number>;
    private var _lineGraphColor as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineGraphType as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineGraphWidth as Array<Number> =
        [10, 10, 10] as Array<Number>;
    private var _lineBarGroupDensity as Array<Number> =
        [0, 0, 0] as Array<Number>;
    private var _lineBarGroupAgg as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineGoal as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineSecType as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineSecField as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineSecColor as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _dataMin as Float = 0.0;
    private var _dataMax as Float = 0.0;
    private var _nowUnixMin as Number = 0;
    private var _wxForecastWindData as Array<Float>? = null;
    private var _wxForecastHumidityData as Array<Float>? = null;
    private var _wxHumidityNum as Number = -1;
    private var _wxHumidity as String = "-";
    private var _wxDewPoint as String = "-";
    private var _wxVisibility as String = "-";
    private var _wxCloudCover as String = "-";
    private var _wxHeatIndex as String = "-";
    private var _wxObsAge as String = "-";
    private var _compNotifications as Number? = null;
    private var _compRacePace5k as Float? = null;
    private var _compRacePace10k as Float? = null;
    private var _compRacePaceHalf as Float? = null;
    private var _compRacePaceMarathon as Float? = null;
    private var _compSolar as Number? = null;
    private var _compFcstCond1d as Number? = null;
    private var _compFcstCond2d as Number? = null;
    private var _compFcstCond3d as Number? = null;
    private var _compSeaLevelPressure as Float? = null;
    private var _compEverFetched as Boolean = false;
    // Set on a deferred fetch; retried unconditionally next frame instead of waiting for the next tick.
    private var _compFetchDeferred as Boolean = false;
    private var _wxForecastUvData as Array<Float>? = null;
    private var _wxForecastCloudData as Array<Float>? = null;
    private var _cachedPressureTrend as Number = 0;

    public function initialize() {
        WatchFace.initialize();
        var s = System.getDeviceSettings();
        _screenW = s.screenWidth;
        _screenH = s.screenHeight;
        _amInfo = ActivityMonitor.getInfo();
        _acInfo = Activity.getActivityInfo();
        reloadFont();
        _applyColorTheme(_getProp("theme", 0));
        _computeRotateMaxPhase();
    }

    // Pre-renders here so first-frame cost doesn't share onUpdate's budget.
    public function onLayout(dc as Dc) as Void {
        _renderBacklightBitmap();
    }

    public function onShow() as Void {}

    (:extendedCode)
    private function _refreshComplications() as Void {
        _compSleepScore = null;
        _compSunrise = null;
        _compSunset = null;
        _compCalendar = null;
        _compWeeklyRun = null;
        _compWeeklyBike = null;
        _compTrainingStatus = null;
        _compRace5k = null;
        _compRace10k = null;
        _compRaceHalf = null;
        _compRaceMarathon = null;
        _compNotifications = null;
        _compRacePace5k = null;
        _compRacePace10k = null;
        _compRacePaceHalf = null;
        _compRacePaceMarathon = null;
        _compSolar = null;
        _compFcstCond1d = null;
        _compFcstCond2d = null;
        _compFcstCond3d = null;
        _compSeaLevelPressure = null;
        var iter = Complications.getComplications();
        var comp = iter.next() as Complications.Complication?;
        var deadline = System.getTimer() + 100;
        while (comp != null && System.getTimer() < deadline) {
            var v = comp.value;
            if (v != null) {
                var t = comp.getType();
                if (t == Complications.COMPLICATION_TYPE_SLEEP_SCORE) {
                    _compSleepScore = v as Number;
                } else if (t == Complications.COMPLICATION_TYPE_SUNRISE) {
                    _compSunrise = v as Number;
                } else if (t == Complications.COMPLICATION_TYPE_SUNSET) {
                    _compSunset = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_CALENDAR_EVENTS
                ) {
                    _compCalendar = v.toString();
                } else if (
                    t == Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE
                ) {
                    _compWeeklyRun = (v as Complications.RangeValue).toFloat();
                } else if (
                    t == Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE
                ) {
                    _compWeeklyBike = (v as Complications.RangeValue).toFloat();
                } else if (
                    t == Complications.COMPLICATION_TYPE_TRAINING_STATUS
                ) {
                    _compTrainingStatus = v.toString();
                } else if (
                    t == Complications.COMPLICATION_TYPE_RACE_PREDICTOR_5K
                ) {
                    _compRace5k = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_RACE_PREDICTOR_10K
                ) {
                    _compRace10k = v as Number;
                } else if (
                    t ==
                    Complications.COMPLICATION_TYPE_RACE_PREDICTOR_HALF_MARATHON
                ) {
                    _compRaceHalf = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_RACE_PREDICTOR_MARATHON
                ) {
                    _compRaceMarathon = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT
                ) {
                    _compNotifications = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_5K
                ) {
                    _compRacePace5k = v as Float;
                } else if (
                    t == Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_10K
                ) {
                    _compRacePace10k = v as Float;
                } else if (
                    t ==
                    Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_HALF_MARATHON
                ) {
                    _compRacePaceHalf = v as Float;
                } else if (
                    t ==
                    Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_MARATHON
                ) {
                    _compRacePaceMarathon = v as Float;
                } else if (t == Complications.COMPLICATION_TYPE_SOLAR_INPUT) {
                    _compSolar = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_FORECAST_WEATHER_1DAY
                ) {
                    _compFcstCond1d = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_FORECAST_WEATHER_2DAY
                ) {
                    _compFcstCond2d = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_FORECAST_WEATHER_3DAY
                ) {
                    _compFcstCond3d = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE
                ) {
                    _compSeaLevelPressure = v as Float;
                }
            }
            comp = iter.next() as Complications.Complication?;
        }
        _compEverFetched = true;
    }

    public function invalidateSettings() as Void {
        _resolvedPhase = -1;
        _graphCacheMin = -1;
        _graphCache = {};
        _groupedBarCache = {};
        _minMaxCache = {};
        _graphEffPeriod = {};
        _graphBmpCache = {};
        _graphBmpDualCache = {};
        _graphBmpDrawOk = {};
        _graphBmpDualDrawOk = {};
        _glowGlyphCache = {};
        _glowGlyphKeys = new [GLOW_GLYPH_CACHE_CAP];
        _glowGlyphIdx = 0;
        _lastDateDay = -1;
        _cachedTimeMin = -1;
        _forecastFetched = false;
        _wxCurrentFetched = false;
        _applyColorTheme(_getProp("theme", 0));
        _computeRotateMaxPhase();
    }

    private function _applyColorTheme(themeIdx as Number) as Void {
        if (themeIdx == _lastColorTheme) {
            return;
        }
        _lastColorTheme = themeIdx;
        _activeColors =
            (
                themeIdx >= 0 && themeIdx < COLOR_THEMES.size()
                    ? COLOR_THEMES[themeIdx]
                    : COLORS
            ) as Array<Number>;
        // Only _bgBacklightBmp bakes in a palette color permanently.
        _bgBacklightBmp = null;
        _bgBacklightDrawOk = null;
        _bgBacklightDrawOkMin = -1;
    }

    private function _computeRotateMaxPhase() as Void {
        var ri = _getProp("rotI", 5);
        if (ri < 1) {
            ri = 1;
        }
        _rotateMainMs = ri * 1000;
        var ra = _getProp("rotA", 0);
        _rotateAltMs = ra > 0 ? ra * 1000 : _rotateMainMs;
        var rm = _getProp("rotMode", ROTATION_HYBRID);
        if (rm < ROTATION_AUTOMATIC || rm > ROTATION_HYBRID) {
            rm = ROTATION_AUTOMATIC;
        }
        if (rm != _rotationMode) {
            _rotationMode = rm;
            // Same "start fresh" treatment as a wake, so a mode switch never resumes from a stale anchor.
            _manualPhase = 0;
            _jumpToPhase(0, Time.now().value());
        }
        _rotateMaxPhase = 0;
        var e3 = _getBoolProp("l3En", true);
        var e4 = _getBoolProp("l4En", true);
        var e5 = _getBoolProp("l5En", true);
        for (var p = 7; p >= 0; p--) {
            var sn = ROTATE_SLOT_NAMES[p];
            if (
                (e3 && _getProp("l3" + sn, FIELD_NONE) != FIELD_NONE) ||
                (e4 && _getProp("l4" + sn, FIELD_NONE) != FIELD_NONE) ||
                (e5 && _getProp("l5" + sn, FIELD_NONE) != FIELD_NONE)
            ) {
                _rotateMaxPhase = p + 1;
                break;
            }
        }
    }

    (:extendedCode)
    public function reloadFont() as Void {
        var choice = _getProp("font", 0);
        if (choice < 0 || choice > 2) {
            choice = 0;
        }
        if (choice == _lastFontChoice) {
            return;
        }
        _lastFontChoice = choice;

        var normalRes = [
            $.Rez.Fonts.JetBrainsMono_NORMAL,
            $.Rez.Fonts.SpaceMono_NORMAL,
            $.Rez.Fonts.NBArchitekt_NORMAL,
        ];
        var smallRes = [
            $.Rez.Fonts.JetBrainsMono_SMALL,
            $.Rez.Fonts.SpaceMono_SMALL,
            $.Rez.Fonts.NBArchitekt_SMALL,
        ];
        var tinyRes = [
            $.Rez.Fonts.JetBrainsMono_TINY,
            $.Rez.Fonts.SpaceMono_TINY,
            $.Rez.Fonts.NBArchitekt_TINY,
        ];
        _font =
            WatchUi.loadResource(normalRes[choice]) as Graphics.FontDefinition;
        _fontSmall =
            WatchUi.loadResource(smallRes[choice]) as Graphics.FontDefinition;
        _fontTiny =
            WatchUi.loadResource(tinyRes[choice]) as Graphics.FontDefinition;

        // choice 1 = SpaceMono (lineHeight 30); all others use lineHeight 28
        var newSizeSet = choice == 1 ? 1 : 0;
        if (newSizeSet != _fontVariant) {
            _fontVariant = newSizeSet;
            _graphBmpCache = {};
            _graphBmpDualCache = {};
            _graphBmpDrawOk = {};
            _graphBmpDualDrawOk = {};
        }
        if (_fontVariant == 1) {
            _arrowH = 16;
            _bmpArrowW = 14;
            _boltH = 20;
            _bmpBoltW = 16;
            _degW = 8;
            _degWSmall = 6;
        } else {
            _arrowH = 15;
            _bmpArrowW = 13;
            _boltH = 17;
            _bmpBoltW = 15;
            _degW = 7;
            _degWSmall = 5;
        }
        _metricsValid = false;
    }

    public function onUpdate(dc as Dc) as Void {
        // Callees later in this same frame use _deferThisFrame to tell they're on the
        // frame that must not block wake-up.
        _deferThisFrame = _justWoke;
        _justWoke = false;
        _deferredWorkPending = false;
        // Guards the retry below plus the phase-change/per-minute blocks against double-refreshing this call.
        var compHandledThisFrame = false;
        if (_compFetchDeferred && !_deferThisFrame) {
            _compFetchDeferred = false;
            _refreshComplications();
            compHandledThisFrame = true;
        }
        var now = System.getTimer();
        var nowMoment = Time.now();
        var phase = _getPhase(nowMoment.value());
        _cursorOn = (now / 1000) % 2 == 0;
        _nowUnixMin = nowMoment.value() / SECS_PER_MIN;
        var clockInfo =
            Gregorian.info(nowMoment, Time.FORMAT_SHORT) as Gregorian.Info;
        _clockInfo = clockInfo;
        var nowMin = clockInfo.min as Number;
        var notifDue = now - _notifLastMs >= 3000;
        var minuteRolled = nowMin != _graphCacheMin;
        if (notifDue || minuteRolled) {
            var ds = System.getDeviceSettings();
            if (notifDue) {
                _notifLastMs = now;
                var newCount = ds.notificationCount;
                if (newCount != _notifCount) {
                    _notifCount = newCount;
                    _notifLabel = "[" + newCount.toString() + " UNREAD]";
                }
                _phoneConnected = ds.phoneConnected;
                _dndOn = ds has :doNotDisturb && ds.doNotDisturb;
            }
            if (minuteRolled) {
                _metric = ds.distanceUnits == System.UNIT_METRIC;
                _is24Hour = ds.is24Hour;
                var fDow = ds.firstDayOfWeek;
                _firstDow = fDow != null ? ((fDow as Number) - 1) % 7 : 1;
            }
        }
        // Rotation/complication-need state is interactive-only - AOD never reaches _drawLineRow.
        if (phase != _resolvedPhase && !_lowPower) {
            _resolvedPhase = phase;
            _resolveAllLines(phase);
            var needsAct = false;
            var needsForecast = false;
            var needsWxCurrent = false;
            var needsComp = false;
            var needsAm = false;
            for (var i = 0; i < 3; i++) {
                var f = _resolvedFields[i];
                if (
                    f == FIELD_HR ||
                    f == FIELD_SPO2 ||
                    f == FIELD_ALTITUDE ||
                    f == FIELD_HR_SPO2 ||
                    f == FIELD_RESP_SPO2
                ) {
                    needsAct = true;
                }
                if (
                    f == FIELD_STEPS ||
                    f == FIELD_FLOORS ||
                    f == FIELD_CALORIES ||
                    f == FIELD_DISTANCE ||
                    f == FIELD_ACTIVE_MIN_DAY ||
                    f == FIELD_INTENSITY_MIN ||
                    f == FIELD_MOVE_BAR ||
                    f == FIELD_CLIMB_DESCEND_DAY ||
                    f == FIELD_CLIMB_DAY ||
                    f == FIELD_DESCENT_DAY ||
                    f == FIELD_RESP ||
                    f == FIELD_RECOVERY ||
                    f == FIELD_BODY_BAT_RECOVERY ||
                    f == FIELD_STRESS_RECOVERY ||
                    f == FIELD_RESP_SPO2 ||
                    f == FIELD_SLEEP_RECOVERY
                ) {
                    needsAm = true;
                }
                if (
                    f == FIELD_WX_FCST_TEMP ||
                    f == FIELD_WX_FCST_PRECIP ||
                    f == FIELD_WX_FCST_DAILY ||
                    f == FIELD_WX_FCST_WIND ||
                    f == FIELD_WX_FCST_HUMIDITY ||
                    f == FIELD_WX_FCST_UV ||
                    f == FIELD_WX_FCST_CLOUD
                ) {
                    needsForecast = true;
                }
                if (
                    f == FIELD_WX_PRECIP ||
                    f == FIELD_WX_WIND ||
                    f == FIELD_WX_UV ||
                    f == FIELD_WX_COND ||
                    f == FIELD_WX_COND_PRECIP ||
                    f == FIELD_WX_WIND_PRECIP ||
                    f == FIELD_WX_TEMP ||
                    f == FIELD_WX_FEELS ||
                    f == FIELD_WX_TEMP_COND ||
                    f == FIELD_WX_TEMP_WIND ||
                    f == FIELD_WX_TEMP_UV ||
                    f == FIELD_WX_UV_PRECIP ||
                    f == FIELD_WX_UV_WIND ||
                    f == FIELD_WX_TEMP_HIGH_LOW ||
                    f == FIELD_WX_HUMIDITY ||
                    f == FIELD_WX_DEW_POINT ||
                    f == FIELD_WX_VISIBILITY ||
                    f == FIELD_WX_CLOUD ||
                    f == FIELD_WX_HIGH_LOW ||
                    f == FIELD_WX_HUMIDITY_DEW ||
                    f == FIELD_WX_HEAT_INDEX ||
                    f == FIELD_WX_TEMP_HUMIDITY ||
                    f == FIELD_WX_TEMP_PRECIP ||
                    f == FIELD_WX_HUMIDITY_PRECIP ||
                    f == FIELD_WX_CLOUD_PRECIP ||
                    f == FIELD_WX_COND_CLOUD ||
                    f == FIELD_WX_OBS_TIME ||
                    f == FIELD_WX_COND_FCST_1D
                ) {
                    needsWxCurrent = true;
                }
                if (
                    f == FIELD_WEEKLY_RUN ||
                    f == FIELD_WEEKLY_BIKE ||
                    f == FIELD_SOLAR ||
                    f == FIELD_WEEKLY_DISTANCES ||
                    f == FIELD_SOLAR_BATTERY ||
                    f == FIELD_SLEEP ||
                    f == FIELD_TRAINING_STATUS ||
                    f == FIELD_VO2_TRAINING ||
                    f == FIELD_SLEEP_RECOVERY ||
                    f == FIELD_SUNRISE ||
                    f == FIELD_SUNSET ||
                    f == FIELD_SUNRISE_SUNSET ||
                    f == FIELD_CALENDAR ||
                    f == FIELD_NOTIFICATIONS ||
                    f == FIELD_RACE_5K ||
                    f == FIELD_RACE_10K ||
                    f == FIELD_RACE_HALF ||
                    f == FIELD_RACE_MARATHON ||
                    f == FIELD_RACE_PACE_5K ||
                    f == FIELD_RACE_PACE_10K ||
                    f == FIELD_RACE_PACE_HALF ||
                    f == FIELD_RACE_PACE_MARATHON ||
                    f == FIELD_WX_SEA_PRESS ||
                    f == FIELD_WX_COND_FCST_1D ||
                    f == FIELD_WX_FCST_COND_12D ||
                    f == FIELD_WX_FCST_COND_1D ||
                    f == FIELD_WX_FCST_COND_2D ||
                    f == FIELD_WX_FCST_COND_3D
                ) {
                    needsComp = true;
                }
                // Must match _resolveLineGraph's write gate, or this reads a stale _lineSecField index.
                if (
                    _lineSecType[i] != SEC_NONE &&
                    (_lineViewMode[i] == VIEW_GRAPH ||
                        _lineViewMode[i] == VIEW_GRAPH_VALUE)
                ) {
                    var sf = GRAPH_SEC_FIELDS[_lineSecField[i]] as Number;
                    if (sf == FIELD_HR || sf == FIELD_SPO2) {
                        needsAct = true;
                    }
                }
            }
            _needsLiveActivity = needsAct;
            // Freshly needed - refresh now rather than waiting for the next per-minute tick.
            if (needsAm && !_needsAm && !_lowPower) {
                _amInfo = ActivityMonitor.getInfo();
            }
            _needsAm = needsAm;
            _needsForecast = needsForecast;
            if (needsComp && !_needsComplications && !compHandledThisFrame) {
                // Freshly needed - refresh now rather than waiting for the next per-minute tick.
                if (_deferThisFrame && _compEverFetched) {
                    _deferredWorkPending = true;
                    _compFetchDeferred = true;
                } else {
                    _refreshComplications();
                }
                compHandledThisFrame = true;
            }
            _needsComplications = needsComp;
            // Forecast fields fall back to current-conditions strings too, so they need this refresh too.
            _needsWeatherCurrent = needsWxCurrent || needsForecast;
            // Force a refresh now if a forecast field just rotated into view mid-minute.
            if (_needsForecast && !_forecastFetched) {
                _wxLastMin = -1;
            }
            if (_needsWeatherCurrent && !_wxCurrentFetched) {
                _wxLastMin = -1;
            }
        }
        if (_needsLiveActivity && !_lowPower) {
            _acInfo = Activity.getActivityInfo();
        }
        if (minuteRolled) {
            _graphCacheMin = nowMin;
            // Not cleared here: _cacheResult() invalidates only the specific key that refreshed.
            _showSeconds = _getBoolProp("shSec", false);
            _leftPad = _getProp("lPad", 4);
            _areaOpacity = _getProp("aOpac", 64);
            _areaShowLine = _getBoolProp("aLine", true);
            _debugGraphGaps = _getBoolProp("dbgGG", false);
            _showBatteryDays = _getBoolProp("batD", true);
            _scanlineIntensity = _getProp("scan", 2);
            _glowIntensity = _getProp("glow", 2);
            if (_glowIntensity < 0 || _glowIntensity > 3) {
                _glowIntensity = 2;
            }
            _bgBacklight = _getProp("bgLt", 0);
            if (_bgBacklight < 0 || _bgBacklight > 3) {
                _bgBacklight = 0;
            }
            _flickerEnabled = _getBoolProp("flick", true);
            _wxUnit = _metric ? "C" : "F";
            // Fitness/complications/pressure-trend data below is interactive-row-only - AOD never draws it.
            if (!_lowPower) {
                if (_needsAm) {
                    _amInfo = ActivityMonitor.getInfo();
                }
                if (_needsComplications && !compHandledThisFrame) {
                    if (_deferThisFrame && _compEverFetched) {
                        _deferredWorkPending = true;
                        _compFetchDeferred = true;
                    } else {
                        _refreshComplications();
                    }
                }
                _refreshPointSamples();
            }
            // _watchCmd is only drawn on the interactive prompt line, never in AOD.
            if (!_lowPower) {
                var showVer = _getBoolProp("shVer", false);
                var cmdStyle = _getProp("cmdSty", 2);
                if (cmdStyle == 1) {
                    _watchCmd = showVer
                        ? "./watch@" + APP_VERSION + ".sh"
                        : "./watch.sh";
                } else if (cmdStyle == 2) {
                    _watchCmd = showVer ? "watch@" + APP_VERSION : "watch";
                } else {
                    _watchCmd = showVer
                        ? ".\\watch@" + APP_VERSION + ".bat"
                        : ".\\watch.bat";
                }
            }
            _line1LabelC = _getProp("l1Lc", 8);
            _line1ValueC = _getProp("l1Vc", 0);
            _line2LabelC = _getProp("l2Lc", 8);
            _line2ValueC = _getProp("l2Vc", 0);
            var fmt = _getProp("dFmt", 0);
            var sy = _getBoolProp("shYr", false);
            if (fmt != _dateFormat || sy != _showYear) {
                _dateFormat = fmt;
                _showYear = sy;
                _lastDateDay = -1;
            }
            // Profile/HR-zone lookups below only feed interactive-row values, never drawn in AOD.
            if (!_lowPower) {
                var profile = UserProfile.getProfile();
                var vo2 = profile.vo2maxRunning;
                if (vo2 == null) {
                    vo2 = profile.vo2maxCycling;
                }
                _cachedVo2Max = vo2 != null ? (vo2 as Number).toString() : "-";
                if (
                    profile has :restingHeartRate &&
                    profile.restingHeartRate != null
                ) {
                    _cachedRestingHR = (
                        profile.restingHeartRate as Number
                    ).toString();
                } else {
                    _cachedRestingHR = "-";
                }
                if (
                    profile has :averageRestingHeartRate &&
                    profile.averageRestingHeartRate != null
                ) {
                    _cachedAvgRestingHR = (
                        profile.averageRestingHeartRate as Number
                    ).toString();
                } else {
                    _cachedAvgRestingHR = "-";
                }
                if (
                    profile has :upcomingSleepTime &&
                    profile.upcomingSleepTime != null
                ) {
                    var st =
                        Gregorian.info(
                            profile.upcomingSleepTime as Time.Moment,
                            Time.FORMAT_SHORT
                        ) as Gregorian.Info;
                    _cachedSleepTime =
                        (st.hour as Number).format("%02d") +
                        ":" +
                        (st.min as Number).format("%02d");
                } else {
                    _cachedSleepTime = "-";
                }
                if (
                    profile has :upcomingWakeTime &&
                    profile.upcomingWakeTime != null
                ) {
                    var wt =
                        Gregorian.info(
                            profile.upcomingWakeTime as Time.Moment,
                            Time.FORMAT_SHORT
                        ) as Gregorian.Info;
                    _cachedWakeTime =
                        (wt.hour as Number).format("%02d") +
                        ":" +
                        (wt.min as Number).format("%02d");
                } else {
                    _cachedWakeTime = "-";
                }
                // UserProfile.Profile has no hrZones field - zones come from this module function instead.
                try {
                    _hrZones = UserProfile.getHeartRateZones(
                        UserProfile.HR_ZONE_SPORT_GENERIC
                    );
                } catch (e instanceof Lang.Exception) {
                    _hrZones = null;
                }
            }
            var stats = System.getSystemStats();
            _charging = stats.charging;
            _batLow = stats.battery <= 10.0 && !_charging;
            _batText = stats.battery.format("%.0f") + "%";
            var days = stats.batteryInDays;
            _batDaysText =
                _showBatteryDays && days != null
                    ? " [" + days.format("%.0f") + "d]"
                    : "";
            _batW = 0;
            _spacedBatW = 0;
        }
        // Weather only feeds interactive-row values, never drawn in AOD.
        if (!_lowPower) {
            _refreshWeather(nowMin);
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (!_lowPower && _bgBacklight > 0 && _bgBacklight < 4) {
            if (_deferThisFrame) {
                // Full-screen blend-mode composite - same one-frame defer as the halo.
                _deferredWorkPending = true;
            } else {
                _drawBacklight(dc);
            }
        }

        if (_haloActive()) {
            _clearHalo();
        }

        if (!_metricsValid) {
            _fh = dc.getFontHeight(_font);
            _charW = dc.getTextWidthInPixels("W", _font);
            _tinyFh = dc.getFontHeight(_fontTiny);
            _smallFh = dc.getFontHeight(_fontSmall);
            _splitPad = dc.getTextWidthInPixels(": ", _font) / 2;
            _arrowW = dc.getTextWidthInPixels(" > ", _font);
            _metricsValid = true;
        }
        var step = _fh + 16;
        var cx = _screenW / 2 - _charW * _leftPad;
        _graphBaseX = cx + _splitPad;
        _graphX = _graphBaseX;
        _graphH = _fh - 2;

        // Lines 3/4/5 always occupy their slot so layout never shifts by content.
        var y = (_screenH - step * 6 - _fh) / 2;
        var row = 0;

        // Always-on: same layout math, but only header/time/date values plus footer, no scanlines (AMOLED pixel budget).
        if (_lowPower) {
            if (_alwaysOn) {
                _drawHeader(dc, y);
                _getTimeParts(dc);
                _drawAodValue(dc, cx, y + step, _cachedTimeStr, _line1ValueC);
                _drawAodValue(
                    dc,
                    cx,
                    y + step * 2,
                    _getDateParts()[1],
                    _line2ValueC
                );
                _drawFooter(dc, y + step * 6 + _fh + 32);
            }
            return;
        }

        _drawHeader(dc, y);

        _drawPromptLine(dc, cx, y + step * row, _watchCmd);
        row++;

        _timeValueX = cx + _splitPad;
        _timeValueY = y + step * row;
        _drawRow(
            dc,
            cx,
            _timeValueY,
            _getTimeParts(dc),
            _line1LabelC,
            _line1ValueC
        );
        row++;
        _drawRow(
            dc,
            cx,
            y + step * row,
            _getDateParts(),
            _line2LabelC,
            _line2ValueC
        );
        row++;
        _drawLineRow(
            dc,
            cx,
            y + step * row,
            _resolvedFields[0],
            _resolvedLabelC[0],
            _resolvedValueC[0],
            0
        );
        row++;
        _drawLineRow(
            dc,
            cx,
            y + step * row,
            _resolvedFields[1],
            _resolvedLabelC[1],
            _resolvedValueC[1],
            1
        );
        row++;
        _drawLineRow(
            dc,
            cx,
            y + step * row,
            _resolvedFields[2],
            _resolvedLabelC[2],
            _resolvedValueC[2],
            2
        );
        row++;

        var splitX = cx + _splitPad;
        var footerY = y + step * row;
        _cursorX = splitX;
        _cursorY = footerY;
        _cursorCharW = _charW;
        _cursorFh = _fh;

        _glowText(
            dc,
            splitX - _arrowW,
            footerY,
            _font,
            "~",
            Graphics.TEXT_JUSTIFY_RIGHT,
            ColorUtils.colorFromIdx(2)
        );
        _glowText(
            dc,
            splitX,
            footerY,
            _font,
            " > ",
            Graphics.TEXT_JUSTIFY_RIGHT,
            ColorUtils.colorFromIdx(0)
        );
        if (_cursorOn) {
            _glowRect(
                dc,
                splitX,
                footerY,
                _charW,
                _fh,
                ColorUtils.colorFromIdx(0)
            );
        }
        _drawFooter(dc, footerY + _fh + 32);

        if (_haloActive()) {
            _compositeHalo(dc);
        }

        // Drawn last so it's a uniform overlay across the whole finished frame, not just the gaps.
        if (_scanlineIntensity > 0 && _scanlineIntensity < 4) {
            _drawScanlines(dc, SCANLINE_ALPHA[_scanlineIntensity]);
        }

        if (_deferredWorkPending) {
            _deferredWorkPending = false;
            WatchUi.requestUpdate();
        }
    }

    private function _drawArrow(
        dc as Dc,
        x as Number,
        y as Number,
        up as Boolean
    ) as Void {
        var w = _bmpArrowW;
        var h = _arrowH;
        var shaftW = 3;
        var headH = (h * 2) / 5;
        var cx = x + w / 2;
        var shaftX = cx - 1;
        var hw = w / 4;
        if (up) {
            dc.fillPolygon([
                [cx, y],
                [cx - hw, y + headH],
                [cx + hw, y + headH],
            ]);
            dc.fillRectangle(shaftX, y + headH, shaftW, h - headH);
        } else {
            dc.fillRectangle(shaftX, y, shaftW, h - headH);
            dc.fillPolygon([
                [cx - hw, y + h - headH],
                [cx + hw, y + h - headH],
                [cx, y + h - 1],
            ]);
        }
    }

    // Draws numStr + small degree circle at (x, y); returns x after the circle.
    private function _drawSmallTempNum(
        dc as Dc,
        x as Number,
        y as Number,
        numStr as String,
        color as Number
    ) as Number {
        _glowText(
            dc,
            x,
            y,
            _fontSmall,
            numStr,
            Graphics.TEXT_JUSTIFY_LEFT,
            color
        );
        x += dc.getTextWidthInPixels(numStr, _fontSmall);
        _glowCircle(
            dc,
            x + _degWSmall / 2,
            y + _degWSmall / 2 + 4,
            (_degWSmall - 1) / 2,
            color
        );
        return x + _degWSmall;
    }

    private function _drawGraphValueLabel(
        dc as Dc,
        x as Number,
        y as Number,
        field as Number,
        str as String,
        color as Number
    ) as Number {
        if (field == FIELD_WRIST_TEMP) {
            var afterNum = _drawSmallTempNum(dc, x, y, str, color);
            _glowText(
                dc,
                afterNum,
                y,
                _fontSmall,
                _wxUnit,
                Graphics.TEXT_JUSTIFY_LEFT,
                color
            );
            return afterNum + dc.getTextWidthInPixels(_wxUnit, _fontSmall);
        } else {
            _glowText(
                dc,
                x,
                y,
                _fontSmall,
                str,
                Graphics.TEXT_JUSTIFY_LEFT,
                color
            );
            return x + dc.getTextWidthInPixels(str, _fontSmall);
        }
    }

    private function _drawValueModeLabel(
        dc as Dc,
        rightX as Number,
        y as Number,
        mode as Number
    ) as Void {
        var label = mode == 0 ? "c" : mode == 1 ? "a" : mode == 3 ? "m" : null;
        if (label == null) {
            return;
        }
        var color =
            mode == 0
                ? ColorUtils.colorFromIdx(1)
                : mode == 1
                  ? ColorUtils.colorFromIdx(5)
                  : ColorUtils.colorFromIdx(6);
        _glowText(
            dc,
            rightX + _charW / 2,
            y - 4,
            _fontTiny,
            label,
            Graphics.TEXT_JUSTIFY_LEFT,
            color
        );
    }

    private function _drawIcon(
        dc as Dc,
        x as Number,
        y as Number,
        iconType as Number,
        colorIdx as Number
    ) as Void {
        var color = ColorUtils.colorFromIdx(colorIdx);
        var hdc = _activeHaloDc();
        if (hdc != null) {
            hdc.setColor(_glowColor(color), Graphics.COLOR_TRANSPARENT);
            _drawIconShape(hdc, x + GLOW_SPREAD, y + GLOW_SPREAD, iconType);
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        _drawIconShape(dc, x, y, iconType);
    }

    private function _drawIconShape(
        dc as Dc,
        x as Number,
        y as Number,
        iconType as Number
    ) as Void {
        if (iconType == ICON_ARROW_UP) {
            _drawArrow(dc, x, y, true);
        } else if (iconType == ICON_ARROW_DN) {
            _drawArrow(dc, x, y, false);
        } else if (iconType == ICON_DEG) {
            dc.drawCircle(x + _degW / 2, y + _degW / 2, (_degW - 1) / 2);
        } else if (iconType == ICON_BOLT) {
            var w = _bmpBoltW - 2;
            var h = _boltH - 2;
            var bx = x + 1;
            var by = y + 1;
            dc.fillPolygon([
                [bx + (w * 7) / 10, by],
                [bx + (w * 1) / 10, by + (h * 11) / 20],
                [bx + (w * 4) / 10, by + (h * 11) / 20],
                [bx + (w * 3) / 10, by + h],
                [bx + (w * 9) / 10, by + (h * 9) / 20],
                [bx + (w * 6) / 10, by + (h * 9) / 20],
            ]);
        }
    }

    private function _drawHeader(dc as Dc, y as Number) as Void {
        var textY = y - 32 - _smallFh;
        if (_dndOn) {
            _glowText(
                dc,
                _screenW / 2,
                textY - _tinyFh - 2,
                _fontTiny,
                "[DND]",
                Graphics.TEXT_JUSTIFY_CENTER,
                GRAYS[3]
            );
        }
        if (_notifCount != 0) {
            _glowText(
                dc,
                _screenW / 2,
                textY,
                _fontSmall,
                _notifLabel,
                Graphics.TEXT_JUSTIFY_CENTER,
                ColorUtils.colorFromIdx(1)
            );
        }
        if (!_phoneConnected) {
            _glowText(
                dc,
                _screenW / 2,
                textY + _smallFh + 2,
                _fontTiny,
                "[OFFLINE]",
                Graphics.TEXT_JUSTIFY_CENTER,
                ColorUtils.colorFromIdx(5)
            );
        }
    }

    private function _drawFooter(dc as Dc, y as Number) as Void {
        if (_batLow) {
            _glowText(
                dc,
                _screenW / 2,
                y - _tinyFh - 2,
                _fontTiny,
                "[LOW]",
                Graphics.TEXT_JUSTIFY_CENTER,
                ColorUtils.colorFromIdx(5)
            );
        }
        var batText = _batText;
        var daysText = _batDaysText;
        var hasDays = daysText.length() > 0;
        if (_batW == 0) {
            _batW = dc.getTextWidthInPixels(batText, _fontSmall);
            _batDaysW = hasDays
                ? dc.getTextWidthInPixels(daysText, _fontSmall)
                : 0;
        }
        if (_charging) {
            if (_spacedBatW == 0) {
                _spacedBatText = " " + batText;
                _spacedBatW = dc.getTextWidthInPixels(
                    _spacedBatText,
                    _fontSmall
                );
            }
            var startX = (_screenW - _bmpBoltW - _spacedBatW - _batDaysW) / 2;
            _drawIcon(dc, startX, y + (_smallFh - _boltH) / 2, ICON_BOLT, 3);
            _glowText(
                dc,
                startX + _bmpBoltW,
                y,
                _fontSmall,
                _spacedBatText,
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.colorFromIdx(0)
            );
            if (hasDays) {
                _glowText(
                    dc,
                    startX + _bmpBoltW + _spacedBatW,
                    y,
                    _fontSmall,
                    daysText,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    GRAYS[3]
                );
            }
            return;
        }
        var startX = (_screenW - _batW - _batDaysW) / 2;
        _glowText(
            dc,
            startX,
            y,
            _fontSmall,
            batText,
            Graphics.TEXT_JUSTIFY_LEFT,
            ColorUtils.colorFromIdx(0)
        );
        if (hasDays) {
            _glowText(
                dc,
                startX + _batW,
                y,
                _fontSmall,
                daysText,
                Graphics.TEXT_JUSTIFY_LEFT,
                GRAYS[3]
            );
        }
    }

    private function _drawBacklight(dc as Dc) as Void {
        if (_bgBacklightBmp == null) {
            _renderBacklightBitmap();
        }
        if (_bgBacklightBmp != null) {
            var bmp = _bgBacklightBmp as Graphics.BufferedBitmap;
            var shift = _flickerShift(
                System.getClockTime().sec + 500,
                BG_BACKLIGHT_SHIFT_MAX
            );
            var y = shift - BG_BACKLIGHT_PAD;
            var r = _tryDrawBitmapRetry(
                dc,
                0,
                y,
                bmp,
                _bgBacklightDrawOk,
                _bgBacklightDrawOkMin
            );
            _bgBacklightDrawOk = r[0];
            _bgBacklightDrawOkMin = r[1];
        }
        if (_bgBacklightDimBmp == null) {
            _bgBacklightDimBmp = _createBitmap(_screenW, _screenH);
        }
        if (_bgBacklightDimBmp != null) {
            var dimBmp = _bgBacklightDimBmp as Graphics.BufferedBitmap;
            var gray = _flickerAlpha(
                BG_BACKLIGHT_DIM_LEVEL[_bgBacklight],
                System.getClockTime().sec + 500,
                FLICKER_MAGNITUDE
            );
            // gray is a pure function of the current clock second, so a same-second
            // redraw (rotation, wake) would otherwise refill this full-screen bitmap for nothing.
            if (gray != _bgBacklightDimGray) {
                _bgBacklightDimGray = gray;
                var dimBdc = dimBmp.getDc();
                dimBdc.setColor(
                    (gray << 16) | (gray << 8) | gray,
                    Graphics.COLOR_TRANSPARENT
                );
                dimBdc.fillRectangle(0, 0, _screenW, _screenH);
            }
            dc.setBlendMode(Graphics.BLEND_MODE_MULTIPLY);
            var dimR = _tryDrawBitmapRetry(
                dc,
                0,
                0,
                dimBmp,
                _bgBacklightDimDrawOk,
                _bgBacklightDimDrawOkMin
            );
            _bgBacklightDimDrawOk = dimR[0];
            _bgBacklightDimDrawOkMin = dimR[1];
            dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
        }
    }

    // Full bright range, taller than the screen so a flicker shift has room.
    private function _renderBacklightBitmap() as Void {
        var bmpH = _screenH + BG_BACKLIGHT_PAD * 2;
        var bmp = _createBitmap(_screenW, bmpH);
        if (bmp == null) {
            return;
        }
        _bgBacklightBmp = bmp;
        var bdc = bmp.getDc();
        var hue = _activeColors[1];
        var cr = ((hue >> 16) & 0xff).toFloat() / 255.0;
        var cg = ((hue >> 8) & 0xff).toFloat() / 255.0;
        var cb = (hue & 0xff).toFloat() / 255.0;
        var by = 0;
        while (by < bmpH) {
            var pos = (by - BG_BACKLIGHT_PAD + 0.5) / _screenH.toFloat();
            var brightness = _backlightFraction(pos) * 255.0;
            var r = _quantizeBits(cr * brightness, 5);
            var g = _quantizeBits(cg * brightness, 6);
            var b = _quantizeBits(cb * brightness, 5);
            bdc.setColor((r << 16) | (g << 8) | b, Graphics.COLOR_TRANSPARENT);
            bdc.fillRectangle(0, by, _screenW, 1);
            by += 1;
        }
    }

    // Rounds v (0-255) to the nearest representable value at bits per channel.
    private function _quantizeBits(v as Float, bits as Number) as Number {
        var step = 1 << (8 - bits);
        var maxQ = (1 << bits) - 1;
        var q = Math.round(v / step).toNumber();
        if (q < 0) {
            q = 0;
        } else if (q > maxQ) {
            q = maxQ;
        }
        return q * step;
    }

    private function _backlightFraction(pos as Float) as Float {
        var d = (pos - 0.5).abs();
        var exponent = -d / BG_BACKLIGHT_SIGMA;
        return Math.pow(2.718281828459045, exponent).toFloat();
    }

    private function _drawScanlines(dc as Dc, alpha as Number) as Void {
        // Black has no headroom over this display's near-always-black clear color; white does.
        dc.setStroke((alpha << 24) | 0xffffff);
        var y = 0;
        while (y < _screenH) {
            dc.drawLine(0, y, _screenW - 1, y);
            y += SCANLINE_SPACING;
        }
    }

    // Draws bmp and reports whether it succeeded (see _haloDrawOk).
    private function _tryDrawBitmap(
        dc as Dc,
        x as Number,
        y as Number,
        bmp as Graphics.BufferedBitmap
    ) as Boolean {
        try {
            dc.drawBitmap(x, y, bmp);
            return true;
        } catch (e instanceof Lang.Exception) {
            return false;
        }
    }

    // Shared by every *DrawOk flag. Returns [ok, lastCheckedMin] for the
    // caller to store back into its own instance vars.
    private function _tryDrawBitmapRetry(
        dc as Dc,
        x as Number,
        y as Number,
        bmp as Graphics.BufferedBitmap,
        lastOk as Boolean?,
        lastMin as Number
    ) as [Boolean, Number] {
        // _nowUnixMin < lastMin means the clock moved backward - retry now rather than trust stale elapsed-time math.
        if (
            lastOk == null ||
            _nowUnixMin < lastMin ||
            _nowUnixMin - lastMin >= BITMAP_DRAW_RETRY_MIN
        ) {
            return [_tryDrawBitmap(dc, x, y, bmp), _nowUnixMin];
        }
        if (lastOk as Boolean) {
            if (!_tryDrawBitmap(dc, x, y, bmp)) {
                return [false, _nowUnixMin];
            }
        }
        return [lastOk, lastMin];
    }

    private function _drawCachedGraphBitmap(
        dc as Dc,
        x as Number,
        y as Number,
        bmp as Graphics.BufferedBitmap,
        cacheKey as Number,
        drawOkCache as Dictionary
    ) as Boolean {
        var state = drawOkCache.hasKey(cacheKey)
            ? drawOkCache.get(cacheKey) as [Boolean?, Number]
            : [null, -1];
        var r = _tryDrawBitmapRetry(dc, x, y, bmp, state[0], state[1]);
        drawOkCache.put(cacheKey, r);
        return r[0];
    }

    // .get() can throw or silently return a pool-reclaimed bitmap; isCached() catches the latter.
    private function _resolveBmpRef(
        ref as Graphics.BufferedBitmapReference?
    ) as Graphics.BufferedBitmap? {
        if (ref == null) {
            return null;
        }
        try {
            var bmp = ref.get() as Graphics.BufferedBitmap?;
            return bmp != null && bmp.isCached() ? bmp : null;
        } catch (e instanceof Lang.Exception) {
            return null;
        }
    }

    // Graphics.createBufferedBitmap() can also throw under memory pressure.
    private function _tryCreateBufferedBitmap(
        w as Number,
        h as Number
    ) as Graphics.BufferedBitmapReference? {
        try {
            return Graphics.createBufferedBitmap({ :width => w, :height => h });
        } catch (e instanceof Lang.Exception) {
            return null;
        }
    }

    private function _newClearedBitmap(
        w as Number,
        h as Number
    ) as [Graphics.BufferedBitmapReference, Graphics.BufferedBitmap]? {
        var newRef = _tryCreateBufferedBitmap(w, h);
        var bmp = _resolveBmpRef(newRef);
        if (bmp == null) {
            return null;
        }
        var bmpDc = bmp.getDc();
        bmpDc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        bmpDc.clear();
        return [newRef, bmp];
    }

    private function _clampByte(v as Number) as Number {
        if (v < 0) {
            return 0;
        }
        if (v > 255) {
            return 255;
        }
        return v;
    }

    // Whether the halo is worth drawing into this frame; lazily creates _haloBmp.
    private function _haloActive() as Boolean {
        if (_glowIntensity == 0 || _lowPower) {
            return false;
        }
        if (_deferThisFrame) {
            // Glow triples every draw call it touches - skip it on the wake frame itself and
            // let it bloom in on the immediate follow-up frame instead of blocking wake-up.
            _deferredWorkPending = true;
            return false;
        }
        if (_haloBmp == null) {
            _haloBmp = _createBitmap(_screenW, _screenH);
        }
        return _haloBmp != null;
    }

    private function _haloDc() as Dc {
        return (_haloBmp as Graphics.BufferedBitmap).getDc();
    }

    private function _activeHaloDc() as Dc? {
        if (_haloBakeDc != null) {
            return _haloBakeDc;
        }
        if (_haloSuppressed) {
            return null;
        }
        return _haloActive() ? _haloDc() : null;
    }

    private function _haloDcIfDrawable() as Dc? {
        return _haloDrawOk == true ? _activeHaloDc() : null;
    }

    // Tries decreasing colorDepth until one is accepted (needs real depth, not a small palette).
    private function _createBitmap(
        w as Number,
        h as Number
    ) as Graphics.BufferedBitmap? {
        var depths = [24, 16, 8] as Array<Number>;
        var i = 0;
        while (i < depths.size()) {
            try {
                var ref = Graphics.createBufferedBitmap({
                    :width => w,
                    :height => h,
                    :colorDepth => depths[i],
                });
                var bmp =
                    (ref as Graphics.BufferedBitmapReference).get() as
                    Graphics.BufferedBitmap?;
                if (bmp != null) {
                    return bmp;
                }
            } catch (e instanceof Lang.Exception) {}
            i += 1;
        }
        try {
            var fallbackRef = Graphics.createBufferedBitmap({
                :width => w,
                :height => h,
            });
            return (
                (fallbackRef as Graphics.BufferedBitmapReference).get() as
                Graphics.BufferedBitmap?
            );
        } catch (e instanceof Lang.Exception) {
            return null;
        }
    }

    private function _clearHalo() as Void {
        var hdc = _haloDc();
        hdc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        hdc.clear();
    }

    private function _compositeHalo(dc as Dc) as Void {
        var bmp = _haloBmp as Graphics.BufferedBitmap;
        dc.setBlendMode(Graphics.BLEND_MODE_ADDITIVE);
        var r = _tryDrawBitmapRetry(dc, 0, 0, bmp, _haloDrawOk, _haloDrawOkMin);
        _haloDrawOk = r[0];
        _haloDrawOkMin = r[1];
        dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
    }

    private function _glowColor(color as Number) as Number {
        var f = GLOW_FRACTION[_glowIntensity];
        var r = (((color >> 16) & 0xff) * f).toNumber();
        var g = (((color >> 8) & 0xff) * f).toNumber();
        var b = ((color & 0xff) * f).toNumber();
        return (r << 16) | (g << 8) | b;
    }

    // Soft halo behind text before the crisp glyphs on top.
    private function _glowText(
        dc as Dc,
        x as Number,
        y as Number,
        font as Graphics.FontType,
        text as String,
        justify as Graphics.TextJustification,
        color as Number
    ) as Void {
        var hdc = _activeHaloDc();
        if (hdc != null) {
            var tinted = _glowColor(color);
            var w = dc.getTextWidthInPixels(text, font);
            var leftX = x;
            if (justify == Graphics.TEXT_JUSTIFY_RIGHT) {
                leftX = x - w;
            } else if (justify == Graphics.TEXT_JUSTIFY_CENTER) {
                leftX = x - w / 2;
            }
            var bmp = _glowGlyphBmp(dc, font, text, tinted, w);
            if (bmp != null) {
                hdc.drawBitmap(leftX + GLOW_SPREAD, y + GLOW_SPREAD, bmp);
            } else {
                hdc.setColor(tinted, Graphics.COLOR_TRANSPARENT);
                hdc.drawText(
                    x + GLOW_SPREAD,
                    y + GLOW_SPREAD,
                    font,
                    text,
                    justify
                );
            }
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justify);
    }

    private function _glowGlyphBmp(
        dc as Dc,
        font as Graphics.FontType,
        text as String,
        tinted as Number,
        w as Number
    ) as Graphics.BufferedBitmap? {
        var key = text + "\t" + font.toString() + "\t" + tinted.toString();
        if (_glowGlyphCache.hasKey(key)) {
            var cached = _resolveBmpRef(
                _glowGlyphCache.get(key) as Graphics.BufferedBitmapReference
            );
            if (cached != null) {
                return cached;
            }
            _glowGlyphCache.remove(key);
        }
        var made = _newClearedBitmap(w, dc.getFontHeight(font));
        if (made == null) {
            return null;
        }
        var ref = made[0];
        var bmp = made[1];
        var bmpDc = bmp.getDc();
        bmpDc.setColor(tinted, Graphics.COLOR_TRANSPARENT);
        bmpDc.drawText(0, 0, font, text, Graphics.TEXT_JUSTIFY_LEFT);

        var evictKey = _glowGlyphKeys[_glowGlyphIdx];
        if (evictKey != null) {
            _glowGlyphCache.remove(evictKey as String);
        }
        _glowGlyphKeys[_glowGlyphIdx] = key;
        _glowGlyphIdx = (_glowGlyphIdx + 1) % GLOW_GLYPH_CACHE_CAP;
        _glowGlyphCache.put(key, ref);
        return bmp;
    }

    private function _glowLine(
        dc as Dc,
        x1 as Number,
        y1 as Number,
        x2 as Number,
        y2 as Number,
        color as Number
    ) as Void {
        var hdc = _activeHaloDc();
        if (hdc != null) {
            hdc.setColor(_glowColor(color), Graphics.COLOR_TRANSPARENT);
            hdc.drawLine(
                x1 + GLOW_SPREAD,
                y1 + GLOW_SPREAD,
                x2 + GLOW_SPREAD,
                y2 + GLOW_SPREAD
            );
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1, y1, x2, y2);
    }

    private function _haloFillDiagSpread(
        hdc as Dc,
        x as Number,
        y as Number,
        w as Number,
        h as Number
    ) as Void {
        hdc.fillRectangle(x + GLOW_SPREAD, y + GLOW_SPREAD, w, h);
    }

    private function _glowRect(
        dc as Dc,
        x as Number,
        y as Number,
        w as Number,
        h as Number,
        color as Number
    ) as Void {
        var hdc = _activeHaloDc();
        if (hdc != null) {
            hdc.setColor(_glowColor(color), Graphics.COLOR_TRANSPARENT);
            _haloFillDiagSpread(hdc, x, y, w, h);
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, w, h);
    }

    // One glow shape per gap-run (live-drawn; per-point glow suppressed for cached bitmaps, see _haloSuppressed).
    private function _glowLineShape(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float,
        maxGap as Number,
        topOff as Number,
        botOff as Number
    ) as Void {
        var hdc = _activeHaloDc();
        if (hdc == null) {
            return;
        }
        var n = data.size();
        var n1 = n - 1;
        if (n1 < 1) {
            return;
        }
        var ghf = gh.toFloat();
        var isGrad = colorIdx >= COLOR_GRAD_TRI;
        var flatColor = isGrad ? 0 : ColorUtils.colorFromIdx(colorIdx);
        var runX = new Array<Number>[0];
        var runY = new Array<Number>[0];
        var runSum = 0.0;
        var runCnt = 0;
        var lastI = -1;
        for (var i = 0; i <= n; i++) {
            var atEnd = i == n;
            var isNull = !atEnd && data[i] == null;
            var gapBreak =
                !atEnd && !isNull && lastI >= 0 && i - lastI > maxGap;
            if ((atEnd || gapBreak) && runX.size() > 0) {
                var color = flatColor;
                if (isGrad) {
                    var frac = _fracClamp(
                        runSum / runCnt.toFloat(),
                        gradMinV,
                        gradRange
                    );
                    color = ColorUtils.gradColor(colorIdx, frac);
                }
                _fillGlowRibbon(
                    hdc,
                    runX,
                    runY,
                    _glowColor(color),
                    topOff,
                    botOff
                );
                runX = new Array<Number>[0];
                runY = new Array<Number>[0];
                runSum = 0.0;
                runCnt = 0;
            }
            if (atEnd || isNull) {
                continue;
            }
            var v = data[i] as Float;
            runX.add(_linePointX(gx, gw, n1, i));
            runY.add(_linePointY(y, gh, v, minV, range, ghf));
            runSum += v;
            runCnt++;
            lastI = i;
        }
    }

    // Chunked to <=16 points (32 vertices): fillPolygon has an undocumented ~240-vertex limit and silently mis-renders past it.
    private function _fillGlowRibbon(
        hdc as Dc,
        xs as Array<Number>,
        ys as Array<Number>,
        dimColor as Number,
        topOff as Number,
        botOff as Number
    ) as Void {
        var n = xs.size();
        hdc.setColor(dimColor, Graphics.COLOR_TRANSPARENT);
        if (n < 2) {
            hdc.fillRectangle(xs[0], ys[0] + topOff, 2, botOff - topOff + 1);
            return;
        }
        var chunkMax = 15;
        var start = 0;
        while (start < n - 1) {
            var end = start + chunkMax;
            if (end > n - 1) {
                end = n - 1;
            }
            var cn = end - start + 1;
            var pts = new Array<[Numeric, Numeric]>[cn * 2];
            for (var i = 0; i < cn; i++) {
                pts[i] = [xs[start + i], ys[start + i] + topOff];
                pts[cn + i] = [
                    xs[start + cn - 1 - i],
                    ys[start + cn - 1 - i] + botOff,
                ];
            }
            hdc.fillPolygon(pts);
            start = end;
        }
    }

    // One glow rect per bar, drawn live at the real screen position
    // (matches _drawBars/_drawGradBars via the shared _barRect helper).
    private function _glowBarsShape(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float
    ) as Void {
        var hdc = _activeHaloDc();
        if (hdc == null) {
            return;
        }
        var n = data.size();
        var ghf = gh.toFloat();
        var isGrad = colorIdx >= COLOR_GRAD_TRI;
        var flatColor = isGrad ? 0 : ColorUtils.colorFromIdx(colorIdx);
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var r = _barRect(gx, gw, y, gh, i, n, v, minV, range, ghf);
            var color = flatColor;
            if (isGrad) {
                var frac = _fracClamp(v, gradMinV, gradRange);
                color = ColorUtils.gradColor(colorIdx, frac);
            }
            hdc.setColor(_glowColor(color), Graphics.COLOR_TRANSPARENT);
            _haloFillDiagSpread(hdc, r[0], r[1], r[2], r[3]);
        }
    }

    // Dual-series counterpart to _glowBarsShape, via the shared _dualBarRect helper.
    private function _glowDualBarsShape(
        dc as Dc,
        data as Array<Float>,
        data2 as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        minV2 as Float,
        range2 as Float,
        colorIdx1 as Number,
        colorIdx2 as Number,
        gradMinV1 as Float,
        gradRange1 as Float,
        gradMinV2 as Float,
        gradRange2 as Float
    ) as Void {
        var hdc = _activeHaloDc();
        if (hdc == null) {
            return;
        }
        var n = data.size();
        var n2 = data2.size();
        var count = n < n2 ? n : n2;
        var ghf = gh.toFloat();
        for (var i = 0; i < count; i++) {
            if (data[i] != null) {
                var v1 = data[i] as Float;
                var r1 = _dualBarRect(
                    gx,
                    gw,
                    y,
                    gh,
                    i,
                    count,
                    v1,
                    minV,
                    range,
                    ghf,
                    true
                );
                var frac1 = _fracClamp(v1, gradMinV1, gradRange1);
                hdc.setColor(
                    _glowColor(ColorUtils.gradColor(colorIdx1, frac1)),
                    Graphics.COLOR_TRANSPARENT
                );
                _haloFillDiagSpread(hdc, r1[0], r1[1], r1[2], r1[3]);
            }
            if (data2[i] != null) {
                var v2 = data2[i] as Float;
                var r2 = _dualBarRect(
                    gx,
                    gw,
                    y,
                    gh,
                    i,
                    count,
                    v2,
                    minV2,
                    range2,
                    ghf,
                    false
                );
                var frac2 = _fracClamp(v2, gradMinV2, gradRange2);
                hdc.setColor(
                    _glowColor(ColorUtils.gradColor(colorIdx2, frac2)),
                    Graphics.COLOR_TRANSPARENT
                );
                _haloFillDiagSpread(hdc, r2[0], r2[1], r2[2], r2[3]);
            }
        }
    }

    // Mirrors _drawOneGraph's dispatch so call sites only need one call after
    // the crisp bitmap-or-fallback render, at the row's real screen position.
    private function _glowOneGraph(
        dc as Dc,
        graphType as Number,
        colorIdx as Number,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        gradMinV as Float,
        gradRange as Float,
        maxGap as Number
    ) as Void {
        if (graphType == GRAPH_BAR) {
            _glowBarsShape(
                dc,
                data,
                gx,
                gw,
                y,
                gh + 1,
                minV,
                range,
                colorIdx,
                gradMinV,
                gradRange
            );
        } else if (graphType == GRAPH_AREA) {
            // Intentionally off - every offset tried read as wrong against
            // the fill's hard top edge. Revisit with a new geometric idea.
        } else {
            _glowLineShape(
                dc,
                data,
                gx,
                gw,
                y,
                gh,
                minV,
                range,
                colorIdx,
                gradMinV,
                gradRange,
                maxGap,
                -GLOW_SPREAD,
                GLOW_SPREAD
            );
        }
    }

    // Same halo treatment as _glowText, for a stroked circle (degree marks).
    private function _glowCircle(
        dc as Dc,
        x as Number,
        y as Number,
        r as Number,
        color as Number
    ) as Void {
        var hdc = _activeHaloDc();
        if (hdc != null) {
            hdc.setColor(_glowColor(color), Graphics.COLOR_TRANSPARENT);
            hdc.drawCircle(x + GLOW_SPREAD, y + GLOW_SPREAD, r);
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y, r);
    }

    // Base most seconds; occasionally spikes for one tick then reverts.
    private function _flickerAlpha(
        base as Number,
        sec as Number,
        magnitude as Number
    ) as Number {
        if (!_flickerEnabled) {
            return base;
        }
        var n = (sec * 374761393 + 907633515) & 0x7fffffff;
        n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff;
        if (n % 100 >= FLICKER_CHANCE_PCT) {
            return base;
        }
        var delta = (n % (magnitude * 2 + 1)) - magnitude;
        return _clampByte(base + delta);
    }

    // Pass the same seed as _flickerAlpha to move together on the same tick.
    private function _flickerShift(
        sec as Number,
        maxShift as Number
    ) as Number {
        if (!_flickerEnabled) {
            return 0;
        }
        var n = (sec * 374761393 + 907633515) & 0x7fffffff;
        n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff;
        if (n % 100 >= FLICKER_CHANCE_PCT) {
            return 0;
        }
        return (n % (maxShift * 2 + 1)) - maxShift;
    }

    private function _drawPromptLine(
        dc as Dc,
        cx as Number,
        y as Number,
        content as String
    ) as Void {
        var splitX = cx + _splitPad;
        _glowText(
            dc,
            splitX - _arrowW,
            y,
            _font,
            "~",
            Graphics.TEXT_JUSTIFY_RIGHT,
            ColorUtils.colorFromIdx(2)
        );
        _glowText(
            dc,
            splitX,
            y,
            _font,
            " > ",
            Graphics.TEXT_JUSTIFY_RIGHT,
            ColorUtils.colorFromIdx(0)
        );
        _glowText(
            dc,
            splitX,
            y,
            _font,
            content,
            Graphics.TEXT_JUSTIFY_LEFT,
            ColorUtils.colorFromIdx(3)
        );
    }

    private function _resolveAllLines(phase as Number) as Void {
        _resolveOneLine(0, "l3", phase);
        _resolveOneLine(1, "l4", phase);
        _resolveOneLine(2, "l5", phase);
        _resolveLineGraph(0);
        _resolveLineGraph(1);
        _resolveLineGraph(2);
    }

    // Mirrors LINE_SLOTS in generate_resources.py - keep in sync if that table changes.
    private function _lineSlotDefaultField(
        pk as String,
        slotName as String
    ) as Number {
        if (pk.equals("l3")) {
            if (slotName.equals("R1")) {
                return FIELD_WX_FCST_TEMP;
            }
            if (slotName.equals("R2")) {
                return FIELD_WX_COND_CLOUD;
            }
            if (slotName.equals("R3")) {
                return FIELD_WX_UV_WIND;
            }
            if (slotName.equals("R4")) {
                return FIELD_WX_HUMIDITY_PRECIP;
            }
            if (slotName.equals("R5")) {
                return FIELD_WX_FCST_DAILY;
            }
        } else if (pk.equals("l4")) {
            if (slotName.equals("R1")) {
                return FIELD_STEPS;
            }
            if (slotName.equals("R2")) {
                return FIELD_ELEVATION;
            }
            if (slotName.equals("R3")) {
                return FIELD_DISTANCE;
            }
            if (slotName.equals("R4")) {
                return FIELD_FLOORS;
            }
            if (slotName.equals("R5")) {
                return FIELD_CLIMB_DESCEND_DAY;
            }
        } else if (pk.equals("l5")) {
            if (slotName.equals("R1")) {
                return FIELD_HR;
            }
            if (slotName.equals("R2")) {
                return FIELD_STRESS;
            }
            if (slotName.equals("R3")) {
                return FIELD_BODY_BAT;
            }
            if (slotName.equals("R4")) {
                return FIELD_ACTIVE_MIN_DAY;
            }
            if (slotName.equals("R5")) {
                return FIELD_INTENSITY_MIN;
            }
        }
        return FIELD_NONE;
    }

    private function _lineLabelColorDefault(pk as String) as Number {
        if (pk.equals("l3")) {
            return 6;
        }
        if (pk.equals("l4")) {
            return 1;
        }
        if (pk.equals("l5")) {
            return 5;
        }
        return 8;
    }

    private function _resolveOneLine(
        li as Number,
        key as String,
        phase as Number
    ) as Void {
        // Label/value colors are per line (shared across rotation slots); only the field rotates.
        var pk = key;
        var f = FIELD_NONE;
        if (_getBoolProp(pk + "En", true)) {
            if (phase >= 1 && phase <= 8) {
                var slotName = ROTATE_SLOT_NAMES[phase - 1];
                f = _getProp(
                    pk + slotName,
                    _lineSlotDefaultField(pk, slotName)
                );
            }
            if (f == FIELD_NONE) {
                f = _getProp(pk + "R1", _lineSlotDefaultField(pk, "R1"));
            }
        }
        _resolvedFields[li] = f;
        _resolvedLabelC[li] = _getProp(pk + "Lc", _lineLabelColorDefault(pk));
        _resolvedValueC[li] = _getProp(pk + "Vc", 0);
    }

    // mode: 1=line,2=bar,3=line+current,4=bar+current,5=area,6=area+current.
    private function _resolveForecastGraph(
        li as Number,
        key as String,
        colorDefault as Number,
        valueDefault as Number
    ) as Void {
        var mode = _getProp(key + "Gm", 4);
        _lineViewMode[li] =
            mode == 3 || mode == 4 || mode == 6 ? VIEW_GRAPH_VALUE : VIEW_GRAPH;
        _lineGraphType[li] =
            mode == 2 || mode == 4
                ? GRAPH_BAR
                : mode == 5 || mode == 6
                  ? GRAPH_AREA
                  : GRAPH_LINE;
        _lineValueMode[li] = _getProp(key + "Vm", valueDefault);
        _lineGraphColor[li] = _getProp(key + "Gc", colorDefault);
        _linePeriodMin[li] = _getProp(key + "Tf", 12);
        _lineGraphWidth[li] = _getProp(key + "Gw", 10);
    }

    // Resolves the show/color/width settings shared by every goal-bar field.
    private function _resolveBarField(
        li as Number,
        propPrefix as String,
        defaultColor as Number,
        defaultWidth as Number,
        defaultShowBar as Boolean
    ) as Void {
        _lineViewMode[li] = _getBoolProp(propPrefix + "Sb", defaultShowBar)
            ? _getBoolProp(propPrefix + "Sv", true)
                ? 2
                : 1
            : 0;
        _lineGraphColor[li] = _getProp(propPrefix + "Bc", defaultColor);
        _lineGraphWidth[li] = _getProp(propPrefix + "Bw", defaultWidth);
    }

    private function _resolveLineGraph(li as Number) as Void {
        _lineSecType[li] = SEC_NONE;
        _lineValueMode[li] = 0;
        _lineViewMode[li] = VIEW_VALUE;
        _lineGraphType[li] = GRAPH_LINE;
        _linePeriodMin[li] = 60;
        _lineGraphColor[li] = 0;
        _lineGraphWidth[li] = 10;
        var field = _resolvedFields[li];
        if (field == FIELD_STEPS) {
            _resolveBarField(li, "stp", 1, 10, true);
            return;
        }
        if (field == FIELD_FLOORS) {
            _resolveBarField(li, "flr", 5, 8, false);
            return;
        }
        if (field == FIELD_INTENSITY_MIN) {
            _resolveBarField(li, "iMin", 5, 8, true);
            return;
        }
        if (field == FIELD_CALORIES) {
            _resolveBarField(li, "cal", 4, 10, false);
            var caloriesGoal = _getProp("calBg", 2000);
            _lineGoal[li] = caloriesGoal <= 0 ? 2000 : caloriesGoal;
            return;
        }
        if (field == FIELD_DISTANCE) {
            _resolveBarField(li, "dist", 6, 10, false);
            var distanceGoal = _getProp("distBg", 5);
            _lineGoal[li] = distanceGoal <= 0 ? 5 : distanceGoal;
            return;
        }
        if (field == FIELD_ACTIVE_MIN_DAY) {
            _resolveBarField(li, "aMin", 9, 10, false);
            var activeMinGoal = _getProp("aMinBg", 30);
            _lineGoal[li] = activeMinGoal <= 0 ? 30 : activeMinGoal;
            return;
        }
        if (field == FIELD_WX_FCST_TEMP) {
            _resolveForecastGraph(li, "wxf", 16, 0);
            return;
        }
        if (field == FIELD_WX_FCST_PRECIP) {
            _resolveForecastGraph(li, "wxfp", 6, 1);
            return;
        }
        if (field == FIELD_WX_FCST_DAILY) {
            _lineViewMode[li] = _getProp("wxfdVw", VIEW_GRAPH_VALUE);
            _lineValueMode[li] = _getProp("wxfdVm", 2);
            _lineGraphColor[li] = _getProp("wxfdGc", 16);
            _linePeriodMin[li] = _getProp("wxfdDy", 5);
            _lineGraphWidth[li] = _getProp("wxfdGw", 8);
            return;
        }
        if (field == FIELD_WX_FCST_WIND) {
            _resolveForecastGraph(li, "wxfw", 6, 1);
            return;
        }
        if (field == FIELD_WX_FCST_HUMIDITY) {
            _resolveForecastGraph(li, "wxfh", 2, 1);
            return;
        }
        if (field == FIELD_WX_FCST_UV) {
            _resolveForecastGraph(li, "wxfu", 3, 2);
            return;
        }
        if (field == FIELD_WX_FCST_CLOUD) {
            _resolveForecastGraph(li, "wxfc", 8, 1);
            return;
        }
        var gk = _fieldGraphKey(field);
        if (gk == null) {
            return;
        }
        var defaults = _graphFieldDefaults(field);
        var mode = _getProp(gk + "Gm", defaults[0]);
        _lineViewMode[li] =
            mode == 3 || mode == 4 || mode == 6
                ? VIEW_GRAPH_VALUE
                : mode > 0
                  ? VIEW_GRAPH
                  : VIEW_VALUE;
        _lineGraphType[li] =
            mode == 2 || mode == 4
                ? GRAPH_BAR
                : mode == 5 || mode == 6
                  ? GRAPH_AREA
                  : GRAPH_LINE;
        _linePeriodMin[li] = _getProp(gk + "Tf", defaults[1]);
        _lineGraphColor[li] = _getProp(gk + "Gc", defaults[2]);
        _lineSecType[li] = _getProp(gk + "St", SEC_NONE);
        _lineValueMode[li] = _getProp(gk + "Gvm", defaults[3]);
        var vm = _lineViewMode[li];
        if (
            _lineSecType[li] != SEC_NONE &&
            (vm == VIEW_GRAPH || vm == VIEW_GRAPH_VALUE)
        ) {
            var sidx = _getProp(gk + "Sf", defaults[4]);
            if (sidx < 0 || sidx >= GRAPH_SEC_FIELDS.size()) {
                sidx = 0;
            }
            _lineSecField[li] = sidx;
            _lineSecColor[li] = _getProp(gk + "Se", 0);
        }
        _lineGraphWidth[li] = _getProp(gk + "Gw", 10);
        _lineBarGroupDensity[li] = _getProp(gk + "Bn", 0);
        _lineBarGroupAgg[li] = _getProp(gk + "Ba", 0);
    }

    private function _drawLineRow(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        labelColor as Number,
        valueColor as Number,
        li as Number
    ) as Void {
        if (field == FIELD_NONE) {
            return;
        }
        _graphW = _charW * _lineGraphWidth[li];
        if (_drawLineRowFitness(dc, cx, y, field, labelColor, valueColor, li)) {
            return;
        }
        if (_drawLineRowHealth(dc, cx, y, field, labelColor, valueColor, li)) {
            return;
        }
        if (
            _drawLineRowWeatherCurrent(
                dc,
                cx,
                y,
                field,
                labelColor,
                valueColor,
                li
            )
        ) {
            return;
        }
        if (
            _drawLineRowWeatherForecast(
                dc,
                cx,
                y,
                field,
                labelColor,
                valueColor,
                li
            )
        ) {
            return;
        }
        _getFieldParts(field);
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
    }

    private function _drawLineRowFitness(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        labelColor as Number,
        valueColor as Number,
        li as Number
    ) as Boolean {
        if (field == FIELD_FLOORS) {
            var vm = _lineViewMode[li];
            if (vm == 1 || vm == 2) {
                _drawFloorsBarRow(
                    dc,
                    cx,
                    y,
                    labelColor,
                    valueColor,
                    vm == 2,
                    _lineGraphColor[li]
                );
                return true;
            }
            _drawFloorsRow(dc, cx, y, labelColor, valueColor);
            return true;
        }
        if (field == FIELD_STEPS) {
            var vm = _lineViewMode[li];
            if (vm == 1 || vm == 2) {
                _drawStepsBarRow(
                    dc,
                    cx,
                    y,
                    labelColor,
                    valueColor,
                    vm == 2,
                    _lineGraphColor[li]
                );
            } else {
                var steps = 0;
                var goal = 10000;
                if (_amInfo != null) {
                    var info = _amInfo as ActivityMonitor.Info;
                    steps = info.steps != null ? info.steps as Number : 0;
                    goal =
                        info.stepGoal != null ? info.stepGoal as Number : 10000;
                }
                _rowBuf[0] = "Steps";
                _rowBuf[1] = steps.format(
                    "%0" + goal.toString().length() + "d"
                );
                _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
                if (steps >= goal) {
                    _glowText(
                        dc,
                        cx +
                            _splitPad +
                            dc.getTextWidthInPixels(_rowBuf[1], _font),
                        y,
                        _font,
                        " [GOAL]",
                        Graphics.TEXT_JUSTIFY_LEFT,
                        ColorUtils.colorFromIdx(1)
                    );
                }
            }
            return true;
        }
        if (field == FIELD_MOVE_BAR) {
            _drawMoveBarRow(dc, cx, y, labelColor, valueColor);
            return true;
        }
        if (field == FIELD_CLIMB_DESCEND_DAY) {
            var up = "-";
            var dn = "-";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.metersClimbed != null) {
                    var m = info.metersClimbed as Float;
                    up = _altStr(m);
                }
                if (info.metersDescended != null) {
                    var m = info.metersDescended as Float;
                    dn = _altStr(m);
                }
            }
            _drawUpDownRow(
                dc,
                cx,
                y,
                "Climb+Desc",
                up,
                dn,
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_INTENSITY_MIN) {
            var vm = _lineViewMode[li];
            if (vm == 1 || vm == 2) {
                _drawIntensityMinBarRow(
                    dc,
                    cx,
                    y,
                    labelColor,
                    valueColor,
                    vm == 2,
                    _lineGraphColor[li]
                );
                return true;
            }
            _getFieldParts(field);
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var info = _amInfo;
            if (info != null) {
                var mins = info.activeMinutesWeek;
                var total =
                    mins != null && mins.total != null
                        ? mins.total as Number
                        : 0;
                var goal =
                    info has :activeMinutesWeekGoal &&
                    info.activeMinutesWeekGoal != null
                        ? info.activeMinutesWeekGoal as Number
                        : 150;
                if (total >= goal) {
                    _glowText(
                        dc,
                        cx +
                            _splitPad +
                            dc.getTextWidthInPixels(_rowBuf[1], _font),
                        y,
                        _font,
                        " [GOAL]",
                        Graphics.TEXT_JUSTIFY_LEFT,
                        ColorUtils.colorFromIdx(1)
                    );
                }
            }
            return true;
        }
        if (field == FIELD_CALORIES) {
            var vm = _lineViewMode[li];
            var current = 0;
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                current = info.calories != null ? info.calories as Number : 0;
            }
            if (vm == 1 || vm == 2) {
                _drawGoalBarRow(
                    dc,
                    cx,
                    y,
                    "Day Cals",
                    current,
                    _lineGoal[li],
                    labelColor,
                    valueColor,
                    vm == 2,
                    _lineGraphColor[li]
                );
                return true;
            }
            _rowBuf[0] = "Day Cals";
            _rowBuf[1] = current.toString() + " kcal";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            if (current >= _lineGoal[li]) {
                _glowText(
                    dc,
                    cx + _splitPad + dc.getTextWidthInPixels(_rowBuf[1], _font),
                    y,
                    _font,
                    " [GOAL]",
                    Graphics.TEXT_JUSTIFY_LEFT,
                    ColorUtils.colorFromIdx(1)
                );
            }
            return true;
        }
        if (field == FIELD_DISTANCE) {
            var vm = _lineViewMode[li];
            var current = 0;
            var distCm = 0;
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.distance != null) {
                    distCm = info.distance as Number;
                    current = _metric
                        ? Math.round(distCm / 100000.0).toNumber()
                        : Math.round(distCm / 160934.0).toNumber();
                }
            }
            if (vm == 1 || vm == 2) {
                _drawGoalBarRow(
                    dc,
                    cx,
                    y,
                    "Day Dist",
                    current,
                    _lineGoal[li],
                    labelColor,
                    valueColor,
                    vm == 2,
                    _lineGraphColor[li]
                );
                return true;
            }
            _rowBuf[0] = "Day Dist";
            _rowBuf[1] = _metric
                ? (distCm / 100000.0).format("%.2f") + "km"
                : (distCm / 160934.0).format("%.2f") + "mi";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            if (current >= _lineGoal[li]) {
                _glowText(
                    dc,
                    cx + _splitPad + dc.getTextWidthInPixels(_rowBuf[1], _font),
                    y,
                    _font,
                    " [GOAL]",
                    Graphics.TEXT_JUSTIFY_LEFT,
                    ColorUtils.colorFromIdx(1)
                );
            }
            return true;
        }
        if (field == FIELD_ACTIVE_MIN_DAY) {
            var vm = _lineViewMode[li];
            var current = 0;
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                var mins = info.activeMinutesDay;
                current =
                    mins != null && mins.total != null
                        ? mins.total as Number
                        : 0;
            }
            if (vm == 1 || vm == 2) {
                _drawGoalBarRow(
                    dc,
                    cx,
                    y,
                    "Act Min",
                    current,
                    _lineGoal[li],
                    labelColor,
                    valueColor,
                    vm == 2,
                    _lineGraphColor[li]
                );
                return true;
            }
            _rowBuf[0] = "Act Min";
            _rowBuf[1] = current.toString();
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            if (current >= _lineGoal[li]) {
                _glowText(
                    dc,
                    cx + _splitPad + dc.getTextWidthInPixels(_rowBuf[1], _font),
                    y,
                    _font,
                    " [GOAL]",
                    Graphics.TEXT_JUSTIFY_LEFT,
                    ColorUtils.colorFromIdx(1)
                );
            }
            return true;
        }
        if (field == FIELD_PRESSURE) {
            _getFieldParts(field);
            var valStr = _rowBuf[1];
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var x = cx + _splitPad;
            var valColor = ColorUtils.colorFromIdx(valueColor);
            _glowText(
                dc,
                x,
                y,
                _font,
                valStr,
                Graphics.TEXT_JUSTIFY_LEFT,
                valColor
            );
            if (_cachedPressureTrend != 0) {
                x += dc.getTextWidthInPixels(valStr, _font) + ARROW_PAD;
                _drawIcon(
                    dc,
                    x,
                    y + (_fh - _arrowH) / 2 + 1,
                    _cachedPressureTrend == 1 ? ICON_ARROW_UP : ICON_ARROW_DN,
                    valueColor
                );
            }
            return true;
        }
        return false;
    }

    private function _drawLineRowHealth(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        labelColor as Number,
        valueColor as Number,
        li as Number
    ) as Boolean {
        if (field == FIELD_WRIST_TEMP) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Wrist Temp",
                _cachedTempWrist,
                "",
                labelColor,
                valueColor
            );
            return true;
        }
        return false;
    }

    private function _drawLineRowWeatherCurrent(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        labelColor as Number,
        valueColor as Number,
        li as Number
    ) as Boolean {
        if (field == FIELD_WX_TEMP_HIGH_LOW) {
            _drawTempMaxMinRow(dc, cx, y, labelColor, valueColor);
            return true;
        }
        if (field == FIELD_WX_HIGH_LOW) {
            _drawHighLowRow(dc, cx, y, labelColor, valueColor);
            return true;
        }
        if (field == FIELD_WX_TEMP) {
            _getFieldParts(field);
            _drawTempRow(
                dc,
                cx,
                y,
                _rowBuf[0],
                _wxTemp,
                "",
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_FEELS) {
            _getFieldParts(field);
            _drawTempRow(
                dc,
                cx,
                y,
                _rowBuf[0],
                _wxFeels,
                "",
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_TEMP_COND) {
            _getFieldParts(field);
            _drawTempRow(
                dc,
                cx,
                y,
                _rowBuf[0],
                _wxTemp,
                _wxCond,
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_TEMP_WIND) {
            _getFieldParts(field);
            _drawTempRow(
                dc,
                cx,
                y,
                _rowBuf[0],
                _wxTemp,
                _wxWind,
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_UV) {
            _getFieldParts(field);
            _drawUvRow(dc, cx, y, _rowBuf[0], "", labelColor, valueColor);
            return true;
        }
        if (field == FIELD_WX_UV_PRECIP) {
            _getFieldParts(field);
            _drawUvRow(
                dc,
                cx,
                y,
                _rowBuf[0],
                _wxPrecip,
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_UV_WIND) {
            _getFieldParts(field);
            _drawUvRow(dc, cx, y, _rowBuf[0], _wxWind, labelColor, valueColor);
            return true;
        }
        if (field == FIELD_WX_TEMP_UV) {
            _getFieldParts(field);
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var x = cx + _splitPad;
            var wxValColor = ColorUtils.colorFromIdx(valueColor);
            _glowText(
                dc,
                x,
                y,
                _font,
                _wxTemp,
                Graphics.TEXT_JUSTIFY_LEFT,
                wxValColor
            );
            x += dc.getTextWidthInPixels(_wxTemp, _font);
            _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valueColor);
            x += _degW;
            _glowText(
                dc,
                x,
                y,
                _font,
                _wxUnit,
                Graphics.TEXT_JUSTIFY_LEFT,
                wxValColor
            );
            x += dc.getTextWidthInPixels(_wxUnit, _font);
            _glowText(
                dc,
                x,
                y,
                _font,
                " | ",
                Graphics.TEXT_JUSTIFY_LEFT,
                GRAYS[3]
            );
            x += dc.getTextWidthInPixels(" | ", _font);
            _drawUvTag(dc, x, y, valueColor);
            return true;
        }
        if (field == FIELD_WX_DEW_POINT) {
            _getFieldParts(field);
            _drawTempRow(
                dc,
                cx,
                y,
                _rowBuf[0],
                _wxDewPoint,
                "",
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_HEAT_INDEX) {
            _getFieldParts(field);
            _drawTempRow(
                dc,
                cx,
                y,
                _rowBuf[0],
                _wxHeatIndex,
                "",
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_TEMP_HUMIDITY) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Temp+Hum",
                _wxTemp,
                _wxHumidity,
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_TEMP_PRECIP) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Temp+Rain",
                _wxTemp,
                _wxPrecip,
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_HUMIDITY_DEW) {
            _drawHumidityDewRow(dc, cx, y, labelColor, valueColor);
            return true;
        }
        return false;
    }

    private function _drawLineRowWeatherForecast(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        labelColor as Number,
        valueColor as Number,
        li as Number
    ) as Boolean {
        if (field == FIELD_WX_FCST_TEMP) {
            _drawForecastTempRow(
                dc,
                cx,
                y,
                _linePeriodMin[li],
                _lineViewMode[li],
                _lineValueMode[li],
                labelColor,
                valueColor,
                _lineGraphColor[li],
                _lineGraphType[li]
            );
            return true;
        }
        if (field == FIELD_WX_FCST_PRECIP) {
            _drawForecastSimpleRow(
                dc,
                cx,
                y,
                _linePeriodMin[li],
                _lineViewMode[li],
                _lineValueMode[li],
                labelColor,
                valueColor,
                _lineGraphColor[li],
                _lineGraphType[li],
                "Rain %",
                _wxPrecip,
                _wxForecastPrecipData,
                FIELD_WX_FCST_PRECIP,
                1.0
            );
            return true;
        }
        if (field == FIELD_WX_FCST_DAILY) {
            _drawForecastDailyRow(
                dc,
                cx,
                y,
                _linePeriodMin[li],
                _lineViewMode[li],
                _lineValueMode[li],
                labelColor,
                valueColor,
                _lineGraphColor[li]
            );
            return true;
        }
        if (field == FIELD_WX_FCST_WIND) {
            _drawForecastSimpleRow(
                dc,
                cx,
                y,
                _linePeriodMin[li],
                _lineViewMode[li],
                _lineValueMode[li],
                labelColor,
                valueColor,
                _lineGraphColor[li],
                _lineGraphType[li],
                "Wind Fcst",
                _wxWind,
                _wxForecastWindData,
                FIELD_WX_FCST_WIND,
                0.1
            );
            return true;
        }
        if (field == FIELD_WX_FCST_HUMIDITY) {
            _drawForecastSimpleRow(
                dc,
                cx,
                y,
                _linePeriodMin[li],
                _lineViewMode[li],
                _lineValueMode[li],
                labelColor,
                valueColor,
                _lineGraphColor[li],
                _lineGraphType[li],
                "Hum Fcst",
                _wxHumidity,
                _wxForecastHumidityData,
                FIELD_WX_FCST_HUMIDITY,
                1.0
            );
            return true;
        }
        if (field == FIELD_WX_FCST_UV) {
            _drawForecastSimpleRow(
                dc,
                cx,
                y,
                _linePeriodMin[li],
                _lineViewMode[li],
                _lineValueMode[li],
                labelColor,
                valueColor,
                _lineGraphColor[li],
                _lineGraphType[li],
                "UV Fcst",
                _wxUv,
                _wxForecastUvData,
                FIELD_WX_FCST_UV,
                0.5
            );
            return true;
        }
        if (field == FIELD_WX_FCST_CLOUD) {
            _drawForecastSimpleRow(
                dc,
                cx,
                y,
                _linePeriodMin[li],
                _lineViewMode[li],
                _lineValueMode[li],
                labelColor,
                valueColor,
                _lineGraphColor[li],
                _lineGraphType[li],
                "Cloud Fcst",
                _wxCloudCover,
                _wxForecastCloudData,
                FIELD_WX_FCST_CLOUD,
                1.0
            );
            return true;
        }
        var gk = _fieldGraphKey(field);
        if (gk != null) {
            var viewMode = _lineViewMode[li];
            if (viewMode == VIEW_GRAPH || viewMode == VIEW_GRAPH_VALUE) {
                if (_lineSecType[li] != SEC_NONE) {
                    _drawDualGraphRow(
                        dc,
                        cx,
                        y,
                        field,
                        GRAPH_SEC_FIELDS[_lineSecField[li]] as Number,
                        _linePeriodMin[li],
                        labelColor,
                        valueColor,
                        _lineGraphColor[li],
                        _lineSecColor[li],
                        _lineGraphType[li],
                        _lineSecType[li],
                        viewMode,
                        _lineValueMode[li],
                        _lineBarGroupDensity[li],
                        _lineBarGroupAgg[li]
                    );
                } else {
                    _drawGraphRow(
                        dc,
                        cx,
                        y,
                        field,
                        _linePeriodMin[li],
                        viewMode,
                        labelColor,
                        valueColor,
                        _lineGraphColor[li],
                        _lineGraphType[li],
                        _lineValueMode[li],
                        _lineBarGroupDensity[li],
                        _lineBarGroupAgg[li]
                    );
                }
                return true;
            }
        }
        return false;
    }
    private function _drawStepsBarRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelColor as Number,
        valueColor as Number,
        showValue as Boolean,
        barColor as Number
    ) as Void {
        var steps = 0;
        var goal = 10000;
        if (_amInfo != null) {
            var info = _amInfo as ActivityMonitor.Info;
            steps = info.steps != null ? info.steps as Number : 0;
            goal = info.stepGoal != null ? info.stepGoal as Number : 0;
            if (goal <= 0) {
                goal = 10000;
            }
        }
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Steps",
            steps,
            goal,
            labelColor,
            valueColor,
            showValue,
            barColor
        );
    }

    private function _drawFloorsRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        var info = _amInfo;
        var climbed = 0;
        var up = (
            info != null && info.floorsClimbed != null
                ? info.floorsClimbed as Number
                : 0
        ).toString();
        var dn = (
            info != null && info.floorsDescended != null
                ? info.floorsDescended as Number
                : 0
        ).toString();
        _rowBuf[0] = "Floors";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelIdx, valIdx);
        var ay = y + (_fh - _arrowH) / 2 + 1;
        var x = cx + _splitPad;
        var valColor = ColorUtils.colorFromIdx(valIdx);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        var upSpace = up + " ";
        _glowText(
            dc,
            x,
            y,
            _font,
            upSpace,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(upSpace, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        _glowText(dc, x, y, _font, dn, Graphics.TEXT_JUSTIFY_LEFT, valColor);
        var goal = 10;
        if (info != null) {
            climbed =
                info.floorsClimbed != null ? info.floorsClimbed as Number : 0;
            if (info has :floorsClimbedGoal && info.floorsClimbedGoal != null) {
                goal = info.floorsClimbedGoal as Number;
            }
            if (goal <= 0) {
                goal = 10;
            }
        }
        if (climbed >= goal) {
            x += dc.getTextWidthInPixels(dn, _font);
            _glowText(
                dc,
                x,
                y,
                _font,
                " [GOAL]",
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.colorFromIdx(1)
            );
        }
    }

    private function _drawFloorsBarRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelColor as Number,
        valueColor as Number,
        showValue as Boolean,
        barColor as Number
    ) as Void {
        var climbed = 0;
        var goal = 10;
        if (_amInfo != null) {
            var info = _amInfo as ActivityMonitor.Info;
            climbed =
                info.floorsClimbed != null ? info.floorsClimbed as Number : 0;
            if (info has :floorsClimbedGoal && info.floorsClimbedGoal != null) {
                goal = info.floorsClimbedGoal as Number;
            }
            if (goal <= 0) {
                goal = 10;
            }
        }
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Floors",
            climbed,
            goal,
            labelColor,
            valueColor,
            showValue,
            barColor
        );
    }

    private function _drawIntensityMinBarRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelColor as Number,
        valueColor as Number,
        showValue as Boolean,
        barColor as Number
    ) as Void {
        var current = 0;
        var goal = 150;
        if (_amInfo != null) {
            var info = _amInfo as ActivityMonitor.Info;
            var mins = info.activeMinutesWeek;
            current =
                mins != null && mins.total != null ? mins.total as Number : 0;
            if (
                info has :activeMinutesWeekGoal &&
                info.activeMinutesWeekGoal != null
            ) {
                goal = info.activeMinutesWeekGoal as Number;
            }
            if (goal <= 0) {
                goal = 150;
            }
        }
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Intens Min",
            current,
            goal,
            labelColor,
            valueColor,
            showValue,
            barColor
        );
    }

    // Shared renderer for the steps/floors/intensity/calories/distance/active-min goal bars.
    private function _drawGoalBarRow(
        dc as Dc,
        cx as Number,
        y as Number,
        label as String,
        current as Number,
        goal as Number,
        labelColor as Number,
        valueColor as Number,
        showValue as Boolean,
        barColor as Number
    ) as Void {
        _rowBuf[0] = label;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var gx = cx + _splitPad + _charW;
        var gw = _graphW;
        var barH = _fh;
        var barCol = ColorUtils.colorFromIdx(barColor);
        dc.setStroke(ColorUtils.withAlpha(barCol, 0x40));
        for (var bx = gx; bx < gx + gw; bx++) {
            dc.drawLine(bx, y, bx, y + barH - 1);
        }
        var frac = current.toFloat() / goal.toFloat();
        if (frac > 1.0) {
            frac = 1.0;
        }
        var fillW = (frac * gw.toFloat()).toNumber();
        if (fillW > 0) {
            _glowRect(dc, gx, y, fillW, barH, barCol);
        }
        _glowLine(dc, gx - 1, y, gx - 1, y + barH - 1, GRAYS[3]);
        _glowLine(dc, gx + gw, y, gx + gw, y + barH - 1, GRAYS[3]);
        _drawDashedV(dc, gx + gw / 4, y, y + barH, barCol, DASH_ALPHA);
        _drawDashedV(dc, gx + gw / 2, y, y + barH, barCol, DASH_ALPHA);
        _drawDashedV(dc, gx + (gw * 3) / 4, y, y + barH, barCol, DASH_ALPHA);
        var labelY = y + (_fh - _tinyFh) / 2 - 1;
        var goalStr = goal.toString();
        var axisColor = ColorUtils.colorFromIdx(0);
        _glowText(
            dc,
            gx - 4,
            labelY,
            _fontTiny,
            "0",
            Graphics.TEXT_JUSTIFY_RIGHT,
            axisColor
        );
        _glowText(
            dc,
            gx + gw + 4,
            labelY,
            _fontTiny,
            goalStr,
            Graphics.TEXT_JUSTIFY_LEFT,
            axisColor
        );
        if (!showValue) {
            return;
        }
        var valY = y + (_fh - _smallFh) / 2 - 1;
        var valX = gx + gw / 2;
        var valStr = current.format("%0" + goalStr.length() + "d");
        dc.setColor(GRAYS[0], Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            valX - 1,
            valY - 1,
            _fontSmall,
            valStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            valX + 1,
            valY - 1,
            _fontSmall,
            valStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            valX - 1,
            valY + 1,
            _fontSmall,
            valStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            valX + 1,
            valY + 1,
            _fontSmall,
            valStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        _glowText(
            dc,
            valX,
            valY,
            _fontSmall,
            valStr,
            Graphics.TEXT_JUSTIFY_CENTER,
            ColorUtils.colorFromIdx(valueColor)
        );
        if (current >= goal) {
            _glowText(
                dc,
                gx + gw + 4 + dc.getTextWidthInPixels(goalStr, _fontTiny),
                valY,
                _fontSmall,
                " [GOAL]",
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.colorFromIdx(1)
            );
        }
    }

    private function _drawUpDownRow(
        dc as Dc,
        cx as Number,
        y as Number,
        label as String,
        up as String,
        dn as String,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        _rowBuf[0] = label;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelIdx, valIdx);
        var ay = y + (_fh - _arrowH) / 2 + 1;
        var x = cx + _splitPad;
        var valColor = ColorUtils.colorFromIdx(valIdx);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        var upSpace = up + " ";
        _glowText(
            dc,
            x,
            y,
            _font,
            upSpace,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(upSpace, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        _glowText(dc, x, y, _font, dn, Graphics.TEXT_JUSTIFY_LEFT, valColor);
    }

    private function _drawTempRow(
        dc as Dc,
        cx as Number,
        y as Number,
        label as String,
        numStr as String,
        suffix as String,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        _rowBuf[0] = label;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelIdx, valIdx);
        var x = cx + _splitPad;
        var valColor = ColorUtils.colorFromIdx(valIdx);
        _glowText(
            dc,
            x,
            y,
            _font,
            numStr,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(numStr, _font);
        _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valIdx);
        x += _degW;
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxUnit,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        if (suffix.length() > 0) {
            x += dc.getTextWidthInPixels(_wxUnit, _font);
            _glowText(
                dc,
                x,
                y,
                _font,
                " | ",
                Graphics.TEXT_JUSTIFY_LEFT,
                GRAYS[3]
            );
            x += dc.getTextWidthInPixels(" | ", _font);
            _glowText(
                dc,
                x,
                y,
                _font,
                suffix,
                Graphics.TEXT_JUSTIFY_LEFT,
                valColor
            );
        }
    }

    private function _uvColorIdx() as Number {
        return _wxUvNum <= 2 ? 1 : _wxUvNum <= 5 ? 3 : _wxUvNum <= 7 ? 4 : 5;
    }

    private function _uvTag() as String {
        return _wxUvNum <= 2
            ? " [LOW]"
            : _wxUvNum <= 5
              ? " [AVG]"
              : _wxUvNum <= 7
                ? " [HIGH]"
                : " [MAX]";
    }

    // Draws UV number in valIdx color, UV level tag in UV color, returns x after tag.
    private function _drawUvTag(
        dc as Dc,
        x as Number,
        y as Number,
        valIdx as Number
    ) as Number {
        if (_wxUvNum < 0) {
            _glowText(
                dc,
                x,
                y,
                _font,
                "-",
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.colorFromIdx(valIdx)
            );
            return x + dc.getTextWidthInPixels("-", _font);
        }
        var numStr = _wxUvNum.toString();
        _glowText(
            dc,
            x,
            y,
            _font,
            numStr,
            Graphics.TEXT_JUSTIFY_LEFT,
            ColorUtils.colorFromIdx(valIdx)
        );
        x += dc.getTextWidthInPixels(numStr, _font);
        var tag = _uvTag();
        _glowText(
            dc,
            x,
            y,
            _font,
            tag,
            Graphics.TEXT_JUSTIFY_LEFT,
            ColorUtils.colorFromIdx(_uvColorIdx())
        );
        return x + dc.getTextWidthInPixels(tag, _font);
    }

    private function _drawUvRow(
        dc as Dc,
        cx as Number,
        y as Number,
        label as String,
        suffix as String,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        _rowBuf[0] = label;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelIdx, valIdx);
        var x = _drawUvTag(dc, cx + _splitPad, y, valIdx);
        if (!suffix.equals("")) {
            _glowText(
                dc,
                x,
                y,
                _font,
                " | ",
                Graphics.TEXT_JUSTIFY_LEFT,
                GRAYS[3]
            );
            x += dc.getTextWidthInPixels(" | ", _font);
            _glowText(
                dc,
                x,
                y,
                _font,
                suffix,
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.colorFromIdx(valIdx)
            );
        }
    }

    private function _drawTempMaxMinRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        _rowBuf[0] = "Temp";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelIdx, valIdx);
        var ay = y + (_fh - _arrowH) / 2 + 1;
        var x = cx + _splitPad;
        var valColor = ColorUtils.colorFromIdx(valIdx);
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxTemp,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(_wxTemp, _font);
        _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valIdx);
        x += _degW;
        var unitBrk = _wxUnit + " [";
        _glowText(
            dc,
            x,
            y,
            _font,
            unitBrk,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(unitBrk, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        var highBrk = _wxHigh + "] [";
        _glowText(
            dc,
            x,
            y,
            _font,
            highBrk,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(highBrk, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxLow + "]",
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
    }

    private function _drawHighLowRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        _rowBuf[0] = "Temp Hi/Lo";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelIdx, valIdx);
        var x = cx + _splitPad;
        var dy = y + (_fh - _degW) / 4;
        var ay = y + (_fh - _arrowH) / 2 + 1;
        var valColor = ColorUtils.colorFromIdx(valIdx);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxHigh,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(_wxHigh, _font);
        _drawIcon(dc, x, dy, ICON_DEG, valIdx);
        x += _degW;
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxUnit,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(_wxUnit, _font);
        _glowText(dc, x, y, _font, " / ", Graphics.TEXT_JUSTIFY_LEFT, GRAYS[3]);
        x += dc.getTextWidthInPixels(" / ", _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxLow,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(_wxLow, _font);
        _drawIcon(dc, x, dy, ICON_DEG, valIdx);
        x += _degW;
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxUnit,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
    }

    private function _drawHumidityDewRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        _rowBuf[0] = "Hum+Dew";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelIdx, valIdx);
        var x = cx + _splitPad;
        var dy = y + (_fh - _degW) / 4;
        var valColor = ColorUtils.colorFromIdx(valIdx);
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxHumidity,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(_wxHumidity, _font);
        _glowText(dc, x, y, _font, " | ", Graphics.TEXT_JUSTIFY_LEFT, GRAYS[3]);
        x += dc.getTextWidthInPixels(" | ", _font);
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxDewPoint,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(_wxDewPoint, _font);
        _drawIcon(dc, x, dy, ICON_DEG, valIdx);
        x += _degW;
        _glowText(
            dc,
            x,
            y,
            _font,
            _wxUnit,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
    }

    // label right-aligned | ": " centered | value left-aligned; colon uses label color
    private function _drawRow(
        dc as Dc,
        cx as Number,
        y as Number,
        parts as Array<String>,
        labelColorIdx as Number,
        valueColorIdx as Number
    ) as Void {
        var label = parts[0];
        var value = parts[1];
        if (label.length() == 0 && value.length() == 0) {
            return;
        }

        var labelColor = ColorUtils.colorFromIdx(labelColorIdx);
        _glowText(
            dc,
            cx,
            y,
            _font,
            ": ",
            Graphics.TEXT_JUSTIFY_CENTER,
            labelColor
        );
        if (label.length() > 0) {
            _glowText(
                dc,
                cx - _splitPad,
                y,
                _font,
                label,
                Graphics.TEXT_JUSTIFY_RIGHT,
                labelColor
            );
        }
        if (value.length() > 0) {
            var valueColor = ColorUtils.colorFromIdx(valueColorIdx);
            var sepIdx = value.find(" | ");
            if (sepIdx != null) {
                var vx = cx + _splitPad;
                var part1 = value.substring(0, sepIdx) as String;
                var part2 =
                    value.substring(sepIdx + 3, value.length()) as String;
                _glowText(
                    dc,
                    vx,
                    y,
                    _font,
                    part1,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valueColor
                );
                vx += dc.getTextWidthInPixels(part1, _font);
                _glowText(
                    dc,
                    vx,
                    y,
                    _font,
                    " | ",
                    Graphics.TEXT_JUSTIFY_LEFT,
                    GRAYS[3]
                );
                vx += dc.getTextWidthInPixels(" | ", _font);
                _glowText(
                    dc,
                    vx,
                    y,
                    _font,
                    part2,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valueColor
                );
            } else {
                _glowText(
                    dc,
                    cx + _splitPad,
                    y,
                    _font,
                    value,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valueColor
                );
            }
        }
    }

    // Value only, no label/separator - used for time/date in always-on mode.
    private function _drawAodValue(
        dc as Dc,
        cx as Number,
        y as Number,
        value as String,
        valueColorIdx as Number
    ) as Void {
        dc.setColor(
            ColorUtils.colorFromIdx(valueColorIdx),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            cx + _splitPad,
            y,
            _font,
            value,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    // Gradient domain can differ from the data's own min/max (e.g. HR always maps 40-200).
    private function _calcGradRange(
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

    private function _fracClamp(
        v as Float,
        gradMinV as Float,
        gradRange as Float
    ) as Float {
        var frac = (v - gradMinV) / gradRange;
        if (frac < 0.0) {
            return 0.0;
        }
        if (frac > 1.0) {
            return 1.0;
        }
        return frac;
    }

    private function _drawDualGraphRow(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        fieldSecondary as Number,
        periodMin as Number,
        labelColor as Number,
        valueColor as Number,
        lineColor as Number,
        lineColor2 as Number,
        graphType as Number,
        secType as Number,
        viewMode as Number,
        valueMode as Number,
        barGroupDensity as Number,
        barAgg as Number
    ) as Void {
        _graphX = _graphBaseX;
        var data = _getFieldHistory(field, periodMin);
        _getFieldParts(field);
        var valueStr = _rowBuf[1];
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        if (data == null) {
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }
        var data2 = _getFieldHistory(fieldSecondary, periodMin);
        var primaryCacheKey = _packGraphKey(_graphW, field, periodMin);
        var secondaryCacheKey = _packGraphKey(
            _graphW,
            fieldSecondary,
            periodMin
        );
        var barCount0 = 0;
        if (graphType == GRAPH_BAR) {
            barCount0 = _resolveBarCount(
                field,
                periodMin,
                _graphW,
                barGroupDensity
            );
            if (barCount0 > 0 && barCount0 < data.size()) {
                data = _groupBarDataCached(
                    primaryCacheKey,
                    data,
                    barCount0,
                    barAgg
                );
                if (secType == SEC_BAR && data2 != null) {
                    data2 = _groupBarDataCached(
                        secondaryCacheKey,
                        data2,
                        barCount0,
                        barAgg
                    );
                }
            } else {
                barCount0 = 0;
            }
        }

        _calcMinMaxCached(primaryCacheKey, data, data);
        var minV = _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }

        var minV2 = 0.0 as Float;
        var maxV2 = 0.0 as Float;
        var range2 = 1.0 as Float;
        if (data2 != null) {
            _calcMinMaxCached(secondaryCacheKey, data2, data2 as Array<Float>);
            minV2 = _dataMin;
            maxV2 = _dataMax;
            range2 = maxV2 - minV2;
            if (range2 < 1.0) {
                range2 = 1.0;
            }
        }

        _setGraphX(field, minV, maxV);
        var rightPad =
            data2 != null
                ? _graphLabelPad(
                      _formatGraphLabel(fieldSecondary, minV2),
                      _formatGraphLabel(fieldSecondary, maxV2)
                  ) + 1
                : 2;
        var gr1 = _calcGradRange(field, lineColor, minV, range);
        var gradMinV1 = gr1[0];
        var gradRange1 = gr1[1];
        var maxFrac1 = _fracClamp(maxV, gradMinV1, gradRange1);
        var minFrac1 = _fracClamp(minV, gradMinV1, gradRange1);

        var gr2 = _calcGradRange(fieldSecondary, lineColor2, minV2, range2);
        var gradMinV2 = gr2[0];
        var gradRange2 = gr2[1];
        var maxFrac2 = _fracClamp(maxV2, gradMinV2, gradRange2);
        var minFrac2 = _fracClamp(minV2, gradMinV2, gradRange2);

        var dualMaxGap = (10 * _graphW) / periodMin;
        if (dualMaxGap < 1) {
            dualMaxGap = 1;
        }
        // Folds GraphWidth into the period slot so two slots sharing (field, fieldSecondary, periodMin) at different widths don't collide.
        var widthIdx = (_graphW / _charW - 6) / 2;
        var dualPeriodKey = (periodMin / 15) * 6 + widthIdx;
        var dualCacheKey = _packGraphKey(field, fieldSecondary, dualPeriodKey);
        var dualBmps = _renderDualGraphToBitmap(
            dualCacheKey,
            field,
            graphType,
            secType,
            lineColor,
            lineColor2,
            data,
            data2,
            _graphW,
            _graphH,
            minV,
            range,
            minV2,
            range2,
            gradMinV1,
            gradRange1,
            gradMinV2,
            gradRange2,
            dualMaxGap
        );
        var dualBmp = dualBmps[0] as Graphics.BufferedBitmap?;
        var cacheHit =
            dualBmp != null &&
            _drawCachedGraphBitmap(
                dc,
                _graphX,
                y,
                dualBmp,
                dualCacheKey,
                _graphBmpDualDrawOk
            );
        if (!cacheHit) {
            _drawMeanLine(
                dc,
                data,
                _graphX,
                _graphW,
                y,
                _graphH,
                minV,
                range,
                lineColor,
                gradMinV1,
                gradRange1
            );
            if (graphType == GRAPH_BAR && secType == SEC_BAR && data2 != null) {
                _drawDualBars(
                    dc,
                    data,
                    data2 as Array<Float>,
                    _graphX,
                    _graphW,
                    y,
                    _graphH + 1,
                    minV,
                    range,
                    minV2,
                    range2,
                    lineColor,
                    lineColor2,
                    gradMinV1,
                    gradRange1,
                    gradMinV2,
                    gradRange2
                );
            } else {
                _drawOneGraph(
                    dc,
                    graphType,
                    lineColor,
                    data,
                    _graphX,
                    _graphW,
                    y,
                    _graphH,
                    minV,
                    range,
                    gradMinV1,
                    gradRange1,
                    dualMaxGap
                );
                if (data2 != null) {
                    _drawOneGraph(
                        dc,
                        secType == SEC_BAR ? GRAPH_BAR : GRAPH_LINE,
                        lineColor2,
                        data2 as Array<Float>,
                        _graphX,
                        _graphW,
                        y,
                        _graphH,
                        minV2,
                        range2,
                        gradMinV2,
                        gradRange2,
                        dualMaxGap
                    );
                }
            }
        }

        var dualGlowBmp = dualBmps[1] as Graphics.BufferedBitmap?;
        if (cacheHit && dualGlowBmp != null) {
            var dualHdc = _activeHaloDc();
            if (dualHdc != null) {
                _tryDrawBitmap(
                    dualHdc,
                    _graphX - GLOW_SPREAD,
                    y - GLOW_SPREAD,
                    dualGlowBmp
                );
            }
        }

        _drawRowAxes(dc, y);

        if (data2 != null) {
            _glowText(
                dc,
                _graphX + _graphW + 4,
                y - 4,
                _fontTiny,
                _formatGraphLabel(fieldSecondary, maxV2),
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.gradColor(lineColor2, maxFrac2)
            );
            _glowText(
                dc,
                _graphX + _graphW + 4,
                y + _graphH - _tinyFh + 4,
                _fontTiny,
                _formatGraphLabel(fieldSecondary, minV2),
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.gradColor(lineColor2, minFrac2)
            );
        }

        // Current values when graph+value mode - 3 normal spaces from graph edge, centered
        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = _graphX + _graphW + _charW * rightPad;
            var totalH = _smallFh * 2 + 2;
            var startY = y + (_fh - totalH) / 2 - 1;
            var cur1 = _graphValueStr(
                field,
                data as Array<Float>,
                minV,
                maxV,
                valueMode,
                valueStr
            );
            _drawGraphValueLabel(
                dc,
                vx,
                startY,
                field,
                cur1,
                ColorUtils.colorFromIdx(lineColor)
            );
            _getFieldParts(fieldSecondary);
            var cur2 = _rowBuf[1];
            var y2 = startY + _smallFh + 2;
            _drawGraphValueLabel(
                dc,
                vx,
                y2,
                fieldSecondary,
                cur2,
                ColorUtils.colorFromIdx(lineColor2)
            );
        }

        _glowText(
            dc,
            _graphX - 4,
            y - 4,
            _fontTiny,
            _formatGraphLabel(field, maxV),
            Graphics.TEXT_JUSTIFY_RIGHT,
            ColorUtils.gradColor(lineColor, maxFrac1)
        );
        _glowText(
            dc,
            _graphX - 4,
            y + _graphH - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(field, minV),
            Graphics.TEXT_JUSTIFY_RIGHT,
            ColorUtils.gradColor(lineColor, minFrac1)
        );

        var yBelow = y + _graphH + 1;
        var secName = Formatters.fieldShortName(fieldSecondary);
        _glowText(
            dc,
            _graphX + _graphW,
            yBelow,
            _fontTiny,
            secName,
            Graphics.TEXT_JUSTIFY_RIGHT,
            ColorUtils.gradColor(lineColor2, minFrac2)
        );
        var effDual = _resolveEffPeriod(
            _packGraphKey(_graphW, field, periodMin),
            periodMin
        );
        var ageColor = GRAYS[3];
        var periodTextDual = Formatters.periodLabel(effDual);
        if (barCount0 > 0) {
            periodTextDual +=
                "/" + Formatters.barDurationLabel(effDual / barCount0);
        }
        _glowText(
            dc,
            _graphX + _graphW - dc.getTextWidthInPixels(secName, _fontTiny),
            yBelow,
            _fontTiny,
            periodTextDual + " ",
            Graphics.TEXT_JUSTIFY_RIGHT,
            ageColor
        );
        var ageSecDual = _dataAge(data, effDual);
        if (ageSecDual > _graphStaleSec(field)) {
            _glowText(
                dc,
                _graphX,
                yBelow,
                _fontTiny,
                Formatters.formatAge(ageSecDual),
                Graphics.TEXT_JUSTIFY_LEFT,
                ageColor
            );
        }
    }

    private function _fieldGraphKey(field as Number) as String? {
        if (field == FIELD_HR) {
            return "hr";
        }
        if (field == FIELD_BODY_BAT) {
            return "bb";
        }
        if (field == FIELD_STRESS) {
            return "str";
        }
        if (field == FIELD_SPO2) {
            return "spo2";
        }
        if (field == FIELD_WRIST_TEMP) {
            return "tw";
        }
        if (field == FIELD_ELEVATION) {
            return "elev";
        }
        if (field == FIELD_PRESSURE) {
            return "pres";
        }
        return null;
    }

    // Fallback [mode, timeFrameMin, graphColor, valueMode, secField] per field - mirrors GRAPH_FIELDS in generate_resources.py.
    private function _graphFieldDefaults(
        field as Number
    ) as [Number, Number, Number, Number, Number] {
        if (field == FIELD_HR) {
            return [3, 60, 5, 0, 2];
        }
        if (field == FIELD_SPO2) {
            return [6, 60, 6, 2, 0];
        }
        if (field == FIELD_BODY_BAT) {
            return [6, 240, 11, 0, 3];
        }
        if (field == FIELD_STRESS) {
            return [3, 120, 10, 1, 0];
        }
        if (field == FIELD_WRIST_TEMP) {
            return [3, 60, 16, 1, 0];
        }
        if (field == FIELD_ELEVATION) {
            return [6, 360, 1, 0, 6];
        }
        return [3, 120, 2, 1, 5];
    }

    // Buckets sensor history into gw time slots (0=most recent). skipZero
    // discards 0 samples - use for HR, where 0bpm means off-wrist.
    (:extendedCode)
    private function _readIter(
        iter as SensorHistory.SensorHistoryIterator,
        periodMin as Number,
        skipZero as Boolean
    ) as Array<Float>? {
        _pendingEffPeriod = 0;
        var gw = _graphW;
        var periodSec = periodMin * SECS_PER_MIN;
        if (periodSec < 1) {
            return null;
        }
        var result = new Array<Float>[gw];
        var now = Time.now().value();
        var s = iter.next();
        var count = 0;
        var maxAge = 0;
        var deadline = System.getTimer() + 150;
        // Real devices emit occasional ~20yr-off corrupted timestamps here (documented Garmin bug) - don't count those toward the give-up streak.
        var corruptAgeSec = 24 * SECS_PER_HOUR;
        var badAgeStreak = 0;
        while (s != null) {
            if (System.getTimer() > deadline) {
                break;
            }
            var age = now - (s.when as Time.Moment).value();
            if (age >= periodSec) {
                if (age < corruptAgeSec) {
                    badAgeStreak++;
                    if (badAgeStreak >= 3) {
                        break;
                    }
                }
                s = iter.next();
                continue;
            }
            badAgeStreak = 0;
            if (age >= 0 && s.data != null) {
                var v = s.data;
                var fv = _numToFloat(v as Numeric);
                if (!skipZero || fv != 0.0) {
                    if (age > maxAge) {
                        maxAge = age;
                    }
                    var slot = (age * gw) / periodSec;
                    if (slot >= gw) {
                        slot = gw - 1;
                    }
                    if (result[slot] == null) {
                        result[slot] = fv;
                        count++;
                    }
                }
            }
            s = iter.next();
        }
        if (count < 2) {
            return null;
        }
        // If the API returned under 90% of the requested period, stretch data to fill the graph width.
        var oldestSlot = (maxAge * gw) / periodSec;
        if (oldestSlot > 0 && maxAge < (periodSec * 9) / 10) {
            var stretched = new Array<Float>[gw];
            for (var i = 0; i < gw; i++) {
                if (result[i] != null) {
                    var newI = (i * (gw - 1)) / oldestSlot;
                    if (newI >= gw) {
                        newI = gw - 1;
                    }
                    if (stretched[newI] == null) {
                        stretched[newI] = result[i] as Float;
                    }
                }
            }
            result = stretched;
        }
        // Gap threshold: 10 min in effective-period slots, so off-wrist gaps stay null.
        var effectiveMin = maxAge > 0 ? maxAge / SECS_PER_MIN : periodMin;
        if (effectiveMin < 1) {
            effectiveMin = 1;
        }
        var didStretch = oldestSlot > 0 && maxAge < (periodSec * 9) / 10;
        var gapThresh = (10 * gw) / (didStretch ? effectiveMin : periodMin);
        if (gapThresh < 1) {
            gapThresh = 1;
        }
        var prevI = -1;
        var prevV = 0.0 as Float;
        for (var i = 0; i < gw; i++) {
            if (result[i] != null) {
                var gap = i - prevI;
                if (prevI >= 0 && gap > 1 && gap <= gapThresh) {
                    var v1 = result[i] as Float;
                    for (var k = prevI + 1; k < i; k++) {
                        var t = (k - prevI).toFloat() / gap.toFloat();
                        result[k] = prevV + t * (v1 - prevV);
                    }
                }
                prevI = i;
                prevV = result[i] as Float;
            }
        }
        // Only report the effective (shorter) period when re-slotting occurred.
        // Reuses didStretch rather than a fresh maxAge>0 check, which can disagree due to integer truncation.
        _pendingEffPeriod = didStretch ? effectiveMin : periodMin;
        return result;
    }

    private function _fieldUpdateMin(field as Number) as Number {
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

    // x6 (not x3) since real devices batch these fields' samples more irregularly than _fieldUpdateMin assumes.
    private function _pointStaleSec(field as Number) as Number {
        return _fieldUpdateMin(field) * SECS_PER_MIN * 6;
    }

    private function _sampleFresh(
        sample as SensorHistory.SensorSample?,
        field as Number
    ) as Boolean {
        if (sample == null || sample.data == null) {
            return false;
        }
        // A future-corrupted timestamp (the bug _readIter also guards against) would otherwise look "fresh".
        var age = Time.now().value() - (sample.when as Time.Moment).value();
        return age >= 0 && age <= _pointStaleSec(field);
    }

    private function _numToFloat(v as Numeric) as Float {
        return v instanceof Float ? v as Float : (v as Number).toFloat();
    }

    // Density is qualitative (Tight/Normal/Loose %) so it stays meaningful across time frames, floored by field cadence so it never fabricates samples.
    private function _resolveBarCount(
        field as Number,
        periodMin as Number,
        gw as Number,
        density as Number
    ) as Number {
        if (density <= 0) {
            return 0;
        }
        // Cap scales with GraphWidth (3 * chars - 6 stays visually distinct).
        var cap = 3 * (gw / _charW) - 6;
        if (cap > gw) {
            cap = gw;
        }
        var pct = density == 1 ? 100 : density == 2 ? 50 : 25;
        var count = (cap * pct) / 100;
        if (count < 2) {
            count = 2;
        }
        // Capped last so the floor above never fabricates more buckets than genuine samples exist.
        var maxUseful = periodMin / _fieldUpdateMin(field);
        if (count > maxUseful) {
            count = maxUseful;
        }
        if (count > cap) {
            count = cap;
        }
        return count;
    }

    private function _graphStaleSec(field as Number) as Number {
        return _pointStaleSec(field) / 2;
    }

    private function _getFieldHistory(
        field as Number,
        periodMin as Number
    ) as Array<Float>? {
        var cacheKey = _packGraphKey(_graphW, field, periodMin);
        var nowUnixMin = _nowUnixMin;
        var entry = _graphCache.hasKey(cacheKey)
            ? _graphCache.get(cacheKey) as [Array<Float>?, Number]
            : null;
        // nowUnixMin < entry[1] means the clock moved backward - don't trust a "future" cache timestamp.
        if (
            entry != null &&
            nowUnixMin >= entry[1] &&
            nowUnixMin - entry[1] < _fieldUpdateMin(field)
        ) {
            return entry[0];
        }
        // Reuse the stale entry on the wake frame so the sensor-history scan below can't
        // delay the screen turning on; a real refresh runs on the very next frame instead.
        if (_deferThisFrame && entry != null) {
            _deferredWorkPending = true;
            return entry[0];
        }
        _graphCache.put(
            cacheKey,
            [null, nowUnixMin] as [Array<Float>?, Number]
        );

        // A plain Number means "last N entries" here, not minutes - only a Duration is a time span.
        var opts = { :period => new Time.Duration(periodMin * SECS_PER_MIN) };
        if (field == FIELD_HR) {
            return _cacheResult(
                cacheKey,
                field,
                _readIter(
                    SensorHistory.getHeartRateHistory(opts),
                    periodMin,
                    true
                )
            );
        }
        if (field == FIELD_BODY_BAT) {
            return _cacheResult(
                cacheKey,
                field,
                _readIter(
                    SensorHistory.getBodyBatteryHistory(opts),
                    periodMin,
                    false
                )
            );
        }
        if (field == FIELD_STRESS) {
            return _cacheResult(
                cacheKey,
                field,
                _readIter(
                    SensorHistory.getStressHistory(opts),
                    periodMin,
                    false
                )
            );
        }
        if (field == FIELD_SPO2) {
            // getOxygenSaturationHistory(opts) is unreliable on-device; pass null instead.
            return _cacheResult(
                cacheKey,
                field,
                _readIter(
                    SensorHistory.getOxygenSaturationHistory(null),
                    periodMin,
                    false
                )
            );
        }
        if (field == FIELD_WRIST_TEMP) {
            return _cacheResult(
                cacheKey,
                field,
                _readIter(
                    SensorHistory.getTemperatureHistory(opts),
                    periodMin,
                    false
                )
            );
        }
        if (field == FIELD_ELEVATION) {
            return _cacheResult(
                cacheKey,
                field,
                _readIter(
                    SensorHistory.getElevationHistory(opts),
                    periodMin,
                    false
                )
            );
        }
        if (field == FIELD_PRESSURE) {
            return _cacheResult(
                cacheKey,
                field,
                _readIter(
                    SensorHistory.getPressureHistory(opts),
                    periodMin,
                    false
                )
            );
        }
        return null;
    }

    private function _tempStrFmt(v as Float, fmt as String) as String {
        return _metric ? v.format(fmt) : Formatters.celsiusToF(v).format(fmt);
    }

    private function _tempStr(v as Float) as String {
        return _tempStrFmt(v, "%.1f");
    }

    private function _tempStr0(v as Float) as String {
        return _tempStrFmt(v, "%.0f");
    }

    private function _altStr(m as Float) as String {
        return _metric
            ? m.format("%.0f") + "m"
            : (m * FEET_PER_METER).format("%.0f") + "ft";
    }

    private function _distStr(d as Float) as String {
        return _metric
            ? (d / 1000.0).format("%.1f") + "km"
            : (d / METERS_PER_MILE).format("%.1f") + "mi";
    }

    private function _formatGraphLabel(field as Number, v as Float) as String {
        if (field == FIELD_WRIST_TEMP || field == FIELD_WX_FCST_TEMP) {
            return _tempStr0(v);
        }
        if (field == FIELD_ELEVATION) {
            return _metric
                ? v.format("%.0f")
                : (v * FEET_PER_METER).format("%.0f");
        }
        if (field == FIELD_PRESSURE) {
            return _metric
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
            return _metric
                ? (v * KMH_PER_MPS).format("%.0f")
                : (v * MPH_PER_MPS).format("%.0f");
        }
        if (field == FIELD_WX_FCST_UV) {
            return v.format("%.1f");
        }
        return Math.round(v).toNumber().toString();
    }

    private function _graphFieldUnit(field as Number) as String {
        if (field == FIELD_HR) {
            return " bpm";
        }
        if (field == FIELD_BODY_BAT || field == FIELD_SPO2) {
            return "%";
        }
        if (field == FIELD_WX_FCST_WIND) {
            return _metric ? "km/h" : "mph";
        }
        if (field == FIELD_ELEVATION) {
            return _metric ? "m" : "ft";
        }
        if (field == FIELD_PRESSURE) {
            return _metric ? "hPa" : "inHg";
        }
        return "";
    }

    private function _graphValueStr(
        field as Number,
        data as Array<Float>,
        minV as Float,
        maxV as Float,
        mode as Number,
        currentStr as String
    ) as String {
        if (mode == 0) {
            return currentStr;
        }
        var unit = _graphFieldUnit(field);
        if (mode == 1) {
            var sum = 0.0 as Float;
            var count = 0;
            for (var i = 0; i < data.size(); i++) {
                if (data[i] != null) {
                    sum += data[i] as Float;
                    count++;
                }
            }
            if (count == 0) {
                return currentStr;
            }
            return _formatGraphLabel(field, sum / count.toFloat()) + unit;
        }
        if (mode == 2) {
            return (
                _formatGraphLabel(field, maxV) +
                "/" +
                _formatGraphLabel(field, minV) +
                unit
            );
        }
        if (mode == 3) {
            return _formatGraphLabel(field, (minV + maxV) / 2.0) + unit;
        }
        return currentStr;
    }

    private function _dataAge(
        data as Array<Float>,
        periodMin as Number
    ) as Number {
        var periodSec = periodMin * SECS_PER_MIN;
        var n = data.size();
        for (var i = 0; i < n; i++) {
            if (data[i] != null) {
                return (i * periodSec) / n;
            }
        }
        return -1;
    }

    // Packs hi/lo (graphW+field, or field+fieldSecondary) and periodMin into one Number.
    private function _packGraphKey(
        hi as Number,
        lo as Number,
        periodMin as Number
    ) as Number {
        return (
            ((hi & CACHE_KEY_MASK) << CACHE_KEY_HI_SHIFT) |
            ((lo & CACHE_KEY_MASK) << CACHE_KEY_LO_SHIFT) |
            (periodMin & CACHE_KEY_PERIOD_MASK)
        );
    }

    private function _graphKeyHi(k as Number) as Number {
        return (k >> CACHE_KEY_HI_SHIFT) & CACHE_KEY_MASK;
    }

    private function _graphKeyLo(k as Number) as Number {
        return (k >> CACHE_KEY_LO_SHIFT) & CACHE_KEY_MASK;
    }

    // Removes a bitmap cache entry together with its drawOk twin so callers can't purge one without the other.
    private function _removeBmpCacheEntry(
        bmpCache as Dictionary,
        drawOkCache as Dictionary,
        key as Number
    ) as Void {
        bmpCache.remove(key);
        drawOkCache.remove(key);
    }

    // Forecast bitmap cache keys don't change on refresh, so purge them here instead.
    private function _invalidateFieldGraphCache(field as Number) as Void {
        var keys = _graphBmpCache.keys();
        for (var i = 0; i < keys.size(); i++) {
            var k = keys[i] as Number;
            if (_graphKeyLo(k) == field) {
                _removeBmpCacheEntry(_graphBmpCache, _graphBmpDrawOk, k);
            }
        }
    }

    private function _cacheResult(
        cacheKey as Number,
        field as Number,
        r as Array<Float>?
    ) as Array<Float>? {
        _graphCache.put(cacheKey, [r, _nowUnixMin] as [Array<Float>?, Number]);
        _removeBmpCacheEntry(_graphBmpCache, _graphBmpDrawOk, cacheKey);
        var dualKeys = _graphBmpDualCache.keys();
        for (var i = 0; i < dualKeys.size(); i++) {
            var k = dualKeys[i] as Number;
            if (_graphKeyHi(k) == field || _graphKeyLo(k) == field) {
                _removeBmpCacheEntry(
                    _graphBmpDualCache,
                    _graphBmpDualDrawOk,
                    k
                );
            }
        }
        if (_pendingEffPeriod > 0) {
            _graphEffPeriod.put(cacheKey, _pendingEffPeriod);
            _pendingEffPeriod = 0;
        }
        return r;
    }

    // Cache entries are [crispRef, glowRef?] pairs so both bitmaps share one
    // invalidation lifecycle - removing the dict entry (data refresh, settings
    // change) drops both together instead of needing a second parallel purge.
    private function _bmpPairGet(
        cache as Dictionary,
        cacheKey as Number
    ) as Array {
        var pair = cache.get(cacheKey) as Array?;
        return pair != null ? pair : [null, null] as Array;
    }

    // Renders to cached bitmaps at (0,0)/(GLOW_SPREAD,GLOW_SPREAD) origin; caller
    // blits crisp at (gx, y) and glow at (gx - GLOW_SPREAD, y - GLOW_SPREAD).
    // Glow is only built (and only kept) while glow is actually enabled - see _renderGraphGlow.
    private function _renderGraphToBitmap(
        cacheKey as Number,
        field as Number,
        graphType as Number,
        lineColor as Number,
        data as Array<Float>,
        gw as Number,
        gh as Number,
        minV as Float,
        range as Float,
        gradMinV as Float,
        gradRange as Float,
        maxGap as Number
    ) as [Graphics.BufferedBitmap?, Graphics.BufferedBitmap?] {
        var pair = _bmpPairGet(_graphBmpCache, cacheKey);
        var crispRef = pair[0] as Graphics.BufferedBitmapReference?;
        var glowRef = pair[1] as Graphics.BufferedBitmapReference?;
        var crispBmp = _resolveBmpRef(crispRef);
        var rebuilt = false;
        if (crispBmp == null) {
            // +1 width/+2 height: the rightmost point and fill's bottom row land exactly at gw/gh+1, past a plain gw x (gh+1) buffer's bounds.
            var created = _newClearedBitmap(gw + 1, gh + 2);
            if (created == null) {
                return [null, null];
            }
            crispRef = created[0];
            crispBmp = created[1];
            var bmpDc = crispBmp.getDc();
            _haloSuppressed = true;
            try {
                _drawMeanLine(
                    bmpDc,
                    data,
                    0,
                    gw,
                    0,
                    gh,
                    minV,
                    range,
                    lineColor,
                    gradMinV,
                    gradRange
                );
                _drawOneGraph(
                    bmpDc,
                    graphType,
                    lineColor,
                    data,
                    0,
                    gw,
                    0,
                    gh,
                    minV,
                    range,
                    gradMinV,
                    gradRange,
                    maxGap
                );
                if (field == FIELD_HR) {
                    _drawHrZones(bmpDc, 0, gw, 0, gh, minV, range);
                }
            } finally {
                _haloSuppressed = false;
            }
            glowRef = null;
            rebuilt = true;
        }
        var glowBmp = _resolveBmpRef(glowRef);
        if (glowBmp == null && _glowIntensity > 0 && !_lowPower) {
            var pad = GLOW_SPREAD;
            var glowCreated = _newClearedBitmap(
                gw + 1 + pad * 2,
                gh + 2 + pad * 2
            );
            if (glowCreated != null) {
                glowRef = glowCreated[0];
                glowBmp = glowCreated[1];
                var gdc = glowBmp.getDc();
                _haloBakeDc = gdc;
                try {
                    _glowMeanLine(
                        gdc,
                        data,
                        pad,
                        gw,
                        pad,
                        gh,
                        minV,
                        range,
                        lineColor,
                        gradMinV,
                        gradRange
                    );
                    _glowOneGraph(
                        gdc,
                        graphType,
                        lineColor,
                        data,
                        pad,
                        gw,
                        pad,
                        gh,
                        minV,
                        range,
                        gradMinV,
                        gradRange,
                        maxGap
                    );
                } finally {
                    _haloBakeDc = null;
                }
                rebuilt = true;
            }
        }
        if (rebuilt) {
            _graphBmpCache.put(cacheKey, [crispRef, glowRef] as Array);
        }
        return [crispBmp, glowBmp];
    }

    private function _renderDualGraphToBitmap(
        cacheKey as Number,
        field as Number,
        graphType as Number,
        secType as Number,
        lineColor as Number,
        lineColor2 as Number,
        data as Array<Float>,
        data2 as Array<Float>?,
        gw as Number,
        gh as Number,
        minV as Float,
        range as Float,
        minV2 as Float,
        range2 as Float,
        gradMinV1 as Float,
        gradRange1 as Float,
        gradMinV2 as Float,
        gradRange2 as Float,
        dualMaxGap as Number
    ) as [Graphics.BufferedBitmap?, Graphics.BufferedBitmap?] {
        var pair = _bmpPairGet(_graphBmpDualCache, cacheKey);
        var crispRef = pair[0] as Graphics.BufferedBitmapReference?;
        var glowRef = pair[1] as Graphics.BufferedBitmapReference?;
        var crispBmp = _resolveBmpRef(crispRef);
        var rebuilt = false;
        if (crispBmp == null) {
            // +1 width/+2 height: the rightmost point and fill's bottom row land exactly at gw/gh+1, past a plain gw x (gh+1) buffer's bounds.
            var created = _newClearedBitmap(gw + 1, gh + 2);
            if (created == null) {
                return [null, null];
            }
            crispRef = created[0];
            crispBmp = created[1];
            var bmpDc = crispBmp.getDc();
            _haloSuppressed = true;
            try {
                _drawMeanLine(
                    bmpDc,
                    data,
                    0,
                    gw,
                    0,
                    gh,
                    minV,
                    range,
                    lineColor,
                    gradMinV1,
                    gradRange1
                );
                if (
                    graphType == GRAPH_BAR &&
                    secType == SEC_BAR &&
                    data2 != null
                ) {
                    _drawDualBars(
                        bmpDc,
                        data,
                        data2 as Array<Float>,
                        0,
                        gw,
                        0,
                        gh + 1,
                        minV,
                        range,
                        minV2,
                        range2,
                        lineColor,
                        lineColor2,
                        gradMinV1,
                        gradRange1,
                        gradMinV2,
                        gradRange2
                    );
                } else {
                    _drawOneGraph(
                        bmpDc,
                        graphType,
                        lineColor,
                        data,
                        0,
                        gw,
                        0,
                        gh,
                        minV,
                        range,
                        gradMinV1,
                        gradRange1,
                        dualMaxGap
                    );
                    if (data2 != null) {
                        _drawOneGraph(
                            bmpDc,
                            secType == SEC_BAR ? GRAPH_BAR : GRAPH_LINE,
                            lineColor2,
                            data2 as Array<Float>,
                            0,
                            gw,
                            0,
                            gh,
                            minV2,
                            range2,
                            gradMinV2,
                            gradRange2,
                            dualMaxGap
                        );
                    }
                }
                if (field == FIELD_HR) {
                    _drawHrZones(bmpDc, 0, gw, 0, gh, minV, range);
                }
            } finally {
                _haloSuppressed = false;
            }
            glowRef = null;
            rebuilt = true;
        }
        var glowBmp = _resolveBmpRef(glowRef);
        if (glowBmp == null && _glowIntensity > 0 && !_lowPower) {
            var pad = GLOW_SPREAD;
            var glowCreated = _newClearedBitmap(
                gw + 1 + pad * 2,
                gh + 2 + pad * 2
            );
            if (glowCreated != null) {
                glowRef = glowCreated[0];
                glowBmp = glowCreated[1];
                var gdc = glowBmp.getDc();
                _haloBakeDc = gdc;
                try {
                    _glowMeanLine(
                        gdc,
                        data,
                        pad,
                        gw,
                        pad,
                        gh,
                        minV,
                        range,
                        lineColor,
                        gradMinV1,
                        gradRange1
                    );
                    if (
                        graphType == GRAPH_BAR &&
                        secType == SEC_BAR &&
                        data2 != null
                    ) {
                        _glowDualBarsShape(
                            gdc,
                            data,
                            data2 as Array<Float>,
                            pad,
                            gw,
                            pad,
                            gh + 1,
                            minV,
                            range,
                            minV2,
                            range2,
                            lineColor,
                            lineColor2,
                            gradMinV1,
                            gradRange1,
                            gradMinV2,
                            gradRange2
                        );
                    } else {
                        _glowOneGraph(
                            gdc,
                            graphType,
                            lineColor,
                            data,
                            pad,
                            gw,
                            pad,
                            gh,
                            minV,
                            range,
                            gradMinV1,
                            gradRange1,
                            dualMaxGap
                        );
                        if (data2 != null) {
                            _glowOneGraph(
                                gdc,
                                secType == SEC_BAR ? GRAPH_BAR : GRAPH_LINE,
                                lineColor2,
                                data2 as Array<Float>,
                                pad,
                                gw,
                                pad,
                                gh,
                                minV2,
                                range2,
                                gradMinV2,
                                gradRange2,
                                dualMaxGap
                            );
                        }
                    }
                } finally {
                    _haloBakeDc = null;
                }
                rebuilt = true;
            }
        }
        if (rebuilt) {
            _graphBmpDualCache.put(cacheKey, [crispRef, glowRef] as Array);
        }
        return [crispBmp, glowBmp];
    }

    // Resolves the actual displayed time range (may be shorter than periodMin).
    private function _resolveEffPeriod(
        key as Number,
        periodMin as Number
    ) as Number {
        return _graphEffPeriod.hasKey(key)
            ? _graphEffPeriod.get(key) as Number
            : periodMin;
    }

    private function _calcMinMax(data as Array<Float>) as Void {
        var n = data.size();
        _dataMin = 1.0e38 as Float;
        _dataMax = -1.0e38 as Float;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            if (v < _dataMin) {
                _dataMin = v;
            }
            if (v > _dataMax) {
                _dataMax = v;
            }
        }
        if (_dataMin > _dataMax) {
            _dataMin = 0.0;
            _dataMax = 0.0;
        }
    }

    // sourceRef marks "the data changed" by identity - data itself, or its pre-copy source if rebuilt fresh each call.
    private function _calcMinMaxCached(
        cacheKey as Number,
        sourceRef as Array<Float>,
        data as Array<Float>
    ) as Void {
        if (_minMaxCache.hasKey(cacheKey)) {
            var entry =
                _minMaxCache.get(cacheKey) as [Float, Float, Array<Float>];
            if (entry[2] == sourceRef) {
                _dataMin = entry[0];
                _dataMax = entry[1];
                return;
            }
        }
        _calcMinMax(data);
        _minMaxCache.put(
            cacheKey,
            [_dataMin, _dataMax, sourceRef] as [Float, Float, Array<Float>]
        );
    }

    private function _graphLabelColor(
        colorIdx as Number,
        isGrad as Boolean,
        frac as Float
    ) as Number {
        return isGrad
            ? ColorUtils.gradColor(colorIdx, frac)
            : ColorUtils.colorFromIdx(0);
    }

    private function _graphLabelPad(a as String, b as String) as Number {
        var len = a.length() > b.length() ? a.length() : b.length();
        var pad = (len + 1) / 2;
        return pad < 1 ? 1 : pad;
    }

    private function _setGraphX(
        field as Number,
        minV as Float,
        maxV as Float
    ) as Void {
        _graphX =
            _graphBaseX +
            _charW *
                _graphLabelPad(
                    _formatGraphLabel(field, minV),
                    _formatGraphLabel(field, maxV)
                );
    }

    private function _drawSingleGraphLabels(
        dc as Dc,
        field as Number,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        maxV as Float,
        bottomLabel as String,
        colorIdx as Number,
        maxFrac as Float,
        minFrac as Float,
        ageSec as Number
    ) as Void {
        var isGrad = colorIdx >= COLOR_GRAD_TRI;
        _glowText(
            dc,
            gx - 4,
            y - 4,
            _fontTiny,
            _formatGraphLabel(field, maxV),
            Graphics.TEXT_JUSTIFY_RIGHT,
            _graphLabelColor(colorIdx, isGrad, maxFrac)
        );
        _glowText(
            dc,
            gx - 4,
            y + gh - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(field, minV),
            Graphics.TEXT_JUSTIFY_RIGHT,
            _graphLabelColor(colorIdx, isGrad, minFrac)
        );
        var ageColor = GRAYS[3];
        _glowText(
            dc,
            gx + gw,
            y + gh + 1,
            _fontTiny,
            bottomLabel,
            Graphics.TEXT_JUSTIFY_RIGHT,
            ageColor
        );
        if (ageSec > _graphStaleSec(field)) {
            _glowText(
                dc,
                gx,
                y + gh + 1,
                _fontTiny,
                Formatters.formatAge(ageSec),
                Graphics.TEXT_JUSTIFY_LEFT,
                ageColor
            );
        }
    }

    private function _drawGraphAxes(
        dc as Dc,
        gx as Number,
        gw as Number,
        y as Number
    ) as Void {
        _glowLine(dc, gx - 1, y, gx - 1, y + _fh - 1, GRAYS[3]);
        _glowLine(dc, gx - 1, y + _fh - 1, gx + gw, y + _fh - 1, GRAYS[3]);
        _glowLine(dc, gx + gw, y, gx + gw, y + _fh - 1, GRAYS[3]);
    }

    private function _drawRowAxes(dc as Dc, y as Number) as Void {
        _drawGraphAxes(dc, _graphX, _graphW, y);
    }

    // Shared by the line-draw functions and _glowLineShape so the glow
    // traces exactly the same points as the crisp line.
    private function _linePointX(
        gx as Number,
        gw as Number,
        n1 as Number,
        i as Number
    ) as Number {
        return gx + ((n1 - i) * gw) / n1;
    }

    private function _linePointY(
        y as Number,
        gh as Number,
        v as Float,
        minV as Float,
        range as Float,
        ghf as Float
    ) as Number {
        return y + gh - Math.round(((v - minV) * ghf) / range).toNumber();
    }

    // DebugGraphGaps setting only: marks a normally-skipped gap in GRAYS[2] instead of leaving it blank.
    private function _drawDebugGapLine(
        dc as Dc,
        x1 as Number,
        y1 as Number,
        x2 as Number,
        y2 as Number
    ) as Void {
        var dx = x2 - x1;
        var dy = y2 - y1;
        var adx = dx < 0 ? -dx : dx;
        var ady = dy < 0 ? -dy : dy;
        var steps = adx > ady ? adx : ady;
        if (steps < 1) {
            steps = 1;
        }
        dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
        var i = 0;
        var on = true;
        while (i < steps) {
            var j = i + 3;
            if (j > steps) {
                j = steps;
            }
            if (on) {
                dc.drawLine(
                    x1 + (dx * i) / steps,
                    y1 + (dy * i) / steps,
                    x1 + (dx * j) / steps,
                    y1 + (dy * j) / steps
                );
            }
            on = !on;
            i = j;
        }
    }

    // data[0] = newest (rightmost), data[n-1] = oldest (leftmost)
    private function _drawGraphLine(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        maxGap as Number,
        color as Number
    ) as Void {
        var n = data.size();
        var n1 = n - 1;
        if (n1 < 1) {
            return;
        }
        var ghf = gh.toFloat();
        var lastX = -1;
        var lastY = 0;
        var lastI = -1;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var x = _linePointX(gx, gw, n1, i);
            var py = _linePointY(y, gh, v, minV, range, ghf);
            if (lastX >= 0 && i - lastI <= maxGap) {
                _glowLine(dc, x, py, lastX, lastY, color);
            } else if (lastX >= 0 && _debugGraphGaps) {
                _drawDebugGapLine(dc, lastX, lastY, x, py);
            }
            _glowRect(dc, x, py, 1, 1, color);
            lastX = x;
            lastY = py;
            lastI = i;
        }
    }

    // alpha == null draws opaque glowing dashes (halo); non-null draws flat, in the dimmed color the caller already set via setColor.
    private function _dashSeg(
        dc as Dc,
        x1 as Number,
        y1 as Number,
        x2 as Number,
        y2 as Number,
        color as Number,
        alpha as Number?
    ) as Void {
        if (alpha != null) {
            dc.drawLine(x1, y1, x2, y2);
        } else {
            _glowLine(dc, x1, y1, x2, y2, color);
        }
    }

    private function _drawDashedH(
        dc as Dc,
        x1 as Number,
        x2 as Number,
        y as Number,
        color as Number,
        alpha as Number?
    ) as Void {
        var w = x2 - x1;
        if (w <= 0) {
            return;
        }
        if (alpha != null) {
            dc.setStroke(ColorUtils.withAlpha(color, alpha));
        }
        if (w <= 3) {
            _dashSeg(dc, x1, y, x2 - 1, y, color, alpha);
            return;
        }
        // Dashes/gaps are 2px; the last dash absorbs any leftover width so gaps stay exact.
        var wEven = w - (w % 2);
        var n = (wEven + 2) / 4;
        if (n < 2) {
            n = 2;
        }
        var slack = wEven - (4 * n - 2);
        var f = 2;
        if (slack < 0) {
            f = 2 + slack;
            if (f < 1) {
                f = 1;
            }
            slack = 0;
        }
        _dashSeg(dc, x1, y, x1 + f - 1, y, color, alpha);
        var x = x1 + f + 2;
        for (var i = 1; i < n - 1; i++) {
            _dashSeg(dc, x, y, x + 1, y, color, alpha);
            x += 4;
        }
        var fLast = f + slack + (w - wEven);
        _dashSeg(dc, x2 - fLast, y, x2 - 1, y, color, alpha);
    }

    private function _drawDashedV(
        dc as Dc,
        x as Number,
        y1 as Number,
        y2 as Number,
        color as Number,
        alpha as Number?
    ) as Void {
        var h = y2 - y1;
        if (h <= 0) {
            return;
        }
        if (alpha != null) {
            dc.setStroke(ColorUtils.withAlpha(color, alpha));
        }
        if (h <= 3) {
            _dashSeg(dc, x, y1, x, y2 - 1, color, alpha);
            return;
        }
        var hEven = h - (h % 2);
        var n = (hEven + 2) / 4;
        if (n < 2) {
            n = 2;
        }
        var slack = hEven - (4 * n - 2);
        var f = 2;
        if (slack < 0) {
            f = 2 + slack;
            if (f < 1) {
                f = 1;
            }
            slack = 0;
        }
        _dashSeg(dc, x, y1, x, y1 + f - 1, color, alpha);
        var yp = y1 + f + 2;
        for (var i = 1; i < n - 1; i++) {
            _dashSeg(dc, x, yp, x, yp + 1, color, alpha);
            yp += 4;
        }
        var fLast = f + slack + (h - hEven);
        _dashSeg(dc, x, y2 - fLast, x, y2 - 1, color, alpha);
    }

    // Shared position/color calc for _drawMeanLine and _glowMeanLine.
    private function _meanLineYColor(
        data as Array<Float>,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float
    ) as Array<Number>? {
        var n = data.size();
        var sum = 0.0;
        var cnt = 0;
        for (var i = 0; i < n; i++) {
            if (data[i] != null) {
                sum += data[i] as Float;
                cnt++;
            }
        }
        if (cnt == 0) {
            return null;
        }
        var mean = sum / cnt.toFloat();
        var meanH = Math.round(
            ((mean - minV) * gh.toFloat()) / range
        ).toNumber();
        if (meanH < 0) {
            meanH = 0;
        }
        if (meanH > gh) {
            meanH = gh;
        }
        var meanY = y + gh - meanH;
        var meanFrac = _fracClamp(mean, gradMinV, gradRange);
        var color =
            colorIdx >= COLOR_GRAD_TRI
                ? ColorUtils.gradColor(colorIdx, meanFrac)
                : Graphics.COLOR_WHITE;
        return [meanY, color] as Array<Number>;
    }

    private function _drawMeanLine(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float
    ) as Void {
        var r = _meanLineYColor(
            data,
            y,
            gh,
            minV,
            range,
            colorIdx,
            gradMinV,
            gradRange
        );
        if (r == null) {
            return;
        }
        // Gradient graphs keep the opaque glowing line; other graphs get a flat translucent one.
        _drawDashedH(
            dc,
            gx,
            gx + gw,
            r[0],
            r[1],
            colorIdx >= COLOR_GRAD_TRI ? null : DASH_ALPHA
        );
    }

    // Restores the mean line's glow on the cache-hit path, as a continuous
    // band rather than dashed - the crisp dashes on top already read as dashed.
    // No-op for the translucent (non-gradient) mean line, which has no halo layer.
    private function _glowMeanLine(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float
    ) as Void {
        if (colorIdx < COLOR_GRAD_TRI) {
            return;
        }
        var hdc = _activeHaloDc();
        if (hdc == null) {
            return;
        }
        var r = _meanLineYColor(
            data,
            y,
            gh,
            minV,
            range,
            colorIdx,
            gradMinV,
            gradRange
        );
        if (r == null) {
            return;
        }
        hdc.setColor(_glowColor(r[1]), Graphics.COLOR_TRANSPARENT);
        _haloFillDiagSpread(hdc, gx, r[0], gw, 1);
    }

    private function _drawGradLine(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float,
        maxGap as Number
    ) as Void {
        var n = data.size();
        var n1 = n - 1;
        if (n1 < 1) {
            return;
        }
        var ghf = gh.toFloat();
        var lastX = -1;
        var lastY = 0;
        var lastV = 0.0 as Float;
        var lastI = -1;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var x = _linePointX(gx, gw, n1, i);
            var py = _linePointY(y, gh, v, minV, range, ghf);
            if (lastX >= 0 && i - lastI <= maxGap) {
                var mid = (v + lastV) / 2.0;
                var mfrac = _fracClamp(mid, gradMinV, gradRange);
                _glowLine(
                    dc,
                    x,
                    py,
                    lastX,
                    lastY,
                    ColorUtils.gradColor(colorIdx, mfrac)
                );
            } else if (lastX >= 0 && _debugGraphGaps) {
                _drawDebugGapLine(dc, lastX, lastY, x, py);
            }
            var frac = _fracClamp(v, gradMinV, gradRange);
            _glowRect(dc, x, py, 1, 1, ColorUtils.gradColor(colorIdx, frac));
            lastX = x;
            lastY = py;
            lastV = v;
            lastI = i;
        }
    }

    // agg: 0=mean, 1=max, 2=last (most recent non-null in the group; index 0
    // is "now", per _readIter's age->slot mapping).
    private function _groupBarData(
        data as Array<Float>,
        barCount as Number,
        agg as Number
    ) as Array<Float> {
        var n = data.size();
        var out = new Array<Float>[barCount];
        for (var j = 0; j < barCount; j++) {
            var lo = (j * n) / barCount;
            var hi = ((j + 1) * n) / barCount;
            if (hi <= lo) {
                hi = lo + 1;
            }
            if (hi > n) {
                hi = n;
            }
            if (agg == 1) {
                var best = 0.0 as Float;
                var found = false;
                for (var i = lo; i < hi; i++) {
                    if (data[i] != null) {
                        var v = data[i] as Float;
                        if (!found || v > best) {
                            best = v;
                            found = true;
                        }
                    }
                }
                if (found) {
                    out[j] = best;
                }
            } else if (agg == 2) {
                for (var i2 = lo; i2 < hi; i2++) {
                    if (data[i2] != null) {
                        out[j] = data[i2] as Float;
                        break;
                    }
                }
            } else {
                var sum = 0.0;
                var cnt = 0;
                for (var i3 = lo; i3 < hi; i3++) {
                    if (data[i3] != null) {
                        sum += data[i3] as Float;
                        cnt++;
                    }
                }
                if (cnt > 0) {
                    out[j] = sum / cnt.toFloat();
                }
            }
        }
        return out;
    }

    // Regroups only when _graphCache shows the history actually refreshed,
    // not every frame - settings changes wipe this via invalidateSettings.
    private function _groupBarDataCached(
        cacheKey as Number,
        data as Array<Float>,
        barCount as Number,
        agg as Number
    ) as Array<Float> {
        var lastMin = (_graphCache.get(cacheKey) as [Array<Float>?, Number])[1];
        if (_groupedBarCache.hasKey(cacheKey)) {
            var entry =
                _groupedBarCache.get(cacheKey) as
                [Array<Float>, Number, Number, Number];
            // barCount/agg can differ per caller even when lastMin matches (shared secondary field, different primaries).
            if (
                entry[1] == lastMin &&
                entry[2] == barCount &&
                entry[3] == agg
            ) {
                return entry[0];
            }
        }
        var grouped = _groupBarData(data, barCount, agg);
        _groupedBarCache.put(
            cacheKey,
            [grouped, lastMin, barCount, agg] as
                [Array<Float>, Number, Number, Number]
        );
        return grouped;
    }

    // Shared by the bar-draw functions and _glowBarsShape so the glow lands
    // on exactly the same rects as the crisp bars. Returns [bx, by, bw, bh].
    private function _barRect(
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        i as Number,
        n as Number,
        v as Float,
        minV as Float,
        range as Float,
        ghf as Float
    ) as Array<Number> {
        var slot = n - 1 - i; // index 0 draws rightmost - forecast callers rely on this to put "now" on the left.
        var bx = gx + (slot * gw) / n;
        var slotEnd = gx + ((slot + 1) * gw) / n;
        var bw = slotEnd - bx - (slot < n - 1 ? 1 : 0);
        if (bw < 1) {
            bw = 1;
        }
        var barH = Math.round(((v - minV) * ghf) / range).toNumber();
        if (barH < 1) {
            barH = 1;
        }
        return [bx, y + gh - barH, bw, barH] as Array<Number>;
    }

    private function _drawBars(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        color as Number
    ) as Void {
        var n = data.size();
        var ghf = gh.toFloat();
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var barV = data[i] as Float;
            var r = _barRect(gx, gw, y, gh, i, n, barV, minV, range, ghf);
            _glowRect(dc, r[0], r[1], r[2], r[3], color);
        }
    }

    private function _drawGradBars(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float
    ) as Void {
        var n = data.size();
        var ghf = gh.toFloat();
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var r = _barRect(gx, gw, y, gh, i, n, v, minV, range, ghf);
            var frac = _fracClamp(v, gradMinV, gradRange);
            _glowRect(
                dc,
                r[0],
                r[1],
                r[2],
                r[3],
                ColorUtils.gradColor(colorIdx, frac)
            );
        }
    }

    // Shared by _drawDualBars and _glowDualBarsShape - a slot is split in
    // half, first series on the left half, second on the right.
    private function _dualBarRect(
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        i as Number,
        count as Number,
        v as Float,
        minV as Float,
        range as Float,
        ghf as Float,
        isFirst as Boolean
    ) as Array<Number> {
        var slot = count - 1 - i;
        var slotX = gx + (slot * gw) / count;
        var slotEnd = gx + ((slot + 1) * gw) / count;
        var slotW = slotEnd - slotX - (slot < count - 1 ? 1 : 0);
        if (slotW < 2) {
            slotW = 2;
        }
        var hw = slotW / 2;
        var barH = Math.round(((v - minV) * ghf) / range).toNumber();
        if (barH < 1) {
            barH = 1;
        }
        return isFirst
            ? [slotX, y + gh - barH, hw, barH] as Array<Number>
            : [slotX + hw, y + gh - barH, slotW - hw, barH] as Array<Number>;
    }

    private function _drawDualBars(
        dc as Dc,
        data as Array<Float>,
        data2 as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        minV2 as Float,
        range2 as Float,
        colorIdx1 as Number,
        colorIdx2 as Number,
        gradMinV1 as Float,
        gradRange1 as Float,
        gradMinV2 as Float,
        gradRange2 as Float
    ) as Void {
        var n = data.size();
        var n2 = data2.size();
        var count = n < n2 ? n : n2;
        var ghf = gh.toFloat();
        for (var i = 0; i < count; i++) {
            if (data[i] != null) {
                var v1 = data[i] as Float;
                var r1 = _dualBarRect(
                    gx,
                    gw,
                    y,
                    gh,
                    i,
                    count,
                    v1,
                    minV,
                    range,
                    ghf,
                    true
                );
                var frac1 = _fracClamp(v1, gradMinV1, gradRange1);
                _glowRect(
                    dc,
                    r1[0],
                    r1[1],
                    r1[2],
                    r1[3],
                    ColorUtils.gradColor(colorIdx1, frac1)
                );
            }
            if (data2[i] != null) {
                var v2 = data2[i] as Float;
                var r2 = _dualBarRect(
                    gx,
                    gw,
                    y,
                    gh,
                    i,
                    count,
                    v2,
                    minV2,
                    range2,
                    ghf,
                    false
                );
                var frac2 = _fracClamp(v2, gradMinV2, gradRange2);
                _glowRect(
                    dc,
                    r2[0],
                    r2[1],
                    r2[2],
                    r2[3],
                    ColorUtils.gradColor(colorIdx2, frac2)
                );
            }
        }
    }

    private function _drawForecastTempRow(
        dc as Dc,
        cx as Number,
        y as Number,
        hours as Number,
        viewMode as Number,
        valueMode as Number,
        labelColor as Number,
        valueColor as Number,
        lineColor as Number,
        graphType as Number
    ) as Void {
        _graphX = _graphBaseX;
        var all = _wxForecastData;
        var n = all != null ? (hours < all.size() ? hours : all.size()) : 0;
        var data = new Array<Float>[n];
        var realCount = 0;
        for (var i = 0; i < n; i++) {
            var v = (all as Array<Float>)[n - 1 - i];
            data[i] = v;
            if (v != null) {
                realCount++;
            }
        }
        if (realCount < 2) {
            _rowBuf[0] = "Temp Fcst";
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }

        var fcstTempCacheKey = _packGraphKey(
            _graphW,
            FIELD_WX_FCST_TEMP,
            hours
        );
        _calcMinMaxCached(fcstTempCacheKey, all as Array<Float>, data);
        var minV = _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }
        _setGraphX(FIELD_WX_FCST_TEMP, minV, maxV);
        var gr = _calcGradRange(FIELD_WX_FCST_TEMP, lineColor, minV, range);
        var gradMinV = gr[0];
        var gradRange = gr[1];
        var maxFrac = _fracClamp(maxV, gradMinV, gradRange);
        var minFrac = _fracClamp(minV, gradMinV, gradRange);

        _rowBuf[0] = "Temp Fcst";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var fcstMaxGap = FORECAST_GAP_HOURS;
        var fcstTempBmps = _renderGraphToBitmap(
            fcstTempCacheKey,
            FIELD_WX_FCST_TEMP,
            graphType,
            lineColor,
            data,
            _graphW,
            _graphH,
            minV,
            range,
            gradMinV,
            gradRange,
            fcstMaxGap
        );
        _drawGraphRowGlow(
            dc,
            fcstTempBmps,
            fcstTempCacheKey,
            _graphBmpDrawOk,
            graphType,
            lineColor,
            data,
            y,
            minV,
            range,
            gradMinV,
            gradRange,
            fcstMaxGap
        );
        _drawRowAxes(dc, y);
        _drawSingleGraphLabels(
            dc,
            FIELD_WX_FCST_TEMP,
            _graphX,
            _graphW,
            y,
            _graphH,
            minV,
            maxV,
            "+" + hours.toString() + "h",
            lineColor,
            maxFrac,
            minFrac,
            -1
        );
        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = _graphX + _graphW + _charW;
            var vy = y + (_fh - _smallFh) / 2 - 1;
            var valColor = ColorUtils.colorFromIdx(valueColor);
            if (valueMode == 2) {
                var maxStr = _tempStr0(maxV);
                var minStr = _tempStr0(minV);
                vx = _drawSmallTempNum(dc, vx, vy, maxStr, valColor);
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    "/",
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
                vx += dc.getTextWidthInPixels("/", _fontSmall);
                vx = _drawSmallTempNum(dc, vx, vy, minStr, valColor);
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
            } else {
                var tStr = _graphValueStr(
                    FIELD_WX_FCST_TEMP,
                    data,
                    minV,
                    maxV,
                    valueMode,
                    _wxTemp
                );
                vx = _drawSmallTempNum(dc, vx, vy, tStr, valColor);
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
                _drawValueModeLabel(
                    dc,
                    vx + dc.getTextWidthInPixels(_wxUnit, _fontSmall),
                    y,
                    valueMode
                );
            }
        }
    }

    private function _drawHrZones(
        dc as Dc,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float
    ) as Void {
        if (_hrZones == null) {
            return;
        }
        var zones = _hrZones as Array<Number>;
        var n = zones.size();
        if (n == 0) {
            return;
        }
        // Color each threshold by its position across the zones' own range (low=green, high=red).
        var zLo = (zones[0] as Number).toFloat();
        var zSpan = (zones[n - 1] as Number).toFloat() - zLo;
        for (var i = 0; i < n; i++) {
            var zv = (zones[i] as Number).toFloat();
            if (zv <= minV || zv >= minV + range) {
                continue;
            }
            var zy = _linePointY(y, gh, zv, minV, range, gh.toFloat());
            var zFrac = zSpan > 0.0 ? (zv - zLo) / zSpan : 0.0;
            _drawDashedH(
                dc,
                gx,
                gx + gw,
                zy,
                ColorUtils.gradFromStops(TRI_GRAD, zFrac),
                DASH_ALPHA
            );
        }
    }

    private function _drawMoveBarRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelColor as Number,
        valueColor as Number
    ) as Void {
        _rowBuf[0] = "Move Bar";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        if (_amInfo == null) {
            return;
        }
        var info = _amInfo as ActivityMonitor.Info;
        if (info.moveBarLevel == null) {
            return;
        }
        var level = info.moveBarLevel as Number;
        var gx = cx + _splitPad;
        var blockW = _charW;
        var blockH = _fh - 4;
        var blockY = y + 2;
        for (var i = 0; i < 5; i++) {
            _glowRect(
                dc,
                gx + i * (blockW + 2),
                blockY,
                blockW,
                blockH,
                i < level ? ColorUtils.colorFromIdx(valueColor) : GRAYS[1]
            );
        }
    }

    private function _drawAreaLine(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        maxGap as Number,
        fillColor as Number
    ) as Void {
        var n = data.size();
        if (n < 2) {
            return;
        }
        var n1 = n - 1;
        var ghf = gh.toFloat();
        var bottom = y + gh;
        // +1 so the fill reaches the axis line without shifting the curve's own mapping.
        var fillBottom = bottom + 1;
        var prevX = -1;
        var prevPY = 0;
        var prevI = -1;
        // Tracks a shared column so it's drawn once, not re-composited per point.
        var runX = -1;
        var runTop = 0;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var x = gx + ((n1 - i) * gw) / n1;
            var py = _linePointY(y, gh, v, minV, range, ghf);
            if (py < y) {
                py = y;
            }
            if (prevX >= 0 && i - prevI <= maxGap) {
                var dx = prevX - x;
                if (dx == 0) {
                    var topY = py < prevPY ? py : prevPY;
                    if (x == runX) {
                        if (topY < runTop) {
                            dc.drawLine(x, topY, x, runTop - 1);
                            runTop = topY;
                        }
                    } else {
                        dc.drawLine(x, topY, x, fillBottom);
                        runX = x;
                        runTop = topY;
                    }
                } else {
                    // < not <=: prevX's column was already drawn last iteration.
                    for (var px = x; px < prevX; px++) {
                        var lerpY = py + ((px - x) * (prevPY - py)) / dx;
                        dc.drawLine(px, lerpY, px, fillBottom);
                    }
                }
            } else {
                if (prevX >= 0 && _debugGraphGaps) {
                    dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
                    var gdx = prevX - x;
                    if (gdx == 0) {
                        var gTopY = py < prevPY ? py : prevPY;
                        dc.drawLine(x, gTopY, x, fillBottom);
                    } else {
                        for (var gpx = x; gpx < prevX; gpx++) {
                            var glerpY = py + ((gpx - x) * (prevPY - py)) / gdx;
                            dc.drawLine(gpx, glerpY, gpx, fillBottom);
                        }
                    }
                    dc.setStroke(fillColor);
                }
                dc.drawLine(x, py, x, fillBottom);
            }
            prevX = x;
            prevPY = py;
            prevI = i;
        }
    }

    private function _drawGradArea(
        dc as Dc,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float,
        maxGap as Number
    ) as Void {
        var n = data.size();
        if (n < 2) {
            return;
        }
        var n1 = n - 1;
        var ghf = gh.toFloat();
        var bottom = y + gh;
        // See _drawAreaLine for fillBottom/runX rationale.
        var fillBottom = bottom + 1;
        var prevX = -1;
        var prevPY = 0;
        var prevV = 0.0 as Float;
        var prevI = -1;
        var runX = -1;
        var runTop = 0;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var x = gx + ((n1 - i) * gw) / n1;
            var py = _linePointY(y, gh, v, minV, range, ghf);
            if (py < y) {
                py = y;
            }
            if (prevX >= 0 && i - prevI <= maxGap) {
                var dx = prevX - x;
                if (dx == 0) {
                    var frac = _fracClamp(v, gradMinV, gradRange);
                    dc.setStroke(
                        ColorUtils.withAlpha(
                            ColorUtils.gradColor(colorIdx, frac),
                            _areaOpacity
                        )
                    );
                    var topY = py < prevPY ? py : prevPY;
                    if (x == runX) {
                        if (topY < runTop) {
                            dc.drawLine(x, topY, x, runTop - 1);
                            runTop = topY;
                        }
                    } else {
                        dc.drawLine(x, topY, x, fillBottom);
                        runX = x;
                        runTop = topY;
                    }
                } else {
                    // px < prevX (not <=): see _drawAreaLine for why.
                    for (var px = x; px < prevX; px++) {
                        var lerpV =
                            v +
                            ((px - x).toFloat() * (prevV - v)) / dx.toFloat();
                        var lerpY = py + ((px - x) * (prevPY - py)) / dx;
                        var frac = _fracClamp(lerpV, gradMinV, gradRange);
                        dc.setStroke(
                            ColorUtils.withAlpha(
                                ColorUtils.gradColor(colorIdx, frac),
                                _areaOpacity
                            )
                        );
                        dc.drawLine(px, lerpY, px, fillBottom);
                    }
                }
            } else {
                if (prevX >= 0 && _debugGraphGaps) {
                    dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
                    var gdx = prevX - x;
                    if (gdx == 0) {
                        var gTopY = py < prevPY ? py : prevPY;
                        dc.drawLine(x, gTopY, x, fillBottom);
                    } else {
                        for (var gpx = x; gpx < prevX; gpx++) {
                            var glerpY = py + ((gpx - x) * (prevPY - py)) / gdx;
                            dc.drawLine(gpx, glerpY, gpx, fillBottom);
                        }
                    }
                }
                var frac = _fracClamp(v, gradMinV, gradRange);
                dc.setStroke(
                    ColorUtils.withAlpha(
                        ColorUtils.gradColor(colorIdx, frac),
                        _areaOpacity
                    )
                );
                dc.drawLine(x, py, x, fillBottom);
            }
            prevX = x;
            prevPY = py;
            prevV = v;
            prevI = i;
        }
    }

    private function _drawForecastSimpleRow(
        dc as Dc,
        cx as Number,
        y as Number,
        hours as Number,
        viewMode as Number,
        valueMode as Number,
        labelColor as Number,
        valueColor as Number,
        lineColor as Number,
        graphType as Number,
        label as String,
        fallbackValue as String,
        all as Array<Float>?,
        fieldConst as Number,
        minRange as Float
    ) as Void {
        _graphX = _graphBaseX;
        var n = all != null ? (hours < all.size() ? hours : all.size()) : 0;
        var data = new Array<Float>[n];
        var realCount = 0;
        for (var i = 0; i < n; i++) {
            var v = (all as Array<Float>)[n - 1 - i];
            data[i] = v;
            if (v != null) {
                realCount++;
            }
        }
        if (realCount < 2) {
            _rowBuf[0] = label;
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }
        var fcstCacheKey = _packGraphKey(_graphW, fieldConst, hours);
        _calcMinMaxCached(fcstCacheKey, all as Array<Float>, data);
        var minV = _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < minRange) {
            range = minRange;
        }
        _setGraphX(fieldConst, minV, maxV);
        var gr = _calcGradRange(fieldConst, lineColor, minV, range);
        var gradMinV = gr[0];
        var gradRange = gr[1];
        var maxFrac = _fracClamp(maxV, gradMinV, gradRange);
        var minFrac = _fracClamp(minV, gradMinV, gradRange);
        _rowBuf[0] = label;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var fcstMaxGap = FORECAST_GAP_HOURS;
        var fcstBmps = _renderGraphToBitmap(
            fcstCacheKey,
            fieldConst,
            graphType,
            lineColor,
            data,
            _graphW,
            _graphH,
            minV,
            range,
            gradMinV,
            gradRange,
            fcstMaxGap
        );
        _drawGraphRowGlow(
            dc,
            fcstBmps,
            fcstCacheKey,
            _graphBmpDrawOk,
            graphType,
            lineColor,
            data,
            y,
            minV,
            range,
            gradMinV,
            gradRange,
            fcstMaxGap
        );
        _drawRowAxes(dc, y);
        _drawSingleGraphLabels(
            dc,
            fieldConst,
            _graphX,
            _graphW,
            y,
            _graphH,
            minV,
            maxV,
            "+" + hours.toString() + "h",
            lineColor,
            maxFrac,
            minFrac,
            -1
        );
        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = _graphX + _graphW + _charW;
            var vy = y + (_fh - _smallFh) / 2 - 1;
            var valStr = _graphValueStr(
                fieldConst,
                data,
                minV,
                maxV,
                valueMode,
                fallbackValue
            );
            _glowText(
                dc,
                vx,
                vy,
                _fontSmall,
                valStr,
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.colorFromIdx(valueColor)
            );
            _drawValueModeLabel(
                dc,
                vx + dc.getTextWidthInPixels(valStr, _fontSmall),
                y,
                valueMode
            );
        }
    }

    // Shared by _drawDailyBars and _glowDailyBarsShape. Returns
    // [slotX, hiY, bw, barH] for the day's high/low range bar.
    private function _dailyBarRect(
        gx as Number,
        y as Number,
        gw as Number,
        gh as Number,
        i as Number,
        n as Number,
        hiV as Float,
        loV as Float,
        allMin as Float,
        range as Float,
        ghf as Float
    ) as Array<Number> {
        var bottom = y + gh;
        var slotX = gx + (i * gw) / n;
        var slotEnd = gx + ((i + 1) * gw) / n;
        var bw = slotEnd - slotX - (i < n - 1 ? 1 : 0);
        if (bw < 1) {
            bw = 1;
        }
        var hiY =
            bottom - Math.round(((hiV - allMin) * ghf) / range).toNumber();
        var loY =
            bottom - Math.round(((loV - allMin) * ghf) / range).toNumber();
        if (hiY < y) {
            hiY = y;
        }
        if (loY > bottom) {
            loY = bottom;
        }
        var barH = loY - hiY + 1;
        if (barH < 1) {
            barH = 1;
        }
        return [slotX, hiY, bw, barH] as Array<Number>;
    }

    private function _drawDailyBars(
        dc as Dc,
        gx as Number,
        y as Number,
        gw as Number,
        gh as Number,
        n as Number,
        highsArr as Array<Float>,
        lowsArr as Array<Float>,
        allMin as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float
    ) as Void {
        var ghf = gh.toFloat();
        for (var si = 1; si < n; si++) {
            _drawDashedV(
                dc,
                gx + (si * gw) / n - 1,
                y,
                y + gh,
                Graphics.COLOR_WHITE,
                DASH_ALPHA
            );
        }
        for (var i = 0; i < n; i++) {
            if (highsArr[i] == null || lowsArr[i] == null) {
                continue;
            }
            var loV = lowsArr[i] as Float;
            var hiV = highsArr[i] as Float;
            var r = _dailyBarRect(
                gx,
                y,
                gw,
                gh,
                i,
                n,
                hiV,
                loV,
                allMin,
                range,
                ghf
            );
            var midV = (hiV + loV) / 2.0;
            var frac = _fracClamp(midV, gradMinV, gradRange);
            _glowRect(
                dc,
                r[0],
                r[1],
                r[2],
                r[3],
                ColorUtils.gradColor(colorIdx, frac)
            );
        }
    }

    // One glow shape per day-bar, matching _drawDailyBars' rects via
    // _dailyBarRect, drawn live at the row's real screen position (the
    // crisp render below is suppressed the same way sensor/dual graphs are).
    private function _glowDailyBarsShape(
        dc as Dc,
        gx as Number,
        y as Number,
        gw as Number,
        gh as Number,
        n as Number,
        highsArr as Array<Float>,
        lowsArr as Array<Float>,
        allMin as Float,
        range as Float,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float
    ) as Void {
        var hdc = _activeHaloDc();
        if (hdc == null) {
            return;
        }
        var ghf = gh.toFloat();
        for (var i = 0; i < n; i++) {
            if (highsArr[i] == null || lowsArr[i] == null) {
                continue;
            }
            var loV = lowsArr[i] as Float;
            var hiV = highsArr[i] as Float;
            var r = _dailyBarRect(
                gx,
                y,
                gw,
                gh,
                i,
                n,
                hiV,
                loV,
                allMin,
                range,
                ghf
            );
            var midV = (hiV + loV) / 2.0;
            var frac = _fracClamp(midV, gradMinV, gradRange);
            hdc.setColor(
                _glowColor(ColorUtils.gradColor(colorIdx, frac)),
                Graphics.COLOR_TRANSPARENT
            );
            _haloFillDiagSpread(hdc, r[0], r[1], r[2], r[3]);
        }
    }

    // Renders to a cached bitmap at (0,0) origin; caller blits it at (gx, y).
    private function _renderDailyBarsToBitmap(
        cacheKey as Number,
        n as Number,
        highsArr as Array<Float>,
        lowsArr as Array<Float>,
        allMin as Float,
        range as Float,
        gw as Number,
        gh as Number,
        colorIdx as Number,
        gradMinV as Float,
        gradRange as Float
    ) as [Graphics.BufferedBitmap?, Graphics.BufferedBitmap?] {
        var pair = _bmpPairGet(_graphBmpCache, cacheKey);
        var crispRef = pair[0] as Graphics.BufferedBitmapReference?;
        var glowRef = pair[1] as Graphics.BufferedBitmapReference?;
        var crispBmp = _resolveBmpRef(crispRef);
        var rebuilt = false;
        if (crispBmp == null) {
            var created = _newClearedBitmap(gw + 1, gh + 1);
            if (created == null) {
                return [null, null];
            }
            crispRef = created[0];
            crispBmp = created[1];
            var bmpDc = crispBmp.getDc();
            _haloSuppressed = true;
            try {
                _drawDailyBars(
                    bmpDc,
                    0,
                    0,
                    gw,
                    gh,
                    n,
                    highsArr,
                    lowsArr,
                    allMin,
                    range,
                    colorIdx,
                    gradMinV,
                    gradRange
                );
            } finally {
                _haloSuppressed = false;
            }
            glowRef = null;
            rebuilt = true;
        }
        var glowBmp = _resolveBmpRef(glowRef);
        if (glowBmp == null && _glowIntensity > 0 && !_lowPower) {
            var pad = GLOW_SPREAD;
            var glowCreated = _newClearedBitmap(
                gw + 1 + pad * 2,
                gh + 1 + pad * 2
            );
            if (glowCreated != null) {
                glowRef = glowCreated[0];
                glowBmp = glowCreated[1];
                var gdc = glowBmp.getDc();
                _haloBakeDc = gdc;
                try {
                    _glowDailyBarsShape(
                        gdc,
                        pad,
                        pad,
                        gw,
                        gh,
                        n,
                        highsArr,
                        lowsArr,
                        allMin,
                        range,
                        colorIdx,
                        gradMinV,
                        gradRange
                    );
                } finally {
                    _haloBakeDc = null;
                }
                rebuilt = true;
            }
        }
        if (rebuilt) {
            _graphBmpCache.put(cacheKey, [crispRef, glowRef] as Array);
        }
        return [crispBmp, glowBmp];
    }

    private function _drawForecastDailyRow(
        dc as Dc,
        cx as Number,
        y as Number,
        days as Number,
        viewMode as Number,
        valueMode as Number,
        labelColor as Number,
        valueColor as Number,
        colorIdx as Number
    ) as Void {
        _graphX = _graphBaseX;
        var highs = _wxDailyForecastHigh;
        var lows = _wxDailyForecastLow;
        if (highs == null || lows == null) {
            _rowBuf[0] = "Day Fcst";
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }
        var highsArr = highs as Array<Float>;
        var lowsArr = lows as Array<Float>;
        var avail = highsArr.size();
        if (lowsArr.size() < avail) {
            avail = lowsArr.size();
        }
        var n = days < avail ? days : avail;
        if (n < 2) {
            _rowBuf[0] = "Day Fcst";
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }
        var allMin = 1.0e38 as Float;
        var allMax = -1.0e38 as Float;
        var realDays = 0;
        for (var i = 0; i < n; i++) {
            if (lowsArr[i] != null && (lowsArr[i] as Float) < allMin) {
                allMin = lowsArr[i] as Float;
            }
            if (highsArr[i] != null && (highsArr[i] as Float) > allMax) {
                allMax = highsArr[i] as Float;
            }
            if (highsArr[i] != null && lowsArr[i] != null) {
                realDays++;
            }
        }
        if (realDays < 2) {
            _rowBuf[0] = "Day Fcst";
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }
        if (allMin > allMax) {
            allMin = 0.0;
            allMax = 1.0;
        }
        var range = allMax - allMin;
        if (range < 1.0) {
            range = 1.0;
        }
        _setGraphX(FIELD_WX_FCST_TEMP, allMin, allMax);
        var gr = _calcGradRange(FIELD_WX_FCST_TEMP, colorIdx, allMin, range);
        var gradMinV = gr[0];
        var gradRange = gr[1];
        _rowBuf[0] = "Day Fcst";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var dailyCacheKey = _packGraphKey(_graphW, FIELD_WX_FCST_DAILY, n);
        var dailyBmps = _renderDailyBarsToBitmap(
            dailyCacheKey,
            n,
            highsArr,
            lowsArr,
            allMin,
            range,
            _graphW,
            _graphH,
            colorIdx,
            gradMinV,
            gradRange
        );
        var dailyBmp = dailyBmps[0] as Graphics.BufferedBitmap?;
        var cacheHit =
            dailyBmp != null &&
            _drawCachedGraphBitmap(
                dc,
                _graphX,
                y,
                dailyBmp,
                dailyCacheKey,
                _graphBmpDrawOk
            );
        if (!cacheHit) {
            _drawDailyBars(
                dc,
                _graphX,
                y,
                _graphW,
                _graphH,
                n,
                highsArr,
                lowsArr,
                allMin,
                range,
                colorIdx,
                gradMinV,
                gradRange
            );
        } else {
            var dailyGlowBmp = dailyBmps[1] as Graphics.BufferedBitmap?;
            if (dailyGlowBmp != null) {
                var dailyHdc = _activeHaloDc();
                if (dailyHdc != null) {
                    _tryDrawBitmap(
                        dailyHdc,
                        _graphX - GLOW_SPREAD,
                        y - GLOW_SPREAD,
                        dailyGlowBmp
                    );
                }
            }
        }
        _drawRowAxes(dc, y);
        var isGrad = colorIdx >= COLOR_GRAD_TRI;
        var maxFrac = _fracClamp(allMax, gradMinV, gradRange);
        var minFrac = _fracClamp(allMin, gradMinV, gradRange);
        _glowText(
            dc,
            _graphX - 4,
            y - 4,
            _fontTiny,
            _formatGraphLabel(FIELD_WX_FCST_TEMP, allMax),
            Graphics.TEXT_JUSTIFY_RIGHT,
            _graphLabelColor(colorIdx, isGrad, maxFrac)
        );
        _glowText(
            dc,
            _graphX - 4,
            y + _graphH - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(FIELD_WX_FCST_TEMP, allMin),
            Graphics.TEXT_JUSTIFY_RIGHT,
            _graphLabelColor(colorIdx, isGrad, minFrac)
        );
        var todayDow = 0;
        if (_clockInfo != null) {
            todayDow =
                ((_clockInfo as Gregorian.Info).day_of_week as Number) - 1;
        }
        for (var di = 0; di < n; di++) {
            var dowColor =
                (todayDow + di) % 7 == _firstDow
                    ? ColorUtils.colorFromIdx(5)
                    : GRAYS[3];
            var slotX = _graphX + (di * _graphW) / n;
            var slotEnd = _graphX + ((di + 1) * _graphW) / n;
            var bw = slotEnd - slotX - (di < n - 1 ? 1 : 0);
            _glowText(
                dc,
                slotX + bw / 2,
                y + _graphH + 1,
                _fontTiny,
                DAY_NAMES_SHORT[(todayDow + di) % 7],
                Graphics.TEXT_JUSTIFY_CENTER,
                dowColor
            );
        }
        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = _graphX + _graphW + _charW;
            var vy = y + (_fh - _smallFh) / 2 - 1;
            var valColor = ColorUtils.colorFromIdx(valueColor);
            if (valueMode == 2) {
                var maxStr = _tempStr0(allMax);
                var minStr = _tempStr0(allMin);
                vx = _drawSmallTempNum(dc, vx, vy, maxStr, valColor);
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    "/",
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
                vx += dc.getTextWidthInPixels("/", _fontSmall);
                vx = _drawSmallTempNum(dc, vx, vy, minStr, valColor);
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
            } else {
                var tStr = _wxTemp;
                if (valueMode == 1) {
                    var sum = 0.0 as Float;
                    var cnt = 0;
                    for (var di = 0; di < n; di++) {
                        if (highsArr[di] != null && lowsArr[di] != null) {
                            sum +=
                                ((highsArr[di] as Float) +
                                    (lowsArr[di] as Float)) /
                                2.0;
                            cnt++;
                        }
                    }
                    var avg = cnt > 0 ? sum / cnt.toFloat() : 0.0 as Float;
                    tStr = _tempStr0(avg);
                } else if (valueMode == 3) {
                    var mid = (allMin + allMax) / 2.0;
                    tStr = _tempStr0(mid);
                }
                vx = _drawSmallTempNum(dc, vx, vy, tStr, valColor);
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
                _drawValueModeLabel(
                    dc,
                    vx + dc.getTextWidthInPixels(_wxUnit, _fontSmall),
                    y,
                    valueMode
                );
            }
        }
    }

    // Returns whether the bitmap was drawn - false means the fallback
    // already drew crisp+glow directly, so skip a separate glow restore.
    private function _drawGraphOrFallback(
        dc as Dc,
        bmp as Graphics.BufferedBitmap?,
        cacheKey as Number,
        drawOkCache as Dictionary,
        graphType as Number,
        lineColor as Number,
        data as Array<Float>,
        y as Number,
        minV as Float,
        range as Float,
        gradMinV as Float,
        gradRange as Float,
        maxGap as Number
    ) as Boolean {
        if (
            bmp == null ||
            !_drawCachedGraphBitmap(dc, _graphX, y, bmp, cacheKey, drawOkCache)
        ) {
            _drawMeanLine(
                dc,
                data,
                _graphX,
                _graphW,
                y,
                _graphH,
                minV,
                range,
                lineColor,
                gradMinV,
                gradRange
            );
            _drawOneGraph(
                dc,
                graphType,
                lineColor,
                data,
                _graphX,
                _graphW,
                y,
                _graphH,
                minV,
                range,
                gradMinV,
                gradRange,
                maxGap
            );
            return false;
        }
        return true;
    }

    // Shared by every single-series graph row: draws the crisp graph (bitmap-cached
    // or live fallback), then on a cache hit blits the graph's own cached glow bitmap
    // instead of re-walking data through _glowMeanLine/_glowOneGraph every frame.
    private function _drawGraphRowGlow(
        dc as Dc,
        bmps as [Graphics.BufferedBitmap?, Graphics.BufferedBitmap?],
        cacheKey as Number,
        drawOkCache as Dictionary,
        graphType as Number,
        lineColor as Number,
        data as Array<Float>,
        y as Number,
        minV as Float,
        range as Float,
        gradMinV as Float,
        gradRange as Float,
        maxGap as Number
    ) as Void {
        var cacheHit = _drawGraphOrFallback(
            dc,
            bmps[0] as Graphics.BufferedBitmap?,
            cacheKey,
            drawOkCache,
            graphType,
            lineColor,
            data,
            y,
            minV,
            range,
            gradMinV,
            gradRange,
            maxGap
        );
        var glowBmp = bmps[1] as Graphics.BufferedBitmap?;
        if (!cacheHit || glowBmp == null) {
            return;
        }
        var hdc = _activeHaloDc();
        if (hdc == null) {
            return;
        }
        _tryDrawBitmap(
            hdc,
            _graphX - GLOW_SPREAD,
            y - GLOW_SPREAD,
            glowBmp as Graphics.BufferedBitmap
        );
    }

    private function _drawOneGraph(
        dc as Dc,
        graphType as Number,
        colorIdx as Number,
        data as Array<Float>,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number,
        minV as Float,
        range as Float,
        gradMinV as Float,
        gradRange as Float,
        maxGap as Number
    ) as Void {
        var isGrad = colorIdx >= COLOR_GRAD_TRI;
        if (graphType == GRAPH_BAR) {
            if (isGrad) {
                _drawGradBars(
                    dc,
                    data,
                    gx,
                    gw,
                    y,
                    gh + 1,
                    minV,
                    range,
                    colorIdx,
                    gradMinV,
                    gradRange
                );
            } else {
                _drawBars(
                    dc,
                    data,
                    gx,
                    gw,
                    y,
                    gh + 1,
                    minV,
                    range,
                    ColorUtils.colorFromIdx(colorIdx)
                );
            }
        } else if (graphType == GRAPH_AREA) {
            if (isGrad) {
                _drawGradArea(
                    dc,
                    data,
                    gx,
                    gw,
                    y,
                    gh,
                    minV,
                    range,
                    colorIdx,
                    gradMinV,
                    gradRange,
                    maxGap
                );
                if (_areaShowLine) {
                    _drawGradLine(
                        dc,
                        data,
                        gx,
                        gw,
                        y,
                        gh,
                        minV,
                        range,
                        colorIdx,
                        gradMinV,
                        gradRange,
                        maxGap
                    );
                }
            } else {
                var fillColor = ColorUtils.withAlpha(
                    ColorUtils.colorFromIdx(colorIdx),
                    _areaOpacity
                );
                dc.setStroke(fillColor);
                _drawAreaLine(
                    dc,
                    data,
                    gx,
                    gw,
                    y,
                    gh,
                    minV,
                    range,
                    maxGap,
                    fillColor
                );
                if (_areaShowLine) {
                    _drawGraphLine(
                        dc,
                        data,
                        gx,
                        gw,
                        y,
                        gh,
                        minV,
                        range,
                        maxGap,
                        ColorUtils.colorFromIdx(colorIdx)
                    );
                }
            }
        } else {
            if (isGrad) {
                _drawGradLine(
                    dc,
                    data,
                    gx,
                    gw,
                    y,
                    gh,
                    minV,
                    range,
                    colorIdx,
                    gradMinV,
                    gradRange,
                    maxGap
                );
            } else {
                _drawGraphLine(
                    dc,
                    data,
                    gx,
                    gw,
                    y,
                    gh,
                    minV,
                    range,
                    maxGap,
                    ColorUtils.colorFromIdx(colorIdx)
                );
            }
        }
    }

    private function _drawGraphNoData(
        dc as Dc,
        gx as Number,
        gw as Number,
        y as Number,
        gh as Number
    ) as Void {
        _drawGraphAxes(dc, gx, gw, y);
        _glowText(
            dc,
            gx + gw / 2,
            y + gh / 2 - _tinyFh / 2 - 1,
            _fontTiny,
            "no data",
            Graphics.TEXT_JUSTIFY_CENTER,
            GRAYS[3]
        );
    }

    private function _drawGraphRow(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        periodMin as Number,
        viewMode as Number,
        labelColor as Number,
        valueColor as Number,
        lineColor as Number,
        graphType as Number,
        valueMode as Number,
        barGroupDensity as Number,
        barAgg as Number
    ) as Void {
        _graphX = _graphBaseX;
        var data = _getFieldHistory(field, periodMin);
        _getFieldParts(field);
        var valueStr = _rowBuf[1];
        if (data == null) {
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }
        var cacheKey = _packGraphKey(_graphW, field, periodMin);
        var barCount0 = 0;
        if (graphType == GRAPH_BAR) {
            barCount0 = _resolveBarCount(
                field,
                periodMin,
                _graphW,
                barGroupDensity
            );
            if (barCount0 > 0 && barCount0 < data.size()) {
                data = _groupBarDataCached(cacheKey, data, barCount0, barAgg);
            } else {
                barCount0 = 0;
            }
        }

        _calcMinMaxCached(cacheKey, data, data);
        var minV = _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }
        _setGraphX(field, minV, maxV);
        var gr = _calcGradRange(field, lineColor, minV, range);
        var gradMinV = gr[0];
        var gradRange = gr[1];
        var maxFrac = _fracClamp(maxV, gradMinV, gradRange);
        var minFrac = _fracClamp(minV, gradMinV, gradRange);

        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var maxGap = (10 * _graphW) / periodMin;
        if (maxGap < 1) {
            maxGap = 1;
        }
        var graphBmps = _renderGraphToBitmap(
            cacheKey,
            field,
            graphType,
            lineColor,
            data,
            _graphW,
            _graphH,
            minV,
            range,
            gradMinV,
            gradRange,
            maxGap
        );
        _drawGraphRowGlow(
            dc,
            graphBmps,
            cacheKey,
            _graphBmpDrawOk,
            graphType,
            lineColor,
            data,
            y,
            minV,
            range,
            gradMinV,
            gradRange,
            maxGap
        );
        _drawRowAxes(dc, y);
        var eff = _resolveEffPeriod(cacheKey, periodMin);
        var periodText = Formatters.periodLabel(eff);
        if (barCount0 > 0) {
            periodText += "/" + Formatters.barDurationLabel(eff / barCount0);
        }
        _drawSingleGraphLabels(
            dc,
            field,
            _graphX,
            _graphW,
            y,
            _graphH,
            minV,
            maxV,
            periodText,
            lineColor,
            maxFrac,
            minFrac,
            _dataAge(data, eff)
        );

        if (viewMode == VIEW_GRAPH_VALUE) {
            var valX = _graphX + _graphW + _charW;
            var valY = y + (_fh - _smallFh) / 2 - 1;
            var valStr2 = _graphValueStr(
                field,
                data as Array<Float>,
                minV,
                maxV,
                valueMode,
                valueStr
            );
            var valEndX = _drawGraphValueLabel(
                dc,
                valX,
                valY,
                field,
                valStr2,
                ColorUtils.colorFromIdx(valueColor)
            );
            _drawValueModeLabel(dc, valEndX, y, valueMode);
        }
    }

    private function _getFieldParts(field as Number) as Void {
        if (_getFitnessFieldParts(field)) {
            return;
        }
        if (_getHealthFieldParts(field)) {
            return;
        }
        if (_getScheduleFieldParts(field)) {
            return;
        }
        if (_getRaceFieldParts(field)) {
            return;
        }
        if (_getWeatherCurrentFieldParts(field)) {
            return;
        }
        if (_getWeatherForecastFieldParts(field)) {
            return;
        }
        _rowBuf[0] = "";
        _rowBuf[1] = "";
    }

    private function _getFitnessFieldParts(field as Number) as Boolean {
        if (field == FIELD_ALTITUDE) {
            _rowBuf[0] = "Altitude";
            var a = _acInfo;
            _rowBuf[1] =
                a != null && a.altitude != null
                    ? _altStr(a.altitude as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_INTENSITY_MIN) {
            _rowBuf[0] = "Intens Min";
            var info = _amInfo;
            var mins = info != null ? info.activeMinutesWeek : null;
            _rowBuf[1] =
                mins != null && mins.total != null
                    ? (mins.total as Number).toString()
                    : "0";
            return true;
        }
        if (field == FIELD_PRESSURE) {
            _rowBuf[0] = "Pressure";
            _rowBuf[1] = _cachedPressure;
            return true;
        }
        if (field == FIELD_ELEVATION) {
            _rowBuf[0] = "Elevation";
            _rowBuf[1] = _cachedElevation;
            return true;
        }
        if (field == FIELD_WEEKLY_RUN) {
            _rowBuf[0] = "Week Run";
            _rowBuf[1] =
                _compWeeklyRun != null
                    ? _distStr(_compWeeklyRun as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_WEEKLY_BIKE) {
            _rowBuf[0] = "Week Bike";
            _rowBuf[1] =
                _compWeeklyBike != null
                    ? _distStr(_compWeeklyBike as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_CLIMB_DAY) {
            _rowBuf[0] = "Climb Day";
            var info = _amInfo;
            _rowBuf[1] =
                info != null && info.metersClimbed != null
                    ? _altStr(info.metersClimbed as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_DESCENT_DAY) {
            _rowBuf[0] = "Descent Day";
            var info = _amInfo;
            _rowBuf[1] =
                info != null && info.metersDescended != null
                    ? _altStr(info.metersDescended as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_SOLAR) {
            _rowBuf[0] = "Solar Input";
            _rowBuf[1] =
                _compSolar != null
                    ? (_compSolar as Number).toString() + "%"
                    : "-";
            return true;
        }
        if (field == FIELD_WEEKLY_DISTANCES) {
            var run = "-";
            var bike = "-";
            if (_compWeeklyRun != null) {
                run = _distStr(_compWeeklyRun as Float);
            }
            if (_compWeeklyBike != null) {
                bike = _distStr(_compWeeklyBike as Float);
            }
            _rowBuf[0] = "Run+Bike";
            _rowBuf[1] = run + " | " + bike;
            return true;
        }
        if (field == FIELD_SOLAR_BATTERY) {
            var solar =
                _compSolar != null
                    ? (_compSolar as Number).toString() + "%"
                    : "-";
            _rowBuf[0] = "Solar/Bat";
            _rowBuf[1] = solar + " | " + _batText;
            return true;
        }
        return false;
    }

    private function _getHealthFieldParts(field as Number) as Boolean {
        if (field == FIELD_HR) {
            _rowBuf[0] = "Heart";
            var a = _acInfo;
            _rowBuf[1] =
                a != null && a.currentHeartRate != null
                    ? (a.currentHeartRate as Number).toString() + " bpm"
                    : "-";
            return true;
        }
        if (field == FIELD_SPO2) {
            _rowBuf[0] = "SpO2";
            var a = _acInfo;
            _rowBuf[1] =
                a != null && a.currentOxygenSaturation != null
                    ? (a.currentOxygenSaturation as Number).format("%.0f") + "%"
                    : "-";
            return true;
        }
        if (field == FIELD_STRESS) {
            _rowBuf[0] = "Stress";
            _rowBuf[1] = _cachedStress;
            return true;
        }
        if (field == FIELD_BODY_BAT) {
            _rowBuf[0] = "Body Bat";
            _rowBuf[1] = _cachedBodyBat;
            return true;
        }
        if (field == FIELD_RESP) {
            _rowBuf[0] = "Resp Rate";
            var info = _amInfo;
            _rowBuf[1] =
                info != null && info.respirationRate != null
                    ? (info.respirationRate as Number).toString() + "/m"
                    : "-";
            return true;
        }
        if (field == FIELD_RECOVERY) {
            _rowBuf[0] = "Recovery";
            var info = _amInfo;
            _rowBuf[1] =
                info != null && info.timeToRecovery != null
                    ? (info.timeToRecovery as Number).toString() + "h"
                    : "-";
            return true;
        }
        if (field == FIELD_WRIST_TEMP) {
            _rowBuf[0] = "Wrist Temp";
            _rowBuf[1] = _cachedTempWrist;
            return true;
        }
        if (field == FIELD_SLEEP) {
            _rowBuf[0] = "Sleep";
            _rowBuf[1] =
                _compSleepScore != null
                    ? (_compSleepScore as Number).toString()
                    : "-";
            return true;
        }
        if (field == FIELD_VO2_MAX) {
            _rowBuf[0] = "VO2 Max";
            _rowBuf[1] = _cachedVo2Max;
            return true;
        }
        if (field == FIELD_TRAINING_STATUS) {
            _rowBuf[0] = "Training";
            _rowBuf[1] =
                _compTrainingStatus != null
                    ? Formatters.trainingStatusStr(
                          _compTrainingStatus as String
                      )
                    : "-";
            return true;
        }
        if (field == FIELD_HR_SPO2) {
            var hr = "-";
            var spo2 = "-";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.currentHeartRate != null) {
                    hr = (a.currentHeartRate as Number).toString() + " bpm";
                }
                if (a.currentOxygenSaturation != null) {
                    spo2 =
                        (a.currentOxygenSaturation as Number).format("%.0f") +
                        "%";
                }
            }
            _rowBuf[0] = "HR+SpO2";
            _rowBuf[1] = hr + " | " + spo2;
            return true;
        }
        if (field == FIELD_BODY_BAT_STRESS) {
            _rowBuf[0] = "Body+Stress";
            _rowBuf[1] = _cachedBodyBat + " | " + _cachedStress;
            return true;
        }
        if (field == FIELD_BODY_BAT_RECOVERY) {
            var rec = "-";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.timeToRecovery != null) {
                    rec = (info.timeToRecovery as Number).toString() + "h";
                }
            }
            _rowBuf[0] = "Body+Recov";
            _rowBuf[1] = _cachedBodyBat + " | " + rec;
            return true;
        }
        if (field == FIELD_STRESS_RECOVERY) {
            var rec = "-";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.timeToRecovery != null) {
                    rec = (info.timeToRecovery as Number).toString() + "h";
                }
            }
            _rowBuf[0] = "Stress+Rec";
            _rowBuf[1] = _cachedStress + " | " + rec;
            return true;
        }
        if (field == FIELD_RESP_SPO2) {
            var resp = "-";
            var spo2 = "-";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.respirationRate != null) {
                    resp = (info.respirationRate as Number).toString() + "/m";
                }
            }
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.currentOxygenSaturation != null) {
                    spo2 =
                        (a.currentOxygenSaturation as Number).format("%.0f") +
                        "%";
                }
            }
            _rowBuf[0] = "Resp+SpO2";
            _rowBuf[1] = resp + " | " + spo2;
            return true;
        }
        if (field == FIELD_VO2_TRAINING) {
            _rowBuf[0] = "VO2+Train";
            _rowBuf[1] =
                _cachedVo2Max +
                " " +
                (_compTrainingStatus != null
                    ? Formatters.trainingStatusStr(
                          _compTrainingStatus as String
                      )
                    : "-");
            return true;
        }
        if (field == FIELD_HR_RESTING_BOTH) {
            _rowBuf[0] = "HR Rest/Avg";
            _rowBuf[1] = _cachedRestingHR + " | " + _cachedAvgRestingHR;
            return true;
        }
        if (field == FIELD_BODY_BAT_REST_HR) {
            _rowBuf[0] = "Bat+RestHR";
            _rowBuf[1] = _cachedBodyBat + " | " + _cachedRestingHR;
            return true;
        }
        if (field == FIELD_SLEEP_RECOVERY) {
            var sleep =
                _compSleepScore != null
                    ? (_compSleepScore as Number).toString()
                    : "-";
            var rec = "-";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.timeToRecovery != null) {
                    rec = (info.timeToRecovery as Number).toString() + "h";
                }
            }
            _rowBuf[0] = "Sleep+Rec";
            _rowBuf[1] = sleep + " | " + rec;
            return true;
        }
        if (field == FIELD_HR_RESTING) {
            _rowBuf[0] = "HR Rest";
            _rowBuf[1] = _cachedRestingHR;
            return true;
        }
        if (field == FIELD_HR_RESTING_AVG) {
            _rowBuf[0] = "HR RestAvg";
            _rowBuf[1] = _cachedAvgRestingHR;
            return true;
        }
        return false;
    }

    private function _getScheduleFieldParts(field as Number) as Boolean {
        if (field == FIELD_SUNRISE) {
            _rowBuf[0] = "Sunrise";
            _rowBuf[1] =
                _compSunrise != null
                    ? Formatters.secsToTime(_compSunrise as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_SUNSET) {
            _rowBuf[0] = "Sunset";
            _rowBuf[1] =
                _compSunset != null
                    ? Formatters.secsToTime(_compSunset as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_SUNRISE_SUNSET) {
            var rise =
                _compSunrise != null
                    ? Formatters.secsToTime(_compSunrise as Number)
                    : "-";
            var set =
                _compSunset != null
                    ? Formatters.secsToTime(_compSunset as Number)
                    : "-";
            _rowBuf[0] = "Sunrise+Set";
            _rowBuf[1] = rise + " / " + set;
            return true;
        }
        if (field == FIELD_CALENDAR) {
            _rowBuf[0] = "Calendar";
            _rowBuf[1] = _compCalendar != null ? _compCalendar as String : "-";
            return true;
        }
        if (field == FIELD_SLEEP_TIME) {
            _rowBuf[0] = "Bedtime";
            _rowBuf[1] = _cachedSleepTime;
            return true;
        }
        if (field == FIELD_WAKE_TIME) {
            _rowBuf[0] = "Wake Time";
            _rowBuf[1] = _cachedWakeTime;
            return true;
        }
        if (field == FIELD_SLEEP_SCHEDULE) {
            _rowBuf[0] = "Sleep Sched";
            _rowBuf[1] = _cachedSleepTime + " | " + _cachedWakeTime;
            return true;
        }
        if (field == FIELD_NOTIFICATIONS) {
            _rowBuf[0] = "Notifs";
            _rowBuf[1] =
                _compNotifications != null
                    ? (_compNotifications as Number).toString()
                    : "-";
            return true;
        }
        return false;
    }

    private function _getRaceFieldParts(field as Number) as Boolean {
        if (field == FIELD_RACE_5K) {
            _rowBuf[0] = "Race 5K";
            _rowBuf[1] =
                _compRace5k != null
                    ? Formatters.secsToRace(_compRace5k as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_10K) {
            _rowBuf[0] = "Race 10K";
            _rowBuf[1] =
                _compRace10k != null
                    ? Formatters.secsToRace(_compRace10k as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_HALF) {
            _rowBuf[0] = "Race Half";
            _rowBuf[1] =
                _compRaceHalf != null
                    ? Formatters.secsToRace(_compRaceHalf as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_MARATHON) {
            _rowBuf[0] = "Race Mar";
            _rowBuf[1] =
                _compRaceMarathon != null
                    ? Formatters.secsToRace(_compRaceMarathon as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_PACE_5K) {
            _rowBuf[0] = "5k Pace";
            _rowBuf[1] =
                _compRacePace5k != null
                    ? _formatPace(_compRacePace5k as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_PACE_10K) {
            _rowBuf[0] = "10k Pace";
            _rowBuf[1] =
                _compRacePace10k != null
                    ? _formatPace(_compRacePace10k as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_PACE_HALF) {
            _rowBuf[0] = "Half Pace";
            _rowBuf[1] =
                _compRacePaceHalf != null
                    ? _formatPace(_compRacePaceHalf as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_PACE_MARATHON) {
            _rowBuf[0] = "Mar Pace";
            _rowBuf[1] =
                _compRacePaceMarathon != null
                    ? _formatPace(_compRacePaceMarathon as Float)
                    : "-";
            return true;
        }
        return false;
    }

    private function _getWeatherCurrentFieldParts(field as Number) as Boolean {
        if (field == FIELD_WX_PRECIP) {
            _rowBuf[0] = "Rain %";
            _rowBuf[1] = _wxPrecip;
            return true;
        }
        if (field == FIELD_WX_WIND) {
            _rowBuf[0] = "Wind Speed";
            _rowBuf[1] = _wxWind;
            return true;
        }
        if (field == FIELD_WX_UV) {
            _rowBuf[0] = "UV Index";
            _rowBuf[1] = _wxUv;
            return true;
        }
        if (field == FIELD_WX_COND) {
            _rowBuf[0] = "Weather";
            _rowBuf[1] = _wxCond;
            return true;
        }
        if (field == FIELD_WX_COND_PRECIP) {
            _rowBuf[0] = "Cond+Rain";
            _rowBuf[1] = _wxCond + " | " + _wxPrecip;
            return true;
        }
        if (field == FIELD_WX_WIND_PRECIP) {
            _rowBuf[0] = "Rain+Wind";
            _rowBuf[1] = _wxPrecip + " | " + _wxWind;
            return true;
        }
        if (field == FIELD_WX_TEMP) {
            _rowBuf[0] = "Temp";
            _rowBuf[1] = _wxTemp + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_FEELS) {
            _rowBuf[0] = "Feels Like";
            _rowBuf[1] = _wxFeels + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_TEMP_COND) {
            _rowBuf[0] = "Temp+Cond";
            _rowBuf[1] = _wxTemp + _wxUnit + " | " + _wxCond;
            return true;
        }
        if (field == FIELD_WX_TEMP_WIND) {
            _rowBuf[0] = "Temp+Wind";
            _rowBuf[1] = _wxTemp + _wxUnit + " | " + _wxWind;
            return true;
        }
        if (field == FIELD_WX_TEMP_UV) {
            _rowBuf[0] = "Temp+UV";
            _rowBuf[1] = _wxTemp + _wxUnit + " | " + _wxUv;
            return true;
        }
        if (field == FIELD_WX_UV_PRECIP) {
            _rowBuf[0] = "UV+Rain";
            _rowBuf[1] = _wxUv + " | " + _wxPrecip;
            return true;
        }
        if (field == FIELD_WX_UV_WIND) {
            _rowBuf[0] = "UV+Wind";
            _rowBuf[1] = _wxUv + " | " + _wxWind;
            return true;
        }
        if (field == FIELD_WX_HUMIDITY) {
            _rowBuf[0] = "Humidity";
            _rowBuf[1] = _wxHumidity;
            return true;
        }
        if (field == FIELD_WX_DEW_POINT) {
            _rowBuf[0] = "Dew Point";
            _rowBuf[1] = _wxDewPoint + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_VISIBILITY) {
            _rowBuf[0] = "Visibility";
            _rowBuf[1] = _wxVisibility;
            return true;
        }
        if (field == FIELD_WX_CLOUD) {
            _rowBuf[0] = "Cloud Cover";
            _rowBuf[1] = _wxCloudCover;
            return true;
        }
        if (field == FIELD_WX_HEAT_INDEX) {
            _rowBuf[0] = "Heat Index";
            _rowBuf[1] = _wxHeatIndex + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_HUMIDITY_PRECIP) {
            _rowBuf[0] = "Rain+Hum";
            _rowBuf[1] = _wxPrecip + " | " + _wxHumidity;
            return true;
        }
        if (field == FIELD_WX_CLOUD_PRECIP) {
            _rowBuf[0] = "Rain+Cloud";
            _rowBuf[1] = _wxPrecip + " | " + _wxCloudCover;
            return true;
        }
        if (field == FIELD_WX_COND_CLOUD) {
            _rowBuf[0] = "Cond+Cloud";
            _rowBuf[1] = _wxCond + " | " + _wxCloudCover;
            return true;
        }
        if (field == FIELD_WX_SEA_PRESS) {
            _rowBuf[0] = "Sea Press";
            _rowBuf[1] =
                _compSeaLevelPressure != null
                    ? ((_compSeaLevelPressure as Float) / 100.0).format(
                          "%.1f"
                      ) + " hPa"
                    : "-";
            return true;
        }
        if (field == FIELD_WX_OBS_TIME) {
            _rowBuf[0] = "WX Age";
            _rowBuf[1] = _wxObsAge;
            return true;
        }
        return false;
    }

    // FIELD_WX_FCST_TEMP/PRECIP/DAILY/WIND/HUMIDITY/UV/CLOUD are handled entirely by
    // _drawLineRowWeatherForecast (every view mode) - they never reach this function.
    private function _getWeatherForecastFieldParts(field as Number) as Boolean {
        if (field == FIELD_WX_COND_FCST_1D) {
            _rowBuf[0] = "Cond/+1d";
            _rowBuf[1] =
                _wxCond +
                " | " +
                (_compFcstCond1d != null
                    ? Formatters.condStr(_compFcstCond1d as Number)
                    : "-");
            return true;
        }
        if (field == FIELD_WX_FCST_COND_12D) {
            var d1 =
                _compFcstCond1d != null
                    ? Formatters.condStr(_compFcstCond1d as Number)
                    : "-";
            var d2 =
                _compFcstCond2d != null
                    ? Formatters.condStr(_compFcstCond2d as Number)
                    : "-";
            _rowBuf[0] = "+1d/+2d";
            _rowBuf[1] = d1 + " | " + d2;
            return true;
        }
        if (field == FIELD_WX_FCST_COND_1D) {
            _rowBuf[0] = "Fcst +1d";
            _rowBuf[1] =
                _compFcstCond1d != null
                    ? Formatters.condStr(_compFcstCond1d as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_WX_FCST_COND_2D) {
            _rowBuf[0] = "Fcst +2d";
            _rowBuf[1] =
                _compFcstCond2d != null
                    ? Formatters.condStr(_compFcstCond2d as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_WX_FCST_COND_3D) {
            _rowBuf[0] = "Fcst +3d";
            _rowBuf[1] =
                _compFcstCond3d != null
                    ? Formatters.condStr(_compFcstCond3d as Number)
                    : "-";
            return true;
        }
        return false;
    }
    private function _getTimeParts(dc as Dc) as Array<String> {
        var t = System.getClockTime();
        if (t.min != _cachedTimeMin) {
            _cachedTimeMin = t.min;
            if (!_is24Hour) {
                var h = t.hour % 12;
                if (h == 0) {
                    h = 12;
                }
                _cachedTimeStr = h.toString() + ":" + t.min.format("%02d");
            } else {
                _cachedTimeStr =
                    t.hour.format("%02d") + ":" + t.min.format("%02d");
            }
            _cachedTimeStrW = dc.getTextWidthInPixels(_cachedTimeStr, _font);
        }
        var ampm = !_is24Hour ? (t.hour >= 12 ? "pm" : "am") : "";
        _timeBuf[1] =
            _cachedTimeStr +
            (_showSeconds ? ":" + t.sec.format("%02d") : "") +
            ampm;
        return _timeBuf;
    }

    private function _getDateParts() as Array<String> {
        if (_clockInfo == null) {
            return _dateBuf;
        }
        var info = _clockInfo as Gregorian.Info;
        var day = info.day as Number;
        if (day != _lastDateDay) {
            _lastDateDay = day;
            // Stubs type these Number-or-String; FORMAT_SHORT always returns Number.
            var month = info.month as Number;
            var year = info.year as Number;
            var dow = info.day_of_week as Number;
            var fmt = _dateFormat;
            var value = "" as String;
            if (fmt == 1) {
                value =
                    year.format("%04d") +
                    "-" +
                    month.format("%02d") +
                    "-" +
                    day.format("%02d");
            } else if (fmt == 2) {
                value =
                    day.format("%02d") +
                    "-" +
                    month.format("%02d") +
                    "-" +
                    year.format("%04d");
            } else if (fmt == 3) {
                value =
                    month.format("%02d") +
                    "-" +
                    day.format("%02d") +
                    "-" +
                    year.format("%04d");
            } else {
                var yr = _showYear ? " " + year.toString() : "";
                if (fmt == 4) {
                    value = DAY_NAMES[dow - 1] + " " + day.format("%02d") + yr;
                } else if (fmt == 5) {
                    value =
                        day.format("%02d") + " " + MONTH_NAMES[month - 1] + yr;
                } else {
                    value =
                        DAY_NAMES[dow - 1] +
                        ", " +
                        day +
                        " " +
                        MONTH_NAMES[month - 1] +
                        yr;
                }
            }
            _dateBuf[1] = value;
        }
        return _dateBuf;
    }

    private function _fieldNeeded(f as Number) as Boolean {
        for (var i = 0; i < 3; i++) {
            if (_resolvedFields[i] == f) {
                return true;
            }
            if (
                _lineSecType[i] != SEC_NONE &&
                (_lineViewMode[i] == VIEW_GRAPH ||
                    _lineViewMode[i] == VIEW_GRAPH_VALUE) &&
                GRAPH_SEC_FIELDS[_lineSecField[i]] == f
            ) {
                return true;
            }
        }
        return false;
    }

    // Same stale-first-sample class _readIter's badAgeStreak guards against, for single lookups.
    private function _firstFreshSample(
        iter as SensorHistory.SensorHistoryIterator,
        field as Number
    ) as SensorHistory.SensorSample? {
        var s = iter.next();
        var tries = 0;
        while (s != null && !_sampleFresh(s, field) && tries < 4) {
            s = iter.next();
            tries++;
        }
        return s;
    }

    private function _refreshPointSamples() as Void {
        if (
            _fieldNeeded(FIELD_BODY_BAT) ||
            _fieldNeeded(FIELD_BODY_BAT_STRESS) ||
            _fieldNeeded(FIELD_BODY_BAT_RECOVERY) ||
            _fieldNeeded(FIELD_BODY_BAT_REST_HR)
        ) {
            var sample = _firstFreshSample(
                SensorHistory.getBodyBatteryHistory({}),
                FIELD_BODY_BAT
            );
            if (_sampleFresh(sample, FIELD_BODY_BAT)) {
                var d = sample.data;
                _cachedBodyBat =
                    (d instanceof Float
                        ? (d as Float).format("%.0f")
                        : (d as Number).toString()) + "%";
            } else {
                _cachedBodyBat = "-";
            }
        }
        if (_fieldNeeded(FIELD_WRIST_TEMP)) {
            var sample = _firstFreshSample(
                SensorHistory.getTemperatureHistory({}),
                FIELD_WRIST_TEMP
            );
            if (_sampleFresh(sample, FIELD_WRIST_TEMP)) {
                var td = sample.data;
                var tempC = _numToFloat(td as Numeric);
                _cachedTempWrist = _tempStr(tempC);
            } else {
                _cachedTempWrist = "-";
            }
        }
        if (_fieldNeeded(FIELD_PRESSURE)) {
            var pIter = SensorHistory.getPressureHistory({
                :period => new Time.Duration(30 * SECS_PER_MIN),
            });
            var s1 = _firstFreshSample(pIter, FIELD_PRESSURE);
            if (_sampleFresh(s1, FIELD_PRESSURE)) {
                var pd = s1.data;
                var pa = _numToFloat(pd as Numeric);
                _cachedPressure = _metric
                    ? (pa / 100.0).format("%.1f") + "hPa"
                    : (pa / PA_PER_INHG).format("%.2f") + "inHg";
                // The trend scan below can walk up to 30 min of samples; skip it on the wake
                // frame and keep the last-known trend so it can't delay the screen turning on.
                if (_deferThisFrame) {
                    _deferredWorkPending = true;
                } else {
                    var oldest = s1;
                    var ps = pIter.next();
                    var deadline = System.getTimer() + 100;
                    while (ps != null && System.getTimer() < deadline) {
                        if (ps.data != null) {
                            oldest = ps;
                        }
                        ps = pIter.next();
                    }
                    if (oldest != s1 && oldest.data != null) {
                        var od = oldest.data;
                        var opa = _numToFloat(od as Numeric);
                        _cachedPressureTrend =
                            pa - opa > 100.0 ? 1 : pa - opa < -100.0 ? -1 : 0;
                    }
                }
            } else {
                _cachedPressure = "-";
                _cachedPressureTrend = 0;
            }
        }
        if (_fieldNeeded(FIELD_ELEVATION)) {
            var sample = _firstFreshSample(
                SensorHistory.getElevationHistory({}),
                FIELD_ELEVATION
            );
            if (_sampleFresh(sample, FIELD_ELEVATION)) {
                var ed = sample.data;
                var elev = _numToFloat(ed as Numeric);
                _cachedElevation = _altStr(elev);
            } else {
                _cachedElevation = "-";
            }
        }
        if (
            _fieldNeeded(FIELD_STRESS) ||
            _fieldNeeded(FIELD_BODY_BAT_STRESS) ||
            _fieldNeeded(FIELD_STRESS_RECOVERY)
        ) {
            var amRef = _amInfo;
            if (
                amRef != null &&
                (amRef as ActivityMonitor.Info).stressScore != null
            ) {
                _cachedStress = (
                    (amRef as ActivityMonitor.Info).stressScore as Number
                ).toString();
            } else {
                var ss = _firstFreshSample(
                    SensorHistory.getStressHistory({
                        :period => new Time.Duration(10 * SECS_PER_MIN),
                    }),
                    FIELD_STRESS
                );
                if (_sampleFresh(ss, FIELD_STRESS)) {
                    var sd = ss.data;
                    _cachedStress =
                        sd instanceof Float
                            ? (sd as Float).format("%.0f")
                            : (sd as Number).toString();
                } else {
                    _cachedStress = "-";
                }
            }
        }
    }

    (:extendedCode)
    private function _refreshWeather(nowMin as Number) as Void {
        if (nowMin == _wxLastMin) {
            return;
        }
        if (!_needsWeatherCurrent) {
            _wxLastMin = nowMin;
            return;
        }
        if (_deferThisFrame && _wxCurrentFetched) {
            // Same one-frame defer as complications - reuse stale weather data on the
            // wake frame and let the follow-up requestUpdate() do the real refresh.
            _deferredWorkPending = true;
            return;
        }
        _wxLastMin = nowMin;
        _wxCurrentFetched = true;
        var c = Weather.getCurrentConditions();
        if (c == null) {
            return;
        }
        _wxHumidityNum = -1;
        var metric = _metric;
        if (c.temperature != null) {
            var t = c.temperature;
            _wxTemp = _tempStr(_numToFloat(t as Numeric));
        }
        if (c.feelsLikeTemperature != null) {
            var fl = c.feelsLikeTemperature;
            _wxFeels = _tempStr(_numToFloat(fl as Numeric));
        }
        if (c.lowTemperature != null) {
            var lo = c.lowTemperature;
            _wxLow = _tempStr0(_numToFloat(lo as Numeric));
        }
        if (c.highTemperature != null) {
            var hi = c.highTemperature;
            _wxHigh = _tempStr0(_numToFloat(hi as Numeric));
        }
        if (c.precipitationChance != null) {
            _wxPrecip = (c.precipitationChance as Number).toString() + "%";
        }
        if (c.windSpeed != null) {
            var ws = c.windSpeed;
            var spd = _numToFloat(ws as Numeric);
            _wxWind = metric
                ? (spd * KMH_PER_MPS).format("%.0f") + "km/h"
                : (spd * MPH_PER_MPS).format("%.0f") + "mph";
            if (c.windBearing != null) {
                var dirIdx = (((c.windBearing as Number) + 22) / 45) % 8;
                if (dirIdx < 0) {
                    dirIdx += 8;
                }
                _wxWind += " " + WIND_DIRS[dirIdx];
            }
        }
        if (c.uvIndex != null) {
            var uv = c.uvIndex;
            _wxUvNum = Math.round(_numToFloat(uv as Numeric)).toNumber();
            _wxUv = _wxUvNum.toString() + _uvTag();
        }
        if (c.condition != null) {
            _wxCond = Formatters.condStr(c.condition as Number);
        }
        if (c.relativeHumidity != null) {
            _wxHumidityNum = c.relativeHumidity as Number;
            _wxHumidity = _wxHumidityNum.toString() + "%";
        }
        if (c.dewPoint != null) {
            var dp = c.dewPoint;
            _wxDewPoint = _tempStr(_numToFloat(dp as Numeric));
        }
        if (c.visibility != null) {
            var vs = c.visibility;
            var vis = _numToFloat(vs as Numeric);
            _wxVisibility = metric
                ? (vis / 1000.0).format("%.1f") + "km"
                : (vis / METERS_PER_MILE).format("%.1f") + "mi";
        }
        if (c.cloudCover != null) {
            _wxCloudCover = (c.cloudCover as Number).toString() + "%";
        }
        if (c has :observationTime && c.observationTime != null) {
            var ageS =
                Time.now().value() - (c.observationTime as Time.Moment).value();
            if (ageS < 0) {
                ageS = 0;
            }
            _wxObsAge = Formatters.formatAge(ageS);
        } else {
            _wxObsAge = "-";
        }
        if (c.temperature != null && _wxHumidityNum >= 0) {
            var ht = c.temperature;
            _wxHeatIndex = _calcHeatIndex(
                _numToFloat(ht as Numeric),
                _wxHumidityNum
            );
        }
        if (_needsForecast) {
            // Mark attempted even if the APIs return null so the phase-change
            // force-refresh in onUpdate fires at most once per need transition.
            _forecastFetched = true;
            var forecast = Weather.getHourlyForecast();
            if (forecast != null && forecast.size() > 0) {
                var cnt = forecast.size() < 24 ? forecast.size() : 24;
                var arr = new Array<Float>[cnt];
                var precipArr = new Array<Float>[cnt];
                var windArr = new Array<Float>[cnt];
                var humArr = new Array<Float>[cnt];
                var uvArr = new Array<Float>[cnt];
                var cloudArr = new Array<Float>[cnt];
                for (var i = 0; i < cnt; i++) {
                    var h = forecast[i];
                    if (h.temperature != null) {
                        var ht2 = h.temperature;
                        arr[i] = _numToFloat(ht2 as Numeric);
                    }
                    if (h.precipitationChance != null) {
                        precipArr[i] = (
                            h.precipitationChance as Number
                        ).toFloat();
                    }
                    if (h.windSpeed != null) {
                        var hws = h.windSpeed;
                        windArr[i] = _numToFloat(hws as Numeric);
                    }
                    if (h.relativeHumidity != null) {
                        humArr[i] = (h.relativeHumidity as Number).toFloat();
                    }
                    if (h.uvIndex != null) {
                        var huv = h.uvIndex;
                        uvArr[i] = _numToFloat(huv as Numeric);
                    }
                    if (h.cloudCover != null) {
                        cloudArr[i] = (h.cloudCover as Number).toFloat();
                    }
                }
                _wxForecastData = arr;
                _wxForecastPrecipData = precipArr;
                _wxForecastWindData = windArr;
                _wxForecastHumidityData = humArr;
                _wxForecastUvData = uvArr;
                _wxForecastCloudData = cloudArr;
                _invalidateFieldGraphCache(FIELD_WX_FCST_TEMP);
                _invalidateFieldGraphCache(FIELD_WX_FCST_PRECIP);
                _invalidateFieldGraphCache(FIELD_WX_FCST_WIND);
                _invalidateFieldGraphCache(FIELD_WX_FCST_HUMIDITY);
                _invalidateFieldGraphCache(FIELD_WX_FCST_UV);
                _invalidateFieldGraphCache(FIELD_WX_FCST_CLOUD);
            }
            var daily = Weather.getDailyForecast();
            if (daily != null && daily.size() >= 2) {
                var dcnt = daily.size() < 7 ? daily.size() : 7;
                var dhigh = new Array<Float>[dcnt];
                var dlow = new Array<Float>[dcnt];
                for (var i = 0; i < dcnt; i++) {
                    var dfc = daily[i];
                    if (dfc.highTemperature != null) {
                        var dh = dfc.highTemperature;
                        dhigh[i] = _numToFloat(dh as Numeric);
                    }
                    if (dfc.lowTemperature != null) {
                        var dl = dfc.lowTemperature;
                        dlow[i] = _numToFloat(dl as Numeric);
                    }
                }
                _wxDailyForecastHigh = dhigh;
                _wxDailyForecastLow = dlow;
                _invalidateFieldGraphCache(FIELD_WX_FCST_DAILY);
            }
        }
    }

    private function _formatPace(speedMps as Float) as String {
        if (speedMps <= MIN_SPEED_MPS) {
            return "-";
        }
        var secPerDist = _metric
            ? 1000.0 / speedMps
            : METERS_PER_MILE / speedMps;
        var totalSec = Math.round(secPerDist).toNumber();
        return (
            (totalSec / SECS_PER_MIN).format("%d") +
            ":" +
            (totalSec % SECS_PER_MIN).format("%02d") +
            (_metric ? "/km" : "/mi")
        );
    }

    private function _calcHeatIndex(
        tempC as Float,
        humidity as Number
    ) as String {
        var T = Formatters.celsiusToF(tempC);
        var RH = humidity.toFloat();
        if (T < 80.0 || RH < 40.0) {
            return _tempStr(tempC);
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
        return _metric
            ? (((HI - 32.0) * 5.0) / 9.0).format("%.1f")
            : HI.format("%.1f");
    }

    private function _phaseFromElapsed(elapsedSec as Number) as Number {
        var mainSec = _rotateMainMs / 1000;
        var altSec = _rotateAltMs / 1000;
        var cycle = mainSec + _rotateMaxPhase * altSec;
        var pos = elapsedSec % cycle;
        if (pos < 0) {
            pos += cycle;
        }
        if (pos < mainSec) {
            return 0;
        }
        pos -= mainSec;
        return pos / altSec + 1;
    }

    private function _getPhase(nowSec as Number) as Number {
        if (_rotationMode == ROTATION_MANUAL) {
            return _manualPhase > _rotateMaxPhase
                ? _rotateMaxPhase
                : _manualPhase;
        }
        if (_phaseAnchorSec < 0) {
            _phaseAnchorSec = nowSec;
        }
        return _phaseFromElapsed(nowSec - _phaseAnchorSec);
    }

    // Sets the anchor so _phaseFromElapsed evaluates to `target` with zero elapsed in its window.
    private function _jumpToPhase(target as Number, nowSec as Number) as Void {
        if (target <= 0) {
            _phaseAnchorSec = nowSec;
            return;
        }
        var mainSec = _rotateMainMs / 1000;
        var altSec = _rotateAltMs / 1000;
        _phaseAnchorSec = nowSec - (mainSec + (target - 1) * altSec);
    }

    // Called by the delegate's long-press.
    public function advanceRotation() as Boolean {
        if (_rotationMode == ROTATION_AUTOMATIC) {
            return false;
        }
        var nowSec = Time.now().value();
        if (_rotationMode == ROTATION_MANUAL) {
            _manualPhase =
                _manualPhase >= _rotateMaxPhase ? 0 : _manualPhase + 1;
        } else {
            var cur = _getPhase(nowSec);
            var next = cur >= _rotateMaxPhase ? 0 : cur + 1;
            _jumpToPhase(next, nowSec);
        }
        WatchUi.requestUpdate();
        return true;
    }

    private function _getProp(key as String, defaultVal as Number) as Number {
        try {
            var val = Properties.getValue(key);
            if (val instanceof Number) {
                return val as Number;
            }
        } catch (e instanceof Lang.Exception) {}
        return defaultVal;
    }

    private function _getBoolProp(
        key as String,
        defaultVal as Boolean
    ) as Boolean {
        try {
            var val = Properties.getValue(key);
            if (val instanceof Boolean) {
                return val as Boolean;
            }
        } catch (e instanceof Lang.Exception) {}
        return defaultVal;
    }

    // Redraws only the seconds digits and cursor blink, via their own clips,
    // instead of repainting the whole screen every second.
    public function onPartialUpdate(dc as Dc) as Void {
        var now = System.getTimer();
        var phase = _getPhase(Time.now().value());
        if (phase != _lastPhase) {
            _lastPhase = phase;
            WatchUi.requestUpdate();
            return;
        }

        if (_showSeconds) {
            _drawSecondsPartial(dc);
        }

        var cursorOn = (now / 1000) % 2 == 0;
        if (cursorOn == _cursorOn) {
            return;
        }
        _cursorOn = cursorOn;
        dc.setClip(_cursorX, _cursorY, _cursorCharW, _cursorFh);
        if (_cursorOn) {
            var hdc = _haloDcIfDrawable();
            if (hdc != null) {
                hdc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                hdc.fillRectangle(
                    _cursorX,
                    _cursorY,
                    _cursorCharW + GLOW_SPREAD,
                    _cursorFh + GLOW_SPREAD
                );
                hdc.setColor(
                    _glowColor(ColorUtils.colorFromIdx(0)),
                    Graphics.COLOR_TRANSPARENT
                );
                _haloFillDiagSpread(
                    hdc,
                    _cursorX,
                    _cursorY,
                    _cursorCharW,
                    _cursorFh
                );
                _compositeHalo(dc);
            }
            dc.setColor(ColorUtils.colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(_cursorX, _cursorY, _cursorCharW, _cursorFh);
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.fillRectangle(_cursorX, _cursorY, _cursorCharW, _cursorFh);
            if (_scanlineIntensity > 0 && _scanlineIntensity < 4) {
                dc.setStroke(
                    (_flickerAlpha(
                        SCANLINE_ALPHA[_scanlineIntensity],
                        System.getClockTime().sec,
                        FLICKER_MAGNITUDE
                    ) <<
                        24) |
                        0xffffff
                );
                var sy = (_cursorY / SCANLINE_SPACING) * SCANLINE_SPACING;
                while (sy < _cursorY + _cursorFh) {
                    dc.drawLine(_cursorX, sy, _cursorX + _cursorCharW - 1, sy);
                    sy += SCANLINE_SPACING;
                }
            }
        }
        dc.clearClip();
    }

    // Redraws just the ":SS" portion of the time row value in its own clip
    // region instead of forcing a full-screen redraw every second.
    private function _drawSecondsPartial(dc as Dc) as Void {
        var sec = System.getClockTime().sec;
        var secStr = _secStrs[sec];
        if (secStr == null) {
            secStr = ":" + sec.format("%02d");
            _secStrs[sec] = secStr;
        }
        var x = _timeValueX + _cachedTimeStrW;
        var w = _charW * 3;
        dc.setClip(x, _timeValueY, w, _fh);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(x, _timeValueY, w, _fh);
        if (_scanlineIntensity > 0 && _scanlineIntensity < 4) {
            dc.setStroke(
                (_flickerAlpha(
                    SCANLINE_ALPHA[_scanlineIntensity],
                    sec,
                    FLICKER_MAGNITUDE
                ) <<
                    24) |
                    0xffffff
            );
            var sy = (_timeValueY / SCANLINE_SPACING) * SCANLINE_SPACING;
            while (sy < _timeValueY + _fh) {
                dc.drawLine(x, sy, x + w - 1, sy);
                sy += SCANLINE_SPACING;
            }
        }
        // Full-frame halo composite only happens in onUpdate, so redraw just this clip here too.
        var hdc = _haloDcIfDrawable();
        if (hdc != null) {
            hdc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            hdc.fillRectangle(
                x,
                _timeValueY,
                w + GLOW_SPREAD,
                _fh + GLOW_SPREAD
            );
            hdc.setColor(
                _glowColor(ColorUtils.colorFromIdx(_line1ValueC)),
                Graphics.COLOR_TRANSPARENT
            );
            hdc.drawText(
                x + GLOW_SPREAD,
                _timeValueY + GLOW_SPREAD,
                _font,
                secStr,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            _compositeHalo(dc);
        }
        dc.setColor(
            ColorUtils.colorFromIdx(_line1ValueC),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(x, _timeValueY, _font, secStr, Graphics.TEXT_JUSTIFY_LEFT);
        dc.clearClip();
    }

    public function onEnterSleep() as Void {
        _lastPhase = -1;
        _lowPower = true;
        var s = System.getDeviceSettings();
        _alwaysOn = s has :alwaysOnEnabled && s.alwaysOnEnabled;
        if (_alwaysOn) {
            WatchUi.requestUpdate();
        }
    }
    public function onExitSleep() as Void {
        _lowPower = false;
        _justWoke = true;
        _manualPhase = 0;
        _jumpToPhase(0, Time.now().value());
        WatchUi.requestUpdate();
    }
}
