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

const APP_VERSION = "0.32.0";

const FIELD_STEPS = 0;
const FIELD_HR = 1;
const FIELD_CALORIES = 2;
const FIELD_DISTANCE = 4;
const FIELD_ALTITUDE = 5;
const FIELD_FLOORS = 6;
const FIELD_NONE = 7;
const FIELD_SPO2 = 9;
const FIELD_ACTIVE_MIN = 10;
const FIELD_WX_TEMP = 11;
const FIELD_WX_FEELS = 12;
const FIELD_WX_PRECIP = 13;
const FIELD_WX_WIND = 14;
const FIELD_WX_UV = 15;
const FIELD_WX_COND = 16;
const FIELD_WX_TEMP_COND = 17;
const FIELD_WX_TEMP_MINMAX = 18;
const FIELD_WX_COND_PRECIP = 19;
const FIELD_WX_TEMP_WIND = 20;
const FIELD_STRESS = 21;
const FIELD_BODY_BAT = 22;
const FIELD_RESP = 23;
const FIELD_HR_MEAN = 24;
const FIELD_CAL_ACT = 25;
const FIELD_RECOVERY = 26;
const FIELD_MOVE_BAR = 27;
const FIELD_TEMP_WRIST = 28;
const FIELD_ACTIVE_MIN_DAY = 29;
const FIELD_HR_MAX = 30;
const FIELD_PRESSURE = 31;
const FIELD_ELEVATION = 32;
const FIELD_WX_FORECAST = 33;
const FIELD_VO2_MAX = 34;
const FIELD_SPEED = 35;
const FIELD_SLEEP = 36;
const FIELD_SUNRISE = 37;
const FIELD_SUNSET = 38;
const FIELD_SUNRISE_SUNSET = 39;
const FIELD_CALENDAR = 40;
const FIELD_WEEKLY_RUN = 41;
const FIELD_WEEKLY_BIKE = 42;
const FIELD_GPS_LAT = 43;
const FIELD_GPS_LON = 44;
const FIELD_GPS_ACCURACY = 45;
const FIELD_HEADING = 46;
const FIELD_ELAPSED = 47;
const FIELD_TRAINING_STATUS = 48;
const FIELD_RACE_5K = 49;
const FIELD_RACE_10K = 50;
const FIELD_RACE_HALF = 51;
const FIELD_RACE_MARATHON = 52;
const FIELD_SLEEP_TIME = 53;
const FIELD_WAKE_TIME = 54;
const FIELD_GPS_LAT_LON = 55;
const FIELD_GPS_LAT_LON_ACC = 56;
const FIELD_WX_WIND_PRECIP = 57;
const FIELD_WX_TEMP_UV = 58;
const FIELD_WX_UV_PRECIP = 59;
const FIELD_WX_UV_WIND = 60;

const VIEW_VALUE = 0;
const VIEW_GRAPH = 1;
const VIEW_GRAPH_VALUE = 2;
const VIEW_GRAPH_MINMAX = 3;

const GRAPH_LINE = 0;
const GRAPH_BAR = 1;

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

// Indices into this array are used as the SecondaryField property value
const GRAPH_FIELDS =
    [
        FIELD_HR,
        FIELD_BODY_BAT,
        FIELD_STRESS,
        FIELD_SPO2,
        FIELD_TEMP_WRIST,
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

const ICON_ARROW_UP = 0;
const ICON_ARROW_DN = 1;
const ICON_DEG = 2;
const ICON_BOLT = 3;

class TerminalWatchfaceView extends WatchUi.WatchFace {
    private var _w as Number = 0;
    private var _h as Number = 0;
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
    private var _cursorFH as Number = 20;
    private var _pad as Number = 0;
    private var _arrowW as Number = 0;
    private var _wxTemp as String = "-";
    private var _wxFeels as String = "-";
    private var _wxPrecip as String = "-";
    private var _wxWind as String = "-";
    private var _wxUv as String = "-";
    private var _wxUvNum as Number = -1;
    private var _wxCond as String = "-";
    private var _wxForecastData as Array<Float>? = null;
    private var _wxForecastRevCache as Dictionary = {};
    private var _wxForecastRevCacheMin as Number = -1;
    private var _wxLow as String = "-";
    private var _wxHigh as String = "-";
    private var _sizeSet as Number = 0; // 0 = lineHeight 28 (default), 1 = lineHeight 30 (SpaceMono)
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
    private var _scanlineIntensity as Number = 2;
    private var _rotateMainMs as Number = 5000;
    private var _rotateAltMs as Number = 5000;
    private var _metricsValid as Boolean = false;
    private var _clockInfo as Gregorian.Info? = null;
    private var _watchCmd as String = "watch";
    private var _cachedBodyBat as String = "-";
    private var _cachedTempWrist as String = "-";
    private var _cachedPressure as String = "-";
    private var _cachedElevation as String = "-";
    private var _cachedStress as String = "-";
    private var _cachedVo2Max as String = "-";
    private var _cachedSleepTime as String = "-";
    private var _cachedWakeTime as String = "-";
    private var _batText as String = "-";
    private var _batDaysText as String = "";
    private var _batW as Number = 0;
    private var _batDaysW as Number = 0;
    private var _charging as Boolean = false;
    private var _cachedNotifLabel as String = "";
    private var _resolvedPhase as Number = -1;
    private var _resolvedFields as Array<Number> = [7, 7, 7] as Array<Number>;
    private var _needsLiveActivity as Boolean = true;
    private var _needsGps as Boolean = false;
    private var _resolvedLabelC as Array<Number> = [8, 8, 8] as Array<Number>;
    private var _resolvedValueC as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _rowBuf as Array<String> = ["", ""] as Array<String>;
    private var _timeBuf as Array<String> = ["Time", ""] as Array<String>;
    private var _timeLastMin as Number = -1;
    private var _timeHMpart as String = "";
    private var _timeAmPm as String = "";
    private var _dateBuf as Array<String> = ["Date", ""] as Array<String>;
    private var _lastDateDay as Number = -1;
    private var _dateFormat as Number = 0;
    private var _showYear as Boolean = false;
    private var _line1LabelC as Number = 8;
    private var _line1ValueC as Number = 0;
    private var _line2LabelC as Number = 8;
    private var _line2ValueC as Number = 0;
    private var _lineViewMode as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _linePeriodMin as Array<Number> = [60, 60, 60] as Array<Number>;
    private var _lineGraphColor as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineGraphType as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineSecType as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineSecField as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _lineSecColor as Array<Number> = [0, 0, 0] as Array<Number>;
    private var _mmMin as Float = 0.0;
    private var _mmMax as Float = 0.0;
    private var _nowUnixMin as Number = 0;
    private var _grMin as Float = 0.0;
    private var _grRange as Float = 1.0;

    public function initialize() {
        WatchFace.initialize();
        var s = System.getDeviceSettings();
        _w = s.screenWidth;
        _h = s.screenHeight;
        _amInfo = ActivityMonitor.getInfo();
        _acInfo = Activity.getActivityInfo();
        _posInfo = Position.getInfo();
        reloadFont();
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
                }
            }
            comp = iter.next() as Complications.Complication?;
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
        if (newSizeSet != _sizeSet) {
            _sizeSet = newSizeSet;
            _graphBmpCache = {};
            _graphBmpDualCache = {};
        }
        if (_sizeSet == 1) {
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
        var nowMoment = Time.now();
        var phase = _getPhase(nowMoment.value());
        _cursorOn = (now / 1000) % 2 == 0;
        _nowUnixMin = nowMoment.value() / 60;
        var clockInfo =
            Gregorian.info(nowMoment, Time.FORMAT_SHORT) as Gregorian.Info;
        _clockInfo = clockInfo;
        var nowMin = clockInfo.min as Number;
        if (phase != _resolvedPhase) {
            _resolvedPhase = phase;
            _resolveAllLines(phase);
            var needsAct = false;
            var needsGps = false;
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
                    f == FIELD_ELAPSED
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
            }
            _needsLiveActivity = needsAct;
            _needsGps = needsGps;
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
            var ri = _getProp("rotateInterval", 10);
            if (ri < 1) {
                ri = 1;
            }
            _rotateMainMs = ri * 1000;
            var ra = _getProp("rotateIntervalAlt", 3);
            _rotateAltMs = ra > 0 ? ra * 1000 : _rotateMainMs;
            var settings = System.getDeviceSettings();
            _metric = settings.distanceUnits == System.UNIT_METRIC;
            _is24Hour = settings.is24Hour;
            _showSeconds = _getBoolProp("showSeconds");
            _scanlineIntensity = _getProp("scanlines", 2);
            _wxUnit = _metric ? "C" : "F";
            _notifCount =
                settings.notificationCount != null
                    ? settings.notificationCount as Number
                    : 0;
            _cachedNotifLabel = "[" + _notifCount.toString() + "]";
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
            _pad = dc.getTextWidthInPixels(": ", _font) / 2;
            _arrowW = dc.getTextWidthInPixels(" > ", _font);
            _metricsValid = true;
        }
        var step = _fh + 16;
        var cx = _w / 2 - _charW * 6;

        var v0 = _resolvedFields[0] != FIELD_NONE;
        var v1 = _resolvedFields[1] != FIELD_NONE;
        var v2 = _resolvedFields[2] != FIELD_NONE;
        var visible = 6 + (v0 ? 1 : 0) + (v1 ? 1 : 0) + (v2 ? 1 : 0);

        var y = (_h - step * (visible - 3) - _fh) / 2;
        var row = 0;

        _drawHeader(dc, y);
        _drawPromptLine(dc, cx, y + step * row, _watchCmd);
        row++;

        _drawRow(
            dc,
            cx,
            y + step * row,
            _timeParts(),
            _line1LabelC,
            _line1ValueC
        );
        row++;
        _drawRow(
            dc,
            cx,
            y + step * row,
            _dateParts(),
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

        var splitX = cx + _pad;
        var footerY = y + step * row;
        _cursorX = splitX;
        _cursorY = footerY;
        _cursorCharW = _charW;
        _cursorFH = _fh;

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
        var label = _cachedNotifLabel;
        dc.setColor(_colorFromIdx(1), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _w / 2,
            textY,
            _fontSmall,
            label,
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
        var batW = _batW;
        var daysW = _batDaysW;
        if (_charging) {
            var spaced = " " + batText;
            var spacedW = dc.getTextWidthInPixels(spaced, _fontSmall);
            var startX = (_w - _bmpBoltW - spacedW - daysW) / 2;
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
        var startX = (_w - batW - daysW) / 2;
        dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, y, _fontSmall, batText, Graphics.TEXT_JUSTIFY_LEFT);
        if (hasDays) {
            dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                startX + batW,
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
        while (y < _h) {
            dc.drawLine(0, y, _w - 1, y);
            y += SCANLINE_SPACING;
        }
    }

    private function _drawPromptLine(
        dc as Dc,
        cx as Number,
        y as Number,
        content as String
    ) as Void {
        var splitX = cx + _pad;
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
        var s3 = _getProp("line3Secondary", FIELD_NONE);
        var t3 = _getProp("line3Tertiary", FIELD_NONE);
        if (phase == 1 && s3 != FIELD_NONE) {
            _resolvedFields[0] = s3;
            _resolvedLabelC[0] = _getProp("line3SecondaryLabelColor", 8);
            _resolvedValueC[0] = _getProp("line3SecondaryValueColor", 0);
        } else if (phase == 2 && t3 != FIELD_NONE) {
            _resolvedFields[0] = t3;
            _resolvedLabelC[0] = _getProp("line3TertiaryLabelColor", 8);
            _resolvedValueC[0] = _getProp("line3TertiaryValueColor", 0);
        } else {
            _resolvedFields[0] = _getProp("line3Primary", FIELD_NONE);
            _resolvedLabelC[0] = _getProp("line3PrimaryLabelColor", 8);
            _resolvedValueC[0] = _getProp("line3PrimaryValueColor", 0);
        }
        var s4 = _getProp("line4Secondary", FIELD_NONE);
        var t4 = _getProp("line4Tertiary", FIELD_NONE);
        if (phase == 1 && s4 != FIELD_NONE) {
            _resolvedFields[1] = s4;
            _resolvedLabelC[1] = _getProp("line4SecondaryLabelColor", 8);
            _resolvedValueC[1] = _getProp("line4SecondaryValueColor", 0);
        } else if (phase == 2 && t4 != FIELD_NONE) {
            _resolvedFields[1] = t4;
            _resolvedLabelC[1] = _getProp("line4TertiaryLabelColor", 8);
            _resolvedValueC[1] = _getProp("line4TertiaryValueColor", 0);
        } else {
            _resolvedFields[1] = _getProp("line4Primary", FIELD_NONE);
            _resolvedLabelC[1] = _getProp("line4PrimaryLabelColor", 8);
            _resolvedValueC[1] = _getProp("line4PrimaryValueColor", 0);
        }
        var s5 = _getProp("line5Secondary", FIELD_NONE);
        var t5 = _getProp("line5Tertiary", FIELD_NONE);
        if (phase == 1 && s5 != FIELD_NONE) {
            _resolvedFields[2] = s5;
            _resolvedLabelC[2] = _getProp("line5SecondaryLabelColor", 8);
            _resolvedValueC[2] = _getProp("line5SecondaryValueColor", 0);
        } else if (phase == 2 && t5 != FIELD_NONE) {
            _resolvedFields[2] = t5;
            _resolvedLabelC[2] = _getProp("line5TertiaryLabelColor", 8);
            _resolvedValueC[2] = _getProp("line5TertiaryValueColor", 0);
        } else {
            _resolvedFields[2] = _getProp("line5Primary", FIELD_NONE);
            _resolvedLabelC[2] = _getProp("line5PrimaryLabelColor", 8);
            _resolvedValueC[2] = _getProp("line5PrimaryValueColor", 0);
        }
        _resolveLineGraph(0);
        _resolveLineGraph(1);
        _resolveLineGraph(2);
    }

    private function _resolveLineGraph(li as Number) as Void {
        _lineSecType[li] = SEC_NONE;
        var field = _resolvedFields[li];
        if (field == FIELD_STEPS) {
            var showBar = _getBoolProp("stepsShowBar");
            var showVal = _getBoolProp("stepsShowBarValue");
            _lineViewMode[li] = showBar ? (showVal ? 2 : 1) : 0;
            _lineGraphColor[li] = _getProp("stepsBarColor", 1);
            return;
        }
        if (field == FIELD_WX_FORECAST) {
            _lineViewMode[li] = _getProp(
                "wxForecastViewMode",
                VIEW_GRAPH_VALUE
            );
            _lineGraphColor[li] = _getProp("wxForecastGraphColor", 16);
            _lineGraphType[li] = _getProp("wxForecastGraphType", GRAPH_BAR);
            _linePeriodMin[li] = _getProp("wxForecastTimeFrame", 12);
            return;
        }
        var gk = _fieldGraphKey(field);
        if (gk == null) {
            return;
        }
        var mode = _getProp(gk + "GraphMode", 0);
        _lineViewMode[li] =
            mode == 3 || mode == 4
                ? VIEW_GRAPH_VALUE
                : mode > 0
                  ? VIEW_GRAPH
                  : VIEW_VALUE;
        _lineGraphType[li] = mode == 2 || mode == 4 ? GRAPH_BAR : GRAPH_LINE;
        _linePeriodMin[li] = _getProp(gk + "TimeFrame", 60);
        _lineGraphColor[li] = _getProp(
            gk + "GraphColor",
            field == FIELD_HR || field == FIELD_HR_MEAN || field == FIELD_HR_MAX
                ? 5
                : 0
        );
        _lineSecType[li] = _getProp(gk + "SecondaryType", SEC_NONE);
        var vm = _lineViewMode[li];
        if (
            _lineSecType[li] != SEC_NONE &&
            (vm == VIEW_GRAPH || vm == VIEW_GRAPH_VALUE)
        ) {
            var sidx = _getProp(gk + "SecondaryField", 0);
            if (sidx < 0 || sidx >= 7) {
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
            _drawFloorsRow(dc, cx, y, labelColor, valueColor);
            return;
        }
        if (field == FIELD_WX_TEMP_MINMAX) {
            _drawTempMinMaxRow(dc, cx, y, labelColor, valueColor);
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
            var x = cx + _pad;
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
                        cx + _pad + dc.getTextWidthInPixels(_rowBuf[1], _font),
                        y,
                        _font,
                        " [GOAL]",
                        Graphics.TEXT_JUSTIFY_LEFT
                    );
                }
            }
            return;
        }
        if (field == FIELD_WX_FORECAST) {
            _drawForecastRow(
                dc,
                cx,
                y,
                _linePeriodMin[li],
                _lineViewMode[li],
                labelColor,
                valueColor,
                _lineGraphColor[li],
                _lineGraphType[li]
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
                        GRAPH_FIELDS[_lineSecField[li]] as Number,
                        _linePeriodMin[li],
                        labelColor,
                        valueColor,
                        _lineGraphColor[li],
                        _lineSecColor[li],
                        _lineGraphType[li],
                        _lineSecType[li],
                        viewMode
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
                        _lineGraphType[li]
                    );
                }
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
        var gx = cx + _pad + _charW;
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
        var x = cx + _pad;
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
        var x = cx + _pad;
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
        var x = _drawUvTag(dc, cx + _pad, y, valIdx);
        if (!suffix.equals("")) {
            dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, " | ", Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(" | ", _font);
            dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, suffix, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function _drawTempMinMaxRow(
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
        var x = cx + _pad;
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, _wxTemp, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxTemp, _font);
        _drawIcon(dc, x, y + (_fh - _degW) / 4, ICON_DEG, valIdx);
        x += _degW;
        var unitBrk = _wxUnit + " [";
        dc.drawText(x, y, _font, unitBrk, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(unitBrk, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        var lowBrk = _wxLow + "] [";
        dc.drawText(x, y, _font, lowBrk, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(lowBrk, _font);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        dc.drawText(x, y, _font, _wxHigh + "]", Graphics.TEXT_JUSTIFY_LEFT);
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
                cx - _pad,
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
                var vx = cx + _pad;
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
                    cx + _pad,
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

    private function _gradColor(
        colorIdx as Number,
        fraction as Float
    ) as Number {
        if (colorIdx == COLOR_GRAD_TRI) {
            return _gradFromStops(TRI_GRAD, fraction);
        }
        if (colorIdx == COLOR_GRAD_TRI_REV) {
            return _gradFromStops(TRI_GRAD, 1.0 - fraction);
        }
        if (colorIdx == COLOR_GRAD_TEMP_CUSTOM) {
            return _gradFromStops(TEMP_GRADS[0] as Array<Number>, fraction);
        }
        if (colorIdx == COLOR_GRAD_TEMP_CUSTOM_REV) {
            return _gradFromStops(
                TEMP_GRADS[0] as Array<Number>,
                1.0 - fraction
            );
        }
        if (colorIdx == COLOR_GRAD_TEMP_SPECTRAL) {
            return _gradFromStops(TEMP_GRADS[1] as Array<Number>, fraction);
        }
        if (colorIdx == COLOR_GRAD_TEMP_SPECTRAL_REV) {
            return _gradFromStops(
                TEMP_GRADS[1] as Array<Number>,
                1.0 - fraction
            );
        }
        if (colorIdx == COLOR_GRAD_TEMP_TURBO) {
            return _gradFromStops(TEMP_GRADS[2] as Array<Number>, fraction);
        }
        if (colorIdx == COLOR_GRAD_TEMP_TURBO_REV) {
            return _gradFromStops(
                TEMP_GRADS[2] as Array<Number>,
                1.0 - fraction
            );
        }
        if (colorIdx == COLOR_GRAD_TEMP_INFERNO) {
            return _gradFromStops(TEMP_GRADS[3] as Array<Number>, fraction);
        }
        if (colorIdx == COLOR_GRAD_TEMP_INFERNO_REV) {
            return _gradFromStops(
                TEMP_GRADS[3] as Array<Number>,
                1.0 - fraction
            );
        }
        return _colorFromIdx(colorIdx);
    }

    private function _getGradRange(
        field as Number,
        colorIdx as Number,
        dataMinV as Float,
        dataRange as Float
    ) as Void {
        if (colorIdx >= COLOR_GRAD_TEMP_CUSTOM) {
            _grMin = -20.0;
            _grRange = 60.0;
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
            } else if (field == FIELD_BODY_BAT || field == FIELD_STRESS) {
                gMin = 0.0;
                gMax = 100.0;
            } else if (field == FIELD_SPO2) {
                gMin = 85.0;
                gMax = 100.0;
            } else {
                _grMin = dataMinV;
                _grRange = dataRange;
                return;
            }
            _grMin = gMin;
            _grRange = gMax - gMin;
            if (_grRange < 1.0) {
                _grRange = 1.0;
            }
            return;
        }
        _grMin = dataMinV;
        _grRange = dataRange;
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
        if (field == FIELD_TEMP_WRIST) {
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
        viewMode as Number
    ) as Void {
        var data = _getFieldHistory(field, periodMin);
        _getFieldParts(field);
        var valueStr = _rowBuf[1];
        var gw = _charW * 10;
        var gx = cx + _pad + _charW * 2;
        var gh = _fh - 2;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        if (data == null) {
            _drawGraphAxes(dc, gx, gw, y);
            dc.setColor(GRAYS[3], Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw / 2,
                y + gh / 2 - _tinyFh / 2 - 1,
                _fontTiny,
                "no data",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            return;
        }

        _minMax(data);
        var minV = _mmMin;
        var maxV = _mmMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }

        var data2 = _getFieldHistory(fieldSecondary, periodMin);
        var minV2 = 0.0 as Float;
        var maxV2 = 0.0 as Float;
        var range2 = 1.0 as Float;
        if (data2 != null) {
            _minMax(data2);
            minV2 = _mmMin;
            maxV2 = _mmMax;
            range2 = maxV2 - minV2;
            if (range2 < 1.0) {
                range2 = 1.0;
            }
        }

        _getGradRange(field, lineColor, minV, range);
        var gradMinV1 = _grMin;
        var gradRange1 = _grRange;
        var maxFrac1 = (maxV - gradMinV1) / gradRange1;
        if (maxFrac1 < 0.0) {
            maxFrac1 = 0.0;
        }
        if (maxFrac1 > 1.0) {
            maxFrac1 = 1.0;
        }
        var minFrac1 = (minV - gradMinV1) / gradRange1;
        if (minFrac1 < 0.0) {
            minFrac1 = 0.0;
        }
        if (minFrac1 > 1.0) {
            minFrac1 = 1.0;
        }

        _getGradRange(fieldSecondary, lineColor2, minV2, range2);
        var gradMinV2 = _grMin;
        var gradRange2 = _grRange;
        var maxFrac2 = (maxV2 - gradMinV2) / gradRange2;
        if (maxFrac2 < 0.0) {
            maxFrac2 = 0.0;
        }
        if (maxFrac2 > 1.0) {
            maxFrac2 = 1.0;
        }
        var minFrac2 = (minV2 - gradMinV2) / gradRange2;
        if (minFrac2 < 0.0) {
            minFrac2 = 0.0;
        }
        if (minFrac2 > 1.0) {
            minFrac2 = 1.0;
        }

        var dualMaxGap = (10 * gw) / periodMin;
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
            gw,
            gh,
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
            dc.drawBitmap(gx, y, dualBmp);
        } else {
            _drawMeanLine(
                dc,
                data,
                gx,
                gw,
                y,
                gh,
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
                    gx,
                    gw,
                    y,
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
                    dc,
                    graphType,
                    lineColor,
                    data,
                    gx,
                    gw,
                    y,
                    gh,
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
                        gx,
                        gw,
                        y,
                        gh,
                        minV2,
                        range2,
                        gradMinV2,
                        gradRange2,
                        dualMaxGap
                    );
                }
            }
        }

        _drawGraphAxes(dc, gx, gw, y);

        // Secondary min/max outside right
        if (data2 != null) {
            dc.setColor(
                _gradColor(lineColor2, maxFrac2),
                Graphics.COLOR_TRANSPARENT
            );
            dc.drawText(
                gx + gw + 4,
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
                gx + gw + 4,
                y + gh - _tinyFh + 4,
                _fontTiny,
                _formatGraphLabel(fieldSecondary, minV2),
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }

        // Current values when graph+value mode — 3 normal spaces from graph edge, centered
        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = gx + gw + _charW * 3;
            var totalH = _smallFh * 2 + 2;
            var startY = y + (_fh - totalH) / 2 - 1;
            var cur1 = valueStr;
            dc.setColor(_colorFromIdx(lineColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                vx,
                startY,
                _fontSmall,
                cur1,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            _getFieldParts(fieldSecondary);
            var cur2 = _rowBuf[1];
            dc.setColor(_colorFromIdx(lineColor2), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                vx,
                startY + _smallFh + 2,
                _fontSmall,
                cur2,
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }

        // Primary min/max outside left
        dc.setColor(
            _gradColor(lineColor, maxFrac1),
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
            _gradColor(lineColor, minFrac1),
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            gx - 4,
            y + gh - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(field, minV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        var yBelow = y + gh + 1;
        var secName = _fieldShortName(fieldSecondary);
        dc.setColor(_colorFromIdx(lineColor2), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx + gw,
            yBelow,
            _fontTiny,
            secName,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx + gw - dc.getTextWidthInPixels(secName, _fontTiny),
            yBelow,
            _fontTiny,
            _effLabel(field, periodMin) + " ",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        var effKeyDual = field * 10000 + periodMin;
        var ageSecDual = _dataAge(
            data,
            _graphEffPeriod.hasKey(effKeyDual)
                ? _graphEffPeriod.get(effKeyDual) as Number
                : periodMin
        );
        if (ageSecDual > _fieldUpdateMin(field) * 60 + 30) {
            dc.setColor(_colorFromIdx(8), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx,
                yBelow,
                _fontTiny,
                _fmtAge(ageSecDual),
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
        if (field == FIELD_TEMP_WRIST) {
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
        var gw = _charW * 10;
        var periodSec = periodMin * 60;
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
        var effectiveMin = maxAge > 0 ? maxAge / 60 : periodMin;
        if (effectiveMin < 1) {
            effectiveMin = 1;
        }
        var gapThresh = (10 * gw) / effectiveMin;
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
        if (field == FIELD_STRESS || field == FIELD_TEMP_WRIST) {
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
        if (field == FIELD_TEMP_WRIST) {
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

    private function _formatGraphLabel(field as Number, v as Float) as String {
        if (field == FIELD_TEMP_WRIST || field == FIELD_WX_FORECAST) {
            return _metric ? v.format("%.0f") : _toF(v).format("%.0f");
        }
        if (field == FIELD_ELEVATION) {
            return _metric ? v.format("%.0f") : (v * 3.28084).format("%.0f");
        }
        if (field == FIELD_PRESSURE) {
            return _metric
                ? (v / 100.0).format("%.0f")
                : (v / 3386.39).format("%.1f");
        }
        return v.toNumber().toString();
    }

    private function _secsToTime(secs as Number) as String {
        var h = secs / 3600;
        var m = (secs % 3600) / 60;
        return h.format("%d") + ":" + m.format("%02d");
    }

    private function _secsToRace(secs as Number) as String {
        var h = secs / 3600;
        var m = (secs % 3600) / 60;
        var s = secs % 60;
        if (h > 0) {
            return (
                h.format("%d") + ":" + m.format("%02d") + ":" + s.format("%02d")
            );
        }
        return m.format("%d") + ":" + s.format("%02d");
    }

    private function _tfLabel(periodMin as Number) as String {
        return periodMin < 60
            ? "-" + periodMin.toString() + "m"
            : "-" + (periodMin / 60).toString() + "h";
    }

    private function _dataAge(
        data as Array<Float>,
        periodMin as Number
    ) as Number {
        var gw = _charW * 10;
        var periodSec = periodMin * 60;
        var n = data.size();
        for (var i = 0; i < n; i++) {
            if (data[i] != null) {
                return (i * periodSec) / gw;
            }
        }
        return -1;
    }

    private function _fmtAge(ageSec as Number) as String {
        if (ageSec < 60) {
            return ">" + ageSec.toString() + "s";
        }
        if (ageSec < 3600) {
            return ">" + (ageSec / 60).toString() + "m";
        }
        return ">" + (ageSec / 3600).toString() + "h";
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
    private function _effLabel(field as Number, periodMin as Number) as String {
        var key = field * 10000 + periodMin;
        var eff = _graphEffPeriod.hasKey(key)
            ? _graphEffPeriod.get(key) as Number
            : periodMin;
        return _tfLabel(eff > 0 ? eff : periodMin);
    }

    private function _minMax(data as Array<Float>) as Void {
        var n = data.size();
        _mmMin = 1.0e38 as Float;
        _mmMax = -1.0e38 as Float;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            if (v < _mmMin) {
                _mmMin = v;
            }
            if (v > _mmMax) {
                _mmMax = v;
            }
        }
        if (_mmMin > _mmMax) {
            _mmMin = 0.0;
            _mmMax = 0.0;
        }
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
            isGrad ? _gradColor(colorIdx, maxFrac) : _colorFromIdx(0),
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
            isGrad ? _gradColor(colorIdx, minFrac) : _colorFromIdx(0),
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
        if (ageSec > _fieldUpdateMin(field) * 60 + 30) {
            dc.drawText(
                gx,
                y + gh + 1,
                _fontTiny,
                _fmtAge(ageSec),
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

    private function _drawForecastRow(
        dc as Dc,
        cx as Number,
        y as Number,
        hours as Number,
        viewMode as Number,
        labelColor as Number,
        valueColor as Number,
        lineColor as Number,
        graphType as Number
    ) as Void {
        var all = _wxForecastData;
        if (all == null) {
            _rowBuf[0] = "Forecast";
            _rowBuf[1] = _wxTemp + _wxUnit;
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            return;
        }
        var cnt = all.size();
        var n = hours < cnt ? hours : cnt;
        if (n < 2) {
            _rowBuf[0] = "Forecast";
            _rowBuf[1] = _wxTemp + _wxUnit;
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            return;
        }

        var gw = _charW * 10;
        var gx = cx + _pad + _charW * 2;
        var gh = _fh - 2;

        if (_wxForecastRevCacheMin != _wxLastMin) {
            _wxForecastRevCache = {};
            _wxForecastRevCacheMin = _wxLastMin;
        }
        var data = _wxForecastRevCache.get(hours) as Array<Float>?;
        if (data == null) {
            var revData = new Array<Float>[n];
            for (var i = 0; i < n; i++) {
                revData[i] = (all as Array<Float>)[n - 1 - i];
            }
            _wxForecastRevCache.put(hours, revData);
            data = revData;
        }

        _minMax(data);
        var minV = _mmMin;
        var maxV = _mmMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }
        _getGradRange(FIELD_WX_FORECAST, lineColor, minV, range);
        var gradMinV = _grMin;
        var gradRange = _grRange;
        var maxFrac = (maxV - gradMinV) / gradRange;
        if (maxFrac < 0.0) {
            maxFrac = 0.0;
        }
        if (maxFrac > 1.0) {
            maxFrac = 1.0;
        }
        var minFrac = (minV - gradMinV) / gradRange;
        if (minFrac < 0.0) {
            minFrac = 0.0;
        }
        if (minFrac > 1.0) {
            minFrac = 1.0;
        }

        _rowBuf[0] = "Forecast";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        _drawMeanLine(
            dc,
            data,
            gx,
            gw,
            y,
            gh,
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
            gx,
            gw,
            y,
            gh,
            minV,
            range,
            gradMinV,
            gradRange,
            data.size()
        );
        _drawGraphAxes(dc, gx, gw, y);
        _drawSingleGraphLabels(
            dc,
            FIELD_WX_FORECAST,
            gx,
            gw,
            y,
            gh,
            minV,
            maxV,
            "+" + hours.toString() + "h",
            lineColor,
            maxFrac,
            minFrac,
            -1
        );
        if (viewMode == VIEW_GRAPH_VALUE || viewMode == VIEW_GRAPH_MINMAX) {
            var vx = gx + gw + _charW;
            var vy = y + (_fh - _smallFh) / 2 - 1;
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            if (viewMode == VIEW_GRAPH_VALUE) {
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    _wxTemp,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
                vx += dc.getTextWidthInPixels(_wxTemp, _fontSmall);
                dc.drawCircle(
                    vx + _degWSmall / 2,
                    vy + _degWSmall / 2 + 4,
                    (_degWSmall - 1) / 2
                );
                vx += _degWSmall;
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            } else {
                var metric = _metric;
                var minStr = metric
                    ? minV.format("%.0f")
                    : _toF(minV).format("%.0f");
                var maxStr = metric
                    ? maxV.format("%.0f")
                    : _toF(maxV).format("%.0f");
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    minStr,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
                vx += dc.getTextWidthInPixels(minStr, _fontSmall);
                dc.drawCircle(
                    vx + _degWSmall / 2,
                    vy + _degWSmall / 2 + 4,
                    (_degWSmall - 1) / 2
                );
                vx += _degWSmall;
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    "/",
                    Graphics.TEXT_JUSTIFY_LEFT
                );
                vx += dc.getTextWidthInPixels("/", _fontSmall);
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    maxStr,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
                vx += dc.getTextWidthInPixels(maxStr, _fontSmall);
                dc.drawCircle(
                    vx + _degWSmall / 2,
                    vy + _degWSmall / 2 + 4,
                    (_degWSmall - 1) / 2
                );
                vx += _degWSmall;
                dc.drawText(
                    vx,
                    vy,
                    _fontSmall,
                    _wxUnit,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
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
        graphType as Number
    ) as Void {
        var data = _getFieldHistory(field, periodMin);
        _getFieldParts(field);
        var valueStr = _rowBuf[1];
        var gw = _charW * 10;
        var gx = cx + _pad + _charW * 2;
        var gh = _fh - 2;
        if (data == null) {
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            _drawGraphAxes(dc, gx, gw, y);
            dc.setColor(GRAYS[3], Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw / 2,
                y + gh / 2 - _tinyFh / 2 - 1,
                _fontTiny,
                "no data",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            return;
        }

        _minMax(data);
        var minV = _mmMin;
        var maxV = _mmMax;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }
        _getGradRange(field, lineColor, minV, range);
        var gradMinV = _grMin;
        var gradRange = _grRange;
        var maxFrac = (maxV - gradMinV) / gradRange;
        if (maxFrac < 0.0) {
            maxFrac = 0.0;
        }
        if (maxFrac > 1.0) {
            maxFrac = 1.0;
        }
        var minFrac = (minV - gradMinV) / gradRange;
        if (minFrac < 0.0) {
            minFrac = 0.0;
        }
        if (minFrac > 1.0) {
            minFrac = 1.0;
        }

        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var maxGap = (10 * gw) / periodMin;
        if (maxGap < 1) {
            maxGap = 1;
        }
        var cacheKey = field * 10000 + periodMin;
        var graphBmp = _renderGraphToBitmap(
            cacheKey,
            graphType,
            lineColor,
            data,
            gw,
            gh,
            minV,
            range,
            gradMinV,
            gradRange,
            maxGap
        );
        if (graphBmp != null) {
            dc.drawBitmap(gx, y, graphBmp);
        } else {
            _drawMeanLine(
                dc,
                data,
                gx,
                gw,
                y,
                gh,
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
                gx,
                gw,
                y,
                gh,
                minV,
                range,
                gradMinV,
                gradRange,
                maxGap
            );
        }
        _drawGraphAxes(dc, gx, gw, y);
        _drawSingleGraphLabels(
            dc,
            field,
            gx,
            gw,
            y,
            gh,
            minV,
            maxV,
            _effLabel(field, periodMin),
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
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw + _charW,
                y + (_fh - _smallFh) / 2 - 1,
                _fontSmall,
                valueStr,
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }

    // Fields handled by special draw functions have early returns in _drawLineRow
    // and never reach here: FLOORS, WX_TEMP, WX_FEELS, WX_TEMP_COND, WX_TEMP_MINMAX, WX_TEMP_WIND,
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
                _rowBuf[0] = "Kcal Day";
                _rowBuf[1] = "0 kcal";
                return;
            }
            var info = _amInfo as ActivityMonitor.Info;
            _rowBuf[0] = "Kcal Day";
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
            if (_metric) {
                _rowBuf[0] = "Altitude";
                _rowBuf[1] = a.altitude.format("%.0f") + "m";
                return;
            }
            _rowBuf[0] = "Altitude";
            _rowBuf[1] = (a.altitude * 3.28084).format("%.0f") + "ft";
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
        if (field == FIELD_ACTIVE_MIN) {
            if (_amInfo == null) {
                _rowBuf[0] = "Int Mins Wk";
                _rowBuf[1] = "0";
                return;
            }
            var mins = (_amInfo as ActivityMonitor.Info).activeMinutesWeek;
            if (mins != null && mins.total != null) {
                _rowBuf[0] = "Int Mins Wk";
                _rowBuf[1] = (mins.total as Number).toString();
                return;
            }
            _rowBuf[0] = "Int Mins Wk";
            _rowBuf[1] = "0";
            return;
        }
        if (field == FIELD_WX_PRECIP) {
            _rowBuf[0] = "Rain";
            _rowBuf[1] = _wxPrecip;
            return;
        }
        if (field == FIELD_WX_WIND) {
            _rowBuf[0] = "Wind";
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
            _rowBuf[0] = "Cond + Rain";
            _rowBuf[1] = _wxCond + " | " + _wxPrecip;
            return;
        }
        if (field == FIELD_WX_WIND_PRECIP) {
            _rowBuf[0] = "Wind + Rain";
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
                _rowBuf[0] = "Kcal Act";
                _rowBuf[1] = "0 kcal";
                return;
            }
            var a = _acInfo as Activity.Info;
            if (a.calories != null) {
                _rowBuf[0] = "Kcal Act";
                _rowBuf[1] = (a.calories as Number).toString() + " kcal";
                return;
            }
            _rowBuf[0] = "Kcal Act";
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
        if (field == FIELD_TEMP_WRIST) {
            _rowBuf[0] = "Wrist Temp";
            _rowBuf[1] = _cachedTempWrist;
            return;
        }
        if (field == FIELD_ACTIVE_MIN_DAY) {
            if (_amInfo == null) {
                _rowBuf[0] = "Act Mins";
                _rowBuf[1] = "0";
                return;
            }
            var mins = (_amInfo as ActivityMonitor.Info).activeMinutesDay;
            if (mins != null && mins.total != null) {
                _rowBuf[0] = "Act Mins";
                _rowBuf[1] = (mins.total as Number).toString();
                return;
            }
            _rowBuf[0] = "Act Mins";
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
            _rowBuf[1] = _cachedPressure;
            return;
        }
        if (field == FIELD_ELEVATION) {
            _rowBuf[0] = "Elevation";
            _rowBuf[1] = _cachedElevation;
            return;
        }
        if (field == FIELD_WX_FORECAST) {
            _rowBuf[0] = "Forecast";
            _rowBuf[1] = _wxTemp + _wxUnit;
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
            _rowBuf[0] = "Sun";
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
                var d = _compWeeklyRun as Number;
                if (_metric) {
                    _rowBuf[0] = "Wk Run";
                    _rowBuf[1] = (d / 1000.0).format("%.1f") + "km";
                    return;
                }
                _rowBuf[0] = "Wk Run";
                _rowBuf[1] = (d / 1609.344).format("%.1f") + "mi";
                return;
            }
            _rowBuf[0] = "Wk Run";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_WEEKLY_BIKE) {
            if (_compWeeklyBike != null) {
                var d = _compWeeklyBike as Number;
                if (_metric) {
                    _rowBuf[0] = "Wk Bike";
                    _rowBuf[1] = (d / 1000.0).format("%.1f") + "km";
                    return;
                }
                _rowBuf[0] = "Wk Bike";
                _rowBuf[1] = (d / 1609.344).format("%.1f") + "mi";
                return;
            }
            _rowBuf[0] = "Wk Bike";
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
                    _rowBuf[1] = (spd * 3.6).format("%.1f") + " km/h";
                    return;
                }
                _rowBuf[0] = "Speed";
                _rowBuf[1] = (spd * 2.23694).format("%.1f") + " mph";
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
                _rowBuf[0] = "Lat";
                _rowBuf[1] = (coords[0] as Double).format("%.5f");
                return;
            }
            _rowBuf[0] = "Lat";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_GPS_LON) {
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                _rowBuf[0] = "Lon";
                _rowBuf[1] = (coords[1] as Double).format("%.5f");
                return;
            }
            _rowBuf[0] = "Lon";
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
                }
                _rowBuf[0] = "GPS Acc";
                _rowBuf[1] = label;
                return;
            }
            _rowBuf[0] = "GPS Acc";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_HEADING) {
            var pos = _posInfo;
            if (pos != null && pos.heading != null) {
                var deg = ((pos.heading as Float) * 57.29577951).toNumber();
                deg = ((deg % 360) + 360) % 360;
                _rowBuf[0] = "Hdg";
                _rowBuf[1] = deg.toString() + "°";
                return;
            }
            _rowBuf[0] = "Hdg";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_GPS_LAT_LON) {
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                var lat = coords[0] as Double;
                var lon = coords[1] as Double;
                _rowBuf[0] = "GPS";
                _rowBuf[1] = lat.format("%.5f") + ", " + lon.format("%.5f");
                return;
            }
            _rowBuf[0] = "GPS";
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
                    accLabel = " [USE]";
                } else if (acc == Position.QUALITY_POOR) {
                    accLabel = " [POOR]";
                } else if (acc == Position.QUALITY_LAST_KNOWN) {
                    accLabel = " [LAST]";
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
            _rowBuf[0] = "Temp + Cond";
            _rowBuf[1] = _wxTemp + _wxUnit + " " + _wxCond;
            return;
        }
        if (field == FIELD_WX_TEMP_WIND) {
            _rowBuf[0] = "Temp + Wind";
            _rowBuf[1] = _wxTemp + _wxUnit + " " + _wxWind;
            return;
        }
        if (field == FIELD_WX_TEMP_UV) {
            _rowBuf[0] = "Temp + UV";
            _rowBuf[1] = _wxTemp + _wxUnit + " UV:" + _wxUv;
            return;
        }
        if (field == FIELD_WX_UV_PRECIP) {
            _rowBuf[0] = "UV + Rain";
            _rowBuf[1] = _wxUv + " " + _wxPrecip;
            return;
        }
        if (field == FIELD_WX_UV_WIND) {
            _rowBuf[0] = "UV + Wind";
            _rowBuf[1] = _wxUv + " " + _wxWind;
            return;
        }
        if (field == FIELD_WX_TEMP_MINMAX) {
            _rowBuf[0] = "Temp";
            _rowBuf[1] = _wxLow + "/" + _wxHigh + _wxUnit;
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
                var m = s / 60;
                var h = m / 60;
                _rowBuf[0] = "Elapsed";
                _rowBuf[1] =
                    h.format("%d") +
                    ":" +
                    (m % 60).format("%02d") +
                    ":" +
                    (s % 60).format("%02d");
                return;
            }
            _rowBuf[0] = "Elapsed";
            _rowBuf[1] = "-";
            return;
        }
        if (field == FIELD_TRAINING_STATUS) {
            _rowBuf[0] = "Train Status";
            _rowBuf[1] =
                _compTrainingStatus != null
                    ? _compTrainingStatus as String
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
            _rowBuf[0] = "Marathon";
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
        _rowBuf[0] = "";
        _rowBuf[1] = "";
        return;
    }

    private function _timeParts() as Array<String> {
        var t = System.getClockTime();
        if (t.min != _timeLastMin) {
            _timeLastMin = t.min;
            if (!_is24Hour) {
                var h = t.hour % 12;
                if (h == 0) {
                    h = 12;
                }
                _timeHMpart = h.toString() + ":" + t.min.format("%02d");
                _timeAmPm = t.hour >= 12 ? "pm" : "am";
            } else {
                _timeHMpart =
                    t.hour.format("%02d") + ":" + t.min.format("%02d");
                _timeAmPm = "";
            }
        }
        _timeBuf[1] =
            _timeHMpart +
            (_showSeconds ? ":" + t.sec.format("%02d") : "") +
            _timeAmPm;
        return _timeBuf;
    }

    private function _dateParts() as Array<String> {
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
                GRAPH_FIELDS[_lineSecField[i]] == f
            ) {
                return true;
            }
        }
        return false;
    }

    private function _refreshPointSamples() as Void {
        if (_fieldNeeded(FIELD_BODY_BAT)) {
            var sample = SensorHistory.getBodyBatteryHistory({}).next();
            if (sample != null && sample.data != null) {
                var d = sample.data;
                _cachedBodyBat =
                    (d instanceof Float
                        ? (d as Float).format("%.0f")
                        : (d as Number).toString()) + "%";
            }
        }
        if (_fieldNeeded(FIELD_TEMP_WRIST)) {
            var sample = SensorHistory.getTemperatureHistory({}).next();
            if (sample != null && sample.data != null) {
                var td = sample.data;
                var tempC =
                    td instanceof Float
                        ? td as Float
                        : (td as Number).toFloat();
                _cachedTempWrist = _metric
                    ? tempC.format("%.1f") + "C"
                    : _toF(tempC).format("%.1f") + "F";
            }
        }
        if (_fieldNeeded(FIELD_PRESSURE)) {
            var sample = SensorHistory.getPressureHistory({}).next();
            if (sample != null && sample.data != null) {
                var pd = sample.data;
                var pa =
                    pd instanceof Float
                        ? pd as Float
                        : (pd as Number).toFloat();
                _cachedPressure = _metric
                    ? (pa / 100.0).format("%.1f") + "hPa"
                    : (pa / 3386.39).format("%.2f") + "inHg";
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
                _cachedElevation = _metric
                    ? elev.format("%.0f") + "m"
                    : (elev * 3.28084).format("%.0f") + "ft";
            }
        }
        if (_fieldNeeded(FIELD_STRESS)) {
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
        var metric = _metric;
        if (c.temperature != null) {
            var tf = c.temperature as Float;
            _wxTemp = metric ? tf.format("%.1f") : _toF(tf).format("%.1f");
        }
        if (c.feelsLikeTemperature != null) {
            var tf = c.feelsLikeTemperature as Float;
            _wxFeels = metric ? tf.format("%.1f") : _toF(tf).format("%.1f");
        }
        if (c.lowTemperature != null) {
            var tf = c.lowTemperature as Float;
            _wxLow = metric ? tf.format("%.0f") : _toF(tf).format("%.0f");
        }
        if (c.highTemperature != null) {
            var tf = c.highTemperature as Float;
            _wxHigh = metric ? tf.format("%.0f") : _toF(tf).format("%.0f");
        }
        if (c.precipitationChance != null) {
            _wxPrecip = (c.precipitationChance as Number).toString() + "%";
        }
        if (c.windSpeed != null) {
            var spd = c.windSpeed as Float;
            _wxWind = metric
                ? (spd * 3.6).format("%.0f") + "km/h"
                : (spd * 2.237).format("%.0f") + "mph";
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
        var forecast = Weather.getHourlyForecast();
        if (forecast != null && forecast.size() > 0) {
            var cnt = forecast.size() < 24 ? forecast.size() : 24;
            var arr = new Array<Float>[cnt];
            for (var i = 0; i < cnt; i++) {
                var h = forecast[i];
                if (h.temperature != null) {
                    arr[i] = h.temperature as Float;
                }
            }
            _wxForecastData = arr;
        } else {
            _wxForecastData = null;
        }
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

    private function _toF(c as Float) as Float {
        return (c * 9.0) / 5.0 + 32.0;
    }

    private function _getPhase(nowSec as Number) as Number {
        var mainSec = _rotateMainMs / 1000;
        var altSec = _rotateAltMs / 1000;
        var cycle = mainSec + 2 * altSec;
        var pos = nowSec % cycle;
        if (pos < 0) {
            pos += cycle;
        }
        if (pos < mainSec) {
            return 0;
        }
        if (pos < mainSec + altSec) {
            return 1;
        }
        return 2;
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
        dc.setClip(_cursorX, _cursorY, _cursorCharW, _cursorFH);
        if (_cursorOn) {
            dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(_cursorX, _cursorY, _cursorCharW, _cursorFH);
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.fillRectangle(_cursorX, _cursorY, _cursorCharW, _cursorFH);
            if (_scanlineIntensity > 0 && _scanlineIntensity < 4) {
                dc.setColor(
                    SCANLINE_COLORS[_scanlineIntensity],
                    Graphics.COLOR_TRANSPARENT
                );
                var sy = (_cursorY / SCANLINE_SPACING) * SCANLINE_SPACING;
                while (sy < _cursorY + _cursorFH) {
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
