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

const MOMENT_NONE = 0;
const MOMENT_MORNING = 1;
const MOMENT_SLEEP = 2;
const MOMENT_WORKOUT = 3;

const VIEW_VALUE = 0;
const VIEW_GRAPH = 1;
const VIEW_GRAPH_VALUE = 2;

const GRAPH_LINE = 0;
const GRAPH_BAR = 1;

const SEC_NONE = 0;
const SEC_LINE = 1;
const SEC_BAR = 2;

const COLOR_GRAD = 10;
const COLOR_GRAD_REV = 11;
const COLOR_GRAD_TEMP = 12;
const COLOR_GRAD_TEMP_REV = 13;

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
        0x55eeff, // 2  cyan
        0xffee55, // 3  yellow
        0xff9944, // 4  orange
        0xff5555, // 5  red
        0x5588ff, // 6  blue
        0xff55ff, // 7  magenta
        0xaaaaaa, // 8  light grey
        0x9955ff, // 9  purple
    ] as Array<Number>;

const SCANLINE_SPACING = 3;
// Overlay color per intensity (0=off handled separately, 1=subtle, 2=medium, 3=strong)
const SCANLINE_COLORS =
    [0x000000, 0x0d0d0d, 0x1a1a1a, 0x2a2a2a] as Array<Number>;

const DAY_NAMES =
    ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] as Array<String>;
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

// Resource lookup arrays indexed by color index (0-9). See gen_icons.py.
const AUP_A_RES = [
    $.Rez.Drawables.AupA0,
    $.Rez.Drawables.AupA1,
    $.Rez.Drawables.AupA2,
    $.Rez.Drawables.AupA3,
    $.Rez.Drawables.AupA4,
    $.Rez.Drawables.AupA5,
    $.Rez.Drawables.AupA6,
    $.Rez.Drawables.AupA7,
    $.Rez.Drawables.AupA8,
    $.Rez.Drawables.AupA9,
];
const AUP_B_RES = [
    $.Rez.Drawables.AupB0,
    $.Rez.Drawables.AupB1,
    $.Rez.Drawables.AupB2,
    $.Rez.Drawables.AupB3,
    $.Rez.Drawables.AupB4,
    $.Rez.Drawables.AupB5,
    $.Rez.Drawables.AupB6,
    $.Rez.Drawables.AupB7,
    $.Rez.Drawables.AupB8,
    $.Rez.Drawables.AupB9,
];
const ADN_A_RES = [
    $.Rez.Drawables.AdnA0,
    $.Rez.Drawables.AdnA1,
    $.Rez.Drawables.AdnA2,
    $.Rez.Drawables.AdnA3,
    $.Rez.Drawables.AdnA4,
    $.Rez.Drawables.AdnA5,
    $.Rez.Drawables.AdnA6,
    $.Rez.Drawables.AdnA7,
    $.Rez.Drawables.AdnA8,
    $.Rez.Drawables.AdnA9,
];
const ADN_B_RES = [
    $.Rez.Drawables.AdnB0,
    $.Rez.Drawables.AdnB1,
    $.Rez.Drawables.AdnB2,
    $.Rez.Drawables.AdnB3,
    $.Rez.Drawables.AdnB4,
    $.Rez.Drawables.AdnB5,
    $.Rez.Drawables.AdnB6,
    $.Rez.Drawables.AdnB7,
    $.Rez.Drawables.AdnB8,
    $.Rez.Drawables.AdnB9,
];
const DEG_A_RES = [
    $.Rez.Drawables.DegA0,
    $.Rez.Drawables.DegA1,
    $.Rez.Drawables.DegA2,
    $.Rez.Drawables.DegA3,
    $.Rez.Drawables.DegA4,
    $.Rez.Drawables.DegA5,
    $.Rez.Drawables.DegA6,
    $.Rez.Drawables.DegA7,
    $.Rez.Drawables.DegA8,
    $.Rez.Drawables.DegA9,
];
const DEG_B_RES = [
    $.Rez.Drawables.DegB0,
    $.Rez.Drawables.DegB1,
    $.Rez.Drawables.DegB2,
    $.Rez.Drawables.DegB3,
    $.Rez.Drawables.DegB4,
    $.Rez.Drawables.DegB5,
    $.Rez.Drawables.DegB6,
    $.Rez.Drawables.DegB7,
    $.Rez.Drawables.DegB8,
    $.Rez.Drawables.DegB9,
];

class TerminalWatchfaceView extends WatchUi.WatchFace {
    private var _w as Number = 0;
    private var _h as Number = 0;
    private var _lastPhase as Number = -1;
    private var _lastFontChoice as Number = -1;
    private var _font as Graphics.FontType = Graphics.FONT_SMALL;
    private var _fontSmall as Graphics.FontType = Graphics.FONT_TINY;
    private var _fontTiny as Graphics.FontType = Graphics.FONT_XTINY;
    private var _graphCache as Dictionary = {};
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
    private var _wxCond as String = "-";
    private var _wxForecastData as Array<Float>? = null;
    private var _wxLow as String = "-";
    private var _wxHigh as String = "-";
    private var _sizeSet as Number = 0; // 0 = lineHeight 30, 1 = lineHeight 32
    private var _bmpCache as Dictionary = {};
    private var _arrowH as Number = 16;
    private var _bmpArrowW as Number = 14;
    private var _boltH as Number = 16;
    private var _bmpBoltW as Number = 16;
    private var _degW as Number = 8;
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
    private var _momentType as Number = 0;
    private var _momentExpiry as Number = 0;
    private var _morningEpoch as Number = -1;
    private var _sleepEpoch as Number = -1;
    private var _workoutEpoch as Number = -1;
    private var _sleepShown as Boolean = false;
    private var _workoutWasActive as Boolean = false;
    private var _prevTimerState as Number = 0;

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

    private function _refreshComplications() as Void {
        _compSleepScore = null;
        _compSunrise = null;
        _compSunset = null;
        _compCalendar = null;
        _compWeeklyRun = null;
        _compWeeklyBike = null;
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
                }
            }
            comp = iter.next() as Complications.Complication?;
        }
    }

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
            _bmpCache = {};
        }
        if (_sizeSet == 1) {
            _arrowH = 16;
            _bmpArrowW = 14;
            _boltH = 18;
            _bmpBoltW = 16;
            _degW = 8;
        } else {
            _arrowH = 15;
            _bmpArrowW = 13;
            _boltH = 17;
            _bmpBoltW = 15;
            _degW = 7;
        }
    }

    public function onUpdate(dc as Dc) as Void {
        var now = System.getTimer();
        var phase = _getPhase(now);
        _cursorOn = (now / 1000) % 2 == 0;
        _amInfo = ActivityMonitor.getInfo();
        _acInfo = Activity.getActivityInfo();
        _posInfo = Position.getInfo();
        var settings = System.getDeviceSettings();
        _metric = settings.distanceUnits == System.UNIT_METRIC;
        _notifCount =
            settings.notificationCount != null
                ? settings.notificationCount as Number
                : 0;
        var clockInfo =
            Gregorian.info(Time.now(), Time.FORMAT_SHORT) as Gregorian.Info;
        var nowMin = clockInfo.min as Number;
        var nowH = clockInfo.hour as Number;
        if (nowMin != _graphCacheMin) {
            _graphCache = {};
            _graphCacheMin = nowMin;
            _refreshComplications();
        }
        _refreshWeather(nowMin);

        // Auto-expire active moment
        if (_momentType != MOMENT_NONE && System.getTimer() >= _momentExpiry) {
            _momentType = MOMENT_NONE;
        }
        // Reset daily flags at midnight
        if (nowH == 0) {
            _sleepShown = false;
        }
        // Detect discrete events this tick
        var tsOff = Activity.TIMER_STATE_OFF as Number;
        var tsOn = Activity.TIMER_STATE_ON as Number;
        var curTimerState = tsOff;
        var acI = _acInfo;
        if (acI != null) {
            var ts = (acI as Activity.Info).timerState;
            if (ts != null) {
                curTimerState = ts as Number;
            }
        }
        if (curTimerState == tsOn) {
            _workoutWasActive = true;
        }
        var workoutFinishEvent =
            _workoutWasActive &&
            curTimerState == tsOff &&
            _prevTimerState != tsOff;
        if (workoutFinishEvent) {
            _workoutWasActive = false;
        }
        _prevTimerState = curTimerState;
        var wakeupEvent = false;
        if (!_sleepShown && _compSleepScore != null && nowH >= 4 && nowH < 13) {
            _sleepShown = true;
            wakeupEvent = true;
        }
        // Check each moment in priority order (only one active at a time)
        var curMin = nowH * 60 + nowMin;
        if (_momentType == MOMENT_NONE) {
            _checkMoment(
                MOMENT_MORNING,
                curMin,
                wakeupEvent,
                workoutFinishEvent
            );
        }
        if (_momentType == MOMENT_NONE) {
            _checkMoment(MOMENT_SLEEP, curMin, wakeupEvent, workoutFinishEvent);
        }
        if (_momentType == MOMENT_NONE) {
            _checkMoment(
                MOMENT_WORKOUT,
                curMin,
                wakeupEvent,
                workoutFinishEvent
            );
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Scanlines drawn before text; text pixels overwrite them via transparent bg
        var scanIntensity = _getProp("scanlines", 2);
        if (scanIntensity > 0 && scanIntensity < SCANLINE_COLORS.size()) {
            _drawScanlines(dc, SCANLINE_COLORS[scanIntensity]);
        }

        _fh = dc.getFontHeight(_font);
        _charW = dc.getTextWidthInPixels("W", _font);
        _tinyFh = dc.getFontHeight(_fontTiny);
        _smallFh = dc.getFontHeight(_fontSmall);
        var step = _fh + 16;
        var gap = 16;
        var cx = _w / 2 - _charW * 4;
        _pad = dc.getTextWidthInPixels(": ", _font) / 2;
        _arrowW = dc.getTextWidthInPixels(" > ", _font);

        if (_momentType != MOMENT_NONE) {
            var momentY = (_h - step * 6 - _fh) / 2;
            _drawHeader(dc, momentY, gap);
            _drawMomentScreen(dc, cx, momentY, step, gap);
            _cursorCharW = 0;
            _drawFooter(dc, momentY + step * 6 + _fh + 2 * gap);
        } else {
            var vis = [false, false, false] as Array<Boolean>;
            var visible = 4;
            for (var ln = 3; ln <= 5; ln++) {
                var v = _lineVisible(ln, phase);
                vis[ln - 3] = v;
                if (v) {
                    visible++;
                }
            }
            visible += 2;

            var y = (_h - step * (visible - 3) - _fh) / 2;
            var row = 0;

            _drawHeader(dc, y, gap);
            _drawPromptLine(dc, cx, y + step * row, ".\\watch.bat");
            row++;

            _drawRow(
                dc,
                cx,
                y + step * row,
                _timeParts(),
                _getProp("line1LabelColor", 8),
                _getProp("line1ValueColor", 0)
            );
            row++;
            _drawRow(
                dc,
                cx,
                y + step * row,
                _dateParts(),
                _getProp("line2LabelColor", 8),
                _getProp("line2ValueColor", 0)
            );
            row++;

            for (var ln = 3; ln <= 5; ln++) {
                if (vis[ln - 3]) {
                    _drawLineRow(dc, cx, y + step * row, ln, phase);
                    row++;
                }
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
            dc.drawText(
                splitX,
                footerY,
                _font,
                " > ",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            if (_cursorOn) {
                dc.fillRectangle(splitX, footerY, _charW, _fh);
            }
            _drawFooter(dc, footerY + _fh + 2 * gap);
        }
    }

    // Returns the color-tinted, size-correct bitmap for the given icon and color
    // index. Lazy-loads from resources and caches by (iconType, _sizeSet, colorIdx).
    private function _getIconBmp(
        iconType as Number,
        colorIdx as Number
    ) as Graphics.BitmapType? {
        if (colorIdx < 0 || colorIdx >= COLORS.size()) {
            colorIdx = 0;
        }
        var key = iconType * 20 + _sizeSet * 10 + colorIdx;
        var cached = _bmpCache.get(key);
        if (cached != null) {
            return cached as Graphics.BitmapType;
        }
        try {
            if (iconType == ICON_BOLT) {
                var bmp =
                    WatchUi.loadResource(
                        _sizeSet == 1
                            ? $.Rez.Drawables.BoltB
                            : $.Rez.Drawables.BoltA
                    ) as Graphics.BitmapType;
                _bmpCache.put(key, bmp);
                return bmp;
            }
            var arr =
                iconType == ICON_ARROW_UP
                    ? _sizeSet == 1
                        ? AUP_B_RES
                        : AUP_A_RES
                    : iconType == ICON_ARROW_DN
                      ? _sizeSet == 1
                          ? ADN_B_RES
                          : ADN_A_RES
                      : iconType == ICON_DEG
                        ? _sizeSet == 1
                            ? DEG_B_RES
                            : DEG_A_RES
                        : null;
            if (arr != null) {
                var bmp =
                    WatchUi.loadResource(arr[colorIdx]) as Graphics.BitmapType;
                _bmpCache.put(key, bmp);
                return bmp;
            }
        } catch (e instanceof Lang.Exception) {}
        return null;
    }

    private function _drawHeader(dc as Dc, y as Number, gap as Number) as Void {
        if (_notifCount == 0) {
            return;
        }
        var textY = y - 2 * gap - _smallFh;
        var label = "[" + _notifCount.toString() + "]";
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
        var stats = System.getSystemStats();
        var bat = stats.battery;
        var days = stats.batteryInDays;
        var batText = bat.format("%.0f") + "%";
        var daysText = days != null ? " [" + days.format("%.0f") + "d]" : "";
        var batW = dc.getTextWidthInPixels(batText, _fontSmall);
        var daysW =
            days != null ? dc.getTextWidthInPixels(daysText, _fontSmall) : 0;
        if (stats.charging) {
            var bolt = _getIconBmp(ICON_BOLT, 0);
            if (bolt != null) {
                var fhSm = _smallFh;
                var spaced = " " + batText;
                var spacedW = dc.getTextWidthInPixels(spaced, _fontSmall);
                var startX = (_w - _bmpBoltW - spacedW - daysW) / 2;
                dc.drawBitmap(startX, y + (fhSm - _boltH) / 2, bolt);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    startX + _bmpBoltW,
                    y,
                    _fontSmall,
                    spaced,
                    Graphics.TEXT_JUSTIFY_LEFT
                );
                if (days != null) {
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
        }
        var startX = (_w - batW - daysW) / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, y, _fontSmall, batText, Graphics.TEXT_JUSTIFY_LEFT);
        if (days != null) {
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
        if (content.length() > 0) {
            dc.setColor(_colorFromIdx(3), Graphics.COLOR_TRANSPARENT);
            dc.drawText(splitX, y, _font, content, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function _lineVisible(
        lineNum as Number,
        phase as Number
    ) as Boolean {
        if (lineNum == 3) {
            if (
                phase == 1 &&
                _getProp("line3Secondary", FIELD_NONE) != FIELD_NONE
            ) {
                return true;
            }
            if (
                phase == 2 &&
                _getProp("line3Tertiary", FIELD_NONE) != FIELD_NONE
            ) {
                return true;
            }
            return _getProp("line3Primary", FIELD_NONE) != FIELD_NONE;
        }
        if (lineNum == 4) {
            if (
                phase == 1 &&
                _getProp("line4Secondary", FIELD_NONE) != FIELD_NONE
            ) {
                return true;
            }
            if (
                phase == 2 &&
                _getProp("line4Tertiary", FIELD_NONE) != FIELD_NONE
            ) {
                return true;
            }
            return _getProp("line4Primary", FIELD_NONE) != FIELD_NONE;
        }
        if (
            phase == 1 &&
            _getProp("line5Secondary", FIELD_NONE) != FIELD_NONE
        ) {
            return true;
        }
        if (phase == 2 && _getProp("line5Tertiary", FIELD_NONE) != FIELD_NONE) {
            return true;
        }
        return _getProp("line5Primary", FIELD_NONE) != FIELD_NONE;
    }

    private function _drawLineRow(
        dc as Dc,
        cx as Number,
        y as Number,
        lineNum as Number,
        phase as Number
    ) as Void {
        var field = FIELD_NONE;
        var labelColor = 8;
        var valueColor = 0;
        if (lineNum == 3) {
            var sec3 = _getProp("line3Secondary", FIELD_NONE);
            var ter3 = _getProp("line3Tertiary", FIELD_NONE);
            if (phase == 1 && sec3 != FIELD_NONE) {
                field = sec3;
                labelColor = _getProp("line3SecondaryLabelColor", 8);
                valueColor = _getProp("line3SecondaryValueColor", 0);
            } else if (phase == 2 && ter3 != FIELD_NONE) {
                field = ter3;
                labelColor = _getProp("line3TertiaryLabelColor", 8);
                valueColor = _getProp("line3TertiaryValueColor", 0);
            } else {
                field = _getProp("line3Primary", FIELD_NONE);
                labelColor = _getProp("line3PrimaryLabelColor", 8);
                valueColor = _getProp("line3PrimaryValueColor", 0);
            }
        } else if (lineNum == 4) {
            var sec4 = _getProp("line4Secondary", FIELD_NONE);
            var ter4 = _getProp("line4Tertiary", FIELD_NONE);
            if (phase == 1 && sec4 != FIELD_NONE) {
                field = sec4;
                labelColor = _getProp("line4SecondaryLabelColor", 8);
                valueColor = _getProp("line4SecondaryValueColor", 0);
            } else if (phase == 2 && ter4 != FIELD_NONE) {
                field = ter4;
                labelColor = _getProp("line4TertiaryLabelColor", 8);
                valueColor = _getProp("line4TertiaryValueColor", 0);
            } else {
                field = _getProp("line4Primary", FIELD_NONE);
                labelColor = _getProp("line4PrimaryLabelColor", 8);
                valueColor = _getProp("line4PrimaryValueColor", 0);
            }
        } else {
            var sec5 = _getProp("line5Secondary", FIELD_NONE);
            var ter5 = _getProp("line5Tertiary", FIELD_NONE);
            if (phase == 1 && sec5 != FIELD_NONE) {
                field = sec5;
                labelColor = _getProp("line5SecondaryLabelColor", 8);
                valueColor = _getProp("line5SecondaryValueColor", 0);
            } else if (phase == 2 && ter5 != FIELD_NONE) {
                field = ter5;
                labelColor = _getProp("line5TertiaryLabelColor", 8);
                valueColor = _getProp("line5TertiaryValueColor", 0);
            } else {
                field = _getProp("line5Primary", FIELD_NONE);
                labelColor = _getProp("line5PrimaryLabelColor", 8);
                valueColor = _getProp("line5PrimaryValueColor", 0);
            }
        }
        if (field == FIELD_FLOORS) {
            _drawFloorsRow(dc, cx, y, labelColor, valueColor);
            return;
        }
        if (field == FIELD_WX_TEMP_MINMAX) {
            _drawTempMinMaxRow(dc, cx, y, labelColor, valueColor);
            return;
        }
        if (field == FIELD_WX_TEMP) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Temp",
                _wxTemp,
                "",
                labelColor,
                valueColor
            );
            return;
        }
        if (field == FIELD_WX_FEELS) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Feels Like",
                _wxFeels,
                "",
                labelColor,
                valueColor
            );
            return;
        }
        if (field == FIELD_WX_TEMP_COND) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Temp",
                _wxTemp,
                " " + _wxCond,
                labelColor,
                valueColor
            );
            return;
        }
        if (field == FIELD_WX_TEMP_WIND) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Temp",
                _wxTemp,
                " " + _wxWind,
                labelColor,
                valueColor
            );
            return;
        }
        if (field == FIELD_STEPS) {
            var stepsView = _getProp("stepsViewMode", 2);
            if (stepsView == 1 || stepsView == 2) {
                var barColor = _getProp("stepsBarColor", 1);
                _drawStepsBarRow(
                    dc,
                    cx,
                    y,
                    labelColor,
                    valueColor,
                    stepsView == 2,
                    barColor
                );
            } else {
                var info = _amInfo as ActivityMonitor.Info;
                var steps = info.steps != null ? info.steps : 0;
                var goal = info.stepGoal != null ? info.stepGoal : 10000;
                var parts =
                    [
                        "Steps",
                        steps.format("%0" + goal.toString().length() + "d"),
                    ] as Array<String>;
                _drawRow(dc, cx, y, parts, labelColor, valueColor);
                if (steps >= goal) {
                    dc.setColor(_colorFromIdx(1), Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        cx + _pad + dc.getTextWidthInPixels(parts[1], _font),
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
            var viewMode = _getProp("wxForecastViewMode", VIEW_GRAPH);
            var lineColor = _getProp("wxForecastGraphColor", 12);
            var graphType = _getProp("wxForecastGraphType", GRAPH_BAR);
            var hours = _getProp("wxForecastTimeFrame", 12);
            _drawForecastRow(
                dc,
                cx,
                y,
                hours,
                viewMode,
                labelColor,
                valueColor,
                lineColor,
                graphType
            );
            return;
        }
        var gk = _fieldGraphKey(field);
        if (gk != null) {
            var viewMode = _getProp(gk + "ViewMode", VIEW_VALUE);
            var periodMin = _getProp(gk + "TimeFrame", 60);
            var lineColor = _getProp(
                gk + "GraphColor",
                gk.equals("hr") ? 5 : 0
            );
            var graphType = _getProp(gk + "GraphType", GRAPH_LINE);
            var secType = _getProp(gk + "SecondaryType", SEC_NONE);
            if (viewMode == VIEW_GRAPH || viewMode == VIEW_GRAPH_VALUE) {
                if (secType != SEC_NONE) {
                    var secIdx = _getProp(gk + "SecondaryField", 0);
                    if (secIdx < 0 || secIdx >= GRAPH_FIELDS.size()) {
                        secIdx = 0;
                    }
                    var lineColor2 = _getProp(gk + "SecondaryColor", 0);
                    _drawDualGraphRow(
                        dc,
                        cx,
                        y,
                        field,
                        GRAPH_FIELDS[secIdx] as Number,
                        periodMin,
                        labelColor,
                        valueColor,
                        lineColor,
                        lineColor2,
                        graphType,
                        secType,
                        viewMode
                    );
                } else {
                    _drawGraphRow(
                        dc,
                        cx,
                        y,
                        field,
                        periodMin,
                        viewMode,
                        labelColor,
                        valueColor,
                        lineColor,
                        graphType
                    );
                }
                return;
            }
        }
        _drawRow(dc, cx, y, _getFieldParts(field), labelColor, valueColor);
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
        var info = _amInfo as ActivityMonitor.Info;
        var steps = info.steps != null ? info.steps as Number : 0;
        var goal = info.stepGoal != null ? info.stepGoal as Number : 10000;
        _drawRow(
            dc,
            cx,
            y,
            ["Steps", ""] as Array<String>,
            labelColor,
            valueColor
        );
        var gx = cx + _pad + _charW;
        var gw = _charW * 10;
        var barH = _fh;
        var barY = y;
        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
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
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw / 2,
                valY,
                _fontSmall,
                steps.format("%0" + goalStr.length() + "d"),
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
        var info = _amInfo as ActivityMonitor.Info;
        var up = (
            info.floorsClimbed != null ? info.floorsClimbed : 0
        ).toString();
        var dn = (
            info.floorsDescended != null ? info.floorsDescended : 0
        ).toString();
        _drawRow(dc, cx, y, ["Floors", ""], labelIdx, valIdx);
        var ay = y + (_fh - _arrowH) / 2;
        var x = cx + _pad;
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        var bmpUp = _getIconBmp(ICON_ARROW_UP, valIdx);
        var bmpDn = _getIconBmp(ICON_ARROW_DN, valIdx);
        if (bmpUp != null) {
            dc.drawBitmap(x, ay, bmpUp);
        }
        x += _bmpArrowW + ARROW_PAD;
        var upSpace = up + " ";
        dc.drawText(x, y, _font, upSpace, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(upSpace, _font);
        if (bmpDn != null) {
            dc.drawBitmap(x, ay, bmpDn);
        }
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
        _drawRow(dc, cx, y, [label, ""] as Array<String>, labelIdx, valIdx);
        var x = cx + _pad;
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, numStr, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(numStr, _font);
        var bmpDeg = _getIconBmp(ICON_DEG, valIdx);
        if (bmpDeg != null) {
            dc.drawBitmap(x, y + (_fh - _degW) / 4, bmpDeg);
        }
        x += _degW;
        dc.drawText(x, y, _font, _wxUnit + suffix, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function _drawTempMinMaxRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        _drawRow(dc, cx, y, ["Temp", ""] as Array<String>, labelIdx, valIdx);
        var ay = y + (_fh - _arrowH) / 2;
        var x = cx + _pad;
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        var bmpDeg = _getIconBmp(ICON_DEG, valIdx);
        var bmpDn = _getIconBmp(ICON_ARROW_DN, valIdx);
        var bmpUp = _getIconBmp(ICON_ARROW_UP, valIdx);
        dc.drawText(x, y, _font, _wxTemp, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxTemp, _font);
        if (bmpDeg != null) {
            dc.drawBitmap(x, y + (_fh - _degW) / 4, bmpDeg);
        }
        x += _degW;
        dc.drawText(x, y, _font, _wxUnit + " [", Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxUnit + " [", _font);
        if (bmpDn != null) {
            dc.drawBitmap(x, ay, bmpDn);
        }
        x += _bmpArrowW + ARROW_PAD;
        dc.drawText(x, y, _font, _wxLow + "] [", Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxLow + "] [", _font);
        if (bmpUp != null) {
            dc.drawBitmap(x, ay, bmpUp);
        }
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
            dc.drawText(cx + _pad, y, _font, value, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function _colorFromIdx(idx as Number) as Number {
        if (idx >= 0 && idx < COLORS.size()) {
            return COLORS[idx];
        }
        return 0xffffff;
    }

    private function _valueTempColor(fraction as Float) as Number {
        var r = 0;
        var g = 0;
        var b = 0;
        if (fraction <= 0.33) {
            var t = fraction / 0.33;
            r = 85;
            g = (136.0 + t * 102.0).toNumber();
            b = 255;
        } else if (fraction <= 0.66) {
            var t = (fraction - 0.33) / 0.33;
            r = (85.0 + t * 170.0).toNumber();
            g = 238;
            b = (255.0 - t * 170.0).toNumber();
        } else {
            var t = (fraction - 0.66) / 0.34;
            r = 255;
            g = (238.0 - t * 153.0).toNumber();
            b = 85;
        }
        return ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff);
    }

    private function _gradColor(
        colorIdx as Number,
        fraction as Float
    ) as Number {
        if (colorIdx == COLOR_GRAD) {
            return _valueColor(fraction);
        }
        if (colorIdx == COLOR_GRAD_REV) {
            return _valueColor(1.0 - fraction);
        }
        if (colorIdx == COLOR_GRAD_TEMP) {
            return _valueTempColor(fraction);
        }
        if (colorIdx == COLOR_GRAD_TEMP_REV) {
            return _valueTempColor(1.0 - fraction);
        }
        return _colorFromIdx(colorIdx);
    }

    private function _gradRange(field as Number) as Array<Float>? {
        if (
            field == FIELD_HR ||
            field == FIELD_HR_MEAN ||
            field == FIELD_HR_MAX
        ) {
            return [40.0, 200.0] as Array<Float>;
        }
        if (field == FIELD_BODY_BAT || field == FIELD_STRESS) {
            return [0.0, 100.0] as Array<Float>;
        }
        if (field == FIELD_SPO2) {
            return [85.0, 100.0] as Array<Float>;
        }
        if (field == FIELD_TEMP_WRIST || field == FIELD_WX_FORECAST) {
            return _metric
                ? [-20.0, 40.0] as Array<Float>
                : [0.0, 104.0] as Array<Float>;
        }
        return null;
    }

    private function _getGradRange(
        field as Number,
        colorIdx as Number,
        dataMinV as Float,
        dataRange as Float
    ) as Array<Float> {
        if (colorIdx >= COLOR_GRAD) {
            var gr = _gradRange(field);
            if (gr != null) {
                var gMin = gr[0] as Float;
                var gRange = (gr[1] as Float) - gMin;
                if (gRange < 1.0) {
                    gRange = 1.0;
                }
                return [gMin, gRange] as Array<Float>;
            }
        }
        return [dataMinV, dataRange] as Array<Float>;
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
        var parts = _getFieldParts(field);
        var gw = _charW * 10;
        var gx = cx + _pad + _charW * 2;
        var gh = _fh - 2;
        _drawRow(
            dc,
            cx,
            y,
            [parts[0], ""] as Array<String>,
            labelColor,
            valueColor
        );
        if (data == null) {
            _drawGraphAxes(dc, gx, gw, y);
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw / 2,
                y + gh / 2 - _tinyFh / 2 - 1,
                _fontTiny,
                "no data",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            return;
        }

        var mm = _minMax(data);
        var minV = mm[0] as Float;
        var maxV = mm[1] as Float;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }

        var data2 = _getFieldHistory(fieldSecondary, periodMin);
        var minV2 = 0.0 as Float;
        var maxV2 = 0.0 as Float;
        var range2 = 1.0 as Float;
        if (data2 != null) {
            var mm2 = _minMax(data2);
            minV2 = mm2[0] as Float;
            maxV2 = mm2[1] as Float;
            range2 = maxV2 - minV2;
            if (range2 < 1.0) {
                range2 = 1.0;
            }
        }

        var gr1 = _getGradRange(field, lineColor, minV, range);
        var gradMinV1 = gr1[0] as Float;
        var gradRange1 = gr1[1] as Float;
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

        var gr2 = _getGradRange(fieldSecondary, lineColor2, minV2, range2);
        var gradMinV2 = gr2[0] as Float;
        var gradRange2 = gr2[1] as Float;
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
        var primaryIsBar = graphType == GRAPH_BAR;
        var secondaryIsBar = secType == SEC_BAR;
        if (primaryIsBar && secondaryIsBar && data2 != null) {
            _drawDualBars(
                dc,
                data,
                data2,
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
                gradRange1
            );
            if (data2 != null) {
                _drawOneGraph(
                    dc,
                    secType - 1,
                    lineColor2,
                    data2,
                    gx,
                    gw,
                    y,
                    gh,
                    minV2,
                    range2,
                    gradMinV2,
                    gradRange2
                );
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
            var cur1 = parts[1];
            dc.setColor(_colorFromIdx(lineColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                vx,
                startY,
                _fontSmall,
                cur1,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            var cur2 = _getFieldParts(fieldSecondary)[1];
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
            _tfLabel(periodMin) + " ",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
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

    private function _readIter(
        iter as SensorHistory.SensorHistoryIterator
    ) as Array<Float>? {
        var raw = [] as Array<Float>;
        var s = iter.next();
        while (s != null) {
            if (s.data != null) {
                var v = s.data;
                raw.add(
                    v instanceof Float ? v as Float : (v as Number).toFloat()
                );
            }
            s = iter.next();
        }
        if (raw.size() < 2) {
            return null;
        }
        var n = raw.size();
        if (n <= 300) {
            return raw;
        }
        var result = [] as Array<Float>;
        var step = n.toFloat() / 300.0;
        for (var i = 0; i < 300; i++) {
            result.add(raw[(i.toFloat() * step).toNumber()]);
        }
        return result;
    }

    private function _getFieldHistory(
        field as Number,
        periodMin as Number
    ) as Array<Float>? {
        var cacheKey = field * 10000 + periodMin;
        var cached = _graphCache.get(cacheKey);
        if (cached != null) {
            return cached as Array<Float>;
        }

        var opts = { :period => periodMin };
        if (
            field == FIELD_HR ||
            field == FIELD_HR_MEAN ||
            field == FIELD_HR_MAX
        ) {
            return _cacheResult(
                cacheKey,
                _readIter(SensorHistory.getHeartRateHistory(opts))
            );
        }
        if (field == FIELD_BODY_BAT) {
            return _cacheResult(
                cacheKey,
                _readIter(SensorHistory.getBodyBatteryHistory(opts))
            );
        }
        if (field == FIELD_STRESS) {
            return _cacheResult(
                cacheKey,
                _readIter(SensorHistory.getStressHistory(opts))
            );
        }
        if (field == FIELD_SPO2) {
            return _cacheResult(
                cacheKey,
                _readIter(SensorHistory.getOxygenSaturationHistory(opts))
            );
        }
        if (field == FIELD_TEMP_WRIST) {
            return _cacheResult(
                cacheKey,
                _readIter(SensorHistory.getTemperatureHistory(opts))
            );
        }
        if (field == FIELD_ELEVATION) {
            return _cacheResult(
                cacheKey,
                _readIter(SensorHistory.getElevationHistory(opts))
            );
        }
        if (field == FIELD_PRESSURE) {
            return _cacheResult(
                cacheKey,
                _readIter(SensorHistory.getPressureHistory(opts))
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

    private function _tfLabel(periodMin as Number) as String {
        return periodMin < 60
            ? "-" + periodMin.toString() + "m"
            : "-" + (periodMin / 60).toString() + "h";
    }

    private function _cacheResult(
        cacheKey as Number,
        r as Array<Float>?
    ) as Array<Float>? {
        if (r != null) {
            _graphCache.put(cacheKey, r);
        }
        return r;
    }

    private function _minMax(data as Array<Float>) as Array<Float> {
        var minV = data[0] as Float;
        var maxV = data[0] as Float;
        for (var i = 1; i < data.size(); i++) {
            var v = data[i] as Float;
            if (v < minV) {
                minV = v;
            }
            if (v > maxV) {
                maxV = v;
            }
        }
        return [minV, maxV] as Array<Float>;
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
        minFrac as Float
    ) as Void {
        var isGrad = colorIdx >= COLOR_GRAD;
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
    }

    private function _drawGraphAxes(
        dc as Dc,
        gx as Number,
        gw as Number,
        y as Number
    ) as Void {
        dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
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
        range as Float
    ) as Void {
        var n1 = data.size() - 1;
        var ghf = gh.toFloat();
        if (n1 < gw) {
            for (var i = 0; i < n1; i++) {
                var x1 = gx + ((n1 - i) * gw) / n1;
                var y1 =
                    y +
                    gh -
                    ((((data[i] as Float) - minV) * ghf) / range).toNumber();
                var x2 = gx + ((n1 - i - 1) * gw) / n1;
                var y2 =
                    y +
                    gh -
                    (
                        (((data[i + 1] as Float) - minV) * ghf) /
                        range
                    ).toNumber();
                dc.drawLine(x1, y1, x2, y2);
                dc.fillRectangle(x1, y1, 1, 1);
                dc.fillRectangle(x2, y2, 1, 1);
            }
            return;
        }
        // Dense: column-fill — one vertical stroke per X pixel covering the full
        // value range of all samples that map to that column, with adjacent
        // columns bridged so the line stays connected even across steep jumps.
        var curCol = -1;
        var colMinPy = 0;
        var colMaxPy = 0;
        var prevMidPy = -1;
        for (var i = 0; i <= n1; i++) {
            var col = (i * gw) / n1;
            var py =
                gh -
                ((((data[n1 - i] as Float) - minV) * ghf) / range).toNumber();
            if (py < 0) {
                py = 0;
            }
            if (py > gh) {
                py = gh;
            }
            if (col != curCol) {
                if (curCol >= 0) {
                    var dMin = colMinPy;
                    var dMax = colMaxPy;
                    if (prevMidPy >= 0) {
                        if (prevMidPy < dMin - 1) {
                            dMin = prevMidPy + 1;
                        } else if (prevMidPy > dMax + 1) {
                            dMax = prevMidPy - 1;
                        }
                    }
                    dc.fillRectangle(gx + curCol, y + dMin, 1, dMax - dMin + 1);
                    prevMidPy = (colMinPy + colMaxPy) / 2;
                }
                curCol = col;
                colMinPy = py;
                colMaxPy = py;
            } else {
                if (py < colMinPy) {
                    colMinPy = py;
                }
                if (py > colMaxPy) {
                    colMaxPy = py;
                }
            }
        }
        if (curCol >= 0) {
            var dMin = colMinPy;
            var dMax = colMaxPy;
            if (prevMidPy >= 0) {
                if (prevMidPy < dMin - 1) {
                    dMin = prevMidPy + 1;
                } else if (prevMidPy > dMax + 1) {
                    dMax = prevMidPy - 1;
                }
            }
            dc.fillRectangle(gx + curCol, y + dMin, 1, dMax - dMin + 1);
        }
    }

    private function _drawDashedH(
        dc as Dc,
        x1 as Number,
        x2 as Number,
        y as Number
    ) as Void {
        var x = x1;
        var on = true;
        while (x < x2) {
            var end = x + 2;
            if (end > x2) {
                end = x2;
            }
            if (on) {
                dc.drawLine(x, y, end - 1, y);
            }
            x = end;
            on = !on;
        }
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
        var sum = 0.0;
        for (var i = 0; i < data.size(); i++) {
            sum += data[i] as Float;
        }
        var mean = sum / data.size().toFloat();
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
            colorIdx >= COLOR_GRAD ? _gradColor(colorIdx, meanFrac) : 0x666666;
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
        gradRange as Float
    ) as Void {
        var n1 = data.size() - 1;
        var ghf = gh.toFloat();
        if (n1 < gw) {
            for (var i = 0; i < n1; i++) {
                var mid = ((data[i] as Float) + (data[i + 1] as Float)) / 2.0;
                var frac = (mid - gradMinV) / gradRange;
                if (frac < 0.0) {
                    frac = 0.0;
                }
                if (frac > 1.0) {
                    frac = 1.0;
                }
                var x1 = gx + ((n1 - i) * gw) / n1;
                var y1 =
                    y +
                    gh -
                    ((((data[i] as Float) - minV) * ghf) / range).toNumber();
                var x2 = gx + ((n1 - i - 1) * gw) / n1;
                var y2 =
                    y +
                    gh -
                    (
                        (((data[i + 1] as Float) - minV) * ghf) /
                        range
                    ).toNumber();
                dc.setColor(
                    _gradColor(colorIdx, frac),
                    Graphics.COLOR_TRANSPARENT
                );
                dc.drawLine(x1, y1, x2, y2);
                dc.fillRectangle(x1, y1, 1, 1);
                dc.fillRectangle(x2, y2, 1, 1);
            }
            return;
        }
        // Dense: per-column average value drives color; full range drawn as vertical stroke.
        var curCol = -1;
        var colMinPy = 0;
        var colMaxPy = 0;
        var colSumV = 0.0 as Float;
        var colCnt = 0;
        var prevMidPy = -1;
        for (var i = 0; i <= n1; i++) {
            var col = (i * gw) / n1;
            var v = data[n1 - i] as Float;
            var py = gh - (((v - minV) * ghf) / range).toNumber();
            if (py < 0) {
                py = 0;
            }
            if (py > gh) {
                py = gh;
            }
            if (col != curCol) {
                if (curCol >= 0) {
                    var avgV = colSumV / colCnt.toFloat();
                    var frac = (avgV - gradMinV) / gradRange;
                    if (frac < 0.0) {
                        frac = 0.0;
                    }
                    if (frac > 1.0) {
                        frac = 1.0;
                    }
                    var dMin = colMinPy;
                    var dMax = colMaxPy;
                    if (prevMidPy >= 0) {
                        if (prevMidPy < dMin - 1) {
                            dMin = prevMidPy + 1;
                        } else if (prevMidPy > dMax + 1) {
                            dMax = prevMidPy - 1;
                        }
                    }
                    dc.setColor(
                        _gradColor(colorIdx, frac),
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillRectangle(gx + curCol, y + dMin, 1, dMax - dMin + 1);
                    prevMidPy = (colMinPy + colMaxPy) / 2;
                }
                curCol = col;
                colMinPy = py;
                colMaxPy = py;
                colSumV = v;
                colCnt = 1;
            } else {
                if (py < colMinPy) {
                    colMinPy = py;
                }
                if (py > colMaxPy) {
                    colMaxPy = py;
                }
                colSumV += v;
                colCnt++;
            }
        }
        if (curCol >= 0) {
            var avgV = colSumV / colCnt.toFloat();
            var frac = (avgV - gradMinV) / gradRange;
            if (frac < 0.0) {
                frac = 0.0;
            }
            if (frac > 1.0) {
                frac = 1.0;
            }
            var dMin = colMinPy;
            var dMax = colMaxPy;
            if (prevMidPy >= 0) {
                if (prevMidPy < dMin - 1) {
                    dMin = prevMidPy + 1;
                } else if (prevMidPy > dMax + 1) {
                    dMax = prevMidPy - 1;
                }
            }
            dc.setColor(_gradColor(colorIdx, frac), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(gx + curCol, y + dMin, 1, dMax - dMin + 1);
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
            var slot = n - 1 - i;
            var bx = gx + (slot * gw) / n;
            var slotEnd = gx + ((slot + 1) * gw) / n;
            var bw = slotEnd - bx - (slot < n - 1 ? 1 : 0);
            if (bw < 1) {
                bw = 1;
            }
            var barH = ((((data[i] as Float) - minV) * ghf) / range).toNumber();
            if (barH < 1) {
                barH = 1;
            }
            dc.fillRectangle(bx, y + gh - barH, bw, barH);
        }
    }

    private function _valueColor(fraction as Float) as Number {
        var r = 0;
        var g = 0;
        var b = 0;
        if (fraction <= 0.5) {
            var t = fraction * 2.0;
            r = (85.0 + t * 170.0).toNumber();
            g = (255.0 - t * 102.0).toNumber();
            b = (119.0 - t * 51.0).toNumber();
        } else {
            var t = (fraction - 0.5) * 2.0;
            r = 255;
            g = (153.0 - t * 68.0).toNumber();
            b = (68.0 + t * 17.0).toNumber();
        }
        return ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff);
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
            var slot = n - 1 - i;
            var bx = gx + (slot * gw) / n;
            var slotEnd = gx + ((slot + 1) * gw) / n;
            var bw = slotEnd - bx - (slot < n - 1 ? 1 : 0);
            if (bw < 1) {
                bw = 1;
            }
            var v = data[i] as Float;
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
        var fallback = ["Forecast", _wxTemp + _wxUnit] as Array<String>;
        var all = _wxForecastData;
        if (all == null) {
            _drawRow(dc, cx, y, fallback, labelColor, valueColor);
            return;
        }
        var cnt = all.size();
        var n = hours < cnt ? hours : cnt;
        if (n < 2) {
            _drawRow(dc, cx, y, fallback, labelColor, valueColor);
            return;
        }

        var gw = _charW * 10;
        var gx = cx + _pad + _charW * 2;
        var gh = _fh - 2;

        // Reverse slice so data[0]=furthest (rightmost), data[n-1]=nearest (leftmost)
        var data = new Array<Float>[n];
        for (var i = 0; i < n; i++) {
            data[i] = (all as Array<Float>)[n - 1 - i];
        }

        var mm = _minMax(data);
        var minV = mm[0] as Float;
        var maxV = mm[1] as Float;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }
        var gr = _getGradRange(FIELD_WX_FORECAST, lineColor, minV, range);
        var gradMinV = gr[0] as Float;
        var gradRange = gr[1] as Float;
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

        _drawRow(
            dc,
            cx,
            y,
            ["Forecast", ""] as Array<String>,
            labelColor,
            valueColor
        );
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
            gradRange
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
            minFrac
        );
        if (viewMode == VIEW_GRAPH_VALUE) {
            var metric = _metric;
            var minStr = metric
                ? minV.format("%.0f")
                : _toF(minV).format("%.0f");
            var maxStr = metric
                ? maxV.format("%.0f")
                : _toF(maxV).format("%.0f");
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw + _charW,
                y + (_fh - _smallFh) / 2 - 1,
                _fontSmall,
                minStr + "/" + maxStr + _wxUnit,
                Graphics.TEXT_JUSTIFY_LEFT
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
        gradRange as Float
    ) as Void {
        var isGrad = colorIdx >= COLOR_GRAD;
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
                    gradRange
                );
            } else {
                dc.setColor(
                    _colorFromIdx(colorIdx),
                    Graphics.COLOR_TRANSPARENT
                );
                _drawGraphLine(dc, data, gx, gw, y, gh, minV, range);
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
        var parts = _getFieldParts(field);
        var gw = _charW * 10;
        var gx = cx + _pad + _charW * 2;
        var gh = _fh - 2;
        if (data == null) {
            _drawRow(
                dc,
                cx,
                y,
                [parts[0], ""] as Array<String>,
                labelColor,
                valueColor
            );
            _drawGraphAxes(dc, gx, gw, y);
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw / 2,
                y + gh / 2 - _tinyFh / 2 - 1,
                _fontTiny,
                "no data",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            return;
        }

        var mm = _minMax(data);
        var minV = mm[0] as Float;
        var maxV = mm[1] as Float;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }
        var gr = _getGradRange(field, lineColor, minV, range);
        var gradMinV = gr[0] as Float;
        var gradRange = gr[1] as Float;
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

        _drawRow(
            dc,
            cx,
            y,
            [parts[0], ""] as Array<String>,
            labelColor,
            valueColor
        );
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
            gradRange
        );
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
            _tfLabel(periodMin),
            lineColor,
            maxFrac,
            minFrac
        );

        if (viewMode == VIEW_GRAPH_VALUE) {
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw + _charW,
                y + (_fh - _smallFh) / 2 - 1,
                _fontSmall,
                parts[1],
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }

    // Fields handled by special draw functions have early returns in _drawLineRow
    // and never reach here: FLOORS, WX_TEMP, WX_FEELS, WX_TEMP_COND, WX_TEMP_MINMAX, WX_TEMP_WIND
    private function _getFieldParts(field as Number) as Array<String> {
        if (field == FIELD_HR) {
            var a = _acInfo as Activity.Info;
            if (a.currentHeartRate != null) {
                return [
                    "Heart",
                    (a.currentHeartRate as Number).toString() + " bpm",
                ];
            }
            return ["Heart", "-"];
        }
        if (field == FIELD_CALORIES) {
            var info = _amInfo as ActivityMonitor.Info;
            return [
                "Calories",
                (info.calories != null ? info.calories : 0).toString() +
                    " kcal",
            ];
        }
        if (field == FIELD_DISTANCE) {
            var info = _amInfo as ActivityMonitor.Info;
            if (info.distance == null) {
                return ["Day Dist", "-"];
            }
            return _metric
                ? ["Day Dist", (info.distance / 100000.0).format("%.2f") + "km"]
                : [
                      "Day Dist",
                      (info.distance / 160934.0).format("%.2f") + "mi",
                  ];
        }
        if (field == FIELD_ALTITUDE) {
            var a = _acInfo as Activity.Info;
            if (a.altitude == null) {
                return ["Altitude", "-"];
            }
            return _metric
                ? ["Altitude", a.altitude.format("%.0f") + "m"]
                : ["Altitude", (a.altitude * 3.28084).format("%.0f") + "ft"];
        }
        if (field == FIELD_SPO2) {
            var a = _acInfo as Activity.Info;
            if (a.currentOxygenSaturation != null) {
                return ["SpO2", a.currentOxygenSaturation.format("%.0f") + "%"];
            }
            return ["SpO2", "-"];
        }
        if (field == FIELD_ACTIVE_MIN) {
            var mins = (_amInfo as ActivityMonitor.Info).activeMinutesWeek;
            if (mins != null && mins.total != null) {
                return ["Int Mins Wk", (mins.total as Number).toString()];
            }
            return ["Int Mins Wk", "0"];
        }
        if (field == FIELD_WX_PRECIP) {
            return ["Precip", _wxPrecip];
        }
        if (field == FIELD_WX_WIND) {
            return ["Wind", _wxWind];
        }
        if (field == FIELD_WX_UV) {
            return ["UV Index", _wxUv];
        }
        if (field == FIELD_WX_COND) {
            return ["Weather", _wxCond];
        }
        if (field == FIELD_WX_COND_PRECIP) {
            return ["Weather", _wxCond + " " + _wxPrecip];
        }
        if (field == FIELD_STRESS) {
            var info = _amInfo as ActivityMonitor.Info;
            if (info.stressScore != null) {
                return ["Stress", (info.stressScore as Number).toString()];
            }
            return ["Stress", "-"];
        }
        if (field == FIELD_BODY_BAT) {
            var sample = SensorHistory.getBodyBatteryHistory({}).next();
            if (sample != null && sample.data != null) {
                var d = sample.data;
                var s =
                    d instanceof Float
                        ? (d as Float).format("%.0f")
                        : (d as Number).toString();
                return ["Body Bat", s + "%"];
            }
            return ["Body Bat", "-"];
        }
        if (field == FIELD_RESP) {
            var info = _amInfo as ActivityMonitor.Info;
            if (info.respirationRate != null) {
                return [
                    "Resp Rate",
                    (info.respirationRate as Number).toString() + "/m",
                ];
            }
            return ["Resp Rate", "-"];
        }
        if (field == FIELD_HR_MEAN) {
            var a = _acInfo as Activity.Info;
            if (a.averageHeartRate != null) {
                return [
                    "Avg HR",
                    (a.averageHeartRate as Number).toString() + " bpm",
                ];
            }
            return ["Avg HR", "-"];
        }
        if (field == FIELD_CAL_ACT) {
            var a = _acInfo as Activity.Info;
            if (a.calories != null) {
                return [
                    "Act Cals",
                    (a.calories as Number).toString() + " kcal",
                ];
            }
            return ["Act Cals", "0 kcal"];
        }
        if (field == FIELD_RECOVERY) {
            var info = _amInfo as ActivityMonitor.Info;
            if (info.timeToRecovery != null) {
                return [
                    "Recovery",
                    (info.timeToRecovery as Number).toString() + "h",
                ];
            }
            return ["Recovery", "-"];
        }
        if (field == FIELD_MOVE_BAR) {
            var info = _amInfo as ActivityMonitor.Info;
            if (info.moveBarLevel != null) {
                return [
                    "Move Bar",
                    (info.moveBarLevel as Number).toString() + "/5",
                ];
            }
            return ["Move Bar", "-"];
        }
        if (field == FIELD_TEMP_WRIST) {
            var sample = SensorHistory.getTemperatureHistory({}).next();
            if (sample != null && sample.data != null) {
                var tempC = sample.data as Float;
                return _metric
                    ? ["Wrist Temp", tempC.format("%.1f") + "C"]
                    : ["Wrist Temp", _toF(tempC).format("%.1f") + "F"];
            }
            return ["Wrist Temp", "-"];
        }
        if (field == FIELD_ACTIVE_MIN_DAY) {
            var mins = (_amInfo as ActivityMonitor.Info).activeMinutesDay;
            if (mins != null && mins.total != null) {
                return ["Act Mins", (mins.total as Number).toString()];
            }
            return ["Act Mins", "0"];
        }
        if (field == FIELD_HR_MAX) {
            var a = _acInfo as Activity.Info;
            if (a.maxHeartRate != null) {
                return [
                    "Max HR",
                    (a.maxHeartRate as Number).toString() + " bpm",
                ];
            }
            return ["Max HR", "-"];
        }
        if (field == FIELD_PRESSURE) {
            var sample = SensorHistory.getPressureHistory({}).next();
            if (sample != null && sample.data != null) {
                var pa = sample.data as Float;
                return _metric
                    ? ["Pressure", (pa / 100.0).format("%.1f") + "hPa"]
                    : ["Pressure", (pa / 3386.39).format("%.2f") + "inHg"];
            }
            return ["Pressure", "-"];
        }
        if (field == FIELD_ELEVATION) {
            var sample = SensorHistory.getElevationHistory({}).next();
            if (sample != null && sample.data != null) {
                var elev = sample.data as Float;
                return _metric
                    ? ["Elevation", elev.format("%.0f") + "m"]
                    : ["Elevation", (elev * 3.28084).format("%.0f") + "ft"];
            }
            return ["Elevation", "-"];
        }
        if (field == FIELD_WX_FORECAST) {
            return ["Forecast", _wxTemp + _wxUnit];
        }
        if (field == FIELD_SLEEP) {
            return [
                "Sleep Score",
                _compSleepScore != null
                    ? (_compSleepScore as Number).toString()
                    : "-",
            ];
        }
        if (field == FIELD_SUNRISE) {
            return [
                "Sunrise",
                _compSunrise != null
                    ? _secsToTime(_compSunrise as Number)
                    : "-",
            ];
        }
        if (field == FIELD_SUNSET) {
            return [
                "Sunset",
                _compSunset != null ? _secsToTime(_compSunset as Number) : "-",
            ];
        }
        if (field == FIELD_SUNRISE_SUNSET) {
            var rise =
                _compSunrise != null
                    ? _secsToTime(_compSunrise as Number)
                    : "-";
            var set =
                _compSunset != null ? _secsToTime(_compSunset as Number) : "-";
            return ["Sun", rise + " / " + set];
        }
        if (field == FIELD_CALENDAR) {
            return [
                "Calendar",
                _compCalendar != null ? _compCalendar as String : "-",
            ];
        }
        if (field == FIELD_WEEKLY_RUN) {
            if (_compWeeklyRun != null) {
                var d = _compWeeklyRun as Number;
                return _metric
                    ? ["Wk Run", (d / 1000.0).format("%.1f") + "km"]
                    : ["Wk Run", (d / 1609.344).format("%.1f") + "mi"];
            }
            return ["Wk Run", "-"];
        }
        if (field == FIELD_WEEKLY_BIKE) {
            if (_compWeeklyBike != null) {
                var d = _compWeeklyBike as Number;
                return _metric
                    ? ["Wk Bike", (d / 1000.0).format("%.1f") + "km"]
                    : ["Wk Bike", (d / 1609.344).format("%.1f") + "mi"];
            }
            return ["Wk Bike", "-"];
        }
        if (field == FIELD_VO2_MAX) {
            var profile = UserProfile.getProfile();
            var vo2 = profile.vo2maxRunning;
            if (vo2 == null) {
                vo2 = profile.vo2maxCycling;
            }
            return ["VO2 Max", vo2 != null ? (vo2 as Number).toString() : "-"];
        }
        if (field == FIELD_SPEED) {
            var a = _acInfo as Activity.Info;
            if (a.currentSpeed != null) {
                var spd = a.currentSpeed as Float;
                return _metric
                    ? ["Speed", (spd * 3.6).format("%.1f") + " km/h"]
                    : ["Speed", (spd * 2.23694).format("%.1f") + " mph"];
            }
            return ["Speed", "-"];
        }
        if (field == FIELD_GPS_LAT) {
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                var lat = coords[0] as Double;
                var suffix = lat >= 0.0 ? "N" : "S";
                return ["Lat", lat.abs().format("%.5f") + suffix];
            }
            return ["Lat", "-"];
        }
        if (field == FIELD_GPS_LON) {
            var pos = _posInfo;
            if (pos != null && pos.position != null) {
                var coords = (pos.position as Position.Location).toDegrees();
                var lon = coords[1] as Double;
                var suffix = lon >= 0.0 ? "E" : "W";
                return ["Lon", lon.abs().format("%.5f") + suffix];
            }
            return ["Lon", "-"];
        }
        if (field == FIELD_GPS_ACCURACY) {
            var pos = _posInfo;
            if (pos != null) {
                var acc = pos.accuracy;
                var label = "-";
                if (acc == Position.QUALITY_GOOD) {
                    label = "Good";
                } else if (acc == Position.QUALITY_USABLE) {
                    label = "Usable";
                } else if (acc == Position.QUALITY_POOR) {
                    label = "Poor";
                } else if (acc == Position.QUALITY_LAST_KNOWN) {
                    label = "Last";
                }
                return ["GPS", label];
            }
            return ["GPS", "-"];
        }
        if (field == FIELD_HEADING) {
            var pos = _posInfo;
            if (pos != null && pos.heading != null) {
                var deg = ((pos.heading as Float) * 57.29577951).toNumber();
                deg = ((deg % 360) + 360) % 360;
                return ["Hdg", deg.toString() + "°"];
            }
            return ["Hdg", "-"];
        }
        if (field == FIELD_FLOORS) {
            var info = _amInfo as ActivityMonitor.Info;
            var up = (
                info.floorsClimbed != null ? info.floorsClimbed : 0
            ).toString();
            var dn = (
                info.floorsDescended != null ? info.floorsDescended : 0
            ).toString();
            return ["Floors", up + "/" + dn];
        }
        if (field == FIELD_WX_TEMP) {
            return ["Temp", _wxTemp + _wxUnit];
        }
        if (field == FIELD_WX_FEELS) {
            return ["Feels", _wxFeels + _wxUnit];
        }
        if (field == FIELD_WX_TEMP_COND) {
            return ["Temp", _wxTemp + _wxUnit + " " + _wxCond];
        }
        if (field == FIELD_WX_TEMP_WIND) {
            return ["Temp", _wxTemp + _wxUnit + " " + _wxWind];
        }
        if (field == FIELD_WX_TEMP_MINMAX) {
            return ["Temp", _wxLow + "/" + _wxHigh + _wxUnit];
        }
        if (field == FIELD_STEPS) {
            var info = _amInfo as ActivityMonitor.Info;
            var steps = info.steps != null ? info.steps as Number : 0;
            var goal = info.stepGoal != null ? info.stepGoal as Number : 10000;
            var goalStr = goal.toString();
            return [
                "Steps",
                steps.format("%0" + goalStr.length() + "d") + "/" + goalStr,
            ];
        }
        if (field == FIELD_ELAPSED) {
            var a = _acInfo as Activity.Info;
            if (a.elapsedTime != null) {
                var ms = a.elapsedTime as Number;
                var s = ms / 1000;
                var m = s / 60;
                var h = m / 60;
                return [
                    "Elapsed",
                    h.format("%d") +
                        ":" +
                        (m % 60).format("%02d") +
                        ":" +
                        (s % 60).format("%02d"),
                ];
            }
            return ["Elapsed", "-"];
        }
        return ["", ""];
    }

    private function _timeParts() as Array<String> {
        var t = System.getClockTime();
        var min = t.min.format("%02d");
        var sec = _getBoolProp("showSeconds") ? ":" + t.sec.format("%02d") : "";
        if (!System.getDeviceSettings().is24Hour) {
            var h = t.hour % 12;
            if (h == 0) {
                h = 12;
            }
            return [
                "Time",
                h.toString() + ":" + min + sec + (t.hour >= 12 ? "pm" : "am"),
            ];
        }
        return ["Time", t.hour.format("%02d") + ":" + min + sec];
    }

    private function _dateParts() as Array<String> {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var fmt = _getProp("dateFormat", 0);
        var value = "" as String;
        if (fmt == 1) {
            value =
                info.year.format("%04d") +
                "-" +
                info.month.format("%02d") +
                "-" +
                info.day.format("%02d");
        } else if (fmt == 2) {
            value =
                info.day.format("%02d") +
                "-" +
                info.month.format("%02d") +
                "-" +
                info.year.format("%04d");
        } else if (fmt == 3) {
            value =
                info.month.format("%02d") +
                "-" +
                info.day.format("%02d") +
                "-" +
                info.year.format("%04d");
        } else {
            // Formats 0, 4, 5: year not included, optionally appended
            var yr = _getBoolProp("showYear") ? " " + info.year.toString() : "";
            if (fmt == 4) {
                value =
                    DAY_NAMES[info.day_of_week - 1] +
                    " " +
                    info.day.format("%02d") +
                    yr;
            } else if (fmt == 5) {
                value =
                    info.day.format("%02d") +
                    " " +
                    MONTH_NAMES[info.month - 1] +
                    yr;
            } else {
                value =
                    DAY_NAMES[info.day_of_week - 1] +
                    ", " +
                    info.day +
                    " " +
                    MONTH_NAMES[info.month - 1] +
                    yr;
            }
        }
        return ["Date", value];
    }

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
        _wxUnit = metric ? "C" : "F";
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
            _wxUv = (c.uvIndex as Float).format("%.0f");
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
                arr[i] = h.temperature != null ? h.temperature as Float : 0.0;
            }
            _wxForecastData = arr;
        } else {
            _wxForecastData = null;
        }
    }

    private function _condStr(cond as Number) as String {
        switch (cond) {
            case Weather.CONDITION_CLEAR:
                return "[CLEAR]";
            case Weather.CONDITION_PARTLY_CLOUDY:
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
                return "[RAIN]";
            case Weather.CONDITION_SNOW:
            case Weather.CONDITION_LIGHT_SNOW:
            case Weather.CONDITION_HEAVY_SNOW:
                return "[SNOW]";
            case Weather.CONDITION_WINDY:
                return "[WINDY]";
            case Weather.CONDITION_THUNDERSTORMS:
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
                return "[STORM]";
            case Weather.CONDITION_WINTRY_MIX:
            case Weather.CONDITION_LIGHT_RAIN_SNOW:
            case Weather.CONDITION_HEAVY_RAIN_SNOW:
            case Weather.CONDITION_RAIN_SNOW:
            case Weather.CONDITION_FREEZING_RAIN:
            case Weather.CONDITION_ICE:
                return "[MIX]";
            case Weather.CONDITION_FOG:
            case Weather.CONDITION_MIST:
                return "[FOG]";
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_SMOKE:
            case Weather.CONDITION_DUST:
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

    private function _getPhase(now as Number) as Number {
        return (now / (_getProp("rotateInterval", 5) * 1000)) % 3;
    }

    private function _checkMoment(
        type as Number,
        curMin as Number,
        wakeupEvent as Boolean,
        workoutFinishEvent as Boolean
    ) as Void {
        var pfx =
            type == MOMENT_MORNING
                ? "momentMorning"
                : type == MOMENT_SLEEP
                  ? "momentSleep"
                  : "momentWorkout";
        if (!_getBoolProp(pfx + "Enabled")) {
            return;
        }
        var defTrigger = type == MOMENT_MORNING ? 1 : 0;
        var triggerMode = _getProp(pfx + "TriggerMode", defTrigger);
        if (triggerMode == 0) {
            var defEvent = type == MOMENT_WORKOUT ? 1 : 0;
            var event = _getProp(pfx + "Event", defEvent);
            if (
                (event == 0 && wakeupEvent) ||
                (event == 1 && workoutFinishEvent)
            ) {
                _triggerMoment(type);
            }
        } else {
            var defH =
                type == MOMENT_MORNING ? 7 : type == MOMENT_SLEEP ? 8 : 0;
            var mH = _getProp(pfx + "Hour", defH);
            var mM = _getProp(pfx + "Minute", 0);
            var dur = _getProp(pfx + "Duration", 15);
            var winStart = mH * 60 + mM;
            var epoch =
                type == MOMENT_MORNING
                    ? _morningEpoch
                    : type == MOMENT_SLEEP
                      ? _sleepEpoch
                      : _workoutEpoch;
            if (curMin >= winStart && curMin < winStart + dur) {
                if (epoch != winStart) {
                    if (type == MOMENT_MORNING) {
                        _morningEpoch = winStart;
                    } else if (type == MOMENT_SLEEP) {
                        _sleepEpoch = winStart;
                    } else {
                        _workoutEpoch = winStart;
                    }
                    _triggerMoment(type);
                }
            } else if (epoch == winStart) {
                if (type == MOMENT_MORNING) {
                    _morningEpoch = -1;
                } else if (type == MOMENT_SLEEP) {
                    _sleepEpoch = -1;
                } else {
                    _workoutEpoch = -1;
                }
            }
        }
    }

    private function _triggerMoment(type as Number) as Void {
        var durKey =
            type == MOMENT_MORNING
                ? "momentMorningDuration"
                : type == MOMENT_SLEEP
                  ? "momentSleepDuration"
                  : "momentWorkoutDuration";
        _momentType = type;
        _momentExpiry = System.getTimer() + _getProp(durKey, 15) * 60000;
    }

    private function _drawMomentField(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        labelIdx as Number,
        valIdx as Number,
        slotPfx as String
    ) as Void {
        if (field == FIELD_NONE) {
            return;
        }
        if (field == FIELD_FLOORS) {
            _drawFloorsRow(dc, cx, y, labelIdx, valIdx);
            return;
        }
        if (field == FIELD_WX_TEMP) {
            _drawTempRow(dc, cx, y, "Temp", _wxTemp, "", labelIdx, valIdx);
            return;
        }
        if (field == FIELD_WX_FEELS) {
            _drawTempRow(dc, cx, y, "Feels", _wxFeels, "", labelIdx, valIdx);
            return;
        }
        if (field == FIELD_WX_TEMP_COND) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Temp",
                _wxTemp,
                " " + _wxCond,
                labelIdx,
                valIdx
            );
            return;
        }
        if (field == FIELD_WX_TEMP_WIND) {
            _drawTempRow(
                dc,
                cx,
                y,
                "Temp",
                _wxTemp,
                " " + _wxWind,
                labelIdx,
                valIdx
            );
            return;
        }
        if (field == FIELD_WX_TEMP_MINMAX) {
            _drawTempMinMaxRow(dc, cx, y, labelIdx, valIdx);
            return;
        }
        if (field == FIELD_WX_FORECAST) {
            var viewMode = _getProp(slotPfx + "ViewMode", VIEW_GRAPH);
            var lineColor = _getProp(slotPfx + "GraphColor", 12);
            var graphType = _getProp(slotPfx + "GraphType", GRAPH_BAR);
            var hours = _getProp(slotPfx + "GraphHours", 6);
            _drawForecastRow(
                dc,
                cx,
                y,
                hours,
                viewMode,
                labelIdx,
                valIdx,
                lineColor,
                graphType
            );
            return;
        }
        var gk = _fieldGraphKey(field);
        if (gk != null) {
            var viewMode = _getProp(slotPfx + "ViewMode", VIEW_VALUE);
            if (viewMode == VIEW_GRAPH || viewMode == VIEW_GRAPH_VALUE) {
                var periodMin = _getProp(slotPfx + "TimeFrame", 60);
                var lineColor = _getProp(slotPfx + "GraphColor", 0);
                var graphType = _getProp(slotPfx + "GraphType", GRAPH_LINE);
                _drawGraphRow(
                    dc,
                    cx,
                    y,
                    field,
                    periodMin,
                    viewMode,
                    labelIdx,
                    valIdx,
                    lineColor,
                    graphType
                );
                return;
            }
        }
        _drawRow(dc, cx, y, _getFieldParts(field), labelIdx, valIdx);
    }

    private function _drawMomentScreen(
        dc as Dc,
        cx as Number,
        y as Number,
        step as Number,
        gap as Number
    ) as Void {
        var half = gap / 2;
        var title =
            _momentType == MOMENT_MORNING
                ? "[TODAY]"
                : _momentType == MOMENT_SLEEP
                  ? "[GOOD MORNING]"
                  : "[WORKOUT DETAILS]";
        var tc = 3;
        var lc1 = 6;
        var lc2 = 6;
        var lc3 = 7;
        var vc = 0;
        var sc = 8;
        var f1 = FIELD_NONE;
        var f2 = FIELD_NONE;
        var f3 = FIELD_NONE;
        if (_momentType == MOMENT_MORNING) {
            tc = _getProp("momentMorningTitleColor", 4);
            lc1 = _getProp("momentMorningField1LabelColor", 7);
            lc2 = _getProp("momentMorningField2LabelColor", 6);
            lc3 = _getProp("momentMorningField3LabelColor", 6);
            vc = _getProp("momentMorningValueColor", 0);
            sc = _getProp("momentMorningSepColor", 4);
            f1 = _getProp("momentMorningField1", FIELD_CALENDAR);
            f2 = _getProp("momentMorningField2", FIELD_WX_FORECAST);
            f3 = _getProp("momentMorningField3", FIELD_WX_COND_PRECIP);
        } else if (_momentType == MOMENT_SLEEP) {
            tc = _getProp("momentSleepTitleColor", 2);
            lc1 = _getProp("momentSleepField1LabelColor", 5);
            lc2 = _getProp("momentSleepField2LabelColor", 6);
            lc3 = _getProp("momentSleepField3LabelColor", 4);
            vc = _getProp("momentSleepValueColor", 0);
            sc = _getProp("momentSleepSepColor", 2);
            f1 = _getProp("momentSleepField1", FIELD_HR);
            f2 = _getProp("momentSleepField2", FIELD_WX_TEMP_MINMAX);
            f3 = _getProp("momentSleepField3", FIELD_SLEEP);
        } else {
            tc = _getProp("momentWorkoutTitleColor", 3);
            lc1 = _getProp("momentWorkoutField1LabelColor", 1);
            lc2 = _getProp("momentWorkoutField2LabelColor", 5);
            lc3 = _getProp("momentWorkoutField3LabelColor", 5);
            vc = _getProp("momentWorkoutValueColor", 0);
            sc = _getProp("momentWorkoutSepColor", 3);
            f1 = _getProp("momentWorkoutField1", FIELD_ACTIVE_MIN_DAY);
            f2 = _getProp("momentWorkoutField2", FIELD_VO2_MAX);
            f3 = _getProp("momentWorkoutField3", FIELD_STRESS);
        }

        dc.setColor(_colorFromIdx(sc), Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, y - half, _w - 1, y - half);

        dc.setColor(_colorFromIdx(tc), Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w / 2, y, _font, title, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(_colorFromIdx(sc), Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, y + _fh + half, _w - 1, y + _fh + half);

        _drawRow(
            dc,
            cx,
            y + step,
            _timeParts(),
            _getProp("line1LabelColor", 8),
            _getProp("line1ValueColor", 0)
        );
        _drawRow(
            dc,
            cx,
            y + step * 2,
            _dateParts(),
            _getProp("line2LabelColor", 8),
            _getProp("line2ValueColor", 0)
        );

        var mPfx =
            _momentType == MOMENT_MORNING
                ? "momentMorning"
                : _momentType == MOMENT_SLEEP
                  ? "momentSleep"
                  : "momentWorkout";
        _drawMomentField(dc, cx, y + step * 3, f1, lc1, vc, mPfx + "Field1");
        _drawMomentField(dc, cx, y + step * 4, f2, lc2, vc, mPfx + "Field2");
        _drawMomentField(dc, cx, y + step * 5, f3, lc3, vc, mPfx + "Field3");

        // Two separators at the bottom, spaced as if a text row sits between them
        dc.setColor(_colorFromIdx(sc), Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            0,
            y + step * 5 + _fh + half,
            _w - 1,
            y + step * 5 + _fh + half
        );
        dc.drawLine(
            0,
            y + step * 6 + _fh + half,
            _w - 1,
            y + step * 6 + _fh + half
        );
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
        var phase = _getPhase(now);
        if (phase != _lastPhase) {
            _lastPhase = phase;
            WatchUi.requestUpdate();
            return;
        }
        if (_getBoolProp("showSeconds")) {
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
            var scanIntensity = _getProp("scanlines", 2);
            if (scanIntensity > 0 && scanIntensity < SCANLINE_COLORS.size()) {
                dc.setColor(
                    SCANLINE_COLORS[scanIntensity],
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

    public function onGesture(gesture as Lang.Object) as Boolean {
        if (_momentType != MOMENT_NONE) {
            _momentType = MOMENT_NONE;
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }
}
