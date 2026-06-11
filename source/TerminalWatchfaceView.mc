import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Timer;
import Toybox.Weather;

const FIELD_STEPS = 0;
const FIELD_HR = 1;
const FIELD_CALORIES = 2;
const FIELD_BATTERY = 3;
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

// Index 0 = white (value default), 8 = light grey (label default). Colon matches label color.
const COLORS =
    [
        0xffffff, // 0 white
        0x44dd88, // 1 green
        0x55ddff, // 2 cyan
        0xeedd55, // 3 yellow
        0xffaa55, // 4 orange
        0xff5555, // 5 red
        0x7799ff, // 6 blue
        0xdd77ff, // 7 magenta
        0xcccccc, // 8 light grey
    ] as Array<Number>;

// Default primary field for configurable lines 3-7 (index = lineNum - 3)
const LINE_DEFAULTS =
    [FIELD_STEPS, FIELD_HR, FIELD_CALORIES, FIELD_DISTANCE, FIELD_BATTERY] as
    Array<Number>;

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

const ARROW_W = 10;
const ARROW_PAD = 2;

class TerminalWatchfaceView extends WatchUi.WatchFace {
    private var _w as Number = 0;
    private var _h as Number = 0;
    private var _lastPhase as Number = -1;
    private var _lastFontChoice as Number = -1;
    private var _font as Graphics.FontType = Graphics.FONT_SMALL;
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
    private var _wxLow as String = "-";
    private var _wxHigh as String = "-";
    private var _bmpUp as Graphics.BitmapType? = null;
    private var _bmpDn as Graphics.BitmapType? = null;
    private var _bmpDeg as Graphics.BitmapType? = null;
    private var _bmpBolt as Graphics.BitmapType? = null;
    private var _arrowH as Number = 16;
    private var _boltH as Number = 20;
    private var _degW as Number = 8;
    private var _overlayOffset as Number = 0;
    private var _overlaySpacings as Array<Number> = [300, 300, 300] as Array<Number>;
    private var _overlayTotal as Number = 900;
    private var _overlayTimer as Timer.Timer? = null;
    private var _wxUnit as String = "C";

    public function initialize() {
        WatchFace.initialize();
        var s = System.getDeviceSettings();
        _w = s.screenWidth;
        _h = s.screenHeight;
        reloadFont();
    }

    public function onLayout(dc as Dc) as Void {}

    public function reloadFont() as Void {
        var choice = _getProp("fontChoice", 0);
        var size = _getProp("fontSizeChoice", 1);
        var key = choice * 3 + size;
        if (key == _lastFontChoice) {
            return;
        }
        _lastFontChoice = key;
        try {
            var res;
            if (choice == 1 && size == 0) {
                res = $.Rez.Fonts.SpaceMono_S;
            } else if (choice == 1 && size == 2) {
                res = $.Rez.Fonts.SpaceMono_L;
            } else if (choice == 1) {
                res = $.Rez.Fonts.SpaceMono_M;
            } else if (choice == 2 && size == 0) {
                res = $.Rez.Fonts.FiraCode_S;
            } else if (choice == 2 && size == 2) {
                res = $.Rez.Fonts.FiraCode_L;
            } else if (choice == 2) {
                res = $.Rez.Fonts.FiraCode_M;
            } else if (size == 0) {
                res = $.Rez.Fonts.JetBrainsMono_S;
            } else if (size == 2) {
                res = $.Rez.Fonts.JetBrainsMono_L;
            } else {
                res = $.Rez.Fonts.JetBrainsMono_M;
            }
            _font = WatchUi.loadResource(res) as Graphics.FontDefinition;
        } catch (e instanceof Lang.Exception) {}
        try {
            if (size == 0) {
                _bmpUp =
                    WatchUi.loadResource($.Rez.Drawables.ArrowUpS) as
                    Graphics.BitmapType;
                _bmpDn =
                    WatchUi.loadResource($.Rez.Drawables.ArrowDnS) as
                    Graphics.BitmapType;
                _bmpDeg =
                    WatchUi.loadResource($.Rez.Drawables.DegS) as
                    Graphics.BitmapType;
                _bmpBolt =
                    WatchUi.loadResource($.Rez.Drawables.BoltS) as
                    Graphics.BitmapType;
                _arrowH = 14;
                _boltH = 18;
                _degW = 7;
            } else if (size == 2) {
                _bmpUp =
                    WatchUi.loadResource($.Rez.Drawables.ArrowUpL) as
                    Graphics.BitmapType;
                _bmpDn =
                    WatchUi.loadResource($.Rez.Drawables.ArrowDnL) as
                    Graphics.BitmapType;
                _bmpDeg =
                    WatchUi.loadResource($.Rez.Drawables.DegL) as
                    Graphics.BitmapType;
                _bmpBolt =
                    WatchUi.loadResource($.Rez.Drawables.BoltL) as
                    Graphics.BitmapType;
                _arrowH = 18;
                _boltH = 22;
                _degW = 9;
            } else {
                _bmpUp =
                    WatchUi.loadResource($.Rez.Drawables.ArrowUpM) as
                    Graphics.BitmapType;
                _bmpDn =
                    WatchUi.loadResource($.Rez.Drawables.ArrowDnM) as
                    Graphics.BitmapType;
                _bmpDeg =
                    WatchUi.loadResource($.Rez.Drawables.DegM) as
                    Graphics.BitmapType;
                _bmpBolt =
                    WatchUi.loadResource($.Rez.Drawables.BoltM) as
                    Graphics.BitmapType;
                _arrowH = 16;
                _boltH = 18;
                _degW = 8;
            }
        } catch (e instanceof Lang.Exception) {}
    }

    public function onUpdate(dc as Dc) as Void {
        var now = System.getTimer();
        var phase = (now / (_getProp("rotateInterval", 5) * 1000)) % 3;
        _cursorOn = (now / 1000) % 2 == 0;
        _refreshWeather();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Scanlines drawn before text; text pixels overwrite them via transparent bg
        var scanIntensity = _getProp("scanlines", 2);
        if (scanIntensity > 0 && scanIntensity < SCANLINE_COLORS.size()) {
            _drawScanlines(dc, SCANLINE_COLORS[scanIntensity]);
        }

        var fh = dc.getFontHeight(_font);
        var step = fh + fh / 3;
        var charW = dc.getTextWidthInPixels("_", _font);
        var cx = _w / 2 - charW * 6;
        _pad = dc.getTextWidthInPixels(": ", _font) / 2;
        _arrowW = dc.getTextWidthInPixels(" > ", _font);

        var vis = [false, false, false, false, false] as Array<Boolean>;
        var visible = 4;
        for (var ln = 3; ln <= 7; ln++) {
            vis[ln - 3] = _lineVisible(ln, phase);
            if (vis[ln - 3]) {
                visible++;
            }
        }

        var y = (_h - step * (visible - 1) - fh) / 2;
        var row = 0;

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

        for (var ln = 3; ln <= 7; ln++) {
            if (vis[ln - 3]) {
                _drawLineRow(dc, cx, y + step * row, ln, phase);
                row++;
            }
        }

        var splitX = cx + _pad;
        var footerY = y + step * row;

        _cursorX = splitX;
        _cursorY = footerY;
        _cursorCharW = charW;
        _cursorFH = fh;

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
            dc.fillRectangle(splitX, footerY, charW, fh);
        }
        _drawOverlayScanlines(dc);
    }

    private function _drawOverlayScanlines(dc as Dc) as Void {
        var intensity = _getProp("overlayLines", 2);
        if (intensity <= 0) { return; }
        var colors = [0x000000, 0x080808, 0x0D0D0D, 0x151515] as Array<Number>;
        dc.setColor(colors[intensity], Graphics.COLOR_TRANSPARENT);
        var cumOffset = 0;
        for (var i = 0; i < _overlaySpacings.size(); i++) {
            var y = (_overlayOffset + cumOffset) % _overlayTotal;
            if (y < _h) { dc.drawLine(0, y, _w - 1, y); }
            cumOffset += _overlaySpacings[i];
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
        if (
            phase == 1 &&
            _getProp("line" + lineNum + "Secondary", FIELD_NONE) != FIELD_NONE
        ) {
            return true;
        }
        if (
            phase == 2 &&
            _getProp("line" + lineNum + "Tertiary", FIELD_NONE) != FIELD_NONE
        ) {
            return true;
        }
        return (
            _getProp(
                "line" + lineNum + "Primary",
                LINE_DEFAULTS[lineNum - 3]
            ) != FIELD_NONE
        );
    }

    private function _drawLineRow(
        dc as Dc,
        cx as Number,
        y as Number,
        lineNum as Number,
        phase as Number
    ) as Void {
        var sec = _getProp("line" + lineNum + "Secondary", FIELD_NONE);
        var ter = _getProp("line" + lineNum + "Tertiary", FIELD_NONE);
        var s = "Primary";
        var field = _getProp(
            "line" + lineNum + "Primary",
            LINE_DEFAULTS[lineNum - 3]
        );
        if (phase == 1 && sec != FIELD_NONE) {
            s = "Secondary";
            field = sec;
        } else if (phase == 2 && ter != FIELD_NONE) {
            s = "Tertiary";
            field = ter;
        }

        var labelColor = _getProp("line" + lineNum + s + "LabelColor", 8);
        var valueColor = _getProp("line" + lineNum + s + "ValueColor", 0);
        if (field == FIELD_BATTERY) {
            _drawBatteryRow(dc, cx, y, labelColor, valueColor);
            return;
        }
        if (field == FIELD_FLOORS || field == 8) {
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
                "Feel",
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
        var tag = "";
        var tagColor = 0;
        var parts;
        if (field == FIELD_STEPS) {
            var info = ActivityMonitor.getInfo();
            var steps = info.steps != null ? info.steps as Number : 0;
            var goal = info.stepGoal != null ? info.stepGoal as Number : 10000;
            if (steps >= goal) {
                tag = " [GOAL]";
                tagColor = 1;
            }
            parts =
                ["Step", steps.format("%0" + goal.toString().length() + "d")] as
                Array<String>;
        } else {
            parts = _getFieldParts(field);
        }
        _drawRow(dc, cx, y, parts, labelColor, valueColor);
        if (tag.length() > 0) {
            dc.setColor(_colorFromIdx(tagColor), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                cx + _pad + dc.getTextWidthInPixels(parts[1], _font),
                y,
                _font,
                tag,
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }

    private function _drawBatteryRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        var stats = System.getSystemStats();
        var bat = stats.battery;
        var vColor = valIdx;
        if (bat <= 10.0 && !stats.charging) {
            vColor = 5;
        } else if (bat >= 100.0) {
            vColor = 1;
        }
        var valStr = bat.format("%.0f") + "%";
        _drawRow(
            dc,
            cx,
            y,
            ["Batt", valStr] as Array<String>,
            labelIdx,
            vColor
        );
        var x = cx + _pad + dc.getTextWidthInPixels(valStr + " ", _font);
        if (stats.charging && _bmpBolt != null) {
            var fh = dc.getFontHeight(_font);
            dc.drawBitmap(
                x,
                y + (fh - _boltH) / 2,
                _bmpBolt as Graphics.BitmapType
            );
        } else if (bat <= 10.0) {
            dc.setColor(_colorFromIdx(5), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _font, " [LOW]", Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function _drawFloorsRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        var info = ActivityMonitor.getInfo();
        var up = (
            info.floorsClimbed != null ? info.floorsClimbed as Number : 0
        ).toString();
        var dn = (
            info.floorsDescended != null ? info.floorsDescended as Number : 0
        ).toString();
        _drawRow(dc, cx, y, ["Strs", ""], labelIdx, valIdx);
        var fh = dc.getFontHeight(_font);
        var ay = y + (fh - _arrowH) / 2;
        var x = cx + _pad;
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        if (_bmpUp != null) {
            dc.drawBitmap(x, ay, _bmpUp as Graphics.BitmapType);
        }
        x += ARROW_W + ARROW_PAD;
        dc.drawText(x, y, _font, up + " ", Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(up + " ", _font);
        if (_bmpDn != null) {
            dc.drawBitmap(x, ay, _bmpDn as Graphics.BitmapType);
        }
        x += ARROW_W + ARROW_PAD;
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
        var fh = dc.getFontHeight(_font);
        var x = cx + _pad;
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, numStr, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(numStr, _font);
        if (_bmpDeg != null) {
            dc.drawBitmap(
                x,
                y + (fh - _degW) / 4,
                _bmpDeg as Graphics.BitmapType
            );
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
        var fh = dc.getFontHeight(_font);
        var ay = y + (fh - _arrowH) / 2;
        var x = cx + _pad;
        dc.setColor(_colorFromIdx(valIdx), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _font, _wxTemp, Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxTemp, _font);
        if (_bmpDeg != null) {
            dc.drawBitmap(
                x,
                y + (fh - _degW) / 4,
                _bmpDeg as Graphics.BitmapType
            );
        }
        x += _degW;
        dc.drawText(x, y, _font, _wxUnit + " [", Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxUnit + " [", _font);
        if (_bmpDn != null) {
            dc.drawBitmap(x, ay, _bmpDn as Graphics.BitmapType);
        }
        x += ARROW_W + ARROW_PAD;
        dc.drawText(x, y, _font, _wxLow + "] [", Graphics.TEXT_JUSTIFY_LEFT);
        x += dc.getTextWidthInPixels(_wxLow + "] [", _font);
        if (_bmpUp != null) {
            dc.drawBitmap(x, ay, _bmpUp as Graphics.BitmapType);
        }
        x += ARROW_W + ARROW_PAD;
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

    private function _getFieldParts(field as Number) as Array<String> {
        switch (field) {
            case FIELD_HR:
                return _partsHR();
            case FIELD_CALORIES:
                return _partsCalories();
            case FIELD_DISTANCE:
                return _partsDistance();
            case FIELD_ALTITUDE:
                return _partsAltitude();
            case FIELD_FLOORS:
            case 8:
                return _partsFloors();
            case FIELD_SPO2:
                return _partsSpO2();
            case FIELD_ACTIVE_MIN:
                return _partsActiveMin();
            case FIELD_WX_TEMP:
                return ["Temp", _wxTemp + _wxUnit];
            case FIELD_WX_FEELS:
                return ["Feel", _wxFeels + _wxUnit];
            case FIELD_WX_PRECIP:
                return ["Rain", _wxPrecip];
            case FIELD_WX_WIND:
                return ["Wind", _wxWind];
            case FIELD_WX_UV:
                return ["UV", _wxUv];
            case FIELD_WX_COND:
                return ["Cond", _wxCond];
            case FIELD_WX_TEMP_COND:
                return ["Temp", _wxTemp + _wxUnit + " " + _wxCond];
            case FIELD_WX_TEMP_MINMAX:
                return [
                    "Temp",
                    _wxTemp + _wxUnit + " [" + _wxLow + "-" + _wxHigh + "]",
                ];
            default:
                return ["", ""];
        }
    }

    private function _timeParts() as Array<String> {
        var t = System.getClockTime();
        var min = t.min.format("%02d");
        if (!System.getDeviceSettings().is24Hour) {
            var h = t.hour % 12;
            if (h == 0) {
                h = 12;
            }
            return [
                "Time",
                h.toString() + ":" + min + (t.hour >= 12 ? "pm" : "am"),
            ];
        }
        return ["Time", t.hour.format("%02d") + ":" + min];
    }

    private function _dateParts() as Array<String> {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return [
            "Date",
            DAY_NAMES[info.day_of_week - 1] +
                ", " +
                info.day +
                " " +
                MONTH_NAMES[info.month - 1],
        ];
    }

    private function _partsHR() as Array<String> {
        var a = Activity.getActivityInfo();
        if (a.currentHeartRate != null) {
            return ["Rate", a.currentHeartRate.toString()];
        }
        return ["Rate", "-"];
    }

    private function _partsCalories() as Array<String> {
        var info = ActivityMonitor.getInfo();
        return ["Kcal", (info.calories != null ? info.calories : 0).toString()];
    }

    private function _partsDistance() as Array<String> {
        var info = ActivityMonitor.getInfo();
        if (info.distance == null) {
            return ["Dist", "-"];
        }
        if (System.getDeviceSettings().distanceUnits == System.UNIT_METRIC) {
            return ["Dist", (info.distance / 100000.0).format("%.2f") + "km"];
        }
        return ["Dist", (info.distance / 160934.0).format("%.2f") + "mi"];
    }

    private function _partsAltitude() as Array<String> {
        var a = Activity.getActivityInfo();
        if (a.altitude == null) {
            return ["Alti", "-"];
        }
        if (System.getDeviceSettings().distanceUnits == System.UNIT_METRIC) {
            return ["Alti", a.altitude.format("%.0f") + "m"];
        }
        return ["Alti", (a.altitude * 3.28084).format("%.0f") + "ft"];
    }

    private function _partsFloors() as Array<String> {
        var info = ActivityMonitor.getInfo();
        return [
            "Strs",
            (info.floorsClimbed != null
                ? info.floorsClimbed as Number
                : 0
            ).toString() +
                " " +
                (info.floorsDescended != null
                    ? info.floorsDescended as Number
                    : 0
                ).toString(),
        ];
    }

    private function _partsSpO2() as Array<String> {
        var a = Activity.getActivityInfo();
        if (a.currentOxygenSaturation != null) {
            return ["SpO2", a.currentOxygenSaturation.format("%.0f") + "%"];
        }
        return ["SpO2", "-"];
    }

    private function _partsActiveMin() as Array<String> {
        var mins = ActivityMonitor.getInfo().activeMinutesWeek;
        if (mins != null && mins.total != null) {
            return ["Intv", (mins.total as Number).toString()];
        }
        return ["Intv", "0"];
    }

    private function _refreshWeather() as Void {
        var c = Weather.getCurrentConditions();
        if (c == null) {
            return;
        }
        var metric =
            System.getDeviceSettings().distanceUnits == System.UNIT_METRIC;
        _wxUnit = metric ? "C" : "F";
        if (c.temperature != null) {
            var tf = c.temperature as Float;
            _wxTemp = metric
                ? tf.format("%.1f")
                : ((tf * 9.0) / 5.0 + 32.0).format("%.1f");
        }
        if (c.feelsLikeTemperature != null) {
            var tf = c.feelsLikeTemperature as Float;
            _wxFeels = metric
                ? tf.format("%.1f")
                : ((tf * 9.0) / 5.0 + 32.0).format("%.1f");
        }
        if (c.lowTemperature != null) {
            var tf = c.lowTemperature as Float;
            _wxLow = metric
                ? tf.format("%.0f")
                : ((tf * 9.0) / 5.0 + 32.0).format("%.0f");
        }
        if (c.highTemperature != null) {
            var tf = c.highTemperature as Float;
            _wxHigh = metric
                ? tf.format("%.0f")
                : ((tf * 9.0) / 5.0 + 32.0).format("%.0f");
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
                _wxWind =
                    _wxWind +
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
    }

    private function _condStr(cond as Number) as String {
        switch (cond) {
            case Weather.CONDITION_CLEAR:
                return "[CLEAR]";
            case Weather.CONDITION_PARTLY_CLOUDY:
                return "[PCLOUD]";
            case Weather.CONDITION_MOSTLY_CLOUDY:
            case Weather.CONDITION_CLOUDY:
                return "[CLOUDY]";
            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_HEAVY_RAIN:
            case Weather.CONDITION_SCATTERED_SHOWERS:
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
                return "[MIX]";
            case Weather.CONDITION_FOG:
                return "[FOG]";
            case Weather.CONDITION_HAZY:
                return "[HAZY]";
            case Weather.CONDITION_HAIL:
                return "[HAIL]";
            default:
                return "[?]";
        }
    }

    private function _getProp(key as String, defaultVal as Number) as Number {
        var val = Properties.getValue(key);
        if (val instanceof Number) {
            return val as Number;
        }
        return defaultVal;
    }

    // Called every second on AMOLED. Blinks the cursor via setClip so only that region
    // redraws. On phase change, triggers a full onUpdate to flip the alt-field display.
    public function onPartialUpdate(dc as Dc) as Void {
        var now = System.getTimer();
        var phase = (now / (_getProp("rotateInterval", 5) * 1000)) % 3;
        if (phase != _lastPhase) {
            _lastPhase = phase;
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

    public function onShow() as Void {
        var s0 = 140 + (Math.rand().abs() % 13).toNumber() * 10;
        var s1 = 140 + (Math.rand().abs() % 13).toNumber() * 10;
        var s2 = 140 + (Math.rand().abs() % 13).toNumber() * 10;
        _overlaySpacings = [s0, s1, s2] as Array<Number>;
        _overlayTotal = s0 + s1 + s2;
        _overlayTimer = new Timer.Timer();
        (_overlayTimer as Timer.Timer).start(method(:_onOverlayTick), 33, true);
    }

    public function onHide() as Void {
        if (_overlayTimer != null) { (_overlayTimer as Timer.Timer).stop(); _overlayTimer = null; }
    }

    public function _onOverlayTick() as Void {
        _overlayOffset = (_overlayOffset + 1) % _overlayTotal;
        WatchUi.requestUpdate();
    }

    public function onEnterSleep() as Void {
        _lastPhase = -1;
    }
    public function onExitSleep() as Void {
        WatchUi.requestUpdate();
    }
}
