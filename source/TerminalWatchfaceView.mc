import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.SensorHistory;
import Toybox.UserProfile;
import Toybox.Complications;
import Toybox.Position;

const APP_VERSION = "0.39.1";

// --- None ---
const FIELD_NONE = 7;

// --- Fitness / Health ---
const FIELD_STEPS = 0;
const FIELD_FLOORS = 6;
const FIELD_MOVE_BAR = 27;
const FIELD_HR = 1;
const FIELD_HR_MEAN = 24;
const FIELD_HR_MAX = 30;
const FIELD_SPO2 = 9;
const FIELD_RESP = 23;
const FIELD_BODY_BAT = 22;
const FIELD_STRESS = 21;
const FIELD_RECOVERY = 26;
const FIELD_SLEEP = 36;
const FIELD_VO2_MAX = 34;
const FIELD_LACTATE_HR = 63;
const FIELD_TRAINING_STATUS = 48;
const FIELD_TRAINING_EFFECT = 74;
const FIELD_WRIST_TEMP = 28;
const FIELD_SOLAR = 84;
const FIELD_NOTIFICATIONS = 77;

// --- Fitness combos ---
const FIELD_HR_SPO2 = 88;
const FIELD_RESP_SPO2 = 94;
const FIELD_BODY_BAT_STRESS = 89;
const FIELD_BODY_BAT_RECOVERY = 90;
const FIELD_STRESS_RECOVERY = 101;
const FIELD_VO2_TRAINING = 100;

// --- Calories / Distance / Speed ---
const FIELD_CALORIES = 2;
const FIELD_CAL_ACT = 25;
const FIELD_DISTANCE = 4;
const FIELD_SPEED = 35;
const FIELD_ACTIVE_MIN_DAY = 29;
const FIELD_INTENSITY_MIN = 10;

// --- Altitude / Pressure ---
const FIELD_ALTITUDE = 5;
const FIELD_ELEVATION = 32;
const FIELD_PRESSURE = 31;

// --- Pace / Race ---
const FIELD_PACE = 65;
const FIELD_PACE_AVG = 66;
const FIELD_PACE_AND_AVG = 87;
const FIELD_RACE_5K = 49;
const FIELD_RACE_10K = 50;
const FIELD_RACE_HALF = 51;
const FIELD_RACE_MARATHON = 52;
const FIELD_RACE_PACE_5K = 78;
const FIELD_RACE_PACE_10K = 79;
const FIELD_RACE_PACE_HALF = 80;
const FIELD_RACE_PACE_MARATHON = 81;

// --- Ascent / Descent ---
const FIELD_TOTAL_ASCENT = 75;
const FIELD_TOTAL_DESCENT = 76;
const FIELD_ASCENT_DESCENT = 91;
const FIELD_CLIMB_DAY = 82;
const FIELD_DESCENT_DAY = 83;
const FIELD_CLIMB_DESCEND_DAY = 92;

// --- Weekly ---
const FIELD_WEEKLY_RUN = 41;
const FIELD_WEEKLY_BIKE = 42;
const FIELD_WEEKLY_DISTANCES = 93;

// --- GPS / Navigation ---
const FIELD_GPS_LAT = 43;
const FIELD_GPS_LON = 44;
const FIELD_GPS_ACCURACY = 45;
const FIELD_GPS_LAT_LON = 55;
const FIELD_GPS_LAT_LON_ACC = 56;
const FIELD_HEADING = 46;

// --- Time / Calendar ---
const FIELD_ELAPSED = 47;
const FIELD_SUNRISE = 37;
const FIELD_SUNSET = 38;
const FIELD_SUNRISE_SUNSET = 39;
const FIELD_CALENDAR = 40;
const FIELD_SLEEP_TIME = 53;
const FIELD_WAKE_TIME = 54;
const FIELD_SLEEP_SCHEDULE = 99;

// --- Weather: current ---
const FIELD_WX_TEMP = 11;
const FIELD_WX_FEELS = 12;
const FIELD_WX_COND = 16;
const FIELD_WX_PRECIP = 13;
const FIELD_WX_WIND = 14;
const FIELD_WX_UV = 15;
const FIELD_WX_CLOUD = 70;
const FIELD_WX_HUMIDITY = 67;
const FIELD_WX_DEW_POINT = 68;
const FIELD_WX_VISIBILITY = 69;
const FIELD_WX_HEAT_INDEX = 72;
const FIELD_WX_HIGH_LOW = 102;

// --- Weather: combos ---
const FIELD_WX_TEMP_COND = 17;
const FIELD_WX_TEMP_WIND = 20;
const FIELD_WX_TEMP_UV = 58;
const FIELD_WX_TEMP_HUMIDITY = 95;
const FIELD_WX_TEMP_PRECIP = 96;
const FIELD_WX_TEMP_HIGH_LOW = 18;
const FIELD_WX_COND_PRECIP = 19;
const FIELD_WX_WIND_PRECIP = 57;
const FIELD_WX_UV_PRECIP = 59;
const FIELD_WX_UV_WIND = 60;
const FIELD_WX_HUMIDITY_PRECIP = 97;
const FIELD_WX_CLOUD_PRECIP = 98;
const FIELD_WX_HUMIDITY_DEW = 71;

// --- Weather: forecast ---
const FIELD_WX_FCST_TEMP = 33;
const FIELD_WX_FCST_PRECIP = 61;
const FIELD_WX_FCST_DAILY = 62;
const FIELD_WX_FCST_WIND = 64;
const FIELD_WX_FCST_HUMIDITY = 73;
const FIELD_WX_FCST_UV = 85;
const FIELD_WX_FCST_CLOUD = 86;

// --- Resting HR ---
const FIELD_HR_RESTING = 103;
const FIELD_HR_RESTING_AVG = 104;

// --- Weather: station ---
const FIELD_WX_SEA_PRESS = 105;
const FIELD_WX_OBS_TIME = 109;

// --- Weather: forecast conditions (from complications) ---
const FIELD_WX_FCST_COND_1D = 106;
const FIELD_WX_FCST_COND_2D = 107;
const FIELD_WX_FCST_COND_3D = 108;

// --- New combos ---
const FIELD_HR_RESTING_BOTH = 110;
const FIELD_WX_COND_FCST_1D = 111;
const FIELD_WX_FCST_COND_12D = 112;
const FIELD_BODY_BAT_REST_HR = 113;
const FIELD_SLEEP_RECOVERY = 114;
const FIELD_HR_MEAN_MAX = 115;
const FIELD_CAL_TOTAL_ACT = 116;
const FIELD_SOLAR_BATTERY = 117;

const VIEW_VALUE = 0;
const VIEW_GRAPH = 1;
const VIEW_GRAPH_VALUE = 2;
const VIEW_GRAPH_MAXMIN = 3;

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

const ROTATE_SLOT_NAMES =
    ["Secondary", "Tertiary", "Quaternary", "Quinary", "Senary"] as
    Array<String>;

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
        0xbbbbbb, // 8  light grey
        0xaa77ff, // 9  purple
    ] as Array<Number>;

// 50% brightness versions of COLORS — for subordinate labels, not configurable
const COLOR_DIM =
    [
        0x7f7f7f, // 0  white
        0x2a7f3b, // 1  green
        0x2a7f7f, // 2  cyan
        0x7f772a, // 3  yellow
        0x7f4c22, // 4  orange
        0x7f2a2a, // 5  red
        0x334c7f, // 6  blue
        0x7f2a7f, // 7  magenta
        0x5d5d5d, // 8  light grey
        0x553b7f, // 9  purple
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
// Overlay color per intensity (0=off handled separately, 1=subtle, 2=medium, 3=strong)
const SCANLINE_COLORS =
    [0x000000, 0x0d0d0d, 0x1a1a1a, 0x2a2a2a] as Array<Number>;

// 0=shadow, 1=bar bg, 2=axes, 3=mean line/no-data
const GRAYS =
    [
        0x222222, // 0  shadow
        0x444444, // 1  bar background
        0x666666, // 2  graph axes
        0x888888, // 3  mean line, no-data text
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
    private var _metric as Boolean = false;
    private var _notifCount as Number = 0;
    private var _notifLabel as String = "";
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
    private var _is24Hour as Boolean = true;
    private var _showSeconds as Boolean = false;
    private var _leftPad as Number = 4;
    private var _areaOpacity as Number = 64;
    private var _areaShowLine as Boolean = true;
    private var _scanlineIntensity as Number = 2;
    private var _rotateMainMs as Number = 5000;
    private var _rotateAltMs as Number = 5000;
    private var _rotateMaxPhase as Number = 5;
    private var _metricsValid as Boolean = false;
    private var _graphW as Number = 0;
    private var _graphX as Number = 0;
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
        _computeRotateMaxPhase();
    }

    public function onLayout(dc as Dc) as Void {}

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
        while (comp != null) {
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
        _graphBmpCache = {};
        _graphBmpDualCache = {};
        _lastDateDay = -1;
        _cachedTimeMin = -1;
        _computeRotateMaxPhase();
    }

    private function _computeRotateMaxPhase() as Void {
        var ri = _getProp("rotateInterval", 10);
        if (ri < 1) {
            ri = 1;
        }
        _rotateMainMs = ri * 1000;
        var ra = _getProp("rotateIntervalAlt", 3);
        _rotateAltMs = ra > 0 ? ra * 1000 : _rotateMainMs;
        _rotateMaxPhase = 0;
        for (var p = 4; p >= 0; p--) {
            var sn = ROTATE_SLOT_NAMES[p];
            if (
                _getProp("line3" + sn, FIELD_NONE) != FIELD_NONE ||
                _getProp("line4" + sn, FIELD_NONE) != FIELD_NONE ||
                _getProp("line5" + sn, FIELD_NONE) != FIELD_NONE
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
            var nc = System.getDeviceSettings().notificationCount;
            var newCount = nc != null ? nc as Number : 0;
            if (newCount != _notifCount) {
                _notifCount = newCount;
                _notifLabel = "[" + newCount.toString() + "]";
            }
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
            for (var i = 0; i < 3; i++) {
                var f = _resolvedFields[i];
                if (
                    f == FIELD_HR ||
                    f == FIELD_SPO2 ||
                    f == FIELD_ALTITUDE ||
                    f == FIELD_HR_MEAN ||
                    f == FIELD_CAL_ACT ||
                    f == FIELD_HR_MAX ||
                    f == FIELD_SPEED ||
                    f == FIELD_ELAPSED ||
                    f == FIELD_PACE ||
                    f == FIELD_PACE_AVG ||
                    f == FIELD_TRAINING_EFFECT ||
                    f == FIELD_TOTAL_ASCENT ||
                    f == FIELD_TOTAL_DESCENT ||
                    f == FIELD_PACE_AND_AVG ||
                    f == FIELD_HR_SPO2 ||
                    f == FIELD_ASCENT_DESCENT ||
                    f == FIELD_RESP_SPO2 ||
                    f == FIELD_HR_MEAN_MAX ||
                    f == FIELD_CAL_TOTAL_ACT
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
        }
        if (_needsLiveActivity) {
            _acInfo = Activity.getActivityInfo();
        }
        if (_needsGps) {
            _posInfo = Position.getInfo();
        }
        if (nowMin != _graphCacheMin) {
            _graphCacheMin = nowMin;
            _graphBmpCache = {};
            _graphBmpDualCache = {};
            var settings = System.getDeviceSettings();
            _metric = settings.distanceUnits == System.UNIT_METRIC;
            _is24Hour = settings.is24Hour;
            _showSeconds = _getBoolProp("showSeconds");
            _leftPad = _getProp("leftPadding", 4);
            _areaOpacity = _getProp("areaOpacity", 64);
            _areaShowLine = _getBoolProp("areaShowLine");
            _scanlineIntensity = _getProp("scanlines", 2);
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
            _batText = stats.battery.format("%.0f") + "%";
            var days = stats.batteryInDays;
            _batDaysText =
                days != null ? " [" + days.format("%.0f") + "d]" : "";
            _batW = 0;
        }
        _refreshWeather(nowMin);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (_scanlineIntensity > 0 && _scanlineIntensity < 4) {
            _drawScanlines(dc, SCANLINE_COLORS[_scanlineIntensity]);
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
        _graphW = _charW * 10;
        _graphX = cx + _splitPad + _charW * 2;
        _graphH = _fh - 2;

        var v0 = _resolvedFields[0] != FIELD_NONE;
        var v1 = _resolvedFields[1] != FIELD_NONE;
        var v2 = _resolvedFields[2] != FIELD_NONE;
        var visible = 6 + (v0 ? 1 : 0) + (v1 ? 1 : 0) + (v2 ? 1 : 0);

        var y = (_screenH - step * (visible - 3) - _fh) / 2;
        var row = 0;

        _drawHeader(dc, y);
        _drawPromptLine(dc, cx, y + step * row, _watchCmd);
        row++;

        _drawRow(
            dc,
            cx,
            y + step * row,
            _getTimeParts(),
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
        if (v0) {
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
        }
        if (v1) {
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
        }
        if (v2) {
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
        }

        var splitX = cx + _splitPad;
        var footerY = y + step * row;
        _cursorX = splitX;
        _cursorY = footerY;
        _cursorCharW = _charW;
        _cursorFh = _fh;

        dc.setColor(_colorFromIdx(2), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            splitX - _arrowW,
            footerY,
            _font,
            "~",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
        dc.drawText(splitX, footerY, _font, " > ", Graphics.TEXT_JUSTIFY_RIGHT);
        if (_cursorOn) {
            dc.fillRectangle(splitX, footerY, _charW, _fh);
        }
        _drawFooter(dc, footerY + _fh + 32);
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
    // Caller must set color and may draw the unit suffix at the returned x.
    private function _drawSmallTempNum(
        dc as Dc,
        x as Number,
        y as Number,
        numStr as String
    ) as Number {
        dc.drawText(x, y, _fontSmall, numStr, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(numStr, _fontSmall);
        dc.drawCircle(
            x + _degWSmall / 2,
            y + _degWSmall / 2 + 4,
            (_degWSmall - 1) / 2
        );
        return x + _degWSmall;
    }

    private function _drawGraphValueLabel(
        dc as Dc,
        x as Number,
        y as Number,
        field as Number,
        str as String
    ) as Number {
        if (field == FIELD_WRIST_TEMP) {
            var afterNum = _drawSmallTempNum(dc, x, y, str);
            dc.drawText(
                afterNum,
                y,
                _fontSmall,
                _wxUnit,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            return afterNum + dc.getTextWidthInPixels(_wxUnit, _fontSmall);
        } else {
            dc.drawText(x, y, _fontSmall, str, Graphics.TEXT_JUSTIFY_LEFT);
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
            mode == 0 ? COLOR_DIM[1] : mode == 1 ? COLOR_DIM[5] : COLOR_DIM[6];
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            rightX + _charW / 2,
            y - 4,
            _fontTiny,
            label,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    private function _drawIcon(
        dc as Dc,
        x as Number,
        y as Number,
        iconType as Number,
        colorIdx as Number
    ) as Void {
        dc.setColor(_colorFromIdx(colorIdx), Graphics.COLOR_TRANSPARENT);
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
        if (_notifCount == 0) {
            return;
        }
        var textY = y - 32 - _smallFh;
        dc.setColor(_colorFromIdx(1), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _screenW / 2,
            textY,
            _fontSmall,
            _notifLabel,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    private function _drawFooter(dc as Dc, y as Number) as Void {
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
            dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                startX + _bmpBoltW,
                y,
                _fontSmall,
                spaced,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            if (hasDays) {
                dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    startX + _bmpBoltW + spacedW,
                    y,
                    _fontSmall,
                    daysText,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
            return;
        }
        var startX = (_screenW - _batW - _batDaysW) / 2;
        dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, y, _fontSmall, batText, Graphics.TEXT_JUSTIFY_LEFT);
        if (hasDays) {
            dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                startX + _batW,
                y,
                _fontSmall,
                daysText,
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }

    private function _drawScanlines(dc as Dc, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        var y = 0;
        while (y < _screenH) {
            dc.drawLine(0, y, _screenW - 1, y);
            y += SCANLINE_SPACING;
        }
    }

    private function _drawPromptLine(
        dc as Dc,
        cx as Number,
        y as Number,
        content as String
    ) as Void {
        var splitX = cx + _splitPad;
        dc.setColor(_colorFromIdx(2), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            splitX - _arrowW,
            y,
            _font,
            "~",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
        dc.drawText(splitX, y, _font, " > ", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(_colorFromIdx(3), Graphics.COLOR_TRANSPARENT);
        dc.drawText(splitX, y, _font, content, Graphics.TEXT_JUSTIFY_LEFT);
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
        var slots =
            [
                [
                    key + "Secondary",
                    key + "SecondaryLabelColor",
                    key + "SecondaryValueColor",
                ],
                [
                    key + "Tertiary",
                    key + "TertiaryLabelColor",
                    key + "TertiaryValueColor",
                ],
                [
                    key + "Quaternary",
                    key + "QuaternaryLabelColor",
                    key + "QuaternaryValueColor",
                ],
                [
                    key + "Quinary",
                    key + "QuinaryLabelColor",
                    key + "QuinaryValueColor",
                ],
                [
                    key + "Senary",
                    key + "SenaryLabelColor",
                    key + "SenaryValueColor",
                ],
            ] as Array<Array<String> >;
        if (phase >= 1 && phase <= 5) {
            var s = slots[phase - 1] as Array<String>;
            var f = _getProp(s[0], FIELD_NONE);
            if (f != FIELD_NONE) {
                _resolvedFields[li] = f;
                _resolvedLabelC[li] = _getProp(s[1], 8);
                _resolvedValueC[li] = _getProp(s[2], 0);
                return;
            }
        }
        _resolvedFields[li] = _getProp(key + "Primary", FIELD_NONE);
        _resolvedLabelC[li] = _getProp(key + "PrimaryLabelColor", 8);
        _resolvedValueC[li] = _getProp(key + "PrimaryValueColor", 0);
    }

    private function _resolveLineGraph(li as Number) as Void {
        _lineSecType[li] = SEC_NONE;
        _lineValueMode[li] = 0;
        _lineViewMode[li] = VIEW_VALUE;
        _lineGraphType[li] = GRAPH_LINE;
        _linePeriodMin[li] = 60;
        _lineGraphColor[li] = 0;
        var field = _resolvedFields[li];
        if (field == FIELD_STEPS) {
            var showBar = _getBoolProp("stepsShowBar");
            var showVal = _getBoolProp("stepsShowBarValue");
            _lineViewMode[li] = showBar ? (showVal ? 2 : 1) : 0;
            _lineGraphColor[li] = _getProp("stepsBarColor", 1);
            return;
        }
        if (field == FIELD_FLOORS) {
            var showBar = _getBoolProp("floorsShowBar");
            var showVal = _getBoolProp("floorsShowBarValue");
            _lineViewMode[li] = showBar ? (showVal ? 2 : 1) : 0;
            _lineGraphColor[li] = _getProp("floorsBarColor", 1);
            return;
        }
        if (field == FIELD_INTENSITY_MIN) {
            var showBar = _getBoolProp("intensityMinShowBar");
            var showVal = _getBoolProp("intensityMinShowBarValue");
            _lineViewMode[li] = showBar ? (showVal ? 2 : 1) : 0;
            _lineGraphColor[li] = _getProp("intensityMinBarColor", 3);
            return;
        }
        if (field == FIELD_WX_FCST_TEMP) {
            var wxvm = _getProp("wxForecastViewMode", VIEW_GRAPH_VALUE);
            if (wxvm == VIEW_GRAPH_MAXMIN) {
                wxvm = VIEW_GRAPH_VALUE;
                _lineValueMode[li] = 2;
            } else {
                _lineValueMode[li] = _getProp("wxForecastValueMode", 1);
            }
            _lineViewMode[li] = wxvm;
            _lineGraphColor[li] = _getProp("wxForecastGraphColor", 16);
            _lineGraphType[li] = _getProp("wxForecastGraphType", GRAPH_BAR);
            _linePeriodMin[li] = _getProp("wxForecastTimeFrame", 12);
            return;
        }
        if (field == FIELD_WX_FCST_PRECIP) {
            _lineViewMode[li] = _getProp(
                "wxForecastPrecipViewMode",
                VIEW_GRAPH_VALUE
            );
            _lineValueMode[li] = _getProp("wxForecastPrecipValueMode", 1);
            _lineGraphColor[li] = _getProp("wxForecastPrecipGraphColor", 6);
            _lineGraphType[li] = _getProp(
                "wxForecastPrecipGraphType",
                GRAPH_BAR
            );
            _linePeriodMin[li] = _getProp("wxForecastPrecipTimeFrame", 12);
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
            return;
        }
        if (field == FIELD_WX_FCST_WIND) {
            _lineViewMode[li] = _getProp(
                "wxForecastWindViewMode",
                VIEW_GRAPH_VALUE
            );
            _lineValueMode[li] = _getProp("wxForecastWindValueMode", 1);
            _lineGraphColor[li] = _getProp("wxForecastWindGraphColor", 6);
            _lineGraphType[li] = _getProp("wxForecastWindGraphType", GRAPH_BAR);
            _linePeriodMin[li] = _getProp("wxForecastWindTimeFrame", 12);
            return;
        }
        if (field == FIELD_WX_FCST_HUMIDITY) {
            _lineViewMode[li] = _getProp(
                "wxForecastHumidityViewMode",
                VIEW_GRAPH_VALUE
            );
            _lineValueMode[li] = _getProp("wxForecastHumidityValueMode", 1);
            _lineGraphColor[li] = _getProp("wxForecastHumidityGraphColor", 2);
            _lineGraphType[li] = _getProp(
                "wxForecastHumidityGraphType",
                GRAPH_BAR
            );
            _linePeriodMin[li] = _getProp("wxForecastHumidityTimeFrame", 12);
            return;
        }
        if (field == FIELD_WX_FCST_UV) {
            _lineViewMode[li] = _getProp(
                "wxForecastUvViewMode",
                VIEW_GRAPH_VALUE
            );
            _lineValueMode[li] = _getProp("wxForecastUvValueMode", 2);
            _lineGraphColor[li] = _getProp("wxForecastUvGraphColor", 3);
            _lineGraphType[li] = _getProp("wxForecastUvGraphType", GRAPH_BAR);
            _linePeriodMin[li] = _getProp("wxForecastUvTimeFrame", 12);
            return;
        }
        if (field == FIELD_WX_FCST_CLOUD) {
            _lineViewMode[li] = _getProp(
                "wxForecastCloudViewMode",
                VIEW_GRAPH_VALUE
            );
            _lineValueMode[li] = _getProp("wxForecastCloudValueMode", 1);
            _lineGraphColor[li] = _getProp("wxForecastCloudGraphColor", 8);
            _lineGraphType[li] = _getProp(
                "wxForecastCloudGraphType",
                GRAPH_BAR
            );
            _linePeriodMin[li] = _getProp("wxForecastCloudTimeFrame", 12);
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
            field == FIELD_HR || field == FIELD_HR_MEAN || field == FIELD_HR_MAX
                ? 5
                : 0
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
                return;
            }
            _drawFloorsRow(dc, cx, y, labelColor, valueColor);
            return;
        }
        if (field == FIELD_WX_TEMP_HIGH_LOW) {
            _drawTempMaxMinRow(dc, cx, y, labelColor, valueColor);
            return;
        }
        if (field == FIELD_WX_HIGH_LOW) {
            _drawHighLowRow(dc, cx, y, labelColor, valueColor);
            return;
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
            return;
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
            return;
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
            return;
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
            return;
        }
        if (field == FIELD_WX_UV) {
            _getFieldParts(field);
            _drawUvRow(dc, cx, y, _rowBuf[0], "", labelColor, valueColor);
            return;
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
            return;
        }
        if (field == FIELD_WX_UV_WIND) {
            _getFieldParts(field);
            _drawUvRow(dc, cx, y, _rowBuf[0], _wxWind, labelColor, valueColor);
            return;
        }
        if (field == FIELD_WX_TEMP_UV) {
            _getFieldParts(field);
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var x = cx + _splitPad;
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, _wxTemp, Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(_wxTemp, _font);
            _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valueColor);
            x += _degW;
            dc.drawText(x, y, _font, _wxUnit, Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(_wxUnit, _font);
            dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, " | ", Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(" | ", _font);
            _drawUvTag(dc, x, y, valueColor);
            return;
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
                    return;
                }
                var info = _amInfo as ActivityMonitor.Info;
                var steps = info.steps != null ? info.steps : 0;
                var goal = info.stepGoal != null ? info.stepGoal : 10000;
                _rowBuf[0] = "Steps";
                _rowBuf[1] = steps.format(
                    "%0" + goal.toString().length() + "d"
                );
                _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
                if (steps >= goal) {
                    dc.setColor(_colorFromIdx(1), Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        cx +
                            _splitPad +
                            dc.getTextWidthInPixels(_rowBuf[1], _font),
                        y,
                        _font,
                        " [GOAL]",
                        Graphics.TEXT_JUSTIFY_LEFT
                    );
                }
            }
            return;
        }
        if (field == FIELD_MOVE_BAR) {
            _drawMoveBarRow(dc, cx, y, labelColor, valueColor);
            return;
        }
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
            return;
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
            return;
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
            return;
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
            return;
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
            return;
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
            return;
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
            return;
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
            return;
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
            return;
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
                return;
            }
        }
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
            return;
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
            return;
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
            return;
        }
        if (field == FIELD_WX_HUMIDITY_DEW) {
            _drawHumidityDewRow(dc, cx, y, labelColor, valueColor);
            return;
        }
        if (field == FIELD_HEADING) {
            _getFieldParts(field);
            var valStr = _rowBuf[1];
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var x = cx + _splitPad;
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, valStr, Graphics.TEXT_JUSTIFY_LEFT);
            if (!valStr.equals("-")) {
                x += dc.getTextWidthInPixels(valStr, _font);
                _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valueColor);
            }
            return;
        }
        if (field == FIELD_ASCENT_DESCENT) {
            var up = "-";
            var dn = "-";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.totalAscent != null) {
                    var m = (a.totalAscent as Number).toFloat();
                    up = _altStr(m);
                }
                if (a.totalDescent != null) {
                    var m = (a.totalDescent as Number).toFloat();
                    dn = _altStr(m);
                }
            }
            _drawUpDownRow(
                dc,
                cx,
                y,
                "Ascent+Desc",
                up,
                dn,
                labelColor,
                valueColor
            );
            return;
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
            return;
        }
        if (field == FIELD_GPS_ACCURACY) {
            _getFieldParts(field);
            var val = _rowBuf[1];
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var pos = _posInfo;
            dc.setColor(
                pos != null ? _GPSQualityColor(pos.accuracy) : 0xffffff,
                Graphics.COLOR_TRANSPARENT
            );
            dc.drawText(
                cx + _splitPad,
                y,
                _font,
                val,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            return;
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
                dc.setColor(
                    pos != null ? _GPSQualityColor(pos.accuracy) : 0xffffff,
                    Graphics.COLOR_TRANSPARENT
                );
                dc.drawText(
                    vx,
                    y,
                    _font,
                    full.substring(sepIdx, full.length()) as String,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            } else {
                _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            }
            return;
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
                return;
            }
        }
        _getFieldParts(field);
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
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
        var steps = info.steps != null ? info.steps as Number : 0;
        var goal = info.stepGoal != null ? info.stepGoal as Number : 0;
        if (goal <= 0) {
            goal = 10000;
        }
        _rowBuf[0] = "Steps";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var gx = cx + _splitPad + _charW;
        var gw = _charW * 12;
        var barH = _fh;
        var barY = y;
        dc.setColor(GRAYS[1], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(gx, barY, gw, barH);
        var frac = steps.toFloat() / goal.toFloat();
        if (frac > 1.0) {
            frac = 1.0;
        }
        var fillW = (frac * gw.toFloat()).toNumber();
        if (fillW > 0) {
            var fillColor =
                steps >= goal ? _colorFromIdx(1) : _colorFromIdx(barColor);
            dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(gx, barY, fillW, barH);
        }
        var labelY = y + (_fh - _tinyFh) / 2 - 1;
        var goalStr = goal.toString();
        dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx - 4,
            labelY,
            _fontTiny,
            "0",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.drawText(
            gx + gw + 4,
            labelY,
            _fontTiny,
            goalStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );
        if (showValue) {
            var valY = y + (_fh - _smallFh) / 2 - 1;
            var valX = gx + gw / 2;
            var stepsStr = steps.format("%0" + goalStr.length() + "d");
            dc.setColor(GRAYS[0], Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                valX - 1,
                valY - 1,
                _fontSmall,
                stepsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX + 1,
                valY - 1,
                _fontSmall,
                stepsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX - 1,
                valY + 1,
                _fontSmall,
                stepsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX + 1,
                valY + 1,
                _fontSmall,
                stepsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                valX,
                valY,
                _fontSmall,
                stepsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            if (steps >= goal) {
                dc.setColor(_colorFromIdx(1), Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    gx + gw + _charW * (goalStr.length() - 1),
                    valY,
                    _fontSmall,
                    "[GOAL]",
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
        }
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
            info.floorsClimbed != null ? info.floorsClimbed : 0
        ).toString();
        var dn = (
            info.floorsDescended != null ? info.floorsDescended : 0
        ).toString();
        _rowBuf[0] = "Floors";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelIdx, valIdx);
        var ay = y + (_fh - _arrowH) / 2 + 1;
        var x = cx + _splitPad;
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        var upSpace = up + " ";
        dc.drawText(x, y, _font, upSpace, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(upSpace, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        dc.drawText(x, y, _font, dn, Graphics.TEXT_JUSTIFY_LEFT);
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
        var floors =
            info.floorsClimbed != null ? info.floorsClimbed as Number : 0;
        var goal = 10;
        if (info has :floorsClimbedGoal && info.floorsClimbedGoal != null) {
            goal = info.floorsClimbedGoal as Number;
        }
        if (goal <= 0) {
            goal = 10;
        }
        _rowBuf[0] = "Floors";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var gx = cx + _splitPad + _charW;
        var gw = _charW * 12;
        var barH = _fh;
        var barY = y;
        dc.setColor(GRAYS[1], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(gx, barY, gw, barH);
        var frac = floors.toFloat() / goal.toFloat();
        if (frac > 1.0) {
            frac = 1.0;
        }
        var fillW = (frac * gw.toFloat()).toNumber();
        if (fillW > 0) {
            var fillColor =
                floors >= goal ? _colorFromIdx(1) : _colorFromIdx(barColor);
            dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(gx, barY, fillW, barH);
        }
        var labelY = y + (_fh - _tinyFh) / 2 - 1;
        var goalStr = goal.toString();
        dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx - 4,
            labelY,
            _fontTiny,
            "0",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.drawText(
            gx + gw + 4,
            labelY,
            _fontTiny,
            goalStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );
        if (showValue) {
            var valY = y + (_fh - _smallFh) / 2 - 1;
            var valX = gx + gw / 2;
            var floorsStr = floors.format("%0" + goalStr.length() + "d");
            dc.setColor(GRAYS[0], Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                valX - 1,
                valY - 1,
                _fontSmall,
                floorsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX + 1,
                valY - 1,
                _fontSmall,
                floorsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX - 1,
                valY + 1,
                _fontSmall,
                floorsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX + 1,
                valY + 1,
                _fontSmall,
                floorsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                valX,
                valY,
                _fontSmall,
                floorsStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            if (floors >= goal) {
                dc.setColor(_colorFromIdx(1), Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    gx + gw + _charW * (goalStr.length() - 1),
                    valY,
                    _fontSmall,
                    "[GOAL]",
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
        }
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
        var current =
            mins != null && mins.total != null ? mins.total as Number : 0;
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
        _rowBuf[0] = "Intens Min";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var gx = cx + _splitPad + _charW;
        var gw = _charW * 12;
        var barH = _fh;
        var barY = y;
        dc.setColor(GRAYS[1], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(gx, barY, gw, barH);
        var frac = current.toFloat() / goal.toFloat();
        if (frac > 1.0) {
            frac = 1.0;
        }
        var fillW = (frac * gw.toFloat()).toNumber();
        if (fillW > 0) {
            var fillColor =
                current >= goal ? _colorFromIdx(1) : _colorFromIdx(barColor);
            dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(gx, barY, fillW, barH);
        }
        var labelY = y + (_fh - _tinyFh) / 2 - 1;
        var goalStr = goal.toString();
        dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx - 4,
            labelY,
            _fontTiny,
            "0",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.drawText(
            gx + gw + 4,
            labelY,
            _fontTiny,
            goalStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );
        if (showValue) {
            var valY = y + (_fh - _smallFh) / 2 - 1;
            var valX = gx + gw / 2;
            var curStr = current.format("%0" + goalStr.length() + "d");
            dc.setColor(GRAYS[0], Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                valX - 1,
                valY - 1,
                _fontSmall,
                curStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX + 1,
                valY - 1,
                _fontSmall,
                curStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX - 1,
                valY + 1,
                _fontSmall,
                curStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                valX + 1,
                valY + 1,
                _fontSmall,
                curStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                valX,
                valY,
                _fontSmall,
                curStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
            if (current >= goal) {
                dc.setColor(_colorFromIdx(1), Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    gx + gw + _charW * (goalStr.length() - 1),
                    valY,
                    _fontSmall,
                    "[GOAL]",
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
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
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        var upSpace = up + " ";
        dc.drawText(x, y, _font, upSpace, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(upSpace, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        dc.drawText(x, y, _font, dn, Graphics.TEXT_JUSTIFY_LEFT);
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
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, numStr, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(numStr, _font);
        _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valIdx);
        x += _degW;
        dc.drawText(x, y, _font, _wxUnit, Graphics.TEXT_JUSTIFY_LEFT);
        if (suffix.length() > 0) {
            x += dc.getTextWidthInPixels(_wxUnit, _font);
            dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, " | ", Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(" | ", _font);
            dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, suffix, Graphics.TEXT_JUSTIFY_LEFT);
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
            dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, "-", Graphics.TEXT_JUSTIFY_LEFT);
            return x + dc.getTextWidthInPixels("-", _font);
        }
        var numStr = _wxUvNum.toString();
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, numStr, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(numStr, _font);
        var tag = _uvTag();
        dc.setColor(_colorFromIdx(_uvColorIdx()), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, tag, Graphics.TEXT_JUSTIFY_LEFT);
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
            dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, " | ", Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(" | ", _font);
            dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, suffix, Graphics.TEXT_JUSTIFY_LEFT);
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
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, _wxTemp, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxTemp, _font);
        _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valIdx);
        x += _degW;
        var unitBrk = _wxUnit + " [";
        dc.drawText(x, y, _font, unitBrk, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(unitBrk, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        var highBrk = _wxHigh + "] [";
        dc.drawText(x, y, _font, highBrk, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(highBrk, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        dc.drawText(x, y, _font, _wxLow + "]", Graphics.TEXT_JUSTIFY_LEFT);
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
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        dc.drawText(x, y, _font, _wxHigh, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxHigh, _font);
        _drawIcon(dc, x, dy, ICON_DEG, valIdx);
        x += _degW;
        dc.drawText(x, y, _font, _wxUnit, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxUnit, _font);
        dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, " / ", Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(" / ", _font);
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        dc.drawText(x, y, _font, _wxLow, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxLow, _font);
        _drawIcon(dc, x, dy, ICON_DEG, valIdx);
        x += _degW;
        dc.drawText(x, y, _font, _wxUnit, Graphics.TEXT_JUSTIFY_LEFT);
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
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, _wxHumidity, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxHumidity, _font);
        dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, " | ", Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(" | ", _font);
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, _wxDewPoint, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxDewPoint, _font);
        _drawIcon(dc, x, dy, ICON_DEG, valIdx);
        x += _degW;
        dc.drawText(x, y, _font, _wxUnit, Graphics.TEXT_JUSTIFY_LEFT);
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

        dc.setColor(_colorFromIdx(labelColorIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, _font, ": ", Graphics.TEXT_JUSTIFY_CENTER);
        if (label.length() > 0) {
            dc.drawText(
                cx - _splitPad,
                y,
                _font,
                label,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
        }
        if (value.length() > 0) {
            dc.setColor(
                _colorFromIdx(valueColorIdx),
                Graphics.COLOR_TRANSPARENT
            );
            var sepIdx = value.find(" | ");
            if (sepIdx != null) {
                var vx = cx + _splitPad;
                var part1 = value.substring(0, sepIdx);
                var part2 = value.substring(sepIdx + 3, value.length());
                dc.drawText(vx, y, _font, part1, Graphics.TEXT_JUSTIFY_LEFT);
                vx += dc.getTextWidthInPixels(part1, _font);
                dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
                dc.drawText(vx, y, _font, " | ", Graphics.TEXT_JUSTIFY_LEFT);
                vx += dc.getTextWidthInPixels(" | ", _font);
                dc.setColor(
                    _colorFromIdx(valueColorIdx),
                    Graphics.COLOR_TRANSPARENT
                );
                dc.drawText(vx, y, _font, part2, Graphics.TEXT_JUSTIFY_LEFT);
            } else {
                dc.drawText(
                    cx + _splitPad,
                    y,
                    _font,
                    value,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
        }
    }

    private function _colorFromIdx(idx as Number) as Number {
        return idx >= 0 && idx < 10 ? COLORS[idx] : 0xffffff;
    }

    private function _GPSQualityColor(acc as Number) as Number {
        if (acc == Position.QUALITY_GOOD) {
            return COLORS[1];
        }
        if (acc == Position.QUALITY_USABLE) {
            return COLORS[3];
        }
        if (acc == Position.QUALITY_POOR) {
            return COLORS[4];
        }
        if (acc == Position.QUALITY_LAST_KNOWN) {
            return COLORS[8];
        }
        if (acc == Position.QUALITY_NOT_AVAILABLE) {
            return COLORS[5];
        }
        return 0xffffff;
    }

    private function _gradFromStops(
        stops as Array<Number>,
        fraction as Float
    ) as Number {
        var n = stops.size();
        if (fraction <= 0.0) {
            return stops[0] as Number;
        }
        if (fraction >= 1.0) {
            return stops[n - 1] as Number;
        }
        var scaled = fraction * (n - 1).toFloat();
        var i = scaled.toNumber();
        if (i >= n - 1) {
            return stops[n - 1] as Number;
        }
        var t = scaled - i.toFloat();
        var ca = stops[i] as Number;
        var cb = stops[i + 1] as Number;
        var r =
            ((ca >> 16) & 0xff) +
            (t * (((cb >> 16) & 0xff) - ((ca >> 16) & 0xff))).toNumber();
        var g =
            ((ca >> 8) & 0xff) +
            (t * (((cb >> 8) & 0xff) - ((ca >> 8) & 0xff))).toNumber();
        var b = (ca & 0xff) + (t * ((cb & 0xff) - (ca & 0xff))).toNumber();
        return ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff);
    }

    private function _withAlpha(color as Number, alpha as Number) as Number {
        return (alpha << 24) | (color & 0xffffff);
    }

    private function _gradColor(
        colorIdx as Number,
        fraction as Float
    ) as Number {
        switch (colorIdx) {
            case COLOR_GRAD_TRI:
                return _gradFromStops(TRI_GRAD, fraction);
            case COLOR_GRAD_TRI_REV:
                return _gradFromStops(TRI_GRAD, 1.0 - fraction);
            case COLOR_GRAD_TEMP_CUSTOM:
                return _gradFromStops(TEMP_GRADS[0] as Array<Number>, fraction);
            case COLOR_GRAD_TEMP_CUSTOM_REV:
                return _gradFromStops(
                    TEMP_GRADS[0] as Array<Number>,
                    1.0 - fraction
                );
            case COLOR_GRAD_TEMP_SPECTRAL:
                return _gradFromStops(TEMP_GRADS[1] as Array<Number>, fraction);
            case COLOR_GRAD_TEMP_SPECTRAL_REV:
                return _gradFromStops(
                    TEMP_GRADS[1] as Array<Number>,
                    1.0 - fraction
                );
            case COLOR_GRAD_TEMP_TURBO:
                return _gradFromStops(TEMP_GRADS[2] as Array<Number>, fraction);
            case COLOR_GRAD_TEMP_TURBO_REV:
                return _gradFromStops(
                    TEMP_GRADS[2] as Array<Number>,
                    1.0 - fraction
                );
            case COLOR_GRAD_TEMP_INFERNO:
                return _gradFromStops(TEMP_GRADS[3] as Array<Number>, fraction);
            case COLOR_GRAD_TEMP_INFERNO_REV:
                return _gradFromStops(
                    TEMP_GRADS[3] as Array<Number>,
                    1.0 - fraction
                );
            default:
                return _colorFromIdx(colorIdx);
        }
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
            if (
                field == FIELD_HR ||
                field == FIELD_HR_MEAN ||
                field == FIELD_HR_MAX
            ) {
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

    private function _fieldShortName(field as Number) as String {
        if (
            field == FIELD_HR ||
            field == FIELD_HR_MEAN ||
            field == FIELD_HR_MAX
        ) {
            return "HR";
        }
        if (field == FIELD_BODY_BAT) {
            return "BB";
        }
        if (field == FIELD_STRESS) {
            return "Str";
        }
        if (field == FIELD_SPO2) {
            return "O2";
        }
        if (field == FIELD_WRIST_TEMP) {
            return "Tmp";
        }
        if (field == FIELD_ELEVATION) {
            return "Elv";
        }
        if (field == FIELD_PRESSURE) {
            return "hPa";
        }
        return "?";
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
        var dualCacheKey = (field * 100 + fieldSecondary) * 10000 + periodMin;
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
        if (
            field == FIELD_HR ||
            field == FIELD_HR_MEAN ||
            field == FIELD_HR_MAX
        ) {
            _drawHrZones(dc, _graphX, _graphW, y, _graphH, minV, range);
        }

        // Secondary min/max outside right
        if (data2 != null) {
            dc.setColor(
                _gradColor(lineColor2, maxFrac2),
                Graphics.COLOR_TRANSPARENT
            );
            dc.drawText(
                _graphX + _graphW + 4,
                y - 4,
                _fontTiny,
                _formatGraphLabel(fieldSecondary, maxV2),
                Graphics.TEXT_JUSTIFY_LEFT
            );
            dc.setColor(
                _gradColor(lineColor2, minFrac2),
                Graphics.COLOR_TRANSPARENT
            );
            dc.drawText(
                _graphX + _graphW + 4,
                y + _graphH - _tinyFh + 4,
                _fontTiny,
                _formatGraphLabel(fieldSecondary, minV2),
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }

        // Current values when graph+value mode — 3 normal spaces from graph edge, centered
        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = _graphX + _graphW + _charW * 3;
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
            dc.setColor(_colorFromIdx(lineColor), Graphics.COLOR_TRANSPARENT);
            _drawGraphValueLabel(dc, vx, startY, field, cur1);
            _getFieldParts(fieldSecondary);
            var cur2 = _rowBuf[1];
            var y2 = startY + _smallFh + 2;
            dc.setColor(_colorFromIdx(lineColor2), Graphics.COLOR_TRANSPARENT);
            _drawGraphValueLabel(dc, vx, y2, fieldSecondary, cur2);
        }

        // Primary min/max outside left
        dc.setColor(
            _gradColor(lineColor, maxFrac1),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            _graphX - 4,
            y - 4,
            _fontTiny,
            _formatGraphLabel(field, maxV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.setColor(
            _gradColor(lineColor, minFrac1),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            _graphX - 4,
            y + _graphH - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(field, minV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        var yBelow = y + _graphH + 1;
        var secName = _fieldShortName(fieldSecondary);
        dc.setColor(_colorFromIdx(lineColor2), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _graphX + _graphW,
            yBelow,
            _fontTiny,
            secName,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _graphX + _graphW - dc.getTextWidthInPixels(secName, _fontTiny),
            yBelow,
            _fontTiny,
            _effPeriodLabel(field, periodMin) + " ",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        var effKeyDual = field * 10000 + periodMin;
        var ageSecDual = _dataAge(
            data,
            _graphEffPeriod.hasKey(effKeyDual)
                ? _graphEffPeriod.get(effKeyDual) as Number
                : periodMin
        );
        if (ageSecDual > _fieldUpdateMin(field) * SECS_PER_MIN + 30) {
            dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                _graphX,
                yBelow,
                _fontTiny,
                _formatAge(ageSecDual),
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }

    private function _fieldGraphKey(field as Number) as String? {
        if (
            field == FIELD_HR ||
            field == FIELD_HR_MEAN ||
            field == FIELD_HR_MAX
        ) {
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

    // Buckets sensor history into gw time-aligned slots so that periods without
    // data (e.g. watch off wrist) appear as gaps in the graph rather than being
    // silently compressed against neighbouring readings.
    // slot 0 = most-recent (right edge), slot gw-1 = oldest (left edge).
    // skipZero: discard samples where data == 0 before slotting.
    // Use for HR — the device stores 0 bpm when off-wrist instead of null.
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
        while (s != null) {
            if (s.data != null) {
                var v = s.data;
                var fv =
                    v instanceof Float ? v as Float : (v as Number).toFloat();
                if (!skipZero || fv != 0.0) {
                    var age = now - (s.when as Time.Moment).value();
                    if (age >= 0 && age < periodSec) {
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
            }
            s = iter.next();
        }
        if (count < 2) {
            return null;
        }
        // If the API returned less than 90 % of the requested period (e.g.
        // elevation only covers ~6.5 h of an 8 h window), stretch the occupied
        // slots to fill the full graph width so the left side isn't empty.
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
        // Gap threshold in slots: 10 min expressed in terms of the effective
        // period so that off-wrist gaps (>10 min) stay null and sensor-cadence
        // gaps are interpolated.
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
        var cacheKey = field * 10000 + periodMin;
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
        if (
            field == FIELD_HR ||
            field == FIELD_HR_MEAN ||
            field == FIELD_HR_MAX
        ) {
            return _cacheResult(
                cacheKey,
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
        return _metric ? v.format("%.1f") : _celsiusToF(v).format("%.1f");
    }

    private function _tempStr0(v as Float) as String {
        return _metric ? v.format("%.0f") : _celsiusToF(v).format("%.0f");
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
        if (
            field == FIELD_HR ||
            field == FIELD_HR_MEAN ||
            field == FIELD_HR_MAX
        ) {
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

    private function _secsToTime(secs as Number) as String {
        var h = secs / SECS_PER_HOUR;
        var m = (secs % SECS_PER_HOUR) / SECS_PER_MIN;
        return h.format("%d") + ":" + m.format("%02d");
    }

    private function _secsToRace(secs as Number) as String {
        var h = secs / SECS_PER_HOUR;
        var m = (secs % SECS_PER_HOUR) / SECS_PER_MIN;
        var s = secs % SECS_PER_MIN;
        if (h > 0) {
            return (
                h.format("%d") + ":" + m.format("%02d") + ":" + s.format("%02d")
            );
        }
        return m.format("%d") + ":" + s.format("%02d");
    }

    private function _periodLabel(periodMin as Number) as String {
        return periodMin < 60
            ? "-" + periodMin.toString() + "m"
            : "-" + (periodMin / 60).toString() + "h";
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

    private function _formatAge(ageSec as Number) as String {
        if (ageSec < SECS_PER_MIN) {
            return ">" + ageSec.toString() + "s";
        }
        if (ageSec < SECS_PER_HOUR) {
            return ">" + (ageSec / SECS_PER_MIN).toString() + "m";
        }
        return ">" + (ageSec / SECS_PER_HOUR).toString() + "h";
    }

    private function _cacheResult(
        cacheKey as Number,
        r as Array<Float>?
    ) as Array<Float>? {
        _graphCache.put(cacheKey, r);
        _graphBmpCache.remove(cacheKey);
        _graphBmpDualCache = {};
        if (_pendingEffPeriod > 0) {
            _graphEffPeriod.put(cacheKey, _pendingEffPeriod);
            _pendingEffPeriod = 0;
        }
        return r;
    }

    // Renders graph content (mean line + bars/lines) to a cached BufferedBitmap.
    // The bitmap is keyed by cacheKey and invalidated whenever _cacheResult is
    // called for that key (i.e. when fresh sensor data arrives).
    // gx/y offsets are NOT applied here — the bitmap is blitted at (gx, y) by
    // the caller so all drawing uses (0, 0) as the top-left origin.
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
        var newRef = Graphics.createBufferedBitmap({
            :width => gw,
            :height => gh + 1,
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
        var newRef = Graphics.createBufferedBitmap({
            :width => gw,
            :height => gh + 1,
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

    // Label showing the actual displayed time range (may be shorter than the
    // requested period when the API returns fewer samples than requested).
    private function _effPeriodLabel(
        field as Number,
        periodMin as Number
    ) as String {
        var key = field * 10000 + periodMin;
        var eff = _graphEffPeriod.hasKey(key)
            ? _graphEffPeriod.get(key) as Number
            : periodMin;
        return _periodLabel(eff > 0 ? eff : periodMin);
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
        return isGrad ? _gradColor(colorIdx, frac) : _colorFromIdx(0);
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
        dc.setColor(
            _graphLabelColor(colorIdx, isGrad, maxFrac),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            gx - 4,
            y - 4,
            _fontTiny,
            _formatGraphLabel(field, maxV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.setColor(
            _graphLabelColor(colorIdx, isGrad, minFrac),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            gx - 4,
            y + gh - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(field, minV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx + gw,
            y + gh + 1,
            _fontTiny,
            bottomLabel,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        if (ageSec > _fieldUpdateMin(field) * SECS_PER_MIN + 30) {
            dc.drawText(
                gx,
                y + gh + 1,
                _fontTiny,
                _formatAge(ageSec),
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }

    private function _drawGraphAxes(
        dc as Dc,
        gx as Number,
        gw as Number,
        y as Number
    ) as Void {
        dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
        dc.drawLine(gx - 1, y, gx - 1, y + _fh - 1);
        dc.drawLine(gx - 1, y + _fh - 1, gx + gw, y + _fh - 1);
        dc.drawLine(gx + gw, y, gx + gw, y + _fh - 1);
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
        var lastI = -1;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var x = gx + ((n1 - i) * gw) / n1;
            var py = y + gh - (((v - minV) * ghf) / range).toNumber();
            if (lastX >= 0 && i - lastI <= maxGap) {
                dc.drawLine(x, py, lastX, lastY);
            }
            dc.fillRectangle(x, py, 1, 1);
            lastX = x;
            lastY = py;
            lastI = i;
        }
    }

    private function _drawDashedH(
        dc as Dc,
        x1 as Number,
        x2 as Number,
        y as Number
    ) as Void {
        var w = x2 - x1;
        if (w <= 0) {
            return;
        }
        if (w <= 3) {
            dc.drawLine(x1, y, x2 - 1, y);
            return;
        }
        // All interior gaps = 2px. All interior dashes = 2px.
        // Endpoint (first + last) dashes are 1 or 2px — equal to each other,
        // chosen so everything sums to exactly w with no rounding.
        // n = ceil((w+2)/4); f = (w + 6 - 4*n) / 2  →  always 1 or 2 for even w.
        var n = (w + 5) / 4;
        if (n < 2) {
            n = 2;
        }
        var f = (w + 6 - 4 * n) / 2;
        if (f < 1) {
            f = 1;
        }
        dc.drawLine(x1, y, x1 + f - 1, y);
        var x = x1 + f + 2;
        for (var i = 1; i < n - 1; i++) {
            dc.drawLine(x, y, x + 1, y);
            x += 4;
        }
        dc.drawLine(x2 - f, y, x2 - 1, y);
    }

    private function _drawDashedV(
        dc as Dc,
        x as Number,
        y1 as Number,
        y2 as Number
    ) as Void {
        var h = y2 - y1;
        if (h <= 0) {
            return;
        }
        if (h <= 3) {
            dc.drawLine(x, y1, x, y2 - 1);
            return;
        }
        var n = (h + 5) / 4;
        if (n < 2) {
            n = 2;
        }
        var f = (h + 6 - 4 * n) / 2;
        if (f < 1) {
            f = 1;
        }
        dc.drawLine(x, y1, x, y1 + f - 1);
        var yp = y1 + f + 2;
        for (var i = 1; i < n - 1; i++) {
            dc.drawLine(x, yp, x, yp + 1);
            yp += 4;
        }
        dc.drawLine(x, y2 - f, x, y2 - 1);
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
                ? _gradColor(colorIdx, meanFrac)
                : GRAYS[3];
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        _drawDashedH(dc, gx, gx + gw, meanY);
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
                dc.setColor(
                    _gradColor(colorIdx, mfrac),
                    Graphics.COLOR_TRANSPARENT
                );
                dc.drawLine(x, py, lastX, lastY);
            }
            var frac = (v - gradMinV) / gradRange;
            if (frac < 0.0) {
                frac = 0.0;
            }
            if (frac > 1.0) {
                frac = 1.0;
            }
            dc.setColor(_gradColor(colorIdx, frac), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x, py, 1, 1);
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
        range as Float
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
            dc.fillRectangle(bx, y + gh - barH, bw, barH);
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
            dc.setColor(_gradColor(colorIdx, frac), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(bx, y + gh - barH, bw, barH);
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
                dc.setColor(
                    _gradColor(colorIdx1, frac1),
                    Graphics.COLOR_TRANSPARENT
                );
                dc.fillRectangle(slotX, y + gh - barH, hw, barH);
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
                dc.setColor(
                    _gradColor(colorIdx2, frac2),
                    Graphics.COLOR_TRANSPARENT
                );
                dc.fillRectangle(slotX + hw, y + gh - barH2, slotW - hw, barH2);
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
        _calcGradRange(FIELD_WX_FCST_TEMP, lineColor, minV, range);
        var gradMinV = _gradMin;
        var gradRange = _gradRange;
        var maxFrac = _clampFrac(maxV);
        var minFrac = _clampFrac(minV);

        _rowBuf[0] = "Temp Fcst";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var fcstTempBmp = _renderGraphToBitmap(
            FIELD_WX_FCST_TEMP * 10000 + hours,
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
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            if (valueMode == 2) {
                var maxStr = _tempStr0(maxV);
                var minStr = _tempStr0(minV);
                vx = _drawSmallTempNum(dc, vx, vy, maxStr);
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    "/",
                    Graphics.TEXT_JUSTIFY_LEFT
                );
                vx += dc.getTextWidthInPixels("/", _fontSmall);
                vx = _drawSmallTempNum(dc, vx, vy, minStr);
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT
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
                vx = _drawSmallTempNum(dc, vx, vy, tStr);
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT
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
        dc.setColor(GRAYS[1], Graphics.COLOR_TRANSPARENT);
        var n = zones.size();
        for (var i = 0; i < n; i++) {
            var zv = (zones[i] as Number).toFloat();
            if (zv <= minV || zv >= minV + range) {
                continue;
            }
            var zy = y + gh - (((zv - minV) * gh.toFloat()) / range).toNumber();
            _drawDashedH(dc, gx, gx + gw, zy);
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
            dc.setColor(
                i < level ? _colorFromIdx(valueColor) : GRAYS[1],
                Graphics.COLOR_TRANSPARENT
            );
            dc.fillRectangle(gx + i * (blockW + 2), blockY, blockW, blockH);
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
        var prevX = -1;
        var prevPY = 0;
        var prevI = -1;
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
                    dc.drawLine(x, py < prevPY ? py : prevPY, x, bottom);
                } else {
                    for (var px = x; px <= prevX; px++) {
                        var lerpY = py + ((px - x) * (prevPY - py)) / dx;
                        dc.drawLine(px, lerpY, px, bottom);
                    }
                }
            } else {
                dc.drawLine(x, py, x, bottom);
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
        var prevX = -1;
        var prevPY = 0;
        var prevV = 0.0 as Float;
        var prevI = -1;
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
                        _withAlpha(_gradColor(colorIdx, frac), _areaOpacity)
                    );
                    dc.drawLine(x, py < prevPY ? py : prevPY, x, bottom);
                } else {
                    for (var px = x; px <= prevX; px++) {
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
                            _withAlpha(_gradColor(colorIdx, frac), _areaOpacity)
                        );
                        dc.drawLine(px, lerpY, px, bottom);
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
                    _withAlpha(_gradColor(colorIdx, frac), _areaOpacity)
                );
                dc.drawLine(x, py, x, bottom);
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
        _calcGradRange(fieldConst, lineColor, minV, range);
        var gradMinV = _gradMin;
        var gradRange = _gradRange;
        var maxFrac = _clampFrac(maxV);
        var minFrac = _clampFrac(minV);
        _rowBuf[0] = label;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var fcstBmp = _renderGraphToBitmap(
            fieldConst * 10000 + hours,
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
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(vx, vy, _fontSmall, valStr, Graphics.TEXT_JUSTIFY_LEFT);
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
        _calcGradRange(FIELD_WX_FCST_TEMP, colorIdx, allMin, range);
        _rowBuf[0] = "Day Fcst";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var ghf = _graphH.toFloat();
        var bottom = y + _graphH;
        dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
        for (var si = 1; si < n; si++) {
            _drawDashedV(dc, _graphX + (si * _graphW) / n - 1, y, y + _graphH);
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
            dc.setColor(_gradColor(colorIdx, frac), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(slotX, hiY, bw, barH);
        }
        _drawRowAxes(dc, y);
        var isGrad = colorIdx >= COLOR_GRAD_TRI;
        var maxFrac = _clampFrac(allMax);
        var minFrac = _clampFrac(allMin);
        dc.setColor(
            _graphLabelColor(colorIdx, isGrad, maxFrac),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            _graphX - 4,
            y - 4,
            _fontTiny,
            _formatGraphLabel(FIELD_WX_FCST_TEMP, allMax),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.setColor(
            _graphLabelColor(colorIdx, isGrad, minFrac),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            _graphX - 4,
            y + _graphH - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(FIELD_WX_FCST_TEMP, allMin),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        var dayNames = ["S", "M", "T", "W", "T", "F", "S"] as Array<String>;
        var todayDow = 0;
        if (_clockInfo != null) {
            var ci = _clockInfo as Gregorian.Info;
            var yr = ci.year as Number;
            var mo = ci.month as Number;
            var t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4] as Array<Number>;
            if (mo < 3) {
                yr -= 1;
            }
            todayDow =
                (yr +
                    yr / 4 -
                    yr / 100 +
                    yr / 400 +
                    t[mo - 1] +
                    (ci.day as Number)) %
                7;
        }
        var fDowSetting = System.getDeviceSettings().firstDayOfWeek;
        var firstDow =
            fDowSetting != null ? ((fDowSetting as Number) - 1) % 7 : 1;
        for (var di = 0; di < n; di++) {
            dc.setColor(
                (todayDow + di) % 7 == firstDow
                    ? _colorFromIdx(5)
                    : _colorFromIdx(8),
                Graphics.COLOR_TRANSPARENT
            );
            var slotX = _graphX + (di * _graphW) / n;
            var slotEnd = _graphX + ((di + 1) * _graphW) / n;
            var bw = slotEnd - slotX - (di < n - 1 ? 1 : 0);
            dc.drawText(
                slotX + bw / 2,
                y + _graphH + 1,
                _fontTiny,
                dayNames[(todayDow + di) % 7],
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = _graphX + _graphW + _charW;
            var vy = y + (_fh - _smallFh) / 2 - 1;
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            if (valueMode == 2) {
                var maxStr = _tempStr0(allMax);
                var minStr = _tempStr0(allMin);
                vx = _drawSmallTempNum(dc, vx, vy, maxStr);
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    "/",
                    Graphics.TEXT_JUSTIFY_LEFT
                );
                vx += dc.getTextWidthInPixels("/", _fontSmall);
                vx = _drawSmallTempNum(dc, vx, vy, minStr);
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT
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
                vx = _drawSmallTempNum(dc, vx, vy, tStr);
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT
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
                dc.setColor(
                    _colorFromIdx(colorIdx),
                    Graphics.COLOR_TRANSPARENT
                );
                _drawBars(dc, data, gx, gw, y, gh + 1, minV, range);
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
                dc.setStroke(_withAlpha(_colorFromIdx(colorIdx), _areaOpacity));
                _drawAreaLine(dc, data, gx, gw, y, gh, minV, range, maxGap);
                if (_areaShowLine) {
                    dc.setColor(
                        _colorFromIdx(colorIdx),
                        Graphics.COLOR_TRANSPARENT
                    );
                    _drawGraphLine(
                        dc,
                        data,
                        gx,
                        gw,
                        y,
                        gh,
                        minV,
                        range,
                        maxGap
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
                dc.setColor(
                    _colorFromIdx(colorIdx),
                    Graphics.COLOR_TRANSPARENT
                );
                _drawGraphLine(dc, data, gx, gw, y, gh, minV, range, maxGap);
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
        dc.setColor(GRAYS[3], Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx + gw / 2,
            y + gh / 2 - _tinyFh / 2 - 1,
            _fontTiny,
            "no data",
            Graphics.TEXT_JUSTIFY_CENTER
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
        var cacheKey = field * 10000 + periodMin;
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
        if (
            field == FIELD_HR ||
            field == FIELD_HR_MEAN ||
            field == FIELD_HR_MAX
        ) {
            _drawHrZones(dc, _graphX, _graphW, y, _graphH, minV, range);
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
            _effPeriodLabel(field, periodMin),
            lineColor,
            maxFrac,
            minFrac,
            _dataAge(
                data,
                _graphEffPeriod.hasKey(cacheKey)
                    ? _graphEffPeriod.get(cacheKey) as Number
                    : periodMin
            )
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
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            var valEndX = _drawGraphValueLabel(dc, valX, valY, field, valStr2);
            _drawValueModeLabel(dc, valEndX, y, valueMode);
        }
    }

    // Fields handled by special draw functions have early returns in _drawLineRow
    // and never reach here: FLOORS, WX_TEMP, WX_FEELS, WX_TEMP_COND, WX_TEMP_HIGH_LOW, WX_TEMP_WIND,
    // WX_UV, WX_TEMP_UV, WX_UV_PRECIP, WX_UV_WIND
    private function _getFieldParts(field as Number) as Void {
        if (field == FIELD_HR) {
            if (_acInfo == null) {
                _rowBuf[0] = "Heart";
                _rowBuf[1] = "-";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.currentHeartRate != null) {
                _rowBuf[0] = "Heart";
                _rowBuf[1] = (a.currentHeartRate as Number).toString() + " bpm";
                return;
            }
            _rowBuf[0] = "Heart";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_CALORIES) {
            if (_amInfo == null) {
                _rowBuf[0] = "Day Cals";
                _rowBuf[1] = "0 kcal";
                return;
            }
            var info = _amInfo as ActivityMonitor.Info;
            _rowBuf[0] = "Day Cals";
            _rowBuf[1] =
                (info.calories != null ? info.calories : 0).toString() +
                " kcal";
            return;
        }
        if (field == FIELD_DISTANCE) {
            if (_amInfo == null) {
                _rowBuf[0] = "Day Dist";
                _rowBuf[1] = "-";
                return;
            }
            var info = _amInfo as ActivityMonitor.Info;
            if (info.distance == null) {
                _rowBuf[0] = "Day Dist";
                _rowBuf[1] = "-";
                return;
            }
            if (_metric) {
                _rowBuf[0] = "Day Dist";
                _rowBuf[1] = (info.distance / 100000.0).format("%.2f") + "km";
                return;
            }
            _rowBuf[0] = "Day Dist";
            _rowBuf[1] = (info.distance / 160934.0).format("%.2f") + "mi";
            return;
        }
        if (field == FIELD_ALTITUDE) {
            if (_acInfo == null) {
                _rowBuf[0] = "Altitude";
                _rowBuf[1] = "-";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.altitude == null) {
                _rowBuf[0] = "Altitude";
                _rowBuf[1] = "-";
                return;
            }
            _rowBuf[0] = "Altitude";
            _rowBuf[1] = _altStr(a.altitude as Float);
            return;
        }
        if (field == FIELD_SPO2) {
            if (_acInfo == null) {
                _rowBuf[0] = "SpO2";
                _rowBuf[1] = "-";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.currentOxygenSaturation != null) {
                _rowBuf[0] = "SpO2";
                _rowBuf[1] = a.currentOxygenSaturation.format("%.0f") + "%";
                return;
            }
            _rowBuf[0] = "SpO2";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_INTENSITY_MIN) {
            if (_amInfo == null) {
                _rowBuf[0] = "Intens Min";
                _rowBuf[1] = "0";
                return;
            }
            var mins = (_amInfo as ActivityMonitor.Info).activeMinutesWeek;
            if (mins != null && mins.total != null) {
                _rowBuf[0] = "Intens Min";
                _rowBuf[1] = (mins.total as Number).toString();
                return;
            }
            _rowBuf[0] = "Intens Min";
            _rowBuf[1] = "0";
            return;
        }
        if (field == FIELD_WX_PRECIP) {
            _rowBuf[0] = "Rain %";
            _rowBuf[1] = _wxPrecip;
            return;
        }
        if (field == FIELD_WX_WIND) {
            _rowBuf[0] = "Wind Speed";
            _rowBuf[1] = _wxWind;
            return;
        }
        if (field == FIELD_WX_UV) {
            _rowBuf[0] = "UV Index";
            _rowBuf[1] = _wxUv;
            return;
        }
        if (field == FIELD_WX_COND) {
            _rowBuf[0] = "Weather";
            _rowBuf[1] = _wxCond;
            return;
        }
        if (field == FIELD_WX_COND_PRECIP) {
            _rowBuf[0] = "Cond+Rain";
            _rowBuf[1] = _wxCond + " | " + _wxPrecip;
            return;
        }
        if (field == FIELD_WX_WIND_PRECIP) {
            _rowBuf[0] = "Wind+Rain";
            _rowBuf[1] = _wxWind + " | " + _wxPrecip;
            return;
        }
        if (field == FIELD_STRESS) {
            _rowBuf[0] = "Stress";
            _rowBuf[1] = _cachedStress;
            return;
        }
        if (field == FIELD_BODY_BAT) {
            _rowBuf[0] = "Body Bat";
            _rowBuf[1] = _cachedBodyBat;
            return;
        }
        if (field == FIELD_RESP) {
            if (_amInfo == null) {
                _rowBuf[0] = "Resp Rate";
                _rowBuf[1] = "-";
                return;
            }
            var info = _amInfo as ActivityMonitor.Info;
            if (info.respirationRate != null) {
                _rowBuf[0] = "Resp Rate";
                _rowBuf[1] = (info.respirationRate as Number).toString() + "/m";
                return;
            }
            _rowBuf[0] = "Resp Rate";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_HR_MEAN) {
            if (_acInfo == null) {
                _rowBuf[0] = "Avg HR";
                _rowBuf[1] = "-";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.averageHeartRate != null) {
                _rowBuf[0] = "Avg HR";
                _rowBuf[1] = (a.averageHeartRate as Number).toString() + " bpm";
                return;
            }
            _rowBuf[0] = "Avg HR";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_CAL_ACT) {
            if (_acInfo == null) {
                _rowBuf[0] = "Active Cals";
                _rowBuf[1] = "0 kcal";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.calories != null) {
                _rowBuf[0] = "Active Cals";
                _rowBuf[1] = (a.calories as Number).toString() + " kcal";
                return;
            }
            _rowBuf[0] = "Active Cals";
            _rowBuf[1] = "0 kcal";
            return;
        }
        if (field == FIELD_RECOVERY) {
            if (_amInfo == null) {
                _rowBuf[0] = "Recovery";
                _rowBuf[1] = "-";
                return;
            }
            var info = _amInfo as ActivityMonitor.Info;
            if (info.timeToRecovery != null) {
                _rowBuf[0] = "Recovery";
                _rowBuf[1] = (info.timeToRecovery as Number).toString() + "h";
                return;
            }
            _rowBuf[0] = "Recovery";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_MOVE_BAR) {
            if (_amInfo == null) {
                _rowBuf[0] = "Move Bar";
                _rowBuf[1] = "-";
                return;
            }
            var info = _amInfo as ActivityMonitor.Info;
            if (info.moveBarLevel != null) {
                _rowBuf[0] = "Move Bar";
                _rowBuf[1] = (info.moveBarLevel as Number).toString() + "/5";
                return;
            }
            _rowBuf[0] = "Move Bar";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_WRIST_TEMP) {
            _rowBuf[0] = "Wrist Temp";
            _rowBuf[1] = _cachedTempWrist;
            return;
        }
        if (field == FIELD_ACTIVE_MIN_DAY) {
            if (_amInfo == null) {
                _rowBuf[0] = "Active Min";
                _rowBuf[1] = "0";
                return;
            }
            var mins = (_amInfo as ActivityMonitor.Info).activeMinutesDay;
            if (mins != null && mins.total != null) {
                _rowBuf[0] = "Active Min";
                _rowBuf[1] = (mins.total as Number).toString();
                return;
            }
            _rowBuf[0] = "Active Min";
            _rowBuf[1] = "0";
            return;
        }
        if (field == FIELD_HR_MAX) {
            if (_acInfo == null) {
                _rowBuf[0] = "Max HR";
                _rowBuf[1] = "-";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.maxHeartRate != null) {
                _rowBuf[0] = "Max HR";
                _rowBuf[1] = (a.maxHeartRate as Number).toString() + " bpm";
                return;
            }
            _rowBuf[0] = "Max HR";
            _rowBuf[1] = "-";
            return;
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
            return;
        }
        if (field == FIELD_ELEVATION) {
            _rowBuf[0] = "Elevation";
            _rowBuf[1] = _cachedElevation;
            return;
        }
        if (field == FIELD_WX_FCST_TEMP) {
            _rowBuf[0] = "Temp Fcst";
            _rowBuf[1] = _wxTemp + _wxUnit;
            return;
        }
        if (field == FIELD_WX_FCST_PRECIP) {
            _rowBuf[0] = "Rain %";
            _rowBuf[1] = _wxPrecip;
            return;
        }
        if (field == FIELD_WX_FCST_DAILY) {
            _rowBuf[0] = "Day Fcst";
            _rowBuf[1] = _wxTemp + _wxUnit;
            return;
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
                    return;
                }
            }
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_SLEEP) {
            _rowBuf[0] = "Sleep";
            _rowBuf[1] =
                _compSleepScore != null
                    ? (_compSleepScore as Number).toString()
                    : "-";
            return;
        }
        if (field == FIELD_SUNRISE) {
            _rowBuf[0] = "Sunrise";
            _rowBuf[1] =
                _compSunrise != null
                    ? _secsToTime(_compSunrise as Number)
                    : "-";
            return;
        }
        if (field == FIELD_SUNSET) {
            _rowBuf[0] = "Sunset";
            _rowBuf[1] =
                _compSunset != null ? _secsToTime(_compSunset as Number) : "-";
            return;
        }
        if (field == FIELD_SUNRISE_SUNSET) {
            var rise =
                _compSunrise != null
                    ? _secsToTime(_compSunrise as Number)
                    : "-";
            var set =
                _compSunset != null ? _secsToTime(_compSunset as Number) : "-";
            _rowBuf[0] = "Sunrise+Set";
            _rowBuf[1] = rise + " / " + set;
            return;
        }
        if (field == FIELD_CALENDAR) {
            _rowBuf[0] = "Calendar";
            _rowBuf[1] = _compCalendar != null ? _compCalendar as String : "-";
            return;
        }
        if (field == FIELD_WEEKLY_RUN) {
            if (_compWeeklyRun != null) {
                _rowBuf[0] = "Week Run";
                _rowBuf[1] = _distStr((_compWeeklyRun as Number).toFloat());
                return;
            }
            _rowBuf[0] = "Week Run";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_WEEKLY_BIKE) {
            if (_compWeeklyBike != null) {
                _rowBuf[0] = "Week Bike";
                _rowBuf[1] = _distStr((_compWeeklyBike as Number).toFloat());
                return;
            }
            _rowBuf[0] = "Week Bike";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_VO2_MAX) {
            _rowBuf[0] = "VO2 Max";
            _rowBuf[1] = _cachedVo2Max;
            return;
        }
        if (field == FIELD_SPEED) {
            if (_acInfo == null) {
                _rowBuf[0] = "Speed";
                _rowBuf[1] = "-";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.currentSpeed != null) {
                var spd = a.currentSpeed as Float;
                if (_metric) {
                    _rowBuf[0] = "Speed";
                    _rowBuf[1] = (spd * KMH_PER_MPS).format("%.1f") + " km/h";
                    return;
                }
                _rowBuf[0] = "Speed";
                _rowBuf[1] = (spd * MPH_PER_MPS).format("%.1f") + " mph";
                return;
            }
            _rowBuf[0] = "Speed";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_GPS_LAT) {
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                _rowBuf[0] = "Latitude";
                _rowBuf[1] = (coords[0] as Double).format("%.5f");
                return;
            }
            _rowBuf[0] = "Latitude";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_GPS_LON) {
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                _rowBuf[0] = "Longitude";
                _rowBuf[1] = (coords[1] as Double).format("%.5f");
                return;
            }
            _rowBuf[0] = "Longitude";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_GPS_ACCURACY) {
            var pos = _posInfo;
            if (pos != null) {
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
                _rowBuf[0] = "GPS Accur";
                _rowBuf[1] = label;
                return;
            }
            _rowBuf[0] = "GPS Accur";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_HEADING) {
            var pos = _posInfo;
            if (pos != null && pos.heading != null) {
                var deg = Math.toDegrees(pos.heading as Float).toNumber();
                deg = ((deg % 360) + 360) % 360;
                _rowBuf[0] = "Heading";
                _rowBuf[1] = deg.toString();
                return;
            }
            _rowBuf[0] = "Heading";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_GPS_LAT_LON) {
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                var lat = coords[0] as Double;
                var lon = coords[1] as Double;
                _rowBuf[0] = "Lat+Lon";
                _rowBuf[1] = lat.format("%.5f") + ", " + lon.format("%.5f");
                return;
            }
            _rowBuf[0] = "Lat+Lon";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_GPS_LAT_LON_ACC) {
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                var lat = coords[0] as Double;
                var lon = coords[1] as Double;
                var acc = pos.accuracy;
                var accLabel = "";
                if (acc == Position.QUALITY_GOOD) {
                    accLabel = " [GOOD]";
                } else if (acc == Position.QUALITY_USABLE) {
                    accLabel = " [FINE]";
                } else if (acc == Position.QUALITY_POOR) {
                    accLabel = " [POOR]";
                } else if (acc == Position.QUALITY_LAST_KNOWN) {
                    accLabel = " [LAST]";
                } else if (acc == Position.QUALITY_NOT_AVAILABLE) {
                    accLabel = " [N/A]";
                }
                _rowBuf[0] = "GPS";
                _rowBuf[1] =
                    lat.format("%.4f") + ", " + lon.format("%.4f") + accLabel;
                return;
            }
            _rowBuf[0] = "GPS";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_FLOORS) {
            if (_amInfo == null) {
                _rowBuf[0] = "Floors";
                _rowBuf[1] = "0/0";
                return;
            }
            var info = _amInfo as ActivityMonitor.Info;
            var up = (
                info.floorsClimbed != null ? info.floorsClimbed : 0
            ).toString();
            var dn = (
                info.floorsDescended != null ? info.floorsDescended : 0
            ).toString();
            _rowBuf[0] = "Floors";
            _rowBuf[1] = up + "/" + dn;
            return;
        }
        if (field == FIELD_WX_TEMP) {
            _rowBuf[0] = "Temp";
            _rowBuf[1] = _wxTemp + _wxUnit;
            return;
        }
        if (field == FIELD_WX_FEELS) {
            _rowBuf[0] = "Feels Like";
            _rowBuf[1] = _wxFeels + _wxUnit;
            return;
        }
        if (field == FIELD_WX_TEMP_COND) {
            _rowBuf[0] = "Temp+Cond";
            _rowBuf[1] = _wxTemp + _wxUnit + " | " + _wxCond;
            return;
        }
        if (field == FIELD_WX_TEMP_WIND) {
            _rowBuf[0] = "Temp+Wind";
            _rowBuf[1] = _wxTemp + _wxUnit + " | " + _wxWind;
            return;
        }
        if (field == FIELD_WX_TEMP_UV) {
            _rowBuf[0] = "Temp+UV";
            _rowBuf[1] = _wxTemp + _wxUnit + " | " + _wxUv;
            return;
        }
        if (field == FIELD_WX_UV_PRECIP) {
            _rowBuf[0] = "UV+Rain";
            _rowBuf[1] = _wxUv + " | " + _wxPrecip;
            return;
        }
        if (field == FIELD_WX_UV_WIND) {
            _rowBuf[0] = "UV+Wind";
            _rowBuf[1] = _wxUv + " | " + _wxWind;
            return;
        }
        if (field == FIELD_WX_TEMP_HIGH_LOW) {
            _rowBuf[0] = "Temp";
            _rowBuf[1] = _wxTemp + " " + _wxHigh + "/" + _wxLow + _wxUnit;
            return;
        }
        if (field == FIELD_STEPS) {
            if (_amInfo == null) {
                _rowBuf[0] = "Steps";
                _rowBuf[1] = "0";
                return;
            }
            var info = _amInfo as ActivityMonitor.Info;
            var steps = info.steps != null ? info.steps as Number : 0;
            var goal = info.stepGoal != null ? info.stepGoal as Number : 10000;
            var goalStr = goal.toString();
            _rowBuf[0] = "Steps";
            _rowBuf[1] =
                steps.format("%0" + goalStr.length() + "d") + "/" + goalStr;
            return;
        }
        if (field == FIELD_ELAPSED) {
            if (_acInfo == null) {
                _rowBuf[0] = "Elapsed";
                _rowBuf[1] = "-";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.elapsedTime != null) {
                var ms = a.elapsedTime as Number;
                var s = ms / 1000;
                var m = s / SECS_PER_MIN;
                var h = m / 60;
                _rowBuf[0] = "Elapsed";
                _rowBuf[1] =
                    h.format("%d") +
                    ":" +
                    (m % 60).format("%02d") +
                    ":" +
                    (s % SECS_PER_MIN).format("%02d");
                return;
            }
            _rowBuf[0] = "Elapsed";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_TRAINING_STATUS) {
            _rowBuf[0] = "Training";
            _rowBuf[1] =
                _compTrainingStatus != null
                    ? _trainingStatusStr(_compTrainingStatus as String)
                    : "-";
            return;
        }
        if (field == FIELD_RACE_5K) {
            _rowBuf[0] = "Race 5K";
            _rowBuf[1] =
                _compRace5k != null ? _secsToRace(_compRace5k as Number) : "-";
            return;
        }
        if (field == FIELD_RACE_10K) {
            _rowBuf[0] = "Race 10K";
            _rowBuf[1] =
                _compRace10k != null
                    ? _secsToRace(_compRace10k as Number)
                    : "-";
            return;
        }
        if (field == FIELD_RACE_HALF) {
            _rowBuf[0] = "Race Half";
            _rowBuf[1] =
                _compRaceHalf != null
                    ? _secsToRace(_compRaceHalf as Number)
                    : "-";
            return;
        }
        if (field == FIELD_RACE_MARATHON) {
            _rowBuf[0] = "Race Mar";
            _rowBuf[1] =
                _compRaceMarathon != null
                    ? _secsToRace(_compRaceMarathon as Number)
                    : "-";
            return;
        }
        if (field == FIELD_SLEEP_TIME) {
            _rowBuf[0] = "Bedtime";
            _rowBuf[1] = _cachedSleepTime;
            return;
        }
        if (field == FIELD_WAKE_TIME) {
            _rowBuf[0] = "Wake Time";
            _rowBuf[1] = _cachedWakeTime;
            return;
        }
        if (field == FIELD_WX_FCST_WIND) {
            _rowBuf[0] = "Wind Fcst";
            _rowBuf[1] = _wxWind;
            return;
        }
        if (field == FIELD_PACE) {
            _rowBuf[0] = "Pace";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (
                    a.currentSpeed != null &&
                    (a.currentSpeed as Float) > MIN_SPEED_MPS
                ) {
                    _rowBuf[1] = _formatPace(a.currentSpeed as Float);
                    return;
                }
            }
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_PACE_AVG) {
            _rowBuf[0] = "Avg Pace";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (
                    a.averageSpeed != null &&
                    (a.averageSpeed as Float) > MIN_SPEED_MPS
                ) {
                    _rowBuf[1] = _formatPace(a.averageSpeed as Float);
                    return;
                }
            }
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_WX_HUMIDITY) {
            _rowBuf[0] = "Humidity";
            _rowBuf[1] = _wxHumidity;
            return;
        }
        if (field == FIELD_WX_DEW_POINT) {
            _rowBuf[0] = "Dew Point";
            _rowBuf[1] = _wxDewPoint + _wxUnit;
            return;
        }
        if (field == FIELD_WX_VISIBILITY) {
            _rowBuf[0] = "Visibility";
            _rowBuf[1] = _wxVisibility;
            return;
        }
        if (field == FIELD_WX_CLOUD) {
            _rowBuf[0] = "Cloud Cover";
            _rowBuf[1] = _wxCloudCover;
            return;
        }
        if (field == FIELD_WX_HIGH_LOW) {
            _rowBuf[0] = "Temp Hi/Lo";
            _rowBuf[1] = _wxHigh + "/" + _wxLow + _wxUnit;
            return;
        }
        if (field == FIELD_WX_HUMIDITY_DEW) {
            _rowBuf[0] = "Hum+Dew";
            _rowBuf[1] = _wxHumidity + " | " + _wxDewPoint + _wxUnit;
            return;
        }
        if (field == FIELD_WX_HEAT_INDEX) {
            _rowBuf[0] = "Heat Index";
            _rowBuf[1] = _wxHeatIndex + _wxUnit;
            return;
        }
        if (field == FIELD_WX_FCST_HUMIDITY) {
            _rowBuf[0] = "Hum Fcst";
            _rowBuf[1] = _wxHumidity;
            return;
        }
        if (field == FIELD_WX_FCST_UV) {
            _rowBuf[0] = "UV Fcst";
            _rowBuf[1] = _wxUv;
            return;
        }
        if (field == FIELD_WX_FCST_CLOUD) {
            _rowBuf[0] = "Cloud Fcst";
            _rowBuf[1] = _wxCloudCover;
            return;
        }
        if (field == FIELD_RACE_PACE_5K) {
            _rowBuf[0] = "5k Pace";
            _rowBuf[1] =
                _compRacePace5k != null
                    ? _formatPace(_compRacePace5k as Float)
                    : "-";
            return;
        }
        if (field == FIELD_RACE_PACE_10K) {
            _rowBuf[0] = "10k Pace";
            _rowBuf[1] =
                _compRacePace10k != null
                    ? _formatPace(_compRacePace10k as Float)
                    : "-";
            return;
        }
        if (field == FIELD_RACE_PACE_HALF) {
            _rowBuf[0] = "Half Pace";
            _rowBuf[1] =
                _compRacePaceHalf != null
                    ? _formatPace(_compRacePaceHalf as Float)
                    : "-";
            return;
        }
        if (field == FIELD_RACE_PACE_MARATHON) {
            _rowBuf[0] = "Mar Pace";
            _rowBuf[1] =
                _compRacePaceMarathon != null
                    ? _formatPace(_compRacePaceMarathon as Float)
                    : "-";
            return;
        }
        if (field == FIELD_CLIMB_DAY) {
            _rowBuf[0] = "Climb Day";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.metersClimbed != null) {
                    var m = info.metersClimbed as Float;
                    _rowBuf[1] = _altStr(m);
                    return;
                }
            }
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_DESCENT_DAY) {
            _rowBuf[0] = "Descent Day";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.metersDescended != null) {
                    var m = info.metersDescended as Float;
                    _rowBuf[1] = _altStr(m);
                    return;
                }
            }
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_SOLAR) {
            _rowBuf[0] = "Solar Input";
            _rowBuf[1] =
                _compSolar != null
                    ? (_compSolar as Number).toString() + "%"
                    : "-";
            return;
        }
        if (field == FIELD_PACE_AND_AVG) {
            _rowBuf[0] = "Pace+Avg";
            var cur = "-";
            var avg = "-";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (
                    a.currentSpeed != null &&
                    (a.currentSpeed as Float) > MIN_SPEED_MPS
                ) {
                    cur = _formatPace(a.currentSpeed as Float);
                }
                if (
                    a.averageSpeed != null &&
                    (a.averageSpeed as Float) > MIN_SPEED_MPS
                ) {
                    avg = _formatPace(a.averageSpeed as Float);
                }
            }
            _rowBuf[1] = cur + " | " + avg;
            return;
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
            return;
        }
        if (field == FIELD_BODY_BAT_STRESS) {
            _rowBuf[0] = "Body+Stress";
            _rowBuf[1] = _cachedBodyBat + " | " + _cachedStress;
            return;
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
            return;
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
            return;
        }
        if (field == FIELD_ASCENT_DESCENT) {
            var up = "-";
            var dn = "-";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.totalAscent != null) {
                    var m = (a.totalAscent as Number).toFloat();
                    up = _altStr(m);
                }
                if (a.totalDescent != null) {
                    var m = (a.totalDescent as Number).toFloat();
                    dn = _altStr(m);
                }
            }
            _rowBuf[0] = "Ascent+Desc";
            _rowBuf[1] = up + " | " + dn;
            return;
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
            _rowBuf[0] = "Climb+Desc";
            _rowBuf[1] = up + " | " + dn;
            return;
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
            return;
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
            return;
        }
        if (field == FIELD_WX_TEMP_HUMIDITY) {
            _rowBuf[0] = "Temp+Hum";
            _rowBuf[1] = _wxTemp + _wxUnit + " " + _wxHumidity;
            return;
        }
        if (field == FIELD_WX_TEMP_PRECIP) {
            _rowBuf[0] = "Temp+Rain";
            _rowBuf[1] = _wxTemp + _wxUnit + " " + _wxPrecip;
            return;
        }
        if (field == FIELD_WX_HUMIDITY_PRECIP) {
            _rowBuf[0] = "Hum+Rain";
            _rowBuf[1] = _wxHumidity + " | " + _wxPrecip;
            return;
        }
        if (field == FIELD_WX_CLOUD_PRECIP) {
            _rowBuf[0] = "Cloud+Rain";
            _rowBuf[1] = _wxCloudCover + " | " + _wxPrecip;
            return;
        }
        if (field == FIELD_SLEEP_SCHEDULE) {
            _rowBuf[0] = "Sleep Sched";
            _rowBuf[1] = _cachedSleepTime + " | " + _cachedWakeTime;
            return;
        }
        if (field == FIELD_VO2_TRAINING) {
            _rowBuf[0] = "VO2+Train";
            _rowBuf[1] =
                _cachedVo2Max +
                " " +
                (_compTrainingStatus != null
                    ? _trainingStatusStr(_compTrainingStatus as String)
                    : "-");
            return;
        }
        if (field == FIELD_TRAINING_EFFECT) {
            _rowBuf[0] = "Train Eff";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.trainingEffect != null) {
                    var te = a.trainingEffect as Float;
                    var tag =
                        te < 1.0
                            ? ""
                            : te < 2.0
                              ? " [MIN]"
                              : te < 3.0
                                ? " [MAINT]"
                                : te < 4.0
                                  ? " [IMPR]"
                                  : te < 5.0
                                    ? " [HIGH]"
                                    : " [OVR]";
                    _rowBuf[1] = te.format("%.1f") + tag;
                    return;
                }
            }
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_TOTAL_ASCENT) {
            _rowBuf[0] = "Ascent";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.totalAscent != null) {
                    var m = (a.totalAscent as Number).toFloat();
                    _rowBuf[1] = _altStr(m);
                    return;
                }
            }
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_TOTAL_DESCENT) {
            _rowBuf[0] = "Descent";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.totalDescent != null) {
                    var m = (a.totalDescent as Number).toFloat();
                    _rowBuf[1] = _altStr(m);
                    return;
                }
            }
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_NOTIFICATIONS) {
            _rowBuf[0] = "Notifs";
            _rowBuf[1] =
                _compNotifications != null
                    ? (_compNotifications as Number).toString()
                    : "-";
            return;
        }
        if (field == FIELD_HR_RESTING_BOTH) {
            _rowBuf[0] = "HR Rest/Avg";
            _rowBuf[1] = _cachedRestingHR + " | " + _cachedAvgRestingHR;
            return;
        }
        if (field == FIELD_WX_COND_FCST_1D) {
            var tomorrow =
                _compFcstCond1d != null
                    ? _condStr(_compFcstCond1d as Number)
                    : "-";
            _rowBuf[0] = "Cond/+1d";
            _rowBuf[1] = _wxCond + " | " + tomorrow;
            return;
        }
        if (field == FIELD_WX_FCST_COND_12D) {
            var d1 =
                _compFcstCond1d != null
                    ? _condStr(_compFcstCond1d as Number)
                    : "-";
            var d2 =
                _compFcstCond2d != null
                    ? _condStr(_compFcstCond2d as Number)
                    : "-";
            _rowBuf[0] = "+1d/+2d";
            _rowBuf[1] = d1 + " | " + d2;
            return;
        }
        if (field == FIELD_BODY_BAT_REST_HR) {
            _rowBuf[0] = "Bat+RestHR";
            _rowBuf[1] = _cachedBodyBat + " | " + _cachedRestingHR;
            return;
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
            return;
        }
        if (field == FIELD_HR_RESTING) {
            _rowBuf[0] = "HR Rest";
            _rowBuf[1] = _cachedRestingHR;
            return;
        }
        if (field == FIELD_HR_RESTING_AVG) {
            _rowBuf[0] = "HR RestAvg";
            _rowBuf[1] = _cachedAvgRestingHR;
            return;
        }
        if (field == FIELD_WX_SEA_PRESS) {
            _rowBuf[0] = "Sea Press";
            _rowBuf[1] =
                _compSeaLevelPressure != null
                    ? ((_compSeaLevelPressure as Float) / 100.0).format(
                          "%.1f"
                      ) + " hPa"
                    : "-";
            return;
        }
        if (field == FIELD_WX_OBS_TIME) {
            _rowBuf[0] = "WX Age";
            _rowBuf[1] = _wxObsAge;
            return;
        }
        if (field == FIELD_WX_FCST_COND_1D) {
            _rowBuf[0] = "Fcst +1d";
            _rowBuf[1] =
                _compFcstCond1d != null
                    ? _condStr(_compFcstCond1d as Number)
                    : "-";
            return;
        }
        if (field == FIELD_WX_FCST_COND_2D) {
            _rowBuf[0] = "Fcst +2d";
            _rowBuf[1] =
                _compFcstCond2d != null
                    ? _condStr(_compFcstCond2d as Number)
                    : "-";
            return;
        }
        if (field == FIELD_WX_FCST_COND_3D) {
            _rowBuf[0] = "Fcst +3d";
            _rowBuf[1] =
                _compFcstCond3d != null
                    ? _condStr(_compFcstCond3d as Number)
                    : "-";
            return;
        }
        if (field == FIELD_HR_MEAN_MAX) {
            var avg = "-";
            var max = "-";
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.averageHeartRate != null) {
                    avg = (a.averageHeartRate as Number).toString();
                }
                if (a.maxHeartRate != null) {
                    max = (a.maxHeartRate as Number).toString();
                }
            }
            _rowBuf[0] = "HR Avg/Max";
            _rowBuf[1] = avg + " | " + max;
            return;
        }
        if (field == FIELD_CAL_TOTAL_ACT) {
            var total = "-";
            var act = "-";
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.calories != null) {
                    total = (info.calories as Number).toString();
                }
            }
            if (_acInfo != null) {
                var a = _acInfo as Activity.Info;
                if (a.calories != null) {
                    act = (a.calories as Number).toString();
                }
            }
            _rowBuf[0] = "Cal Tot/Act";
            _rowBuf[1] = total + " | " + act;
            return;
        }
        if (field == FIELD_SOLAR_BATTERY) {
            var solar =
                _compSolar != null
                    ? (_compSolar as Number).toString() + "%"
                    : "-";
            _rowBuf[0] = "Solar/Bat";
            _rowBuf[1] = solar + " | " + _batText;
            return;
        }
        _rowBuf[0] = "";
        _rowBuf[1] = "";
        return;
    }

    private function _getTimeParts() as Array<String> {
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
            var fmt = _dateFormat;
            var value = "" as String;
            if (fmt == 1) {
                value =
                    info.year.format("%04d") +
                    "-" +
                    info.month.format("%02d") +
                    "-" +
                    day.format("%02d");
            } else if (fmt == 2) {
                value =
                    day.format("%02d") +
                    "-" +
                    info.month.format("%02d") +
                    "-" +
                    info.year.format("%04d");
            } else if (fmt == 3) {
                value =
                    info.month.format("%02d") +
                    "-" +
                    day.format("%02d") +
                    "-" +
                    info.year.format("%04d");
            } else {
                var yr = _showYear ? " " + info.year.toString() : "";
                if (fmt == 4) {
                    value =
                        DAY_NAMES[info.day_of_week - 1] +
                        " " +
                        day.format("%02d") +
                        yr;
                } else if (fmt == 5) {
                    value =
                        day.format("%02d") +
                        " " +
                        MONTH_NAMES[info.month - 1] +
                        yr;
                } else {
                    value =
                        DAY_NAMES[info.day_of_week - 1] +
                        ", " +
                        day +
                        " " +
                        MONTH_NAMES[info.month - 1] +
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
                while (ps != null) {
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
        var c = Weather.getCurrentConditions();
        if (c == null) {
            return;
        }
        _wxHumidityNum = -1;
        var metric = _metric;
        if (c.temperature != null) {
            var tf = c.temperature as Float;
            _wxTemp = _tempStr(tf);
        }
        if (c.feelsLikeTemperature != null) {
            var tf = c.feelsLikeTemperature as Float;
            _wxFeels = _tempStr(tf);
        }
        if (c.lowTemperature != null) {
            var tf = c.lowTemperature as Float;
            _wxLow = _tempStr0(tf);
        }
        if (c.highTemperature != null) {
            var tf = c.highTemperature as Float;
            _wxHigh = _tempStr0(tf);
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
                _wxWind +=
                    " " +
                    WIND_DIRS[(((c.windBearing as Number) + 22) / 45) % 8];
            }
        }
        if (c.uvIndex != null) {
            _wxUvNum = (c.uvIndex as Float).toNumber();
            _wxUv = _wxUvNum.toString() + _uvTag();
        }
        if (c.condition != null) {
            _wxCond = _condStr(c.condition as Number);
        }
        if (c.relativeHumidity != null) {
            _wxHumidityNum = c.relativeHumidity as Number;
            _wxHumidity = _wxHumidityNum.toString() + "%";
        }
        if (c.dewPoint != null) {
            var dp = c.dewPoint as Float;
            _wxDewPoint = _tempStr(dp);
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
            var tf = c.temperature as Float;
            _wxHeatIndex = _calcHeatIndex(tf, _wxHumidityNum);
        }
        if (_needsForecast) {
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
            } else {
                _wxForecastData = null;
                _wxForecastPrecipData = null;
                _wxForecastWindData = null;
                _wxForecastHumidityData = null;
                _wxForecastUvData = null;
                _wxForecastCloudData = null;
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
            } else {
                _wxDailyForecastHigh = null;
                _wxDailyForecastLow = null;
            }
        }
    }

    (:extendedCode)
    private function _trainingStatusStr(s as String) as String {
        if (s.equals("Productive")) {
            return "[PRODUCTIVE]";
        }
        if (s.equals("Maintaining")) {
            return "[MAINT]";
        }
        if (s.equals("Peaking")) {
            return "[PEAKING]";
        }
        if (s.equals("Recovery")) {
            return "[RECOVERY]";
        }
        if (s.equals("Overreaching")) {
            return "[OVERREACH]";
        }
        if (s.equals("Detraining")) {
            return "[DETRAIN]";
        }
        if (s.equals("Ready")) {
            return "[READY]";
        }
        if (s.equals("Not Ready")) {
            return "[NOT READY]";
        }
        if (s.equals("No Status")) {
            return "-";
        }
        return "[" + s + "]";
    }

    (:extendedCode)
    private function _condStr(cond as Number) as String {
        switch (cond) {
            case Weather.CONDITION_CLEAR:
            case Weather.CONDITION_MOSTLY_CLEAR:
            case Weather.CONDITION_FAIR:
                return "[CLEAR]";
            case Weather.CONDITION_PARTLY_CLOUDY:
            case Weather.CONDITION_PARTLY_CLEAR:
                return "[PCLOUD]";
            case Weather.CONDITION_MOSTLY_CLOUDY:
            case Weather.CONDITION_CLOUDY:
            case Weather.CONDITION_THIN_CLOUDS:
                return "[CLOUDY]";
            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_HEAVY_RAIN:
            case Weather.CONDITION_SCATTERED_SHOWERS:
            case Weather.CONDITION_SHOWERS:
            case Weather.CONDITION_LIGHT_SHOWERS:
            case Weather.CONDITION_HEAVY_SHOWERS:
            case Weather.CONDITION_DRIZZLE:
            case Weather.CONDITION_UNKNOWN_PRECIPITATION:
            case Weather.CONDITION_CHANCE_OF_SHOWERS:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
                return "[RAIN]";
            case Weather.CONDITION_SNOW:
            case Weather.CONDITION_LIGHT_SNOW:
            case Weather.CONDITION_HEAVY_SNOW:
            case Weather.CONDITION_FLURRIES:
            case Weather.CONDITION_CHANCE_OF_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
                return "[SNOW]";
            case Weather.CONDITION_WINDY:
                return "[WINDY]";
            case Weather.CONDITION_THUNDERSTORMS:
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
            case Weather.CONDITION_SQUALL:
            case Weather.CONDITION_HURRICANE:
            case Weather.CONDITION_TROPICAL_STORM:
                return "[STORM]";
            case Weather.CONDITION_WINTRY_MIX:
            case Weather.CONDITION_LIGHT_RAIN_SNOW:
            case Weather.CONDITION_HEAVY_RAIN_SNOW:
            case Weather.CONDITION_RAIN_SNOW:
            case Weather.CONDITION_FREEZING_RAIN:
            case Weather.CONDITION_ICE:
            case Weather.CONDITION_SLEET:
            case Weather.CONDITION_ICE_SNOW:
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:
                return "[MIX]";
            case Weather.CONDITION_FOG:
            case Weather.CONDITION_MIST:
                return "[FOG]";
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_HAZE:
            case Weather.CONDITION_SMOKE:
            case Weather.CONDITION_DUST:
            case Weather.CONDITION_SAND:
            case Weather.CONDITION_SANDSTORM:
            case Weather.CONDITION_VOLCANIC_ASH:
                return "[HAZY]";
            case Weather.CONDITION_HAIL:
                return "[HAIL]";
            case Weather.CONDITION_TORNADO:
                return "[TORN]";
            default:
                return "[?]";
        }
    }

    private function _celsiusToF(tempC as Float) as Float {
        return (tempC * 9.0) / 5.0 + 32.0;
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

    // Called every second on AMOLED. Blinks the cursor via setClip so only that region
    // redraws. On phase change or when seconds are shown, triggers a full onUpdate.
    public function onPartialUpdate(dc as Dc) as Void {
        var now = System.getTimer();
        var phase = _getPhase(Time.now().value());
        if (phase != _lastPhase) {
            _lastPhase = phase;
            WatchUi.requestUpdate();
            return;
        }
        if (_showSeconds) {
            WatchUi.requestUpdate();
            return;
        }

        var cursorOn = (now / 1000) % 2 == 0;
        if (cursorOn == _cursorOn) {
            return;
        }
        _cursorOn = cursorOn;
        dc.setClip(_cursorX, _cursorY, _cursorCharW, _cursorFh);
        if (_cursorOn) {
            dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(_cursorX, _cursorY, _cursorCharW, _cursorFh);
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.fillRectangle(_cursorX, _cursorY, _cursorCharW, _cursorFh);
            if (_scanlineIntensity > 0 && _scanlineIntensity < 4) {
                dc.setColor(
                    SCANLINE_COLORS[_scanlineIntensity],
                    Graphics.COLOR_TRANSPARENT
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

    public function onEnterSleep() as Void {
        _lastPhase = -1;
    }
    public function onExitSleep() as Void {
        WatchUi.requestUpdate();
    }
}
