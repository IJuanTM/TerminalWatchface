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
import Toybox.Position;

const APP_VERSION = "0.45.4";

// FIELD_* constants live in generated source/FieldIds.mc - never hand-edit that file.

const VIEW_VALUE = 0;
const VIEW_GRAPH = 1;
const VIEW_GRAPH_VALUE = 2;

const GRAPH_LINE = 0;
const GRAPH_BAR = 1;
const GRAPH_AREA = 2;

const SEC_NONE = 0;
const SEC_LINE = 1;
const SEC_BAR = 2;

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

const ROTATE_SLOT_NAMES =
    ["Secondary", "Tertiary", "Quaternary", "Quinary", "Senary"] as
    Array<String>;

// Property key prefix per screen index (0-2), selected by the activeScreen
// property and cycled on-device via a long-press (TerminalWatchfaceDelegate).
const SCREEN_PREFIXES = ["screen1_", "screen2_", "screen3_"] as Array<String>;

// Indices into this array are used as the SecondaryField property value
const GRAPH_SEC_FIELDS =
    [
        FIELD_HR,
        FIELD_BODY_BAT,
        FIELD_STRESS,
        FIELD_SPO2,
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
// Black overlay alpha per intensity (0=off, 1=subtle, 2=medium, 3=strong).
const SCANLINE_ALPHA = [0, 15, 30, 45] as Array<Number>;
// CRT flicker: max brightness swing, and odds any given second flickers at all.
const FLICKER_MAGNITUDE = 10;
const FLICKER_CHANCE_PCT = 20;
// Max vertical shift (px) on a wash flicker tick, and padding above/below to cover it.
const BG_WASH_SHIFT_MAX = 20;
const BG_WASH_PAD = 22;
// Side vignette gray mask: darkest at true edge/mid-height, fades to none.
const VIGNETTE_REACH = 0.34;
const VIGNETTE_Y_LIMIT = 1.0;
const VIGNETTE_MIN_GRAY = 180;
const VIGNETTE_ROW_BAND = 10;
const VIGNETTE_COL_STEPS = 24;

// Exponential falloff width for the backlight glow - smaller = tighter peak.
const BG_WASH_SIGMA = 0.26;
// Gray level multiplied over the bright gradient (BLEND_MODE_MULTIPLY) to dim it.
const BG_WASH_DIM_LEVEL = [0, 20, 50, 80] as Array<Number>;

// Halo blend fraction toward a shape's own color, per bgGradient level (0=off).
const GLOW_FRACTION = [0.0, 0.08, 0.14, 0.2] as Array<Float>;

// 0=shadow, 1=bar bg, 2=dashed lines/separators, 3=mean line/no-data/axes
const GRAYS =
    [
        0x111111, // 0  shadow
        0x333333, // 1  bar background
        0x555555, // 2  dashed lines, text separators
        0x777777, // 3  mean line, no-data text, graph axes
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

const ARROW_PAD = 2;

const FEET_PER_METER = 3.28084;
const METERS_PER_MILE = 1609.344;
const PA_PER_INHG = 3386.39;
const KMH_PER_MPS = 3.6;
const MPH_PER_MPS = 2.23694;

const MIN_SPEED_MPS = 0.05;

const SECS_PER_HOUR = 3600;
const SECS_PER_MIN = 60;

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
    private var _graphCache as Dictionary = {};
    private var _graphCacheTimes as Dictionary = {};
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
    private var _notifLastMs as Number = -5000;
    private var _compSleepScore as Number? = null;
    private var _compSunrise as Number? = null;
    private var _compSunset as Number? = null;
    private var _compCalendar as String? = null;
    private var _compWeeklyRun as Number? = null;
    private var _compWeeklyBike as Number? = null;
    private var _posInfo as Position.Info? = null;
    private var _compTrainingStatus as String? = null;
    private var _compRace5k as Number? = null;
    private var _compRace10k as Number? = null;
    private var _compRaceHalf as Number? = null;
    private var _compRaceMarathon as Number? = null;
    private var _graphBmpCache as Dictionary = {};
    private var _graphBmpDualCache as Dictionary = {};
    // Offscreen surface every halo is drawn onto, then additively composited.
    private var _haloBmp as Graphics.BufferedBitmap? = null;
    // Null until first drawBitmap attempt; caches whether it worked.
    private var _haloDrawOk as Boolean? = null;
    private var _bgWashBmp as Graphics.BufferedBitmap? = null;
    private var _bgWashDrawOk as Boolean? = null;
    private var _bgWashDimBmp as Graphics.BufferedBitmap? = null;
    private var _bgWashDimDrawOk as Boolean? = null;
    private var _vignetteBmp as Graphics.BufferedBitmap? = null;
    private var _vignetteDrawOk as Boolean? = null;
    private var _is24Hour as Boolean = true;
    private var _showSeconds as Boolean = false;
    private var _lowPower as Boolean = false;
    private var _wakeFlicker as Boolean = true;
    private var _leftPad as Number = 4;
    private var _areaOpacity as Number = 64;
    private var _areaShowLine as Boolean = true;
    private var _scanlineIntensity as Number = 2;
    private var _bgGradient as Number = 2;
    private var _bgWash as Number = 2;
    private var _flickerEnabled as Boolean = true;
    private var _rotateMainMs as Number = 5000;
    private var _rotateAltMs as Number = 5000;
    private var _rotateMaxPhase as Number = 5;
    private var _activeScreen as Number = 0;
    private var _showScreenBadge as Boolean = true;
    private var _screenMasterEnabled as Boolean = true;
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
    private var _charging as Boolean = false;
    private var _batLow as Boolean = false;
    private var _showBatteryDays as Boolean = true;
    private var _resolvedPhase as Number = -1;
    private var _resolvedFields as Array<Number> = [7, 7, 7] as Array<Number>;
    private var _needsLiveActivity as Boolean = true;
    private var _needsGps as Boolean = false;
    private var _needsForecast as Boolean = true;
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
    private var _lineSecType as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineSecField as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineSecColor as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _dataMin as Float = 0.0;
    private var _dataMax as Float = 0.0;
    private var _nowUnixMin as Number = 0;
    private var _gradMin as Float = 0.0;
    private var _gradRange as Float = 1.0;
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
        _posInfo = Position.getInfo();
        reloadFont();
        _readActiveScreen();
        _computeRotateMaxPhase();
    }

    // Pre-renders here so first-frame cost doesn't share onUpdate's budget.
    public function onLayout(dc as Dc) as Void {
        _renderBgWashBitmap();
        _renderVignetteBitmap();
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
                    _compWeeklyRun = v as Number;
                } else if (
                    t == Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE
                ) {
                    _compWeeklyBike = v as Number;
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
    }

    public function invalidateSettings() as Void {
        _resolvedPhase = -1;
        _graphCacheMin = -1;
        _graphCache = {};
        _graphCacheTimes = {};
        _graphEffPeriod = {};
        _graphBmpCache = {};
        _graphBmpDualCache = {};
        _lastDateDay = -1;
        _cachedTimeMin = -1;
        _forecastFetched = false;
        _wxCurrentFetched = false;
        _readActiveScreen();
        _computeRotateMaxPhase();
    }

    private function _readActiveScreen() as Void {
        var p = _getProp("activeScreen", 0);
        _activeScreen = p < 0 || p > 2 ? 0 : p;
        _screenMasterEnabled =
            _activeScreen == 0
                ? true
                : _getBoolProp(
                      "screen" + (_activeScreen + 1).toString() + "Enabled"
                  );

        // If screens 2 and 3 are both master-disabled, showing "[SCREEN 1]" on
        // the default screen is just clutter since there's nothing to switch to.
        var screen2Off = !_getBoolProp("screen2Enabled");
        var screen3Off = !_getBoolProp("screen3Enabled");
        _showScreenBadge = !(_activeScreen == 0 && screen2Off && screen3Off);
    }

    private function _computeRotateMaxPhase() as Void {
        var ri = _getProp("rotateInterval", 10);
        if (ri < 1) {
            ri = 1;
        }
        _rotateMainMs = ri * 1000;
        var ra = _getProp("rotateIntervalAlt", 5);
        _rotateAltMs = ra > 0 ? ra * 1000 : _rotateMainMs;
        _rotateMaxPhase = 0;
        if (!_screenMasterEnabled) {
            return;
        }
        var pk = SCREEN_PREFIXES[_activeScreen];
        var e3 = _getBoolProp(pk + "line3Enabled");
        var e4 = _getBoolProp(pk + "line4Enabled");
        var e5 = _getBoolProp(pk + "line5Enabled");
        for (var p = 4; p >= 0; p--) {
            var sn = ROTATE_SLOT_NAMES[p];
            if (
                (e3 && _getProp(pk + "line3" + sn, FIELD_NONE) != FIELD_NONE) ||
                (e4 && _getProp(pk + "line4" + sn, FIELD_NONE) != FIELD_NONE) ||
                (e5 && _getProp(pk + "line5" + sn, FIELD_NONE) != FIELD_NONE)
            ) {
                _rotateMaxPhase = p + 1;
                break;
            }
        }
    }

    (:extendedCode)
    public function reloadFont() as Void {
        var choice = _getProp("fontChoice", 0);
        if (choice < 0 || choice > 3) {
            choice = 0;
        }
        if (choice == _lastFontChoice) {
            return;
        }
        _lastFontChoice = choice;

        var normalRes = [
            $.Rez.Fonts.JetBrainsMono_NORMAL,
            $.Rez.Fonts.SpaceMono_NORMAL,
            $.Rez.Fonts.FiraCode_NORMAL,
            $.Rez.Fonts.NBArchitekt_NORMAL,
        ];
        var smallRes = [
            $.Rez.Fonts.JetBrainsMono_SMALL,
            $.Rez.Fonts.SpaceMono_SMALL,
            $.Rez.Fonts.FiraCode_SMALL,
            $.Rez.Fonts.NBArchitekt_SMALL,
        ];
        var tinyRes = [
            $.Rez.Fonts.JetBrainsMono_TINY,
            $.Rez.Fonts.SpaceMono_TINY,
            $.Rez.Fonts.FiraCode_TINY,
            $.Rez.Fonts.NBArchitekt_TINY,
        ];
        try {
            _font =
                WatchUi.loadResource(normalRes[choice]) as
                Graphics.FontDefinition;
        } catch (e instanceof Lang.Exception) {}
        try {
            _fontSmall =
                WatchUi.loadResource(smallRes[choice]) as
                Graphics.FontDefinition;
        } catch (e instanceof Lang.Exception) {}
        try {
            _fontTiny =
                WatchUi.loadResource(tinyRes[choice]) as
                Graphics.FontDefinition;
        } catch (e instanceof Lang.Exception) {}

        // choice 1 = SpaceMono (lineHeight 30); all others use lineHeight 28
        var newSizeSet = choice == 1 ? 1 : 0;
        if (newSizeSet != _fontVariant) {
            _fontVariant = newSizeSet;
            _graphBmpCache = {};
            _graphBmpDualCache = {};
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
        var now = System.getTimer();
        if (now - _notifLastMs >= 5000) {
            _notifLastMs = now;
            var ds = System.getDeviceSettings();
            var nc = ds.notificationCount;
            var newCount = nc != null ? nc as Number : 0;
            if (newCount != _notifCount) {
                _notifCount = newCount;
                _notifLabel = "[" + newCount.toString() + " UNREAD]";
            }
            _phoneConnected = ds.phoneConnected;
            _dndOn = ds.doNotDisturb;
        }
        var nowMoment = Time.now();
        var phase = _getPhase(nowMoment.value());
        _cursorOn = (now / 1000) % 2 == 0;
        _nowUnixMin = nowMoment.value() / SECS_PER_MIN;
        var clockInfo =
            Gregorian.info(nowMoment, Time.FORMAT_SHORT) as Gregorian.Info;
        _clockInfo = clockInfo;
        var nowMin = clockInfo.min as Number;
        if (phase != _resolvedPhase) {
            _resolvedPhase = phase;
            _resolveAllLines(phase);
            var needsAct = false;
            var needsGps = false;
            var needsForecast = false;
            var needsWxCurrent = false;
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
                    f == FIELD_GPS_LAT ||
                    f == FIELD_GPS_LON ||
                    f == FIELD_GPS_ACCURACY ||
                    f == FIELD_HEADING ||
                    f == FIELD_GPS_LAT_LON ||
                    f == FIELD_GPS_LAT_LON_ACC
                ) {
                    needsGps = true;
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
                    f == FIELD_WX_OBS_TIME ||
                    f == FIELD_WX_COND_FCST_1D
                ) {
                    needsWxCurrent = true;
                }
                if (_lineSecType[i] != SEC_NONE) {
                    var sf = GRAPH_SEC_FIELDS[_lineSecField[i]] as Number;
                    if (sf == FIELD_HR || sf == FIELD_SPO2) {
                        needsAct = true;
                    }
                }
            }
            _needsLiveActivity = needsAct;
            _needsGps = needsGps;
            _needsForecast = needsForecast;
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
        if (_needsLiveActivity) {
            _acInfo = Activity.getActivityInfo();
        }
        if (_needsGps) {
            _posInfo = Position.getInfo();
        }
        if (nowMin != _graphCacheMin) {
            _graphCacheMin = nowMin;
            // Not cleared here: _cacheResult() invalidates only the specific key that refreshed.
            var settings = System.getDeviceSettings();
            _metric = settings.distanceUnits == System.UNIT_METRIC;
            _is24Hour = settings.is24Hour;
            _showSeconds = _getBoolProp("showSeconds");
            _leftPad = _getProp("leftPadding", 4);
            _areaOpacity = _getProp("areaOpacity", 64);
            _areaShowLine = _getBoolProp("areaShowLine");
            _showBatteryDays = _getBoolProp("showBatteryDays");
            _scanlineIntensity = _getProp("scanlines", 2);
            _bgGradient = _getProp("bgGradient", 2);
            if (_bgGradient < 0 || _bgGradient > 3) {
                _bgGradient = 2;
            }
            _bgWash = _getProp("bgWash", 2);
            if (_bgWash < 0 || _bgWash > 3) {
                _bgWash = 2;
            }
            _flickerEnabled = _getBoolProp("flickerEnabled");
            _wxUnit = _metric ? "C" : "F";
            _amInfo = ActivityMonitor.getInfo();
            _refreshComplications();
            _refreshPointSamples();
            var showVer = _getBoolProp("showVersion");
            var cmdStyle = _getProp("watchCommandStyle", 2);
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
            _line1LabelC = _getProp("line1LabelColor", 8);
            _line1ValueC = _getProp("line1ValueColor", 0);
            _line2LabelC = _getProp("line2LabelColor", 8);
            _line2ValueC = _getProp("line2ValueColor", 0);
            var fmt = _getProp("dateFormat", 0);
            var sy = _getBoolProp("showYear");
            if (fmt != _dateFormat || sy != _showYear) {
                _dateFormat = fmt;
                _showYear = sy;
                _lastDateDay = -1;
            }
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
            if (profile has :hrZones) {
                _hrZones = profile.hrZones as Array<Number>?;
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
        }
        _refreshWeather(nowMin);

        if (_wakeFlicker) {
            _wakeFlicker = false;
            dc.setColor(0x224422, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        }
        dc.clear();

        if (!_lowPower && _bgWash > 0 && _bgWash < 4) {
            _drawBgWash(dc);
        }

        if (!_lowPower && _scanlineIntensity > 0 && _scanlineIntensity < 4) {
            _drawScanlines(dc, SCANLINE_ALPHA[_scanlineIntensity]);
        }

        if (!_lowPower) {
            _drawVignette(dc);
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

        // Lines 3/4/5 always occupy their row slot (blank when the resolved
        // field is FIELD_NONE) so the layout never shifts based on content.
        var y = (_screenH - step * 6 - _fh) / 2;
        var row = 0;

        _drawHeader(dc, y);

        // Always-on: same layout math, but only time/date values plus header/footer, no scanlines (AMOLED pixel budget).
        if (_lowPower) {
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
            _drawScreenBadge(dc, y + step * 6 + _fh + 32 + _smallFh + 2);
            return;
        }

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
        _drawScreenBadge(dc, footerY + _fh + 32 + _smallFh + 2);

        if (_haloActive()) {
            _compositeHalo(dc);
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
            _drawIconShape(hdc, x, y + 1, iconType);
            _drawIconShape(hdc, x + 1, y, iconType);
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
            var spaced = " " + batText;
            var spacedW = dc.getTextWidthInPixels(spaced, _fontSmall);
            var startX = (_screenW - _bmpBoltW - spacedW - _batDaysW) / 2;
            _drawIcon(dc, startX, y + (_smallFh - _boltH) / 2, ICON_BOLT, 3);
            _glowText(
                dc,
                startX + _bmpBoltW,
                y,
                _fontSmall,
                spaced,
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.colorFromIdx(0)
            );
            if (hasDays) {
                _glowText(
                    dc,
                    startX + _bmpBoltW + spacedW,
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

    private function _drawScreenBadge(dc as Dc, y as Number) as Void {
        if (!_showScreenBadge) {
            return;
        }
        var label = "[" + (_activeScreen + 1).toString() + "]";
        var labelW = dc.getTextWidthInPixels(label, _fontTiny);
        var x = _screenW / 2 - labelW / 2;

        // C/M/Y per screen so the active screen is distinguishable at a glance.
        var labelColor = ColorUtils.colorFromIdx(
            _activeScreen == 0 ? 2 : _activeScreen == 1 ? 7 : 3
        );
        _glowText(
            dc,
            x,
            y,
            _fontTiny,
            label,
            Graphics.TEXT_JUSTIFY_LEFT,
            labelColor
        );
    }

    private function _drawBgWash(dc as Dc) as Void {
        if (_bgWashBmp == null) {
            _renderBgWashBitmap();
        }
        if (_bgWashBmp != null) {
            var bmp = _bgWashBmp as Graphics.BufferedBitmap;
            var shift = _flickerShift(
                System.getClockTime().sec + 500,
                BG_WASH_SHIFT_MAX
            );
            var y = shift - BG_WASH_PAD;
            if (_bgWashDrawOk == null) {
                _bgWashDrawOk = _tryDrawBitmap(dc, 0, y, bmp);
            } else if (_bgWashDrawOk as Boolean) {
                dc.drawBitmap(0, y, bmp);
            }
        }
        if (_bgWashDimBmp == null) {
            _bgWashDimBmp = _createBitmap(_screenW, _screenH);
        }
        if (_bgWashDimBmp != null) {
            var dimBmp = _bgWashDimBmp as Graphics.BufferedBitmap;
            var gray = _flickerAlpha(
                BG_WASH_DIM_LEVEL[_bgWash],
                System.getClockTime().sec + 500,
                FLICKER_MAGNITUDE
            );
            var dimBdc = dimBmp.getDc();
            dimBdc.setColor(
                (gray << 16) | (gray << 8) | gray,
                Graphics.COLOR_TRANSPARENT
            );
            dimBdc.fillRectangle(0, 0, _screenW, _screenH);
            dc.setBlendMode(Graphics.BLEND_MODE_MULTIPLY);
            if (_bgWashDimDrawOk == null) {
                _bgWashDimDrawOk = _tryDrawBitmap(dc, 0, 0, dimBmp);
            } else if (_bgWashDimDrawOk as Boolean) {
                dc.drawBitmap(0, 0, dimBmp);
            }
            dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
        }
    }

    private function _drawVignette(dc as Dc) as Void {
        if (_vignetteBmp == null) {
            _renderVignetteBitmap();
        }
        if (_vignetteBmp == null) {
            return;
        }
        var bmp = _vignetteBmp as Graphics.BufferedBitmap;
        dc.setBlendMode(Graphics.BLEND_MODE_MULTIPLY);
        if (_vignetteDrawOk == null) {
            _vignetteDrawOk = _tryDrawBitmap(dc, 0, 0, bmp);
        } else if (_vignetteDrawOk as Boolean) {
            dc.drawBitmap(0, 0, bmp);
        }
        dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
    }

    private function _renderVignetteBitmap() as Void {
        var bmp = _createBitmap(_screenW, _screenH);
        if (bmp == null) {
            return;
        }
        _vignetteBmp = bmp;
        var bdc = bmp.getDc();
        bdc.setColor(0xffffff, Graphics.COLOR_TRANSPARENT);
        bdc.fillRectangle(0, 0, _screenW, _screenH);

        var cx = _screenW / 2;
        var cy = _screenH / 2;
        var maxR = (_screenW / 2).toFloat();
        var reachPx = maxR * VIGNETTE_REACH;

        var y = 0;
        while (y < _screenH) {
            var dy = (y + VIGNETTE_ROW_BAND / 2 - cy).toFloat();
            var yFrac = dy.abs() / maxR;
            if (yFrac < VIGNETTE_Y_LIMIT) {
                var t = yFrac / VIGNETTE_Y_LIMIT;
                var vFactor = Math.sqrt(1.0 - t * t);
                var reach = reachPx * vFactor;
                // Anchor to the round display's actual boundary, not the square bitmap's edge.
                var halfW = Math.sqrt(maxR * maxR - dy * dy);
                var bandH = VIGNETTE_ROW_BAND;
                if (y + bandH > _screenH) {
                    bandH = _screenH - y;
                }
                var seg = 0;
                while (seg < VIGNETTE_COL_STEPS) {
                    var hFrac = (seg + 0.5) / VIGNETTE_COL_STEPS;
                    // Ease-out falloff (squared) so the fade tapers to nothing
                    // near the inner edge instead of cutting off abruptly.
                    var falloff = 1.0 - hFrac;
                    falloff *= falloff;
                    var gray = (
                        255 -
                        (255 - VIGNETTE_MIN_GRAY) * vFactor * falloff
                    ).toNumber();
                    bdc.setColor(
                        (gray << 16) | (gray << 8) | gray,
                        Graphics.COLOR_TRANSPARENT
                    );
                    var off0 = (reach * seg) / VIGNETTE_COL_STEPS;
                    var off1 = (reach * (seg + 1)) / VIGNETTE_COL_STEPS;
                    var segX0 = (cx - halfW + off0).toNumber();
                    var segX1 = (cx - halfW + off1).toNumber();
                    var segW = segX1 - segX0;
                    if (segW < 1) {
                        segW = 1;
                    }
                    bdc.fillRectangle(segX0, y, segW, bandH);
                    var rSegX1 = (cx + halfW - off0).toNumber();
                    var rSegX0 = (cx + halfW - off1).toNumber();
                    var rSegW = rSegX1 - rSegX0;
                    if (rSegW < 1) {
                        rSegW = 1;
                    }
                    bdc.fillRectangle(rSegX0, y, rSegW, bandH);
                    seg += 1;
                }
            }
            y += VIGNETTE_ROW_BAND;
        }
    }

    // Full bright range, taller than the screen so a flicker shift has room.
    private function _renderBgWashBitmap() as Void {
        var bmpH = _screenH + BG_WASH_PAD * 2;
        var bmp = _createBitmap(_screenW, bmpH);
        if (bmp == null) {
            return;
        }
        _bgWashBmp = bmp;
        var bdc = bmp.getDc();
        var hue = COLORS[1];
        var cr = ((hue >> 16) & 0xff).toFloat() / 255.0;
        var cg = ((hue >> 8) & 0xff).toFloat() / 255.0;
        var cb = (hue & 0xff).toFloat() / 255.0;
        var by = 0;
        while (by < bmpH) {
            var pos = (by - BG_WASH_PAD + 0.5) / _screenH.toFloat();
            var brightness = _washFraction(pos) * 255.0;
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

    private function _washFraction(pos as Float) as Float {
        var d = (pos - 0.5).abs();
        var exponent = -d / BG_WASH_SIGMA;
        return Math.pow(2.718281828459045, exponent).toFloat();
    }

    private function _drawScanlines(dc as Dc, alpha as Number) as Void {
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
        if (_bgGradient == 0 || _lowPower) {
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
        return _haloActive() ? _haloDc() : null;
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

    // Wipes the halo surface to black before this redraw's halos are drawn.
    private function _clearHalo() as Void {
        var hdc = _haloDc();
        hdc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        hdc.clear();
    }

    // Composites the halo surface onto dc additively so it brightens rather than replaces.
    private function _compositeHalo(dc as Dc) as Void {
        var bmp = _haloBmp as Graphics.BufferedBitmap;
        dc.setBlendMode(Graphics.BLEND_MODE_ADDITIVE);
        if (_haloDrawOk == null) {
            _haloDrawOk = _tryDrawBitmap(dc, 0, 0, bmp);
        } else if (_haloDrawOk as Boolean) {
            dc.drawBitmap(0, 0, bmp);
        }
        dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
    }

    // Blends a color toward black by the current halo fraction.
    private function _glowColor(color as Number) as Number {
        var f = GLOW_FRACTION[_bgGradient];
        var r = (((color >> 16) & 0xff) * f).toNumber();
        var g = (((color >> 8) & 0xff) * f).toNumber();
        var b = ((color & 0xff) * f).toNumber();
        return (r << 16) | (g << 8) | b;
    }

    // Soft 1px halo behind text before the crisp glyphs on top.
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
            hdc.setColor(_glowColor(color), Graphics.COLOR_TRANSPARENT);
            hdc.drawText(x, y + 1, font, text, justify);
            hdc.drawText(x + 1, y, font, text, justify);
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justify);
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
            hdc.drawLine(x1, y1 + 1, x2, y2 + 1);
            hdc.drawLine(x1 + 1, y1, x2 + 1, y2);
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1, y1, x2, y2);
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
            hdc.fillRectangle(x, y + 1, w, h);
            hdc.fillRectangle(x + 1, y, w, h);
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, w, h);
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
            hdc.drawCircle(x, y + 1, r);
            hdc.drawCircle(x + 1, y, r);
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
        _resolveOneLine(0, "line3", phase);
        _resolveOneLine(1, "line4", phase);
        _resolveOneLine(2, "line5", phase);
        _resolveLineGraph(0);
        _resolveLineGraph(1);
        _resolveLineGraph(2);
    }

    private function _resolveOneLine(
        li as Number,
        key as String,
        phase as Number
    ) as Void {
        // Label/value colors are per line (shared across rotation slots); only the field rotates.
        var pk = SCREEN_PREFIXES[_activeScreen] + key;
        var f = FIELD_NONE;
        if (_screenMasterEnabled && _getBoolProp(pk + "Enabled")) {
            if (phase >= 1 && phase <= 5) {
                f = _getProp(pk + ROTATE_SLOT_NAMES[phase - 1], FIELD_NONE);
            }
            if (f == FIELD_NONE) {
                f = _getProp(pk + "Primary", FIELD_NONE);
            }
        }
        _resolvedFields[li] = f;
        _resolvedLabelC[li] = _getProp(pk + "LabelColor", 8);
        _resolvedValueC[li] = _getProp(pk + "ValueColor", 0);
    }

    // Decodes a merged graph mode (1=line,2=bar,3=line+current,4=bar+current,
    // 5=area,6=area+current) into view mode and graph type.
    private function _resolveForecastGraph(
        li as Number,
        key as String,
        colorDefault as Number,
        valueDefault as Number
    ) as Void {
        var mode = _getProp(key + "GraphMode", 4);
        _lineViewMode[li] =
            mode == 3 || mode == 4 || mode == 6 ? VIEW_GRAPH_VALUE : VIEW_GRAPH;
        _lineGraphType[li] =
            mode == 2 || mode == 4
                ? GRAPH_BAR
                : mode == 5 || mode == 6
                  ? GRAPH_AREA
                  : GRAPH_LINE;
        _lineValueMode[li] = _getProp(key + "ValueMode", valueDefault);
        _lineGraphColor[li] = _getProp(key + "GraphColor", colorDefault);
        _linePeriodMin[li] = _getProp(key + "TimeFrame", 12);
        _lineGraphWidth[li] = _getProp(key + "GraphWidth", 10);
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
            var showBar = _getBoolProp("stepsShowBar");
            var showVal = _getBoolProp("stepsShowBarValue");
            _lineViewMode[li] = showBar ? (showVal ? 2 : 1) : 0;
            _lineGraphColor[li] = _getProp("stepsBarColor", 1);
            _lineGraphWidth[li] = _getProp("stepsBarWidth", 10);
            return;
        }
        if (field == FIELD_FLOORS) {
            var showBar = _getBoolProp("floorsShowBar");
            var showVal = _getBoolProp("floorsShowBarValue");
            _lineViewMode[li] = showBar ? (showVal ? 2 : 1) : 0;
            _lineGraphColor[li] = _getProp("floorsBarColor", 5);
            _lineGraphWidth[li] = _getProp("floorsBarWidth", 8);
            return;
        }
        if (field == FIELD_INTENSITY_MIN) {
            var showBar = _getBoolProp("intensityMinShowBar");
            var showVal = _getBoolProp("intensityMinShowBarValue");
            _lineViewMode[li] = showBar ? (showVal ? 2 : 1) : 0;
            _lineGraphColor[li] = _getProp("intensityMinBarColor", 5);
            _lineGraphWidth[li] = _getProp("intensityMinBarWidth", 8);
            return;
        }
        if (field == FIELD_WX_FCST_TEMP) {
            _resolveForecastGraph(li, "wxForecast", 16, 0);
            return;
        }
        if (field == FIELD_WX_FCST_PRECIP) {
            _resolveForecastGraph(li, "wxForecastPrecip", 6, 1);
            return;
        }
        if (field == FIELD_WX_FCST_DAILY) {
            _lineViewMode[li] = _getProp(
                "wxForecastDailyViewMode",
                VIEW_GRAPH_VALUE
            );
            _lineValueMode[li] = _getProp("wxForecastDailyValueMode", 2);
            _lineGraphColor[li] = _getProp("wxForecastDailyGraphColor", 16);
            _linePeriodMin[li] = _getProp("wxForecastDailyDays", 5);
            _lineGraphWidth[li] = _getProp("wxForecastDailyGraphWidth", 8);
            return;
        }
        if (field == FIELD_WX_FCST_WIND) {
            _resolveForecastGraph(li, "wxForecastWind", 6, 1);
            return;
        }
        if (field == FIELD_WX_FCST_HUMIDITY) {
            _resolveForecastGraph(li, "wxForecastHumidity", 2, 1);
            return;
        }
        if (field == FIELD_WX_FCST_UV) {
            _resolveForecastGraph(li, "wxForecastUv", 3, 2);
            return;
        }
        if (field == FIELD_WX_FCST_CLOUD) {
            _resolveForecastGraph(li, "wxForecastCloud", 8, 1);
            return;
        }
        var gk = _fieldGraphKey(field);
        if (gk == null) {
            return;
        }
        var mode = _getProp(gk + "GraphMode", 0);
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
        _linePeriodMin[li] = _getProp(gk + "TimeFrame", 60);
        _lineGraphColor[li] = _getProp(
            gk + "GraphColor",
            field == FIELD_HR ? 5 : 0
        );
        _lineSecType[li] = _getProp(gk + "SecondaryType", SEC_NONE);
        _lineValueMode[li] = _getProp(gk + "GraphValueMode", 0);
        var vm = _lineViewMode[li];
        if (
            _lineSecType[li] != SEC_NONE &&
            (vm == VIEW_GRAPH || vm == VIEW_GRAPH_VALUE)
        ) {
            var sidx = _getProp(gk + "SecondaryField", 0);
            if (sidx < 0 || sidx >= GRAPH_SEC_FIELDS.size()) {
                sidx = 0;
            }
            _lineSecField[li] = sidx;
            _lineSecColor[li] = _getProp(gk + "SecondaryColor", 0);
        }
        _lineGraphWidth[li] = _getProp(gk + "GraphWidth", 10);
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
        if (_drawLineRowNav(dc, cx, y, field, labelColor, valueColor, li)) {
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
                if (_amInfo == null) {
                    return true;
                }
                var info = _amInfo as ActivityMonitor.Info;
                var steps = info.steps != null ? info.steps as Number : 0;
                var goal =
                    info.stepGoal != null ? info.stepGoal as Number : 10000;
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

    private function _drawLineRowNav(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        labelColor as Number,
        valueColor as Number,
        li as Number
    ) as Boolean {
        if (field == FIELD_HEADING) {
            _getFieldParts(field);
            var valStr = _rowBuf[1];
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var x = cx + _splitPad;
            _glowText(
                dc,
                x,
                y,
                _font,
                valStr,
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.colorFromIdx(valueColor)
            );
            if (!valStr.equals("-")) {
                x += dc.getTextWidthInPixels(valStr, _font);
                _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valueColor);
            }
            return true;
        }
        if (field == FIELD_GPS_ACCURACY) {
            _getFieldParts(field);
            var val = _rowBuf[1];
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var pos = _posInfo;
            _glowText(
                dc,
                cx + _splitPad,
                y,
                _font,
                val,
                Graphics.TEXT_JUSTIFY_LEFT,
                pos != null
                    ? ColorUtils.gpsQualityColor(pos.accuracy)
                    : 0xffffff
            );
            return true;
        }
        if (field == FIELD_GPS_LAT_LON_ACC) {
            _getFieldParts(field);
            var full = _rowBuf[1];
            var sepIdx = full.find(" [");
            if (sepIdx != null) {
                var coords = full.substring(0, sepIdx) as String;
                _rowBuf[1] = coords;
                _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
                var pos = _posInfo;
                var vx =
                    cx + _splitPad + dc.getTextWidthInPixels(coords, _font);
                _glowText(
                    dc,
                    vx,
                    y,
                    _font,
                    full.substring(sepIdx, full.length()) as String,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    pos != null
                        ? ColorUtils.gpsQualityColor(pos.accuracy)
                        : 0xffffff
                );
            } else {
                _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            }
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
                        _lineValueMode[li]
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
                        _lineValueMode[li]
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
        if (_amInfo == null) {
            return;
        }
        var info = _amInfo as ActivityMonitor.Info;
        var goal = info.stepGoal != null ? info.stepGoal as Number : 0;
        if (goal <= 0) {
            goal = 10000;
        }
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Steps",
            info.steps != null ? info.steps as Number : 0,
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
        if (_amInfo == null) {
            return;
        }
        var info = _amInfo as ActivityMonitor.Info;
        var up = (
            info.floorsClimbed != null ? info.floorsClimbed as Number : 0
        ).toString();
        var dn = (
            info.floorsDescended != null ? info.floorsDescended as Number : 0
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
        var goal =
            info has :floorsClimbedGoal && info.floorsClimbedGoal != null
                ? info.floorsClimbedGoal as Number
                : 10;
        if (
            (info.floorsClimbed != null ? info.floorsClimbed as Number : 0) >=
            goal
        ) {
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
        if (_amInfo == null) {
            return;
        }
        var info = _amInfo as ActivityMonitor.Info;
        var goal = 10;
        if (info has :floorsClimbedGoal && info.floorsClimbedGoal != null) {
            goal = info.floorsClimbedGoal as Number;
        }
        if (goal <= 0) {
            goal = 10;
        }
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Floors",
            info.floorsClimbed != null ? info.floorsClimbed as Number : 0,
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
        if (_amInfo == null) {
            return;
        }
        var info = _amInfo as ActivityMonitor.Info;
        var mins = info.activeMinutesWeek;
        var goal = 150;
        if (
            info has :activeMinutesWeekGoal &&
            info.activeMinutesWeekGoal != null
        ) {
            goal = info.activeMinutesWeekGoal as Number;
        }
        if (goal <= 0) {
            goal = 150;
        }
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Intens Min",
            mins != null && mins.total != null ? mins.total as Number : 0,
            goal,
            labelColor,
            valueColor,
            showValue,
            barColor
        );
    }

    // Shared renderer for the steps/floors/intensity goal bars.
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
        dc.setStroke(
            ColorUtils.withAlpha(ColorUtils.colorFromIdx(barColor), 0x40)
        );
        for (var bx = gx; bx < gx + gw; bx++) {
            dc.drawLine(bx, y, bx, y + barH - 1);
        }
        var frac = current.toFloat() / goal.toFloat();
        if (frac > 1.0) {
            frac = 1.0;
        }
        var fillW = (frac * gw.toFloat()).toNumber();
        if (fillW > 0) {
            _glowRect(
                dc,
                gx,
                y,
                fillW,
                barH,
                ColorUtils.colorFromIdx(barColor)
            );
        }
        _glowLine(dc, gx - 1, y, gx - 1, y + barH - 1, GRAYS[3]);
        _glowLine(dc, gx + gw, y, gx + gw, y + barH - 1, GRAYS[3]);
        _drawDashedV(dc, gx + gw / 4, y, y + barH, GRAYS[2]);
        _drawDashedV(dc, gx + gw / 2, y, y + barH, GRAYS[2]);
        _drawDashedV(dc, gx + (gw * 3) / 4, y, y + barH, GRAYS[2]);
        var labelY = y + (_fh - _tinyFh) / 2 - 1;
        var goalStr = goal.toString();
        var axisColor = GRAYS[3];
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
        _glowText(dc, x, y, _font, " / ", Graphics.TEXT_JUSTIFY_LEFT, GRAYS[2]);
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

    // Draws a row value only (no label or separator) at the normal value
    // position. Used for the time and date in always-on mode.
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

    private function _calcGradRange(
        field as Number,
        colorIdx as Number,
        dataMinV as Float,
        dataRange as Float
    ) as Void {
        if (colorIdx >= COLOR_GRAD_TEMP_CUSTOM) {
            _gradMin = -20.0;
            _gradRange = 60.0;
            return;
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
                _gradMin = dataMinV;
                _gradRange = dataRange;
                return;
            }
            _gradMin = gMin;
            _gradRange = gMax - gMin;
            if (_gradRange < 1.0) {
                _gradRange = 1.0;
            }
            return;
        }
        _gradMin = dataMinV;
        _gradRange = dataRange;
    }

    private function _clampFrac(v as Float) as Float {
        var frac = (v - _gradMin) / _gradRange;
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
        valueMode as Number
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

        _calcMinMax(data);
        var minV = _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }

        var data2 = _getFieldHistory(fieldSecondary, periodMin);
        var minV2 = 0.0 as Float;
        var maxV2 = 0.0 as Float;
        var range2 = 1.0 as Float;
        if (data2 != null) {
            _calcMinMax(data2);
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
        _calcGradRange(field, lineColor, minV, range);
        var gradMinV1 = _gradMin;
        var gradRange1 = _gradRange;
        var maxFrac1 = _clampFrac(maxV);
        var minFrac1 = _clampFrac(minV);

        _calcGradRange(fieldSecondary, lineColor2, minV2, range2);
        var gradMinV2 = _gradMin;
        var gradRange2 = _gradRange;
        var maxFrac2 = _clampFrac(maxV2);
        var minFrac2 = _clampFrac(minV2);

        var dualMaxGap = (10 * _graphW) / periodMin;
        if (dualMaxGap < 1) {
            dualMaxGap = 1;
        }
        var dualCacheKey = _packGraphKey(field, fieldSecondary, periodMin);
        var dualBmp = _renderDualGraphToBitmap(
            dualCacheKey,
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
        if (dualBmp != null) {
            dc.drawBitmap(_graphX, y, dualBmp);
        } else {
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

        _drawRowAxes(dc, y);
        if (field == FIELD_HR) {
            _drawHrZones(dc, _graphX, _graphW, y, _graphH, minV, range);
        }

        // Secondary min/max outside right
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

        // Primary min/max outside left
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
            ColorUtils.colorFromIdx(lineColor2)
        );
        var effDual = _resolveEffPeriod(
            _packGraphKey(_graphW, field, periodMin),
            periodMin
        );
        var ageColor = GRAYS[3];
        _glowText(
            dc,
            _graphX + _graphW - dc.getTextWidthInPixels(secName, _fontTiny),
            yBelow,
            _fontTiny,
            Formatters.periodLabel(effDual) + " ",
            Graphics.TEXT_JUSTIFY_RIGHT,
            ageColor
        );
        var ageSecDual = _dataAge(data, effDual);
        if (ageSecDual > _fieldUpdateMin(field) * SECS_PER_MIN + 30) {
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
            return "bodyBat";
        }
        if (field == FIELD_STRESS) {
            return "stress";
        }
        if (field == FIELD_SPO2) {
            return "spo2";
        }
        if (field == FIELD_WRIST_TEMP) {
            return "tempWrist";
        }
        if (field == FIELD_ELEVATION) {
            return "elevation";
        }
        if (field == FIELD_PRESSURE) {
            return "pressure";
        }
        return null;
    }

    // Buckets sensor history into gw time slots (0=most recent), gaps stay
    // gaps. skipZero discards 0 samples - use for HR (0bpm means off-wrist).
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
        while (s != null) {
            if (System.getTimer() > deadline) {
                break;
            }
            var age = now - (s.when as Time.Moment).value();
            if (age >= periodSec) {
                break;
            }
            if (age >= 0 && s.data != null) {
                var v = s.data;
                var fv =
                    v instanceof Float ? v as Float : (v as Number).toFloat();
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
        // Store the period actually displayed so the label can reflect it.
        // Only report the effective (shorter) period when re-slotting occurred.
        _pendingEffPeriod =
            maxAge > 0 && maxAge < (periodSec * 9) / 10
                ? effectiveMin
                : periodMin;
        return result;
    }

    // Returns how often (in minutes) each sensor field generates a new reading.
    // Used to avoid re-fetching history more often than the sensor updates.
    private function _fieldUpdateMin(field as Number) as Number {
        if (field == FIELD_STRESS || field == FIELD_WRIST_TEMP) {
            return 3;
        }
        if (field == FIELD_BODY_BAT || field == FIELD_SPO2) {
            return 5;
        }
        return 1;
    }

    private function _getFieldHistory(
        field as Number,
        periodMin as Number
    ) as Array<Float>? {
        var cacheKey = _packGraphKey(_graphW, field, periodMin);
        var nowUnixMin = _nowUnixMin;
        if (_graphCacheTimes.hasKey(cacheKey)) {
            var lastMin = _graphCacheTimes.get(cacheKey) as Number;
            if (nowUnixMin - lastMin < _fieldUpdateMin(field)) {
                var cached = _graphCache.get(cacheKey);
                return cached != null ? cached as Array<Float> : null;
            }
        }
        _graphCacheTimes.put(cacheKey, nowUnixMin);

        var opts = { :period => periodMin };
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
            return _cacheResult(
                cacheKey,
                field,
                _readIter(
                    SensorHistory.getOxygenSaturationHistory(opts),
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

    private function _tempStr(v as Float) as String {
        return _metric
            ? v.format("%.1f")
            : Formatters.celsiusToF(v).format("%.1f");
    }

    private function _tempStr0(v as Float) as String {
        return _metric
            ? v.format("%.0f")
            : Formatters.celsiusToF(v).format("%.0f");
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
        return v.toNumber().toString();
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
        var gw = _graphW;
        var periodSec = periodMin * SECS_PER_MIN;
        var n = data.size();
        for (var i = 0; i < n; i++) {
            if (data[i] != null) {
                return (i * periodSec) / gw;
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

    private function _cacheResult(
        cacheKey as Number,
        field as Number,
        r as Array<Float>?
    ) as Array<Float>? {
        _graphCache.put(cacheKey, r);
        _graphBmpCache.remove(cacheKey);
        var dualKeys = _graphBmpDualCache.keys();
        for (var i = 0; i < dualKeys.size(); i++) {
            var k = dualKeys[i] as Number;
            if (_graphKeyHi(k) == field || _graphKeyLo(k) == field) {
                _graphBmpDualCache.remove(k);
            }
        }
        if (_pendingEffPeriod > 0) {
            _graphEffPeriod.put(cacheKey, _pendingEffPeriod);
            _pendingEffPeriod = 0;
        }
        return r;
    }

    // Renders graph content to a cached BufferedBitmap, keyed by cacheKey.
    // Drawing uses (0,0) as origin - caller blits the bitmap at (gx, y).
    private function _renderGraphToBitmap(
        cacheKey as Number,
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
    ) as Graphics.BufferedBitmap? {
        var ref =
            _graphBmpCache.get(cacheKey) as Graphics.BufferedBitmapReference?;
        if (ref != null) {
            var cached = ref.get() as Graphics.BufferedBitmap?;
            if (cached != null) {
                return cached;
            }
        }
        // +1 width/+2 height: the rightmost point and fill's bottom row land exactly at gw/gh+1, past a plain gw x (gh+1) buffer's bounds.
        var newRef = Graphics.createBufferedBitmap({
            :width => gw + 1,
            :height => gh + 2,
        });
        var bmp =
            (newRef as Graphics.BufferedBitmapReference).get() as
            Graphics.BufferedBitmap?;
        if (bmp == null) {
            return null;
        }
        var bmpDc = bmp.getDc();
        bmpDc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        bmpDc.clear();
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
        _graphBmpCache.put(cacheKey, newRef);
        return bmp;
    }

    private function _renderDualGraphToBitmap(
        cacheKey as Number,
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
    ) as Graphics.BufferedBitmap? {
        var ref =
            _graphBmpDualCache.get(cacheKey) as
            Graphics.BufferedBitmapReference?;
        if (ref != null) {
            var cached = ref.get() as Graphics.BufferedBitmap?;
            if (cached != null) {
                return cached;
            }
        }
        // +1 width/+2 height: the rightmost point and fill's bottom row land exactly at gw/gh+1, past a plain gw x (gh+1) buffer's bounds.
        var newRef = Graphics.createBufferedBitmap({
            :width => gw + 1,
            :height => gh + 2,
        });
        var bmp =
            (newRef as Graphics.BufferedBitmapReference).get() as
            Graphics.BufferedBitmap?;
        if (bmp == null) {
            return null;
        }
        var bmpDc = bmp.getDc();
        bmpDc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        bmpDc.clear();
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
        if (graphType == GRAPH_BAR && secType == SEC_BAR && data2 != null) {
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
        _graphBmpDualCache.put(cacheKey, newRef);
        return bmp;
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
        if (ageSec > _fieldUpdateMin(field) * SECS_PER_MIN + 30) {
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
            var x = gx + ((n1 - i) * gw) / n1;
            var py = y + gh - (((v - minV) * ghf) / range).toNumber();
            if (lastX >= 0 && i - lastI <= maxGap) {
                _glowLine(dc, x, py, lastX, lastY, color);
            }
            _glowRect(dc, x, py, 1, 1, color);
            lastX = x;
            lastY = py;
            lastI = i;
        }
    }

    private function _drawDashedH(
        dc as Dc,
        x1 as Number,
        x2 as Number,
        y as Number,
        color as Number
    ) as Void {
        var w = x2 - x1;
        if (w <= 0) {
            return;
        }
        if (w <= 3) {
            _glowLine(dc, x1, y, x2 - 1, y, color);
            return;
        }
        // Dashes/gaps are 2px; for odd w the last dash absorbs the extra 1px so gaps stay exact.
        var wEven = w - (w % 2);
        var n = (wEven + 5) / 4;
        if (n < 2) {
            n = 2;
        }
        var f = (wEven + 6 - 4 * n) / 2;
        if (f < 1) {
            f = 1;
        }
        _glowLine(dc, x1, y, x1 + f - 1, y, color);
        var x = x1 + f + 2;
        for (var i = 1; i < n - 1; i++) {
            _glowLine(dc, x, y, x + 1, y, color);
            x += 4;
        }
        var fLast = f + (w - wEven);
        _glowLine(dc, x2 - fLast, y, x2 - 1, y, color);
    }

    private function _drawDashedV(
        dc as Dc,
        x as Number,
        y1 as Number,
        y2 as Number,
        color as Number
    ) as Void {
        var h = y2 - y1;
        if (h <= 0) {
            return;
        }
        if (h <= 3) {
            _glowLine(dc, x, y1, x, y2 - 1, color);
            return;
        }
        var hEven = h - (h % 2);
        var n = (hEven + 5) / 4;
        if (n < 2) {
            n = 2;
        }
        var f = (hEven + 6 - 4 * n) / 2;
        if (f < 1) {
            f = 1;
        }
        _glowLine(dc, x, y1, x, y1 + f - 1, color);
        var yp = y1 + f + 2;
        for (var i = 1; i < n - 1; i++) {
            _glowLine(dc, x, yp, x, yp + 1, color);
            yp += 4;
        }
        var fLast = f + (h - hEven);
        _glowLine(dc, x, y2 - fLast, x, y2 - 1, color);
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
            return;
        }
        var mean = sum / cnt.toFloat();
        var meanH = (((mean - minV) * gh.toFloat()) / range).toNumber();
        if (meanH < 0) {
            meanH = 0;
        }
        if (meanH > gh) {
            meanH = gh;
        }
        var meanY = y + gh - meanH;
        var meanFrac = (mean - gradMinV) / gradRange;
        if (meanFrac < 0.0) {
            meanFrac = 0.0;
        }
        if (meanFrac > 1.0) {
            meanFrac = 1.0;
        }
        var color =
            colorIdx >= COLOR_GRAD_TRI
                ? ColorUtils.gradColor(colorIdx, meanFrac)
                : GRAYS[3];
        _drawDashedH(dc, gx, gx + gw, meanY, color);
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
            var x = gx + ((n1 - i) * gw) / n1;
            var py = y + gh - (((v - minV) * ghf) / range).toNumber();
            if (lastX >= 0 && i - lastI <= maxGap) {
                var mid = (v + lastV) / 2.0;
                var mfrac = (mid - gradMinV) / gradRange;
                if (mfrac < 0.0) {
                    mfrac = 0.0;
                }
                if (mfrac > 1.0) {
                    mfrac = 1.0;
                }
                _glowLine(
                    dc,
                    x,
                    py,
                    lastX,
                    lastY,
                    ColorUtils.gradColor(colorIdx, mfrac)
                );
            }
            var frac = (v - gradMinV) / gradRange;
            if (frac < 0.0) {
                frac = 0.0;
            }
            if (frac > 1.0) {
                frac = 1.0;
            }
            _glowRect(dc, x, py, 1, 1, ColorUtils.gradColor(colorIdx, frac));
            lastX = x;
            lastY = py;
            lastV = v;
            lastI = i;
        }
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
            var slot = n - 1 - i;
            var bx = gx + (slot * gw) / n;
            var slotEnd = gx + ((slot + 1) * gw) / n;
            var bw = slotEnd - bx - (slot < n - 1 ? 1 : 0);
            if (bw < 1) {
                bw = 1;
            }
            var barH = (((barV - minV) * ghf) / range).toNumber();
            if (barH < 1) {
                barH = 1;
            }
            _glowRect(dc, bx, y + gh - barH, bw, barH, color);
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
            var slot = n - 1 - i;
            var bx = gx + (slot * gw) / n;
            var slotEnd = gx + ((slot + 1) * gw) / n;
            var bw = slotEnd - bx - (slot < n - 1 ? 1 : 0);
            if (bw < 1) {
                bw = 1;
            }
            var barH = (((v - minV) * ghf) / range).toNumber();
            if (barH < 1) {
                barH = 1;
            }
            var frac = (v - gradMinV) / gradRange;
            if (frac < 0.0) {
                frac = 0.0;
            }
            if (frac > 1.0) {
                frac = 1.0;
            }
            _glowRect(
                dc,
                bx,
                y + gh - barH,
                bw,
                barH,
                ColorUtils.gradColor(colorIdx, frac)
            );
        }
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
            var slot = count - 1 - i;
            var slotX = gx + (slot * gw) / count;
            var slotEnd = gx + ((slot + 1) * gw) / count;
            var slotW = slotEnd - slotX - (slot < count - 1 ? 1 : 0);
            if (slotW < 2) {
                slotW = 2;
            }
            var hw = slotW / 2;
            if (data[i] != null) {
                var v1 = data[i] as Float;
                var barH = (((v1 - minV) * ghf) / range).toNumber();
                if (barH < 1) {
                    barH = 1;
                }
                var frac1 = (v1 - gradMinV1) / gradRange1;
                if (frac1 < 0.0) {
                    frac1 = 0.0;
                }
                if (frac1 > 1.0) {
                    frac1 = 1.0;
                }
                _glowRect(
                    dc,
                    slotX,
                    y + gh - barH,
                    hw,
                    barH,
                    ColorUtils.gradColor(colorIdx1, frac1)
                );
            }
            if (data2[i] != null) {
                var v2 = data2[i] as Float;
                var barH2 = (((v2 - minV2) * ghf) / range2).toNumber();
                if (barH2 < 1) {
                    barH2 = 1;
                }
                var frac2 = (v2 - gradMinV2) / gradRange2;
                if (frac2 < 0.0) {
                    frac2 = 0.0;
                }
                if (frac2 > 1.0) {
                    frac2 = 1.0;
                }
                _glowRect(
                    dc,
                    slotX + hw,
                    y + gh - barH2,
                    slotW - hw,
                    barH2,
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
        if (n < 2) {
            _rowBuf[0] = "Temp Fcst";
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }

        var data = new Array<Float>[n];
        for (var i = 0; i < n; i++) {
            data[i] = (all as Array<Float>)[n - 1 - i];
        }

        _calcMinMax(data);
        var minV = _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }
        _setGraphX(FIELD_WX_FCST_TEMP, minV, maxV);
        _calcGradRange(FIELD_WX_FCST_TEMP, lineColor, minV, range);
        var gradMinV = _gradMin;
        var gradRange = _gradRange;
        var maxFrac = _clampFrac(maxV);
        var minFrac = _clampFrac(minV);

        _rowBuf[0] = "Temp Fcst";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var fcstTempBmp = _renderGraphToBitmap(
            _packGraphKey(_graphW, FIELD_WX_FCST_TEMP, hours),
            graphType,
            lineColor,
            data,
            _graphW,
            _graphH,
            minV,
            range,
            gradMinV,
            gradRange,
            data.size()
        );
        _drawGraphOrFallback(
            dc,
            fcstTempBmp,
            graphType,
            lineColor,
            data,
            y,
            minV,
            range,
            gradMinV,
            gradRange,
            data.size()
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
        for (var i = 0; i < n; i++) {
            var zv = (zones[i] as Number).toFloat();
            if (zv <= minV || zv >= minV + range) {
                continue;
            }
            var zy = y + gh - (((zv - minV) * gh.toFloat()) / range).toNumber();
            _drawDashedH(dc, gx, gx + gw, zy, GRAYS[1]);
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
        maxGap as Number
    ) as Void {
        var n = data.size();
        if (n < 2) {
            return;
        }
        var n1 = n - 1;
        var ghf = gh.toFloat();
        var bottom = y + gh;
        // Fill extends 1px past the baseline to reach the axis line; kept separate from
        // ghf/bottom so the curve still matches the outline's (gh-based) mapping exactly.
        var fillBottom = bottom + 1;
        var prevX = -1;
        var prevPY = 0;
        var prevI = -1;
        // Tracks a run of points sharing a column so it's only drawn once (extended
        // upward if taller), instead of re-compositing alpha on the same column repeatedly.
        var runX = -1;
        var runTop = 0;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var x = gx + ((n1 - i) * gw) / n1;
            var py = bottom - (((v - minV) * ghf) / range).toNumber();
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
                    // px < prevX (not <=): prevX's column was already drawn by the
                    // previous point's iteration; including it again double-composites its alpha.
                    for (var px = x; px < prevX; px++) {
                        var lerpY = py + ((px - x) * (prevPY - py)) / dx;
                        dc.drawLine(px, lerpY, px, fillBottom);
                    }
                }
            } else {
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
        // See _drawAreaLine: kept separate from ghf/bottom so the curve
        // position still matches the outline line's (gh-based) mapping.
        var fillBottom = bottom + 1;
        var prevX = -1;
        var prevPY = 0;
        var prevV = 0.0 as Float;
        var prevI = -1;
        // See _drawAreaLine: only ever draw a shared column once in full.
        var runX = -1;
        var runTop = 0;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var x = gx + ((n1 - i) * gw) / n1;
            var py = bottom - (((v - minV) * ghf) / range).toNumber();
            if (py < y) {
                py = y;
            }
            if (prevX >= 0 && i - prevI <= maxGap) {
                var dx = prevX - x;
                if (dx == 0) {
                    var frac = (v - gradMinV) / gradRange;
                    if (frac < 0.0) {
                        frac = 0.0;
                    }
                    if (frac > 1.0) {
                        frac = 1.0;
                    }
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
                        var frac = (lerpV - gradMinV) / gradRange;
                        if (frac < 0.0) {
                            frac = 0.0;
                        }
                        if (frac > 1.0) {
                            frac = 1.0;
                        }
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
                var frac = (v - gradMinV) / gradRange;
                if (frac < 0.0) {
                    frac = 0.0;
                }
                if (frac > 1.0) {
                    frac = 1.0;
                }
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
        if (n < 2) {
            _rowBuf[0] = label;
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
            return;
        }
        var data = new Array<Float>[n];
        for (var i = 0; i < n; i++) {
            data[i] = (all as Array<Float>)[n - 1 - i];
        }
        _calcMinMax(data);
        var minV = _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < minRange) {
            range = minRange;
        }
        _setGraphX(fieldConst, minV, maxV);
        _calcGradRange(fieldConst, lineColor, minV, range);
        var gradMinV = _gradMin;
        var gradRange = _gradRange;
        var maxFrac = _clampFrac(maxV);
        var minFrac = _clampFrac(minV);
        _rowBuf[0] = label;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var fcstBmp = _renderGraphToBitmap(
            _packGraphKey(_graphW, fieldConst, hours),
            graphType,
            lineColor,
            data,
            _graphW,
            _graphH,
            minV,
            range,
            gradMinV,
            gradRange,
            data.size()
        );
        _drawGraphOrFallback(
            dc,
            fcstBmp,
            graphType,
            lineColor,
            data,
            y,
            minV,
            range,
            gradMinV,
            gradRange,
            data.size()
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
        for (var i = 0; i < n; i++) {
            if (lowsArr[i] != null && (lowsArr[i] as Float) < allMin) {
                allMin = lowsArr[i] as Float;
            }
            if (highsArr[i] != null && (highsArr[i] as Float) > allMax) {
                allMax = highsArr[i] as Float;
            }
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
        _calcGradRange(FIELD_WX_FCST_TEMP, colorIdx, allMin, range);
        _rowBuf[0] = "Day Fcst";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var ghf = _graphH.toFloat();
        var bottom = y + _graphH;
        for (var si = 1; si < n; si++) {
            _drawDashedV(
                dc,
                _graphX + (si * _graphW) / n - 1,
                y,
                y + _graphH,
                GRAYS[2]
            );
        }
        for (var i = 0; i < n; i++) {
            if (highsArr[i] == null || lowsArr[i] == null) {
                continue;
            }
            var loV = lowsArr[i] as Float;
            var hiV = highsArr[i] as Float;
            var slotX = _graphX + (i * _graphW) / n;
            var slotEnd = _graphX + ((i + 1) * _graphW) / n;
            var bw = slotEnd - slotX - (i < n - 1 ? 1 : 0);
            if (bw < 1) {
                bw = 1;
            }
            var hiY = bottom - (((hiV - allMin) * ghf) / range).toNumber();
            var loY = bottom - (((loV - allMin) * ghf) / range).toNumber();
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
            var midV = (hiV + loV) / 2.0;
            var frac = _clampFrac(midV);
            _glowRect(
                dc,
                slotX,
                hiY,
                bw,
                barH,
                ColorUtils.gradColor(colorIdx, frac)
            );
        }
        _drawRowAxes(dc, y);
        var isGrad = colorIdx >= COLOR_GRAD_TRI;
        var maxFrac = _clampFrac(allMax);
        var minFrac = _clampFrac(allMin);
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
        var dayNames = ["S", "M", "T", "W", "T", "F", "S"] as Array<String>;
        // day_of_week is 1=Sun..7=Sat under FORMAT_SHORT; dayNames is 0=Sun-indexed.
        var todayDow = 0;
        if (_clockInfo != null) {
            todayDow =
                ((_clockInfo as Gregorian.Info).day_of_week as Number) - 1;
        }
        var fDowSetting = System.getDeviceSettings().firstDayOfWeek;
        var firstDow =
            fDowSetting != null ? ((fDowSetting as Number) - 1) % 7 : 1;
        for (var di = 0; di < n; di++) {
            var dowColor =
                (todayDow + di) % 7 == firstDow
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
                dayNames[(todayDow + di) % 7],
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

    private function _drawGraphOrFallback(
        dc as Dc,
        bmp as Graphics.BufferedBitmap?,
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
        if (bmp != null) {
            dc.drawBitmap(_graphX, y, bmp);
        } else {
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
        }
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
                dc.setStroke(
                    ColorUtils.withAlpha(
                        ColorUtils.colorFromIdx(colorIdx),
                        _areaOpacity
                    )
                );
                _drawAreaLine(dc, data, gx, gw, y, gh, minV, range, maxGap);
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
        valueMode as Number
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

        _calcMinMax(data);
        var minV = _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }
        _setGraphX(field, minV, maxV);
        _calcGradRange(field, lineColor, minV, range);
        var gradMinV = _gradMin;
        var gradRange = _gradRange;
        var maxFrac = _clampFrac(maxV);
        var minFrac = _clampFrac(minV);

        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var maxGap = (10 * _graphW) / periodMin;
        if (maxGap < 1) {
            maxGap = 1;
        }
        var cacheKey = _packGraphKey(_graphW, field, periodMin);
        var graphBmp = _renderGraphToBitmap(
            cacheKey,
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
        _drawGraphOrFallback(
            dc,
            graphBmp,
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
        if (field == FIELD_HR) {
            _drawHrZones(dc, _graphX, _graphW, y, _graphH, minV, range);
        }
        var eff = _resolveEffPeriod(cacheKey, periodMin);
        _drawSingleGraphLabels(
            dc,
            field,
            _graphX,
            _graphW,
            y,
            _graphH,
            minV,
            maxV,
            Formatters.periodLabel(eff),
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

    // FLOORS and the WX_TEMP*/WX_UV* fields early-return in _drawLineRow, never reach here.
    private function _getFieldParts(field as Number) as Void {
        if (_getFitnessFieldParts(field)) {
            return;
        }
        if (_getHealthFieldParts(field)) {
            return;
        }
        if (_getNavFieldParts(field)) {
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
        if (field == FIELD_CALORIES) {
            _rowBuf[0] = "Day Cals";
            var info = _amInfo;
            _rowBuf[1] =
                (info != null && info.calories != null
                    ? info.calories as Number
                    : 0
                ).toString() + " kcal";
            return true;
        }
        if (field == FIELD_DISTANCE) {
            _rowBuf[0] = "Day Dist";
            var info = _amInfo;
            if (info == null || info.distance == null) {
                _rowBuf[1] = "-";
                return true;
            }
            var distCm = info.distance as Number;
            _rowBuf[1] = _metric
                ? (distCm / 100000.0).format("%.2f") + "km"
                : (distCm / 160934.0).format("%.2f") + "mi";
            return true;
        }
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
        if (field == FIELD_MOVE_BAR) {
            _rowBuf[0] = "Move Bar";
            var info = _amInfo;
            _rowBuf[1] =
                info != null && info.moveBarLevel != null
                    ? (info.moveBarLevel as Number).toString() + "/5"
                    : "-";
            return true;
        }
        if (field == FIELD_ACTIVE_MIN_DAY) {
            _rowBuf[0] = "Act Min";
            var info = _amInfo;
            var mins = info != null ? info.activeMinutesDay : null;
            _rowBuf[1] =
                mins != null && mins.total != null
                    ? (mins.total as Number).toString()
                    : "0";
            return true;
        }
        if (field == FIELD_PRESSURE) {
            _rowBuf[0] = "Pressure";
            var ptag =
                _cachedPressureTrend == 1
                    ? " [R]"
                    : _cachedPressureTrend == -1
                      ? " [F]"
                      : "";
            _rowBuf[1] = _cachedPressure + ptag;
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
                    ? _distStr((_compWeeklyRun as Number).toFloat())
                    : "-";
            return true;
        }
        if (field == FIELD_WEEKLY_BIKE) {
            _rowBuf[0] = "Week Bike";
            _rowBuf[1] =
                _compWeeklyBike != null
                    ? _distStr((_compWeeklyBike as Number).toFloat())
                    : "-";
            return true;
        }
        if (field == FIELD_FLOORS) {
            _rowBuf[0] = "Floors";
            var info = _amInfo;
            if (info == null) {
                _rowBuf[1] = "0/0";
                return true;
            }
            _rowBuf[1] =
                (info.floorsClimbed != null
                    ? info.floorsClimbed as Number
                    : 0
                ).toString() +
                "/" +
                (info.floorsDescended != null
                    ? info.floorsDescended as Number
                    : 0
                ).toString();
            return true;
        }
        if (field == FIELD_STEPS) {
            _rowBuf[0] = "Steps";
            var info = _amInfo;
            if (info == null) {
                _rowBuf[1] = "0";
                return true;
            }
            var goalStr = (
                info.stepGoal != null ? info.stepGoal as Number : 10000
            ).toString();
            _rowBuf[1] =
                (info.steps != null ? info.steps as Number : 0).format(
                    "%0" + goalStr.length() + "d"
                ) +
                "/" +
                goalStr;
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
        if (field == FIELD_CLIMB_DESCEND_DAY) {
            var up = "-";
            var dn = "-";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.metersClimbed != null) {
                    up = _altStr(info.metersClimbed as Float);
                }
                if (info.metersDescended != null) {
                    dn = _altStr(info.metersDescended as Float);
                }
            }
            _rowBuf[0] = "Climb+Desc";
            _rowBuf[1] = up + " | " + dn;
            return true;
        }
        if (field == FIELD_WEEKLY_DISTANCES) {
            var run = "-";
            var bike = "-";
            if (_compWeeklyRun != null) {
                run = _distStr((_compWeeklyRun as Number).toFloat());
            }
            if (_compWeeklyBike != null) {
                bike = _distStr((_compWeeklyBike as Number).toFloat());
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
        if (field == FIELD_LACTATE_HR) {
            _rowBuf[0] = "Lactate HR";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (
                    info has :lactateThresholdHeartRate &&
                    info.lactateThresholdHeartRate != null
                ) {
                    _rowBuf[1] =
                        (info.lactateThresholdHeartRate as Number).toString() +
                        " bpm";
                    return true;
                }
            }
            _rowBuf[1] = "-";
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

    private function _getNavFieldParts(field as Number) as Boolean {
        if (field == FIELD_GPS_LAT) {
            _rowBuf[0] = "Latitude";
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                _rowBuf[1] = (
                    (pos.position as Position.Location).toDegrees()[0] as Double
                ).format("%.5f");
                return true;
            }
            _rowBuf[1] = "-";
            return true;
        }
        if (field == FIELD_GPS_LON) {
            _rowBuf[0] = "Longitude";
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                _rowBuf[1] = (
                    (pos.position as Position.Location).toDegrees()[1] as Double
                ).format("%.5f");
                return true;
            }
            _rowBuf[1] = "-";
            return true;
        }
        if (field == FIELD_GPS_ACCURACY) {
            _rowBuf[0] = "GPS Accur";
            var pos = _posInfo;
            if (pos == null) {
                _rowBuf[1] = "-";
                return true;
            }
            var acc = pos.accuracy;
            var label = "-";
            if (acc == Position.QUALITY_GOOD) {
                label = "GOOD";
            } else if (acc == Position.QUALITY_USABLE) {
                label = "FAIR";
            } else if (acc == Position.QUALITY_POOR) {
                label = "POOR";
            } else if (acc == Position.QUALITY_LAST_KNOWN) {
                label = "LAST";
            } else if (acc == Position.QUALITY_NOT_AVAILABLE) {
                label = "N/A";
            }
            _rowBuf[1] = label;
            return true;
        }
        if (field == FIELD_HEADING) {
            _rowBuf[0] = "Heading";
            var pos = _posInfo;
            if (pos != null && pos.heading != null) {
                var deg = Math.toDegrees(pos.heading as Float).toNumber();
                deg = ((deg % 360) + 360) % 360;
                _rowBuf[1] = deg.toString();
                return true;
            }
            _rowBuf[1] = "-";
            return true;
        }
        if (field == FIELD_GPS_LAT_LON) {
            _rowBuf[0] = "Lat+Lon";
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                _rowBuf[1] =
                    (coords[0] as Double).format("%.5f") +
                    ", " +
                    (coords[1] as Double).format("%.5f");
                return true;
            }
            _rowBuf[1] = "-";
            return true;
        }
        if (field == FIELD_GPS_LAT_LON_ACC) {
            _rowBuf[0] = "GPS";
            var pos = _posInfo;
            if (pos == null || pos.position == null) {
                _rowBuf[1] = "-";
                return true;
            }
            var coords = (pos.position as Position.Location).toDegrees();
            var acc = pos.accuracy;
            var accLabel = "";
            if (acc == Position.QUALITY_GOOD) {
                accLabel = " [GOOD]";
            } else if (acc == Position.QUALITY_USABLE) {
                accLabel = " [FAIR]";
            } else if (acc == Position.QUALITY_POOR) {
                accLabel = " [POOR]";
            } else if (acc == Position.QUALITY_LAST_KNOWN) {
                accLabel = " [LAST]";
            } else if (acc == Position.QUALITY_NOT_AVAILABLE) {
                accLabel = " [N/A]";
            }
            _rowBuf[1] =
                (coords[0] as Double).format("%.4f") +
                ", " +
                (coords[1] as Double).format("%.4f") +
                accLabel;
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
            _rowBuf[0] = "Wind+Rain";
            _rowBuf[1] = _wxWind + " | " + _wxPrecip;
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
        if (field == FIELD_WX_TEMP_HIGH_LOW) {
            _rowBuf[0] = "Temp";
            _rowBuf[1] = _wxTemp + " " + _wxHigh + "/" + _wxLow + _wxUnit;
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
        if (field == FIELD_WX_HIGH_LOW) {
            _rowBuf[0] = "Temp Hi/Lo";
            _rowBuf[1] = _wxHigh + "/" + _wxLow + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_HUMIDITY_DEW) {
            _rowBuf[0] = "Hum+Dew";
            _rowBuf[1] = _wxHumidity + " | " + _wxDewPoint + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_HEAT_INDEX) {
            _rowBuf[0] = "Heat Index";
            _rowBuf[1] = _wxHeatIndex + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_TEMP_HUMIDITY) {
            _rowBuf[0] = "Temp+Hum";
            _rowBuf[1] = _wxTemp + _wxUnit + " " + _wxHumidity;
            return true;
        }
        if (field == FIELD_WX_TEMP_PRECIP) {
            _rowBuf[0] = "Temp+Rain";
            _rowBuf[1] = _wxTemp + _wxUnit + " " + _wxPrecip;
            return true;
        }
        if (field == FIELD_WX_HUMIDITY_PRECIP) {
            _rowBuf[0] = "Hum+Rain";
            _rowBuf[1] = _wxHumidity + " | " + _wxPrecip;
            return true;
        }
        if (field == FIELD_WX_CLOUD_PRECIP) {
            _rowBuf[0] = "Cloud+Rain";
            _rowBuf[1] = _wxCloudCover + " | " + _wxPrecip;
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

    private function _getWeatherForecastFieldParts(field as Number) as Boolean {
        if (field == FIELD_WX_FCST_TEMP) {
            _rowBuf[0] = "Temp Fcst";
            _rowBuf[1] = _wxTemp + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_FCST_PRECIP) {
            _rowBuf[0] = "Rain %";
            _rowBuf[1] = _wxPrecip;
            return true;
        }
        if (field == FIELD_WX_FCST_DAILY) {
            _rowBuf[0] = "Day Fcst";
            _rowBuf[1] = _wxTemp + _wxUnit;
            return true;
        }
        if (field == FIELD_WX_FCST_WIND) {
            _rowBuf[0] = "Wind Fcst";
            _rowBuf[1] = _wxWind;
            return true;
        }
        if (field == FIELD_WX_FCST_HUMIDITY) {
            _rowBuf[0] = "Hum Fcst";
            _rowBuf[1] = _wxHumidity;
            return true;
        }
        if (field == FIELD_WX_FCST_UV) {
            _rowBuf[0] = "UV Fcst";
            _rowBuf[1] = _wxUv;
            return true;
        }
        if (field == FIELD_WX_FCST_CLOUD) {
            _rowBuf[0] = "Cloud Fcst";
            _rowBuf[1] = _wxCloudCover;
            return true;
        }
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
            // FORMAT_SHORT returns these as Numbers; the stubs type them as
            // Number-or-String, so cast once into locals.
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
                GRAPH_SEC_FIELDS[_lineSecField[i]] == f
            ) {
                return true;
            }
        }
        return false;
    }

    private function _refreshPointSamples() as Void {
        if (
            _fieldNeeded(FIELD_BODY_BAT) ||
            _fieldNeeded(FIELD_BODY_BAT_STRESS) ||
            _fieldNeeded(FIELD_BODY_BAT_RECOVERY) ||
            _fieldNeeded(FIELD_BODY_BAT_REST_HR)
        ) {
            var sample = SensorHistory.getBodyBatteryHistory({}).next();
            if (sample != null && sample.data != null) {
                var d = sample.data;
                _cachedBodyBat =
                    (d instanceof Float
                        ? (d as Float).format("%.0f")
                        : (d as Number).toString()) + "%";
            }
        }
        if (_fieldNeeded(FIELD_WRIST_TEMP)) {
            var sample = SensorHistory.getTemperatureHistory({}).next();
            if (sample != null && sample.data != null) {
                var td = sample.data;
                var tempC =
                    td instanceof Float
                        ? td as Float
                        : (td as Number).toFloat();
                _cachedTempWrist = _tempStr(tempC);
            }
        }
        if (_fieldNeeded(FIELD_PRESSURE)) {
            var pIter = SensorHistory.getPressureHistory({ :period => 30 });
            var s1 = pIter.next();
            if (s1 != null && s1.data != null) {
                var pd = s1.data;
                var pa =
                    pd instanceof Float
                        ? pd as Float
                        : (pd as Number).toFloat();
                _cachedPressure = _metric
                    ? (pa / 100.0).format("%.1f") + "hPa"
                    : (pa / PA_PER_INHG).format("%.2f") + "inHg";
                var oldest = s1;
                var ps = pIter.next();
                var deadline = System.getTimer() + 100;
                while (ps != null && System.getTimer() < deadline) {
                    oldest = ps;
                    ps = pIter.next();
                }
                if (oldest != s1 && oldest.data != null) {
                    var od = oldest.data;
                    var opa =
                        od instanceof Float
                            ? od as Float
                            : (od as Number).toFloat();
                    _cachedPressureTrend =
                        pa - opa > 100.0 ? 1 : pa - opa < -100.0 ? -1 : 0;
                }
            }
        }
        if (_fieldNeeded(FIELD_ELEVATION)) {
            var sample = SensorHistory.getElevationHistory({}).next();
            if (sample != null && sample.data != null) {
                var ed = sample.data;
                var elev =
                    ed instanceof Float
                        ? ed as Float
                        : (ed as Number).toFloat();
                _cachedElevation = _altStr(elev);
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
                var ss = SensorHistory.getStressHistory({
                    :period => 10,
                }).next();
                if (ss != null && ss.data != null) {
                    var stressAge =
                        Time.now().value() - (ss.when as Time.Moment).value();
                    if (stressAge <= 600) {
                        var sd = ss.data;
                        _cachedStress =
                            sd instanceof Float
                                ? (sd as Float).format("%.0f")
                                : (sd as Number).toString();
                    } else {
                        _cachedStress = "-";
                    }
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
        _wxLastMin = nowMin;
        if (!_needsWeatherCurrent) {
            return;
        }
        _wxCurrentFetched = true;
        var c = Weather.getCurrentConditions();
        if (c == null) {
            return;
        }
        _wxHumidityNum = -1;
        var metric = _metric;
        if (c.temperature != null) {
            _wxTemp = _tempStr(c.temperature as Float);
        }
        if (c.feelsLikeTemperature != null) {
            _wxFeels = _tempStr(c.feelsLikeTemperature as Float);
        }
        if (c.lowTemperature != null) {
            _wxLow = _tempStr0(c.lowTemperature as Float);
        }
        if (c.highTemperature != null) {
            _wxHigh = _tempStr0(c.highTemperature as Float);
        }
        if (c.precipitationChance != null) {
            _wxPrecip = (c.precipitationChance as Number).toString() + "%";
        }
        if (c.windSpeed != null) {
            var spd = c.windSpeed as Float;
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
            _wxUvNum = (c.uvIndex as Float).toNumber();
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
            _wxDewPoint = _tempStr(c.dewPoint as Float);
        }
        if (c.visibility != null) {
            var vis = c.visibility as Float;
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
            _wxObsAge = (ageS / 60).toString() + "m";
        } else {
            _wxObsAge = "-";
        }
        if (c.temperature != null && _wxHumidityNum >= 0) {
            _wxHeatIndex = _calcHeatIndex(
                c.temperature as Float,
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
                        arr[i] = h.temperature as Float;
                    }
                    if (h.precipitationChance != null) {
                        precipArr[i] = (
                            h.precipitationChance as Number
                        ).toFloat();
                    }
                    if (h.windSpeed != null) {
                        windArr[i] = h.windSpeed as Float;
                    }
                    if (h.relativeHumidity != null) {
                        humArr[i] = (h.relativeHumidity as Number).toFloat();
                    }
                    if (h.uvIndex != null) {
                        uvArr[i] = h.uvIndex as Float;
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
            }
            var daily = Weather.getDailyForecast();
            if (daily != null && daily.size() >= 2) {
                var dcnt = daily.size() < 7 ? daily.size() : 7;
                var dhigh = new Array<Float>[dcnt];
                var dlow = new Array<Float>[dcnt];
                for (var i = 0; i < dcnt; i++) {
                    var dfc = daily[i];
                    if (dfc.highTemperature != null) {
                        dhigh[i] = dfc.highTemperature as Float;
                    }
                    if (dfc.lowTemperature != null) {
                        dlow[i] = dfc.lowTemperature as Float;
                    }
                }
                _wxDailyForecastHigh = dhigh;
                _wxDailyForecastLow = dlow;
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
        var totalSec = secPerDist.toNumber();
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
        var T = (tempC * 9.0) / 5.0 + 32.0;
        var RH = humidity.toFloat();
        if (T < 80.0 || RH < 40.0) {
            return _metric ? tempC.format("%.1f") : T.format("%.1f");
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

    private function _getPhase(nowSec as Number) as Number {
        var mainSec = _rotateMainMs / 1000;
        var altSec = _rotateAltMs / 1000;
        var cycle = mainSec + _rotateMaxPhase * altSec;
        var pos = nowSec % cycle;
        if (pos < 0) {
            pos += cycle;
        }
        if (pos < mainSec) {
            return 0;
        }
        pos -= mainSec;
        return pos / altSec + 1;
    }

    private function _getProp(key as String, defaultVal as Number) as Number {
        var val = Properties.getValue(key);
        if (val instanceof Number) {
            return val as Number;
        }
        return defaultVal;
    }

    private function _getBoolProp(key as String) as Boolean {
        var val = Properties.getValue(key);
        if (val instanceof Boolean) {
            return val as Boolean;
        }
        return false;
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
            var hdc = _haloDrawOk == true ? _activeHaloDc() : null;
            if (hdc != null) {
                hdc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                hdc.fillRectangle(
                    _cursorX,
                    _cursorY,
                    _cursorCharW + 1,
                    _cursorFh + 1
                );
                hdc.setColor(
                    _glowColor(ColorUtils.colorFromIdx(0)),
                    Graphics.COLOR_TRANSPARENT
                );
                hdc.fillRectangle(
                    _cursorX,
                    _cursorY + 1,
                    _cursorCharW,
                    _cursorFh
                );
                hdc.fillRectangle(
                    _cursorX + 1,
                    _cursorY,
                    _cursorCharW,
                    _cursorFh
                );
                dc.setBlendMode(Graphics.BLEND_MODE_ADDITIVE);
                dc.drawBitmap(0, 0, _haloBmp as Graphics.BufferedBitmap);
                dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
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
        var secStr = ":" + sec.format("%02d");
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
        var hdc = _haloDrawOk == true ? _activeHaloDc() : null;
        if (hdc != null) {
            hdc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            hdc.fillRectangle(x, _timeValueY, w + 1, _fh + 1);
            hdc.setColor(
                _glowColor(ColorUtils.colorFromIdx(_line1ValueC)),
                Graphics.COLOR_TRANSPARENT
            );
            hdc.drawText(
                x,
                _timeValueY + 1,
                _font,
                secStr,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            hdc.drawText(
                x + 1,
                _timeValueY,
                _font,
                secStr,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            dc.setBlendMode(Graphics.BLEND_MODE_ADDITIVE);
            dc.drawBitmap(0, 0, _haloBmp as Graphics.BufferedBitmap);
            dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
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
        if (s has :alwaysOnEnabled && s.alwaysOnEnabled) {
            WatchUi.requestUpdate();
        }
    }
    public function onExitSleep() as Void {
        _lowPower = false;
        _wakeFlicker = true;
        WatchUi.requestUpdate();
    }
}
