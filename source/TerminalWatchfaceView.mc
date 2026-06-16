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

const VIEW_VALUE = 0;
const VIEW_GRAPH = 1;
const VIEW_GRAPH_VALUE = 2;

const GRAPH_LINE = 0;
const GRAPH_BAR = 1;
const GRAPH_GRAD_LINE = 2;
const GRAPH_GRAD_BAR = 3;

const SEC_NONE = 0;
const SEC_LINE = 1;
const SEC_BAR = 2;
const SEC_GRAD_LINE = 3;
const SEC_GRAD_BAR = 4;

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
    private var _amInfo as ActivityMonitor.Info? = null;
    private var _acInfo as Activity.Info? = null;
    private var _wxLastMin as Number = -1;
    private var _metric as Boolean = false;
    private var _notifCount as Number = 0;

    public function initialize() {
        WatchFace.initialize();
        var s = System.getDeviceSettings();
        _w = s.screenWidth;
        _h = s.screenHeight;
        _amInfo = ActivityMonitor.getInfo();
        _acInfo = Activity.getActivityInfo();
        reloadFont();
    }

    public function onLayout(dc as Dc) as Void {}

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
        var settings = System.getDeviceSettings();
        _metric = settings.distanceUnits == System.UNIT_METRIC;
        _notifCount =
            settings.notificationCount != null
                ? settings.notificationCount as Number
                : 0;
        var nowMin =
            (Gregorian.info(Time.now(), Time.FORMAT_SHORT) as Gregorian.Info)
                .min as Number;
        if (nowMin != _graphCacheMin) {
            _graphCache = {};
            _graphCacheMin = nowMin;
        }
        _refreshWeather(nowMin);

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
        var step = _fh + 16;
        var gap = 16;
        var cx = _w / 2 - _charW * 4;
        _pad = dc.getTextWidthInPixels(": ", _font) / 2;
        _arrowW = dc.getTextWidthInPixels(" > ", _font);

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
        dc.drawText(splitX, footerY, _font, " > ", Graphics.TEXT_JUSTIFY_RIGHT);
        if (_cursorOn) {
            dc.fillRectangle(splitX, footerY, _charW, _fh);
        }
        _drawFooter(dc, footerY + _fh + 2 * gap);
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
        var textY = y - 2 * gap - dc.getFontHeight(_fontSmall);
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
                var fhSm = dc.getFontHeight(_fontSmall);
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
            return;
        }
        if (field == FIELD_WX_FORECAST) {
            var viewMode = _getProp("wxForecastViewMode", VIEW_GRAPH);
            var lineColor = _getProp("wxForecastGraphColor", 6);
            var graphType = _getProp("wxForecastGraphType", GRAPH_BAR);
            var hours = _getProp("wxForecastTimeFrame", 6);
            if (viewMode == VIEW_GRAPH || viewMode == VIEW_GRAPH_VALUE) {
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
            } else {
                _drawRow(
                    dc,
                    cx,
                    y,
                    _getFieldParts(field),
                    labelColor,
                    valueColor
                );
            }
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
                        secType
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
        secType as Number
    ) as Void {
        var data = _getFieldHistory(field, periodMin);
        var parts = _getFieldParts(field);
        if (data == null) {
            _drawRow(dc, cx, y, parts, labelColor, valueColor);
            return;
        }

        _drawRow(
            dc,
            cx,
            y,
            [parts[0], ""] as Array<String>,
            labelColor,
            valueColor
        );

        var gw = _charW * 10;
        var gx = cx + _pad + _charW * 2;
        var gh = _fh - 2;

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

        var primaryIsBar =
            graphType == GRAPH_BAR || graphType == GRAPH_GRAD_BAR;
        var secondaryIsBar = secType == SEC_BAR || secType == SEC_GRAD_BAR;
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
                _colorFromIdx(lineColor),
                _colorFromIdx(lineColor2)
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
                range
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
                    range2
                );
            }
        }

        _drawGraphAxes(dc, gx, gw, y);

        // Secondary min/max outside right
        if (data2 != null) {
            dc.setColor(_colorFromIdx(lineColor2), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw + 4,
                y - 4,
                _fontTiny,
                _formatGraphLabel(fieldSecondary, maxV2),
                Graphics.TEXT_JUSTIFY_LEFT
            );
            dc.drawText(
                gx + gw + 4,
                y + gh - _tinyFh + 4,
                _fontTiny,
                _formatGraphLabel(fieldSecondary, minV2),
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }

        // Primary min/max outside left
        dc.setColor(_colorFromIdx(lineColor), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx - 4,
            y - 4,
            _fontTiny,
            _formatGraphLabel(field, maxV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.drawText(
            gx - 4,
            y + gh - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(field, minV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // Below: timeframe in white, secondary field name in secondary color
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
        dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
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
        bottomLabel as String
    ) as Void {
        dc.setColor(_colorFromIdx(0), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gx - 4,
            y - 4,
            _fontTiny,
            _formatGraphLabel(field, maxV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        dc.drawText(
            gx - 4,
            y + gh - _tinyFh + 4,
            _fontTiny,
            _formatGraphLabel(field, minV),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
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
        dc.drawLine(gx, y, gx, y + _fh - 1);
        dc.drawLine(gx, y + _fh - 1, gx + gw - 1, y + _fh - 1);
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
        for (var i = 0; i < n1; i++) {
            dc.drawLine(
                gx + ((n1 - i) * gw) / n1,
                y +
                    gh -
                    ((((data[i] as Float) - minV) * ghf) / range).toNumber(),
                gx + ((n1 - i - 1) * gw) / n1,
                y +
                    gh -
                    ((((data[i + 1] as Float) - minV) * ghf) / range).toNumber()
            );
        }
    }

    private function _drawGradLine(
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
        for (var i = 0; i < n1; i++) {
            var mid =
                ((data[i] as Float) + (data[i + 1] as Float)) / 2.0 - minV;
            var frac = mid / range;
            if (frac < 0.0) {
                frac = 0.0;
            }
            if (frac > 1.0) {
                frac = 1.0;
            }
            dc.setColor(_valueColor(frac), Graphics.COLOR_TRANSPARENT);
            dc.drawLine(
                gx + ((n1 - i) * gw) / n1,
                y +
                    gh -
                    ((((data[i] as Float) - minV) * ghf) / range).toNumber(),
                gx + ((n1 - i - 1) * gw) / n1,
                y +
                    gh -
                    ((((data[i + 1] as Float) - minV) * ghf) / range).toNumber()
            );
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
            var barTop = y + gh - barH;
            for (var sy = 0; sy < barH; sy++) {
                var frac = (barH - 1 - sy).toFloat() / ghf;
                if (frac < 0.0) {
                    frac = 0.0;
                }
                if (frac > 1.0) {
                    frac = 1.0;
                }
                dc.setColor(_valueColor(frac), Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(bx, barTop + sy, bw, 1);
            }
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
        color as Number,
        color2 as Number
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
            var barH = ((((data[i] as Float) - minV) * ghf) / range).toNumber();
            if (barH < 1) {
                barH = 1;
            }
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(slotX, y + gh - barH, hw, barH);
            var barH2 = (
                (((data2[i] as Float) - minV2) * ghf) /
                range2
            ).toNumber();
            if (barH2 < 1) {
                barH2 = 1;
            }
            dc.setColor(color2, Graphics.COLOR_TRANSPARENT);
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

        _drawRow(
            dc,
            cx,
            y,
            ["Forecast", ""] as Array<String>,
            labelColor,
            valueColor
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
            range
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
            "+" + hours.toString() + "h"
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
                y,
                _font,
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
        range as Float
    ) as Void {
        if (graphType == GRAPH_GRAD_LINE) {
            _drawGradLine(dc, data, gx, gw, y, gh, minV, range);
        } else if (graphType == GRAPH_GRAD_BAR) {
            _drawGradBars(dc, data, gx, gw, y, gh + 1, minV, range);
        } else if (graphType == GRAPH_BAR) {
            dc.setColor(_colorFromIdx(colorIdx), Graphics.COLOR_TRANSPARENT);
            _drawBars(dc, data, gx, gw, y, gh + 1, minV, range);
        } else {
            dc.setColor(_colorFromIdx(colorIdx), Graphics.COLOR_TRANSPARENT);
            _drawGraphLine(dc, data, gx, gw, y, gh, minV, range);
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
        if (data == null) {
            _drawRow(dc, cx, y, parts, labelColor, valueColor);
            return;
        }

        var gw = _charW * 10;
        var gx = cx + _pad + _charW * 2;
        var gh = _fh - 2;

        var mm = _minMax(data);
        var minV = mm[0] as Float;
        var maxV = mm[1] as Float;
        var range = maxV - minV;
        if (range < 1.0) {
            range = 1.0;
        }

        _drawRow(
            dc,
            cx,
            y,
            [parts[0], ""] as Array<String>,
            labelColor,
            valueColor
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
            range
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
            _tfLabel(periodMin)
        );

        if (viewMode == VIEW_GRAPH_VALUE) {
            dc.setColor(_colorFromIdx(valueColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                gx + gw + _charW,
                y,
                _font,
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
                return ["Distance", "-"];
            }
            return _metric
                ? ["Distance", (info.distance / 100000.0).format("%.2f") + "km"]
                : [
                      "Distance",
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
                return ["Int Mins", (mins.total as Number).toString()];
            }
            return ["Int Mins", "0"];
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
                return ["Body Bat", (sample.data as Number).toString() + "%"];
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
}
