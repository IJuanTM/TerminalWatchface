import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.SensorHistory;

class TerminalWatchfaceView extends WatchUi.WatchFace {
    private var _halo as BitmapSlot;
    private var _backlight as Backlight;
    private var _nowcast as NowcastData;
    private var _comp as ComplicationData;
    private var _units as Units;
    private var _graphs as GraphCache;
    private var _wx as WeatherData;
    private var _rotation as Rotation;
    private var _profile as ProfileData;

    private var _screenW as Number = 0;
    private var _screenH as Number = 0;
    private var _lastFontChoice as Number = -1;
    private var _font as Graphics.FontType = Graphics.FONT_SMALL;
    private var _fontSmall as Graphics.FontType = Graphics.FONT_TINY;
    private var _fontTiny as Graphics.FontType = Graphics.FONT_XTINY;
    private var _fontVariant as Number = 0; // 0 = lineHeight 28 (default), 1 = lineHeight 30 (SpaceMono)
    private var _fh as Number = 20;
    private var _charW as Number = 12;
    private var _tinyFh as Number = 10;
    private var _smallFh as Number = 16;
    private var _splitPad as Number = 0;
    private var _arrowW as Number = 0;
    private var _arrowH as Number = 16;
    private var _bmpArrowW as Number = 14;
    private var _boltH as Number = 16;
    private var _bmpBoltW as Number = 16;
    private var _degW as Number = 8;
    private var _degWSmall as Number = 5;
    private var _leftPad as Number = 4;
    private var _metricsValid as Boolean = false;
    private var _graphW as Number = 0;
    private var _graphX as Number = 0;
    private var _graphBaseX as Number = 0;
    private var _graphH as Number = 0;

    private var _is24Hour as Boolean = true;
    private var _firstDow as Number = 1;
    private var _lowPower as Boolean = false;
    private var _alwaysOn as Boolean = false;
    private var _justWoke as Boolean = true;
    private var _deferThisFrame as Boolean = false;
    private var _deferredWorkPending as Boolean = false;
    private var _nowUnixMin as Number = 0;
    private var _lastUpdateMin as Number = -1;
    private var _settingsMin as Number = -1;
    private var _interactiveMin as Number = -1;
    private var _clockInfo as Gregorian.Info? = null;

    private var _showSeconds as Boolean = false;
    private var _areaOpacity as Number = 64;
    private var _areaShowLine as Boolean = true;
    private var _debugGraphGaps as Boolean = false;
    private var _scanlineIntensity as Number = 2;
    private var _glowIntensity as Number = 2;
    private var _bgBacklight as Number = 0;
    private var _lastColorTheme as Number = -1;
    private var _flickerEnabled as Boolean = true;
    private var _showBatteryDays as Boolean = true;
    private var _dateFormat as Number = 0;
    private var _showYear as Boolean = false;
    private var _watchCmd as String = "watch";

    private var _resolvedPhase as Number = -1;

    private var _resolvedFields as Array<Number> = [7, 7, 7] as Array<Number>;
    private var _resolvedLabelColor as Array<Number> =
        [8, 8, 8] as Array<Number>;
    private var _resolvedValueColor as Array<Number> =
        [0, 0, 0] as Array<Number>;
    private var _line1LabelColor as Number = 8;
    private var _line1ValueColor as Number = 0;
    private var _line2LabelColor as Number = 8;
    private var _line2ValueColor as Number = 0;
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

    private var _needsLiveActivity as Boolean = true;
    private var _needsAm as Boolean = true;
    private var _needsForecast as Boolean = true;
    private var _needsWeatherCurrent as Boolean = true;
    private var _needsNowcast as Boolean = false;

    private var _amInfo as ActivityMonitor.Info? = null;
    private var _acInfo as Activity.Info? = null;
    private var _notifCount as Number = 0;
    private var _notifLabel as String = "";
    private var _phoneConnected as Boolean = true;
    private var _dndOn as Boolean = false;
    private var _notifLastMs as Number = -3000;
    private var _cachedBodyBat as String = "-";
    private var _cachedTempWrist as String = "-";
    private var _cachedPressure as String = "-";
    private var _cachedElevation as String = "-";
    private var _cachedStress as String = "-";
    private var _cachedPressureTrend as Number = 0;
    private var _pointSamplesDeferred as Boolean = false;

    private var _batText as String = "-";
    private var _batDaysText as String = "";
    private var _batW as Number = 0;
    private var _batDaysW as Number = 0;
    private var _spacedBatText as String = "";
    private var _spacedBatW as Number = 0;
    private var _charging as Boolean = false;
    private var _batLow as Boolean = false;

    private var _rowBuf as Array<String> = ["", ""] as Array<String>;
    private var _timeBuf as Array<String> = ["Time", ""] as Array<String>;
    private var _dateBuf as Array<String> = ["Date", ""] as Array<String>;
    private var _lastDateDay as Number = -1;
    private var _cachedTimeMin as Number = -1;
    private var _cachedTimeStr as String = "";

    private var _dataMin as Float = 0.0;
    private var _dataMax as Float = 0.0;
    private var _pendingEffPeriod as Number = 0;
    private var _bmpCreateFailMin as Number = -1;

    // _glowText halo-copy cache, round-robin evicted so repeat-hit labels survive high-cardinality live-value churn.
    private var _glowGlyphCache as Dictionary = {};
    private var _glowGlyphKeys as Array<String?> = new [GLOW_GLYPH_CACHE_CAP];
    private var _glowGlyphIdx as Number = 0;
    // True while rendering a graph bitmap offscreen (halo coords would be bitmap-local, not screen-space).
    private var _haloSuppressed as Boolean = false;
    // Non-null while baking a graph's cached glow bitmap - redirects every _glow*Shape call's target dc here instead of the shared per-frame _halo (bake is a rare cache-miss event, not a per-frame cost).
    private var _haloBakeDc as Dc? = null;

    public function initialize() {
        WatchFace.initialize();
        _halo = new BitmapSlot();
        _backlight = new Backlight();
        _nowcast = new NowcastData();
        _comp = new ComplicationData();
        _units = new Units();
        _graphs = new GraphCache();
        _wx = new WeatherData();
        _rotation = new Rotation();
        _profile = new ProfileData();
        var s = System.getDeviceSettings();
        _screenW = s.screenWidth;
        _screenH = s.screenHeight;
        _amInfo = ActivityMonitor.getInfo();
        _acInfo = Activity.getActivityInfo();
        reloadFont();
        _applyColorTheme(Props.getNum(P_COLOR_THEME, 0));
        _rotation.configure();
        _subscribeComplications();
        reloadNowcast();
    }

    // Pre-renders here so first-frame cost doesn't share onUpdate's budget.
    public function onLayout(dc as Dc) as Void {
        if (Props.getNum(P_BG_BACKLIGHT, 0) > 0) {
            _backlight.render(_screenW, _screenH, _nowUnixMin);
        }
    }

    public function onShow() as Void {}

    public function invalidateSettings() as Void {
        _resolvedPhase = -1;
        _lastUpdateMin = -1;
        _settingsMin = -1;
        _graphs.clear();
        _glowGlyphCache = {};
        _glowGlyphKeys = new [GLOW_GLYPH_CACHE_CAP];
        _glowGlyphIdx = 0;
        _lastDateDay = -1;
        _cachedTimeMin = -1;
        _wx.lastMin = -1;
        _wx.fetchedMin = -1;
        _wx.fcstFetchedMin = -1;
        _interactiveMin = -1;
        _nowcast.invalidate();
        _applyColorTheme(Props.getNum(P_COLOR_THEME, 0));
        _rotation.configure();
        _subscribeComplications();
    }

    // All slots, not just this phase, so a rotation never shows stale values.
    private function _subscribeComplications() as Void {
        var types = [] as Array<Complications.Type>;
        var lines = [PP_L3, PP_L4, PP_L5] as Array<String>;
        for (var i = 0; i < lines.size(); i++) {
            var pk = lines[i];
            if (!Props.getBool(pk + PS_ENABLED, true)) {
                continue;
            }
            for (var p = -1; p < ROTATE_SLOT_NAMES.size(); p++) {
                var ct = FieldTables.compTypes(
                    FieldMeta.slotField(
                        pk,
                        p < 0 ? PS_PRIMARY : ROTATE_SLOT_NAMES[p]
                    )
                );
                if (ct == null) {
                    continue;
                }
                for (var j = 0; j < ct.size(); j++) {
                    if (types.indexOf(ct[j]) < 0) {
                        types.add(ct[j]);
                    }
                }
            }
        }
        _comp.subscribe(types);
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
        _backlight.resetColor();
    }

    (:extendedCode)
    public function reloadFont() as Void {
        var choice = Props.getNum(P_FONT_CHOICE, 0);
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

        var newSizeSet = choice == 1 ? 1 : 0;
        if (newSizeSet != _fontVariant) {
            _fontVariant = newSizeSet;
            _graphs.clearBitmaps();
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
        // Callees later in this same frame use _deferThisFrame to tell they're on the frame that must not block wake-up.
        _deferThisFrame = _justWoke;
        _justWoke = false;
        _deferredWorkPending = false;
        var now = System.getTimer();
        var nowMoment = Time.now();
        var phase = _rotation.phase(nowMoment.value());
        _nowUnixMin = nowMoment.value() / SECS_PER_MIN;
        _clockInfo =
            Gregorian.info(nowMoment, Time.FORMAT_SHORT) as Gregorian.Info;
        var notifDue = now - _notifLastMs >= 3000;
        var minuteRolled = _nowUnixMin != _lastUpdateMin;
        // Interactive-only data is never drawn in AOD, so it refreshes on its own minute and catches up on the first frame after waking.
        var interactiveDue = !_lowPower && _nowUnixMin != _interactiveMin;
        if (interactiveDue && _deferThisFrame && _interactiveMin >= 0) {
            interactiveDue = false;
            _deferredWorkPending = true;
        }
        if (notifDue || minuteRolled) {
            _refreshDeviceSettings(now, notifDue, minuteRolled);
        }
        if (phase != _resolvedPhase && !_lowPower) {
            _onPhaseChange(phase, interactiveDue);
        }
        if (_needsLiveActivity && !_lowPower) {
            _acInfo = Activity.getActivityInfo();
        }
        if (minuteRolled) {
            _onMinuteRolled();
        }
        if (interactiveDue) {
            _refreshInteractive();
        } else if (_pointSamplesDeferred && !_deferThisFrame && !_lowPower) {
            _refreshPointSamples();
        }
        if (!_lowPower) {
            _refreshWeather(_nowUnixMin);
            if (_needsNowcast) {
                _refreshNowcast();
            }
        }
        _drawFrame(dc, now);
    }

    private function _refreshDeviceSettings(
        now as Number,
        notifDue as Boolean,
        minuteRolled as Boolean
    ) as Void {
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
            _units.resolve(ds);
            _is24Hour = ds.is24Hour;
            var fDow = ds.firstDayOfWeek;
            _firstDow = fDow != null ? ((fDow as Number) - 1) % 7 : 1;
        }
    }

    private function _onPhaseChange(
        phase as Number,
        interactiveDue as Boolean
    ) as Void {
        _resolvedPhase = phase;
        var prevFields = _resolvedFields.slice(0, null);
        _resolveAllLines(phase);
        var needs = 0;
        for (var i = 0; i < 3; i++) {
            needs |= FieldTables.needs(_resolvedFields[i]);
            // Must match _resolveLineGraph's write gate, or this reads a stale _lineSecField index.
            if (
                _lineSecType[i] != SEC_NONE &&
                (_lineViewMode[i] == VIEW_GRAPH ||
                    _lineViewMode[i] == VIEW_GRAPH_VALUE)
            ) {
                needs |= FieldTables.needs(
                    GRAPH_SEC_FIELDS[_lineSecField[i]] as Number
                );
            }
        }
        _needsLiveActivity = (needs & NEED_LIVE_ACTIVITY) != 0;
        var needsAm = (needs & NEED_AM) != 0;
        // Freshly needed data below is refreshed now rather than waiting for the next per-minute tick.
        if (needsAm && !_needsAm) {
            _amInfo = ActivityMonitor.getInfo();
        }
        _needsAm = needsAm;
        _needsForecast = (needs & NEED_FORECAST) != 0;
        _needsNowcast = (needs & NEED_NOWCAST) != 0;
        // Left registered when a rotation phase without the field shows, so rotating never resets the 5-minute timer.
        if (_needsNowcast) {
            _nowcast.schedule();
        }
        if (!interactiveDue) {
            for (var i = 0; i < 3; i++) {
                if (prevFields.indexOf(_resolvedFields[i]) < 0) {
                    _refreshPointSamples();
                    break;
                }
            }
        }
        // Forecast fields fall back to current-conditions strings too, so they need this refresh too.
        _needsWeatherCurrent =
            (needs & (NEED_WX_CURRENT | NEED_FORECAST | NEED_NOWCAST)) != 0;
        if (
            (_needsForecast && _wx.fcstFetchedMin != _nowUnixMin) ||
            (_needsWeatherCurrent && _wx.fetchedMin != _nowUnixMin)
        ) {
            _wx.lastMin = -1;
        }
    }

    private function _onMinuteRolled() as Void {
        _lastUpdateMin = _nowUnixMin;
        // Not cleared here: _cacheResult() invalidates only the specific key that refreshed.
        // invalidateSettings already forces a reload on every change, so the timed one is only a safety net.
        if (
            _settingsMin < 0 ||
            _nowUnixMin < _settingsMin ||
            _nowUnixMin - _settingsMin >= SETTINGS_RELOAD_MIN
        ) {
            _loadDisplaySettings();
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

    private function _loadDisplaySettings() as Void {
        _settingsMin = _nowUnixMin;
        _showSeconds = Props.getBool(P_SHOW_SECONDS, false);
        _leftPad = Props.getNum(P_LEFT_PADDING, 4);
        _areaOpacity = Props.getNum(P_AREA_OPACITY, 64);
        _areaShowLine = Props.getBool(P_AREA_SHOW_LINE, true);
        _debugGraphGaps = Props.getBool(P_DEBUG_GRAPH_GAPS, false);
        _showBatteryDays = Props.getBool(P_SHOW_BATTERY_DAYS, true);
        _scanlineIntensity = Props.getNum(P_SCANLINES, 2);
        _glowIntensity = Props.getNum(P_GLOW_INTENSITY, 2);
        if (_glowIntensity < 0 || _glowIntensity > 3) {
            _glowIntensity = 2;
        }
        _bgBacklight = Props.getNum(P_BG_BACKLIGHT, 0);
        if (_bgBacklight < 0 || _bgBacklight > 3) {
            _bgBacklight = 0;
        }
        _flickerEnabled = Props.getBool(P_FLICKER_ENABLED, true);
        _line1LabelColor = Props.getNum(P_LINE1_LABEL_COLOR, 8);
        _line1ValueColor = Props.getNum(P_LINE1_VALUE_COLOR, 0);
        _line2LabelColor = Props.getNum(P_LINE2_LABEL_COLOR, 8);
        _line2ValueColor = Props.getNum(P_LINE2_VALUE_COLOR, 0);
        var fmt = Props.getNum(P_DATE_FORMAT, 0);
        var sy = Props.getBool(P_SHOW_YEAR, false);
        if (fmt != _dateFormat || sy != _showYear) {
            _dateFormat = fmt;
            _showYear = sy;
            _lastDateDay = -1;
        }
    }

    private function _refreshInteractive() as Void {
        _interactiveMin = _nowUnixMin;
        if (_needsAm) {
            _amInfo = ActivityMonitor.getInfo();
        }
        _comp.poll();
        _refreshPointSamples();
        _refreshWatchCmd();
        _profile.refresh();
    }

    private function _refreshWatchCmd() as Void {
        var showVer = Props.getBool(P_SHOW_VERSION, false);
        var cmdStyle = Props.getNum(P_WATCH_COMMAND_STYLE, 2);
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

    private function _drawFrame(dc as Dc, now as Number) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (!_lowPower && _bgBacklight > 0 && _bgBacklight < 4) {
            if (_deferThisFrame) {
                // Full-screen blend-mode composite - same one-frame defer as the halo.
                _deferredWorkPending = true;
            } else {
                var sec = System.getClockTime().sec + 500;
                _backlight.draw(
                    dc,
                    _screenW,
                    _screenH,
                    _nowUnixMin,
                    _flickerShift(sec, BG_BACKLIGHT_SHIFT_MAX),
                    _flickerAlpha(
                        BG_BACKLIGHT_DIM_LEVEL[_bgBacklight],
                        sec,
                        FLICKER_MAGNITUDE
                    )
                );
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

        if (_lowPower) {
            if (_alwaysOn) {
                _drawAodFrame(dc, cx, y, step);
            }
            return;
        }

        _drawHeader(dc, y);
        _drawPromptLine(dc, cx, y, _watchCmd);
        _drawRow(
            dc,
            cx,
            y + step,
            _getTimeParts(),
            _line1LabelColor,
            _line1ValueColor
        );
        _drawRow(
            dc,
            cx,
            y + step * 2,
            _getDateParts(),
            _line2LabelColor,
            _line2ValueColor
        );
        for (var li = 0; li < 3; li++) {
            _drawLineRow(
                dc,
                cx,
                y + step * (3 + li),
                _resolvedFields[li],
                _resolvedLabelColor[li],
                _resolvedValueColor[li],
                li
            );
        }

        var splitX = cx + _splitPad;
        var footerY = y + step * 6;

        _drawPromptPrefix(dc, splitX, footerY);
        if ((now / 1000) % 2 == 0) {
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

    // Same layout math as interactive, but only header/time/date values plus footer, no scanlines (AMOLED pixel budget).
    private function _drawAodFrame(
        dc as Dc,
        cx as Number,
        y as Number,
        step as Number
    ) as Void {
        _drawHeader(dc, y);
        _getTimeParts();
        _drawAodValue(dc, cx, y + step, _cachedTimeStr, _line1ValueColor);
        _drawAodValue(
            dc,
            cx,
            y + step * 2,
            _getDateParts()[1],
            _line2ValueColor
        );
        _drawFooter(dc, y + step * 6 + _fh + 32);
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
                _units.tempUnit,
                Graphics.TEXT_JUSTIFY_LEFT,
                color
            );
            return (
                afterNum + dc.getTextWidthInPixels(_units.tempUnit, _fontSmall)
            );
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
        if (mode == 0) {
            _drawValueTag(dc, rightX, y, "c", 1);
        } else if (mode == 1) {
            _drawValueTag(dc, rightX, y, "a", 5);
        } else if (mode == 3) {
            _drawValueTag(dc, rightX, y, "m", 6);
        }
    }

    private function _drawValueTag(
        dc as Dc,
        rightX as Number,
        y as Number,
        label as String,
        colorIdx as Number
    ) as Void {
        _glowText(
            dc,
            rightX + _charW / 2,
            y - 4,
            _fontTiny,
            label,
            Graphics.TEXT_JUSTIFY_LEFT,
            ColorUtils.colorFromIdx(colorIdx)
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

    private function _drawScanlines(dc as Dc, alpha as Number) as Void {
        dc.setStroke((alpha << 24) | 0xffffff);
        var y = 0;
        while (y < _screenH) {
            dc.drawLine(0, y, _screenW - 1, y);
            y += SCANLINE_SPACING;
        }
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
        var r = Bitmaps.tryDrawRetry(
            dc,
            x,
            y,
            bmp,
            state[0],
            state[1],
            _nowUnixMin
        );
        drawOkCache.put(cacheKey, r);
        return r[0];
    }

    private function _newClearedBitmap(
        w as Number,
        h as Number
    ) as [Graphics.BufferedBitmapReference, Graphics.BufferedBitmap]? {
        // One failed create means the graphics pool is full; retrying every draw call until next minute only burns time.
        if (w <= 0 || h <= 0 || _bmpCreateFailMin == _nowUnixMin) {
            return null;
        }
        var newRef = Bitmaps.tryCreate(w, h);
        var bmp = Bitmaps.resolveRef(newRef);
        if (bmp == null) {
            _bmpCreateFailMin = _nowUnixMin;
            return null;
        }
        var bmpDc = bmp.getDc();
        bmpDc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        bmpDc.clear();
        return [newRef, bmp];
    }

    private function _haloActive() as Boolean {
        if (_glowIntensity == 0 || _lowPower) {
            return false;
        }
        if (_halo.drawBlocked(_nowUnixMin)) {
            return false;
        }
        if (_deferThisFrame) {
            // Glow triples every draw call it touches - skip it on the wake frame and let it bloom in the frame after.
            _deferredWorkPending = true;
            return false;
        }
        if (_halo.bmp == null) {
            _halo.create(_screenW, _screenH, _nowUnixMin);
        }
        return _halo.bmp != null;
    }

    private function _haloDc() as Dc {
        return (_halo.bmp as Graphics.BufferedBitmap).getDc();
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

    private function _clearHalo() as Void {
        var hdc = _haloDc();
        hdc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        hdc.clear();
    }

    private function _compositeHalo(dc as Dc) as Void {
        dc.setBlendMode(Graphics.BLEND_MODE_ADDITIVE);
        _halo.draw(dc, 0, 0, _nowUnixMin);
        dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
    }

    private function _glowColor(color as Number) as Number {
        var f = GLOW_FRACTION[_glowIntensity];
        var r = (((color >> 16) & 0xff) * f).toNumber();
        var g = (((color >> 8) & 0xff) * f).toNumber();
        var b = ((color & 0xff) * f).toNumber();
        return (r << 16) | (g << 8) | b;
    }

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
        var cachedRef =
            _glowGlyphCache.get(key) as Graphics.BufferedBitmapReference?;
        if (cachedRef != null) {
            var cached = Bitmaps.resolveRef(cachedRef);
            if (cached != null) {
                return cached;
            }
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

        // A reclaimed entry keeps its existing ring slot; only new keys claim (and evict) one.
        if (cachedRef == null) {
            var evictKey = _glowGlyphKeys[_glowGlyphIdx];
            if (evictKey != null) {
                _glowGlyphCache.remove(evictKey as String);
            }
            _glowGlyphKeys[_glowGlyphIdx] = key;
            _glowGlyphIdx = (_glowGlyphIdx + 1) % GLOW_GLYPH_CACHE_CAP;
        }
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

    private function _glowLineShape(
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
                    color = ColorUtils.gradColor(
                        colorIdx,
                        NumUtils.fracClamp(
                            runSum / runCnt.toFloat(),
                            gradMinV,
                            gradRange
                        )
                    );
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

    private function _glowBarsShape(
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
                color = ColorUtils.gradColor(
                    colorIdx,
                    NumUtils.fracClamp(v, gradMinV, gradRange)
                );
            }
            hdc.setColor(_glowColor(color), Graphics.COLOR_TRANSPARENT);
            _haloFillDiagSpread(hdc, r[0], r[1], r[2], r[3]);
        }
    }

    private function _glowDualBarsShape(
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
                hdc.setColor(
                    _glowColor(
                        ColorUtils.gradColor(
                            colorIdx1,
                            NumUtils.fracClamp(v1, gradMinV1, gradRange1)
                        )
                    ),
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
                hdc.setColor(
                    _glowColor(
                        ColorUtils.gradColor(
                            colorIdx2,
                            NumUtils.fracClamp(v2, gradMinV2, gradRange2)
                        )
                    ),
                    Graphics.COLOR_TRANSPARENT
                );
                _haloFillDiagSpread(hdc, r2[0], r2[1], r2[2], r2[3]);
            }
        }
    }

    private function _glowOneGraph(
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
            // Intentionally off, every offset tried read as wrong against the fill's hard top edge.
        } else {
            _glowLineShape(
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

    // Shared by _flickerAlpha/_flickerShift; null means no flicker this tick (disabled or chance-miss).
    private function _flickerRoll(sec as Number) as Number? {
        if (!_flickerEnabled) {
            return null;
        }
        var n = (sec * 374761393 + 907633515) & 0x7fffffff;
        n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff;
        return n % 100 >= FLICKER_CHANCE_PCT ? null : n;
    }

    private function _flickerAlpha(
        base as Number,
        sec as Number,
        magnitude as Number
    ) as Number {
        var n = _flickerRoll(sec);
        if (n == null) {
            return base;
        }
        return ColorUtils.clampByte(
            base + ((n as Number) % (magnitude * 2 + 1)) - magnitude
        );
    }

    // Pass the same seed as _flickerAlpha to move together on the same tick.
    private function _flickerShift(
        sec as Number,
        maxShift as Number
    ) as Number {
        var n = _flickerRoll(sec);
        if (n == null) {
            return 0;
        }
        return ((n as Number) % (maxShift * 2 + 1)) - maxShift;
    }

    private function _drawPromptPrefix(
        dc as Dc,
        splitX as Number,
        y as Number
    ) as Void {
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
    }

    private function _drawPromptLine(
        dc as Dc,
        cx as Number,
        y as Number,
        content as String
    ) as Void {
        var splitX = cx + _splitPad;
        _drawPromptPrefix(dc, splitX, y);
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
        _resolveOneLine(0, PP_L3, phase);
        _resolveOneLine(1, PP_L4, phase);
        _resolveOneLine(2, PP_L5, phase);
        _resolveLineGraph(0);
        _resolveLineGraph(1);
        _resolveLineGraph(2);
    }

    private function _resolveOneLine(
        li as Number,
        pk as String,
        phase as Number
    ) as Void {
        var f = FIELD_NONE;
        if (Props.getBool(pk + PS_ENABLED, true)) {
            if (phase >= 1 && phase <= ROTATE_SLOT_NAMES.size()) {
                f = FieldMeta.slotField(pk, ROTATE_SLOT_NAMES[phase - 1]);
            }
            if (f == FIELD_NONE) {
                f = FieldMeta.slotField(pk, PS_PRIMARY);
            }
        }
        _resolvedFields[li] = f;
        _resolvedLabelColor[li] = Props.getNum(
            pk + PS_LABEL_COLOR,
            FieldTables.lineLabelColorDefault(pk)
        );
        _resolvedValueColor[li] = Props.getNum(pk + PS_VALUE_COLOR, 0);
    }

    // mode: 0=value only, 1=line, 2=bar, 3=line+value, 4=bar+value, 5=area, 6=area+value.
    private function _applyGraphMode(li as Number, mode as Number) as Void {
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
    }

    private function _resolveForecastGraph(
        li as Number,
        key as String,
        colorDefault as Number,
        valueDefault as Number
    ) as Void {
        _applyGraphMode(li, Props.getNum(key + PS_GRAPH_MODE, 4));
        _lineValueMode[li] = Props.getNum(key + PS_VALUE_MODE, valueDefault);
        _lineGraphColor[li] = Props.getNum(key + PS_GRAPH_COLOR, colorDefault);
        _linePeriodMin[li] = Props.getNum(key + PS_TIME_FRAME, 12);
        _lineGraphWidth[li] = Props.getNum(key + PS_GRAPH_WIDTH, 10);
    }

    private function _resolveBarField(
        li as Number,
        propPrefix as String,
        defaultColor as Number,
        defaultWidth as Number,
        defaultShowBar as Boolean
    ) as Void {
        _lineViewMode[li] = Props.getBool(
            propPrefix + PS_SHOW_BAR,
            defaultShowBar
        )
            ? Props.getBool(propPrefix + PS_SHOW_BAR_VALUE, true)
                ? VIEW_GRAPH_VALUE
                : VIEW_GRAPH
            : VIEW_VALUE;
        _lineGraphColor[li] = Props.getNum(
            propPrefix + PS_BAR_COLOR,
            defaultColor
        );
        _lineGraphWidth[li] = Props.getNum(
            propPrefix + PS_BAR_WIDTH,
            defaultWidth
        );
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
            _resolveBarField(li, PP_STEPS, 1, 10, true);
            return;
        }
        if (field == FIELD_FLOORS) {
            _resolveBarField(li, PP_FLOORS, 5, 8, false);
            return;
        }
        if (field == FIELD_INTENSITY_MIN) {
            _resolveBarField(li, PP_INTENSITY_MIN, 5, 8, true);
            return;
        }
        if (field == FIELD_CALORIES) {
            _resolveBarField(li, PP_CALORIES, 4, 10, false);
            var caloriesGoal = Props.getNum(PP_CALORIES + PS_BAR_GOAL, 2000);
            _lineGoal[li] = caloriesGoal <= 0 ? 2000 : caloriesGoal;
            return;
        }
        if (field == FIELD_DISTANCE) {
            _resolveBarField(li, PP_DISTANCE, 6, 10, false);
            var distanceGoal = Props.getNum(PP_DISTANCE + PS_BAR_GOAL, 5);
            _lineGoal[li] = distanceGoal <= 0 ? 5 : distanceGoal;
            return;
        }
        if (field == FIELD_ACTIVE_MIN_DAY) {
            _resolveBarField(li, PP_ACTIVE_MIN_DAY, 9, 10, false);
            var activeMinGoal = Props.getNum(
                PP_ACTIVE_MIN_DAY + PS_BAR_GOAL,
                30
            );
            _lineGoal[li] = activeMinGoal <= 0 ? 30 : activeMinGoal;
            return;
        }
        if (field == FIELD_WX_FCST_TEMP) {
            _resolveForecastGraph(li, PP_WX_FORECAST, 16, 0);
            return;
        }
        if (field == FIELD_WX_FCST_PRECIP) {
            _resolveForecastGraph(li, PP_WX_FORECAST_PRECIP, 6, 1);
            return;
        }
        if (field == FIELD_WX_FCST_DAILY) {
            var dk = PP_WX_FORECAST_DAILY;
            _lineViewMode[li] = Props.getNum(
                dk + PS_VIEW_MODE,
                VIEW_GRAPH_VALUE
            );
            _lineValueMode[li] = Props.getNum(dk + PS_VALUE_MODE, 2);
            _lineGraphColor[li] = Props.getNum(dk + PS_GRAPH_COLOR, 16);
            _linePeriodMin[li] = Props.getNum(dk + PS_DAYS, 5);
            _lineGraphWidth[li] = Props.getNum(dk + PS_GRAPH_WIDTH, 8);
            return;
        }
        if (field == FIELD_WX_FCST_WIND) {
            _resolveForecastGraph(li, PP_WX_FORECAST_WIND, 6, 1);
            return;
        }
        if (field == FIELD_WX_FCST_HUMIDITY) {
            _resolveForecastGraph(li, PP_WX_FORECAST_HUMIDITY, 2, 1);
            return;
        }
        if (field == FIELD_WX_FCST_UV) {
            _resolveForecastGraph(li, PP_WX_FORECAST_UV, 3, 2);
            return;
        }
        if (field == FIELD_WX_FCST_CLOUD) {
            _resolveForecastGraph(li, PP_WX_FORECAST_CLOUD, 8, 1);
            return;
        }
        if (field == FIELD_WX_NOWCAST) {
            _resolveForecastGraph(li, PP_WX_NOWCAST, 6, 0);
            _applyGraphMode(li, Props.getNum(PP_WX_NOWCAST + PS_GRAPH_MODE, 6));
            _linePeriodMin[li] = Props.getNum(
                PP_WX_NOWCAST + PS_TIME_FRAME,
                120
            );
            return;
        }
        var gk = FieldMeta.graphKey(field);
        if (gk == null) {
            return;
        }
        var defaults = FieldTables.graphDefaults(field);
        _applyGraphMode(li, Props.getNum(gk + PS_GRAPH_MODE, defaults[0]));
        _linePeriodMin[li] = Props.getNum(gk + PS_TIME_FRAME, defaults[1]);
        // Mirrors SpO2's min_time_frame in generate_resources.py; older installs may still hold a removed shorter frame.
        if (field == FIELD_SPO2 && _linePeriodMin[li] < 120) {
            _linePeriodMin[li] = defaults[1];
        }
        _lineGraphColor[li] = Props.getNum(gk + PS_GRAPH_COLOR, defaults[2]);
        _lineSecType[li] = Props.getNum(gk + PS_SECONDARY_TYPE, SEC_NONE);
        _lineValueMode[li] = Props.getNum(
            gk + PS_GRAPH_VALUE_MODE,
            defaults[3]
        );
        var vm = _lineViewMode[li];
        if (
            _lineSecType[li] != SEC_NONE &&
            (vm == VIEW_GRAPH || vm == VIEW_GRAPH_VALUE)
        ) {
            var sidx = Props.getNum(gk + PS_SECONDARY_FIELD, defaults[4]);
            if (sidx < 0 || sidx >= GRAPH_SEC_FIELDS.size()) {
                sidx = 0;
            }
            _lineSecField[li] = sidx;
            _lineSecColor[li] = Props.getNum(gk + PS_SECONDARY_COLOR, 0);
        }
        _lineGraphWidth[li] = Props.getNum(gk + PS_GRAPH_WIDTH, 10);
        _lineBarGroupDensity[li] = Props.getNum(gk + PS_BAR_GROUP, 0);
        _lineBarGroupAgg[li] = Props.getNum(gk + PS_BAR_GROUP_AGG, 0);
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
        if (
            _drawLineRowSensorGraph(
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

    private function _drawLineRowSensorGraph(
        dc as Dc,
        cx as Number,
        y as Number,
        field as Number,
        labelColor as Number,
        valueColor as Number,
        li as Number
    ) as Boolean {
        if (FieldMeta.graphKey(field) == null) {
            return false;
        }
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
        return false;
    }

    private function _drawGoalTag(dc as Dc, cx as Number, y as Number) as Void {
        _drawGoalTagAt(
            dc,
            cx + _splitPad + dc.getTextWidthInPixels(_rowBuf[1], _font),
            y
        );
    }

    private function _drawGoalTagAt(
        dc as Dc,
        x as Number,
        y as Number
    ) as Void {
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
            if (vm != VIEW_VALUE) {
                _drawFloorsBarRow(
                    dc,
                    cx,
                    y,
                    labelColor,
                    valueColor,
                    vm == VIEW_GRAPH_VALUE,
                    _lineGraphColor[li]
                );
                return true;
            }
            _drawFloorsRow(dc, cx, y, labelColor, valueColor);
            return true;
        }
        if (field == FIELD_STEPS) {
            var vm = _lineViewMode[li];
            if (vm != VIEW_VALUE) {
                _drawStepsBarRow(
                    dc,
                    cx,
                    y,
                    labelColor,
                    valueColor,
                    vm == VIEW_GRAPH_VALUE,
                    _lineGraphColor[li]
                );
            } else {
                var sg = _stepsAndGoal();
                var steps = sg[0];
                var goal = sg[1];
                _rowBuf[0] = "Steps";
                _rowBuf[1] = steps.format(
                    "%0" + goal.toString().length() + "d"
                );
                _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
                if (steps >= goal) {
                    _drawGoalTag(dc, cx, y);
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
                    up = _units.altStr(info.metersClimbed as Float);
                }
                if (info.metersDescended != null) {
                    dn = _units.altStr(info.metersDescended as Float);
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
            if (vm != VIEW_VALUE) {
                _drawIntensityMinBarRow(
                    dc,
                    cx,
                    y,
                    labelColor,
                    valueColor,
                    vm == VIEW_GRAPH_VALUE,
                    _lineGraphColor[li]
                );
                return true;
            }
            _getFieldParts(field);
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var ig = _intensityMinAndGoal();
            if (_amInfo != null && ig[0] >= ig[1]) {
                _drawGoalTag(dc, cx, y);
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
            if (vm != VIEW_VALUE) {
                _drawGoalBarRow(
                    dc,
                    cx,
                    y,
                    "Day Cals",
                    current,
                    _lineGoal[li],
                    labelColor,
                    valueColor,
                    vm == VIEW_GRAPH_VALUE,
                    _lineGraphColor[li]
                );
                return true;
            }
            _rowBuf[0] = "Day Cals";
            _rowBuf[1] = current.toString() + " kcal";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            if (current >= _lineGoal[li]) {
                _drawGoalTag(dc, cx, y);
            }
            return true;
        }
        if (field == FIELD_DISTANCE) {
            var vm = _lineViewMode[li];
            var distCm = 0;
            if (_amInfo != null) {
                var info = _amInfo as ActivityMonitor.Info;
                if (info.distance != null) {
                    distCm = info.distance as Number;
                }
            }
            var current = distCm / (_units.distMetric ? 100000.0 : 160934.0);
            if (vm != VIEW_VALUE) {
                _drawGoalBarRow(
                    dc,
                    cx,
                    y,
                    "Day Dist",
                    current,
                    _lineGoal[li],
                    labelColor,
                    valueColor,
                    vm == VIEW_GRAPH_VALUE,
                    _lineGraphColor[li]
                );
                return true;
            }
            _rowBuf[0] = "Day Dist";
            _rowBuf[1] =
                current.format("%.2f") + (_units.distMetric ? "km" : "mi");
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            if (current >= _lineGoal[li]) {
                _drawGoalTag(dc, cx, y);
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
            if (vm != VIEW_VALUE) {
                _drawGoalBarRow(
                    dc,
                    cx,
                    y,
                    "Act Min",
                    current,
                    _lineGoal[li],
                    labelColor,
                    valueColor,
                    vm == VIEW_GRAPH_VALUE,
                    _lineGraphColor[li]
                );
                return true;
            }
            _rowBuf[0] = "Act Min";
            _rowBuf[1] = current.toString();
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            if (current >= _lineGoal[li]) {
                _drawGoalTag(dc, cx, y);
            }
            return true;
        }
        if (field == FIELD_PRESSURE) {
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
                _wx.temp,
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
                _wx.feels,
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
                _wx.temp,
                _wx.cond,
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
                _wx.temp,
                _wx.wind,
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
                _wx.precip,
                labelColor,
                valueColor
            );
            return true;
        }
        if (field == FIELD_WX_UV_WIND) {
            _getFieldParts(field);
            _drawUvRow(dc, cx, y, _rowBuf[0], _wx.wind, labelColor, valueColor);
            return true;
        }
        if (field == FIELD_WX_TEMP_UV) {
            _getFieldParts(field);
            _rowBuf[1] = "";
            _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
            var x = cx + _splitPad;
            x = _drawTempValue(dc, x, y, _wx.temp, _units.tempUnit, valueColor);
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
                _wx.dewPoint,
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
                _wx.heatIndex,
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
                _wx.temp,
                _wx.humidity,
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
                _wx.temp,
                _wx.precip,
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
        if (field == FIELD_WX_NOWCAST) {
            _drawNowcastRow(dc, cx, y, li, labelColor, valueColor);
            return true;
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
                _wx.precip,
                _wx.fcstPrecip,
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
                _wx.wind,
                _wx.fcstWind,
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
                _wx.humidity,
                _wx.fcstHumidity,
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
                _wx.uv,
                _wx.fcstUv,
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
                _wx.cloudCover,
                _wx.fcstCloud,
                FIELD_WX_FCST_CLOUD,
                1.0
            );
            return true;
        }
        return false;
    }

    private function _stepsAndGoal() as [Number, Number] {
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
        return [steps, goal];
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
        var sg = _stepsAndGoal();
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Steps",
            sg[0],
            sg[1],
            labelColor,
            valueColor,
            showValue,
            barColor
        );
    }

    private function _floorsClimbedAndGoal() as [Number, Number] {
        var climbed = 0;
        var goal = 10;
        var info = _amInfo;
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
        return [climbed, goal];
    }

    private function _drawFloorsRow(
        dc as Dc,
        cx as Number,
        y as Number,
        labelIdx as Number,
        valIdx as Number
    ) as Void {
        var info = _amInfo;
        var fg = _floorsClimbedAndGoal();
        var x = _drawUpDownRow(
            dc,
            cx,
            y,
            "Floors",
            fg[0].toString(),
            (info != null && info.floorsDescended != null
                ? info.floorsDescended as Number
                : 0
            ).toString(),
            labelIdx,
            valIdx
        );
        if (fg[0] >= fg[1]) {
            _drawGoalTagAt(dc, x, y);
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
        var fg = _floorsClimbedAndGoal();
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Floors",
            fg[0],
            fg[1],
            labelColor,
            valueColor,
            showValue,
            barColor
        );
    }

    private function _intensityMinAndGoal() as [Number, Number] {
        var total = 0;
        var goal = 150;
        if (_amInfo != null) {
            var info = _amInfo as ActivityMonitor.Info;
            var mins = info.activeMinutesWeek;
            total =
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
        return [total, goal];
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
        var ig = _intensityMinAndGoal();
        _drawGoalBarRow(
            dc,
            cx,
            y,
            "Intens Min",
            ig[0],
            ig[1],
            labelColor,
            valueColor,
            showValue,
            barColor
        );
    }

    private function _drawGoalBarRow(
        dc as Dc,
        cx as Number,
        y as Number,
        label as String,
        current as Numeric,
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
        _drawDashed(dc, gx + gw / 4, y, barH, true, false, barCol, DASH_ALPHA);
        _drawDashed(dc, gx + gw / 2, y, barH, true, false, barCol, DASH_ALPHA);
        _drawDashed(
            dc,
            gx + (gw * 3) / 4,
            y,
            barH,
            true,
            false,
            barCol,
            DASH_ALPHA
        );
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
        var valStr =
            current instanceof Lang.Float
                ? current.format("%.1f")
                : current.format("%0" + goalStr.length() + "d");
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
    ) as Number {
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
        return x + dc.getTextWidthInPixels(dn, _font);
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
        x = _drawTempValue(dc, x, y, numStr, _units.tempUnit, valIdx);
        if (suffix.length() > 0) {
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

    private function _drawUvTag(
        dc as Dc,
        x as Number,
        y as Number,
        valIdx as Number
    ) as Number {
        if (_wx.uvNum < 0) {
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
        var numStr = _wx.uvNum.toString();
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
        var tag = _wx.uvTag();
        _glowText(
            dc,
            x,
            y,
            _font,
            tag,
            Graphics.TEXT_JUSTIFY_LEFT,
            ColorUtils.colorFromIdx(_wx.uvColorIdx())
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
        x = _drawTempValue(dc, x, y, _wx.temp, _units.tempUnit + " [", valIdx);
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        var highBrk = _wx.high + "] [";
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
            _wx.low + "]",
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
        var ay = y + (_fh - _arrowH) / 2 + 1;
        _drawIcon(dc, x, ay, ICON_ARROW_UP, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        x = _drawTempValue(dc, x, y, _wx.high, _units.tempUnit, valIdx);
        _glowText(dc, x, y, _font, " / ", Graphics.TEXT_JUSTIFY_LEFT, GRAYS[3]);
        x += dc.getTextWidthInPixels(" / ", _font);
        _drawIcon(dc, x, ay, ICON_ARROW_DN, valIdx);
        x += _bmpArrowW + ARROW_PAD;
        x = _drawTempValue(dc, x, y, _wx.low, _units.tempUnit, valIdx);
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
        var valColor = ColorUtils.colorFromIdx(valIdx);
        _glowText(
            dc,
            x,
            y,
            _font,
            _wx.humidity,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        x += dc.getTextWidthInPixels(_wx.humidity, _font);
        _glowText(dc, x, y, _font, " | ", Graphics.TEXT_JUSTIFY_LEFT, GRAYS[3]);
        x += dc.getTextWidthInPixels(" | ", _font);
        x = _drawTempValue(dc, x, y, _wx.dewPoint, _units.tempUnit, valIdx);
    }

    private function _drawTempValue(
        dc as Dc,
        x as Number,
        y as Number,
        numStr as String,
        unitStr as String,
        valIdx as Number
    ) as Number {
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
            unitStr,
            Graphics.TEXT_JUSTIFY_LEFT,
            valColor
        );
        return x + dc.getTextWidthInPixels(unitStr, _font);
    }

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
        var rawData = data;
        var primaryCacheKey = GraphUtils.packKey(_graphW, field, periodMin);
        var secondaryCacheKey = GraphUtils.packKey(
            _graphW,
            fieldSecondary,
            periodMin
        );
        // Packed keys never use the sign bit, so this keeps the secondary's derived caches apart from a single row of the same field.
        var secondaryStoreKey = secondaryCacheKey | (1 << 31);
        var barCount0 = 0;
        if (graphType == GRAPH_BAR) {
            barCount0 = _resolveBarCount(
                field,
                periodMin,
                _graphW,
                barGroupDensity
            );
            if (barCount0 > 0 && barCount0 < data.size()) {
                data = _graphs.groupBarData(
                    primaryCacheKey,
                    primaryCacheKey,
                    data,
                    barCount0,
                    barAgg
                );
                if (secType == SEC_BAR && data2 != null) {
                    data2 = _graphs.groupBarData(
                        secondaryCacheKey,
                        secondaryStoreKey,
                        data2,
                        barCount0,
                        barAgg
                    );
                }
            } else {
                barCount0 = 0;
            }
        }
        if (data2 != null) {
            data2 = _graphs.alignSecondary(
                secondaryCacheKey,
                data2 as Array<Float>,
                _graphs.resolveEffPeriod(secondaryCacheKey, periodMin),
                _graphs.resolveEffPeriod(primaryCacheKey, periodMin)
            );
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
            _calcMinMaxCached(secondaryStoreKey, data2, data2 as Array<Float>);
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
                ? GraphUtils.labelPad(
                      _units.formatGraphLabel(fieldSecondary, minV2),
                      _units.formatGraphLabel(fieldSecondary, maxV2)
                  ) + 1
                : 2;
        var gr1 = FieldMeta.gradRange(field, lineColor, minV, range);
        var gradMinV1 = gr1[0];
        var gradRange1 = gr1[1];
        var maxFrac1 = NumUtils.fracClamp(maxV, gradMinV1, gradRange1);
        var minFrac1 = NumUtils.fracClamp(minV, gradMinV1, gradRange1);

        var gr2 = FieldMeta.gradRange(
            fieldSecondary,
            lineColor2,
            minV2,
            range2
        );
        var gradMinV2 = gr2[0];
        var gradRange2 = gr2[1];
        var maxFrac2 = NumUtils.fracClamp(maxV2, gradMinV2, gradRange2);
        var minFrac2 = NumUtils.fracClamp(minV2, gradMinV2, gradRange2);

        var dualMaxGap = (10 * _graphW) / periodMin;
        if (dualMaxGap < 1) {
            dualMaxGap = 1;
        }
        // Folds GraphWidth into the period slot so two slots sharing (field, fieldSecondary, periodMin) at different widths don't collide.
        var dualCacheKey = GraphUtils.packKey(
            field,
            fieldSecondary,
            (periodMin / 15) * 6 + (_graphW / _charW - 6) / 2
        );
        var dualBmps = _renderDualGraphToBitmap(
            dualCacheKey,
            field,
            fieldSecondary,
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
            dualMaxGap,
            barCount0 > 0 ? barAgg : 0
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
                _graphs.bmpDualDrawOk
            );
        if (!cacheHit) {
            _haloSuppressed = true;
            try {
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
                if (
                    graphType == GRAPH_BAR &&
                    secType == SEC_BAR &&
                    data2 != null
                ) {
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
                if (field == FIELD_HR) {
                    _drawHrZones(dc, _graphX, _graphW, y, _graphH, minV, range);
                } else if (fieldSecondary == FIELD_HR && data2 != null) {
                    _drawHrZones(
                        dc,
                        _graphX,
                        _graphW,
                        y,
                        _graphH,
                        minV2,
                        range2
                    );
                }
            } finally {
                _haloSuppressed = false;
            }
        }

        var dualGlowBmp = dualBmps[1] as Graphics.BufferedBitmap?;
        if (cacheHit && dualGlowBmp != null) {
            var dualHdc = _activeHaloDc();
            if (dualHdc != null) {
                Bitmaps.tryDraw(
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
                _units.formatGraphLabel(fieldSecondary, maxV2),
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.gradColor(lineColor2, maxFrac2)
            );
            _glowText(
                dc,
                _graphX + _graphW + 4,
                y + _graphH - _tinyFh + 4,
                _fontTiny,
                _units.formatGraphLabel(fieldSecondary, minV2),
                Graphics.TEXT_JUSTIFY_LEFT,
                ColorUtils.gradColor(lineColor2, minFrac2)
            );
        }

        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = _graphX + _graphW + _charW * rightPad;
            var startY = y + (_fh - _smallFh * 2 - 2) / 2 - 1;
            var valEndX = _drawGraphValueLabel(
                dc,
                vx,
                startY,
                field,
                _graphValueStr(field, rawData, valueMode, valueStr),
                _seriesValueColor(lineColor, data, gradMinV1, gradRange1)
            );
            _drawValueModeLabel(dc, valEndX, startY, valueMode);
            _getFieldParts(fieldSecondary);
            _drawGraphValueLabel(
                dc,
                vx,
                startY + _smallFh + 2,
                fieldSecondary,
                _rowBuf[1],
                data2 != null
                    ? _seriesValueColor(
                          lineColor2,
                          data2 as Array<Float>,
                          gradMinV2,
                          gradRange2
                      )
                    : ColorUtils.colorFromIdx(lineColor2)
            );
        }

        _glowText(
            dc,
            _graphX - 4,
            y - 4,
            _fontTiny,
            _units.formatGraphLabel(field, maxV),
            Graphics.TEXT_JUSTIFY_RIGHT,
            ColorUtils.gradColor(lineColor, maxFrac1)
        );
        _glowText(
            dc,
            _graphX - 4,
            y + _graphH - _tinyFh + 4,
            _fontTiny,
            _units.formatGraphLabel(field, minV),
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
        var effDual = _graphs.resolveEffPeriod(primaryCacheKey, periodMin);
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
        if (ageSecDual > FieldMeta.graphStaleSec(field)) {
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

    // skipZero discards 0 samples - HR reports 0bpm when off-wrist.
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
        var corruptAgeSec = 365 * 24 * SECS_PER_HOUR;
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
                var fv = NumUtils.numToFloat(s.data as Numeric);
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
        var oldestSlot = (maxAge * gw) / periodSec;
        var didStretch = oldestSlot > 0 && maxAge < (periodSec * 9) / 10;
        if (didStretch) {
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
                        result[k] =
                            prevV +
                            ((k - prevI).toFloat() / gap.toFloat()) *
                                (v1 - prevV);
                    }
                }
                prevI = i;
                prevV = result[i] as Float;
            }
        }
        _pendingEffPeriod = didStretch ? effectiveMin : periodMin;
        return result;
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
        return age >= 0 && age <= FieldMeta.pointStaleSec(field);
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
        var maxUseful = periodMin / FieldMeta.updateMin(field);
        if (maxUseful < 2) {
            return 0;
        }
        if (count > maxUseful) {
            count = maxUseful;
        }
        if (count > cap) {
            count = cap;
        }
        return count;
    }

    private function _getFieldHistory(
        field as Number,
        periodMin as Number
    ) as Array<Float>? {
        var cacheKey = GraphUtils.packKey(_graphW, field, periodMin);
        var nowUnixMin = _nowUnixMin;
        var entry = _graphs.history.hasKey(cacheKey)
            ? _graphs.history.get(cacheKey) as [Array<Float>?, Number]
            : null;
        // nowUnixMin < entry[1] means the clock moved backward - don't trust a "future" cache timestamp.
        if (
            entry != null &&
            nowUnixMin >= entry[1] &&
            nowUnixMin - entry[1] < FieldMeta.updateMin(field)
        ) {
            return entry[0];
        }
        // Reuse the stale entry on the wake frame so the scan below can't delay the screen turning on; a real refresh runs next frame.
        if (_deferThisFrame && entry != null) {
            _deferredWorkPending = true;
            return entry[0];
        }
        _graphs.history.put(
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

    // data must be the ungrouped series, so avg/max/min reflect real samples rather than bar aggregates.
    private function _graphValueStr(
        field as Number,
        data as Array<Float>,
        mode as Number,
        currentStr as String
    ) as String {
        if (mode < 1 || mode > 3) {
            return currentStr;
        }
        var minV = 0.0 as Float;
        var maxV = 0.0 as Float;
        var sum = 0.0 as Float;
        var count = 0;
        for (var i = 0; i < data.size(); i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            if (count == 0 || v < minV) {
                minV = v;
            }
            if (count == 0 || v > maxV) {
                maxV = v;
            }
            sum += v;
            count++;
        }
        if (count == 0) {
            return currentStr;
        }
        var unit = _units.graphFieldUnit(field);
        if (mode == 1) {
            return _units.formatGraphLabel(field, sum / count.toFloat()) + unit;
        }
        if (mode == 2) {
            return (
                _units.formatGraphLabel(field, maxV) +
                "/" +
                _units.formatGraphLabel(field, minV) +
                unit
            );
        }
        return _units.formatGraphLabel(field, (minV + maxV) / 2.0) + unit;
    }

    private function _seriesValueColor(
        colorIdx as Number,
        data as Array<Float>,
        gradMinV as Float,
        gradRange as Float
    ) as Number {
        if (colorIdx < COLOR_GRAD_TRI) {
            return ColorUtils.colorFromIdx(colorIdx);
        }
        for (var i = 0; i < data.size(); i++) {
            if (data[i] != null) {
                return ColorUtils.gradColor(
                    colorIdx,
                    NumUtils.fracClamp(data[i] as Float, gradMinV, gradRange)
                );
            }
        }
        return ColorUtils.colorFromIdx(0);
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

    private function _cacheResult(
        cacheKey as Number,
        field as Number,
        r as Array<Float>?
    ) as Array<Float>? {
        _graphs.store(cacheKey, field, r, _nowUnixMin, _pendingEffPeriod);
        _pendingEffPeriod = 0;
        return r;
    }

    // +1 width/+2 height: the rightmost point and fill's bottom row land exactly at gw/gh+1, past a plain gw x (gh+1) buffer's bounds.
    private function _newGraphBitmap(
        gw as Number,
        gh as Number,
        pad as Number
    ) as [Graphics.BufferedBitmapReference, Graphics.BufferedBitmap]? {
        return _newClearedBitmap(gw + 1 + pad * 2, gh + 2 + pad * 2);
    }

    // Renders to cached bitmaps at (0,0)/(GLOW_SPREAD,GLOW_SPREAD) origin; caller blits crisp at (gx, y) and glow at (gx - GLOW_SPREAD, y - GLOW_SPREAD).
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
        maxGap as Number,
        barAgg as Number
    ) as [Graphics.BufferedBitmap?, Graphics.BufferedBitmap?] {
        var style = GraphUtils.style(graphType, lineColor, data.size(), barAgg);
        var pair = _graphs.pairGet(_graphs.bmp, cacheKey, style);
        var crispRef = pair[0] as Graphics.BufferedBitmapReference?;
        var glowRef = pair[1] as Graphics.BufferedBitmapReference?;
        var crispBmp = Bitmaps.resolveRef(crispRef);
        var rebuilt = false;
        if (crispBmp == null) {
            var created = _newGraphBitmap(gw, gh, 0);
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
        var glowBmp = Bitmaps.resolveRef(glowRef);
        if (glowBmp == null && _glowIntensity > 0 && !_lowPower) {
            var pad = GLOW_SPREAD;
            var glowCreated = _newGraphBitmap(gw, gh, pad);
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
            _graphs.bmp.put(cacheKey, [crispRef, glowRef, style] as Array);
        }
        return [crispBmp, glowBmp];
    }

    private function _renderDualGraphToBitmap(
        cacheKey as Number,
        field as Number,
        fieldSecondary as Number,
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
        dualMaxGap as Number,
        barAgg as Number
    ) as [Graphics.BufferedBitmap?, Graphics.BufferedBitmap?] {
        var style =
            GraphUtils.style(graphType, lineColor, data.size(), barAgg) |
            ((secType & 0x3) << 21) |
            ((lineColor2 & 0x7f) << 23);
        var pair = _graphs.pairGet(_graphs.bmpDual, cacheKey, style);
        var crispRef = pair[0] as Graphics.BufferedBitmapReference?;
        var glowRef = pair[1] as Graphics.BufferedBitmapReference?;
        var crispBmp = Bitmaps.resolveRef(crispRef);
        var rebuilt = false;
        if (crispBmp == null) {
            var created = _newGraphBitmap(gw, gh, 0);
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
                } else if (fieldSecondary == FIELD_HR && data2 != null) {
                    _drawHrZones(bmpDc, 0, gw, 0, gh, minV2, range2);
                }
            } finally {
                _haloSuppressed = false;
            }
            glowRef = null;
            rebuilt = true;
        }
        var glowBmp = Bitmaps.resolveRef(glowRef);
        if (glowBmp == null && _glowIntensity > 0 && !_lowPower) {
            var pad = GLOW_SPREAD;
            var glowCreated = _newGraphBitmap(gw, gh, pad);
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
            _graphs.bmpDual.put(cacheKey, [crispRef, glowRef, style] as Array);
        }
        return [crispBmp, glowBmp];
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
        if (_graphs.minMax.hasKey(cacheKey)) {
            var entry =
                _graphs.minMax.get(cacheKey) as [Float, Float, Array<Float>];
            if (entry[2] == sourceRef) {
                _dataMin = entry[0];
                _dataMax = entry[1];
                return;
            }
        }
        _calcMinMax(data);
        _graphs.minMax.put(
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

    private function _setGraphX(
        field as Number,
        minV as Float,
        maxV as Float
    ) as Void {
        _graphX =
            _graphBaseX +
            _charW *
                GraphUtils.labelPad(
                    _units.formatGraphLabel(field, minV),
                    _units.formatGraphLabel(field, maxV)
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
            _units.formatGraphLabel(field, maxV),
            Graphics.TEXT_JUSTIFY_RIGHT,
            _graphLabelColor(colorIdx, isGrad, maxFrac)
        );
        _glowText(
            dc,
            gx - 4,
            y + gh - _tinyFh + 4,
            _fontTiny,
            _units.formatGraphLabel(field, minV),
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
        if (ageSec > FieldMeta.graphStaleSec(field)) {
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

    // Shared by the line-draw functions and _glowLineShape so the glow traces exactly the same points as the crisp line.
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

    private function _drawDashed(
        dc as Dc,
        x as Number,
        y as Number,
        span as Number,
        vertical as Boolean,
        toEdges as Boolean,
        color as Number,
        alpha as Number?
    ) as Void {
        var n;
        var first;
        var last;
        if (toEdges) {
            // End dashes absorb the leftover as 2-4px (never 1px, which doesn't render under alpha); inner dashes/gaps stay 2px.
            var q = span / 4;
            var r = span % 4;
            var ends = r >= 2 ? r + 2 : r + 6;
            n = (r >= 2 ? q - 1 : q - 2) + 2;
            first = (ends + 1) / 2;
            last = ends / 2;
        } else {
            n = (span - 2) / 4;
            first = 2;
            last = 2;
        }
        if (n < (toEdges ? 2 : 1)) {
            return;
        }
        if (alpha != null) {
            dc.setStroke(ColorUtils.withAlpha(color, alpha));
        }
        var p = toEdges ? 0 : (span - (4 * n + 2)) / 2 + 2;
        for (var i = 0; i < n; i++) {
            var len = i == 0 ? first : i == n - 1 ? last : 2;
            if (vertical) {
                _dashSeg(dc, x, y + p, x, y + p + len - 1, color, alpha);
            } else {
                _dashSeg(dc, x + p, y, x + p + len - 1, y, color, alpha);
            }
            p += len + 2;
        }
    }

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
        return (
            [
                y + gh - meanH,
                colorIdx >= COLOR_GRAD_TRI
                    ? ColorUtils.gradColor(
                          colorIdx,
                          NumUtils.fracClamp(mean, gradMinV, gradRange)
                      )
                    : Graphics.COLOR_WHITE,
            ] as Array<Number>
        );
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
        _drawDashed(
            dc,
            gx,
            r[0],
            gw,
            false,
            true,
            r[1],
            colorIdx >= COLOR_GRAD_TRI ? null : DASH_ALPHA
        );
    }

    // A continuous band rather than dashes: the crisp dashes drawn on top already read as dashed.
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
                _glowLine(
                    dc,
                    x,
                    py,
                    lastX,
                    lastY,
                    ColorUtils.gradColor(
                        colorIdx,
                        NumUtils.fracClamp(
                            (v + lastV) / 2.0,
                            gradMinV,
                            gradRange
                        )
                    )
                );
            } else if (lastX >= 0 && _debugGraphGaps) {
                _drawDebugGapLine(dc, lastX, lastY, x, py);
            }
            _glowRect(
                dc,
                x,
                py,
                1,
                1,
                ColorUtils.gradColor(
                    colorIdx,
                    NumUtils.fracClamp(v, gradMinV, gradRange)
                )
            );
            lastX = x;
            lastY = py;
            lastV = v;
            lastI = i;
        }
    }

    // Shared by the bar-draw functions and _glowBarsShape so glow matches the crisp bars exactly - returns [bx, by, bw, bh].
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
            _glowRect(
                dc,
                r[0],
                r[1],
                r[2],
                r[3],
                ColorUtils.gradColor(
                    colorIdx,
                    NumUtils.fracClamp(v, gradMinV, gradRange)
                )
            );
        }
    }

    // Shared by _drawDualBars and _glowDualBarsShape - a slot is split in half, first series left, second right.
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
                _glowRect(
                    dc,
                    r1[0],
                    r1[1],
                    r1[2],
                    r1[3],
                    ColorUtils.gradColor(
                        colorIdx1,
                        NumUtils.fracClamp(v1, gradMinV1, gradRange1)
                    )
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
                _glowRect(
                    dc,
                    r2[0],
                    r2[1],
                    r2[2],
                    r2[3],
                    ColorUtils.gradColor(
                        colorIdx2,
                        NumUtils.fracClamp(v2, gradMinV2, gradRange2)
                    )
                );
            }
        }
    }

    private function _drawForecastGraphCore(
        dc as Dc,
        cx as Number,
        y as Number,
        hours as Number,
        labelColor as Number,
        valueColor as Number,
        lineColor as Number,
        graphType as Number,
        label as String,
        fieldConst as Number,
        all as Array<Float>?,
        minRange as Float,
        stepMin as Number,
        ageSec as Number
    ) as [Array<Float>, Float, Float]? {
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
            return null;
        }
        var fcstCacheKey = GraphUtils.packKey(_graphW, fieldConst, hours);
        _calcMinMaxCached(fcstCacheKey, all as Array<Float>, data);
        // Rain amounts read wrong against a floating baseline: 0.5 vs 0.6 mm/h would look like dry vs pouring.
        var minV = fieldConst == FIELD_WX_NOWCAST ? 0.0 : _dataMin;
        var maxV = _dataMax;
        var range = maxV - minV;
        if (range < minRange) {
            range = minRange;
        }
        _setGraphX(fieldConst, minV, maxV);
        var gr = FieldMeta.gradRange(fieldConst, lineColor, minV, range);
        var gradMinV = gr[0];
        var gradRange = gr[1];
        var maxFrac = NumUtils.fracClamp(maxV, gradMinV, gradRange);
        var minFrac = NumUtils.fracClamp(minV, gradMinV, gradRange);

        _rowBuf[0] = label;
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
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
            FORECAST_GAP_HOURS,
            0
        );
        _drawGraphRowGlow(
            dc,
            fcstBmps,
            fcstCacheKey,
            _graphs.bmpDrawOk,
            graphType,
            lineColor,
            data,
            y,
            minV,
            range,
            gradMinV,
            gradRange,
            FORECAST_GAP_HOURS,
            fieldConst
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
            (n * stepMin) % 60 == 0
                ? "+" + ((n * stepMin) / 60).toString() + "h"
                : "+" + (n * stepMin).toString() + "m",
            lineColor,
            maxFrac,
            minFrac,
            ageSec
        );
        return [data, minV, maxV];
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
        var core = _drawForecastGraphCore(
            dc,
            cx,
            y,
            hours,
            labelColor,
            valueColor,
            lineColor,
            graphType,
            "Temp Fcst",
            FIELD_WX_FCST_TEMP,
            _wx.fcstTemp,
            1.0,
            60,
            -1
        );
        if (core == null) {
            return;
        }
        var data = core[0];
        var minV = core[1];
        var maxV = core[2];
        if (viewMode == VIEW_GRAPH_VALUE) {
            var vx = _graphX + _graphW + _charW;
            var vy = y + (_fh - _smallFh) / 2 - 1;
            var valColor = ColorUtils.colorFromIdx(valueColor);
            if (valueMode == 2) {
                vx = _drawSmallTempNum(
                    dc,
                    vx,
                    vy,
                    _units.tempStr0(maxV),
                    valColor
                );
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
                vx = _drawSmallTempNum(
                    dc,
                    vx,
                    vy,
                    _units.tempStr0(minV),
                    valColor
                );
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    _units.tempUnit,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
            } else {
                var tStr = _graphValueStr(
                    FIELD_WX_FCST_TEMP,
                    data,
                    valueMode,
                    _wx.temp
                );
                vx = _drawSmallTempNum(dc, vx, vy, tStr, valColor);
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    _units.tempUnit,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
                _drawValueModeLabel(
                    dc,
                    vx + dc.getTextWidthInPixels(_units.tempUnit, _fontSmall),
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
        if (_profile.hrZones == null) {
            return;
        }
        var zones = _profile.hrZones as Array<Number>;
        var n = zones.size();
        if (n == 0) {
            return;
        }
        var zLo = (zones[0] as Number).toFloat();
        var zSpan = (zones[n - 1] as Number).toFloat() - zLo;
        for (var i = 0; i < n; i++) {
            var zv = (zones[i] as Number).toFloat();
            if (zv <= minV || zv >= minV + range) {
                continue;
            }
            _drawDashed(
                dc,
                gx,
                _linePointY(y, gh, zv, minV, range, gh.toFloat()),
                gw,
                false,
                true,
                ColorUtils.gradFromStops(
                    TRI_GRAD,
                    zSpan > 0.0 ? (zv - zLo) / zSpan : 0.0
                ),
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
        // +1 so the fill reaches the axis line without shifting the curve's own mapping.
        var fillBottom = y + gh + 1;
        var prevX = -1;
        var prevPY = 0;
        var prevV = 0.0 as Float;
        var prevI = -1;
        for (var i = 0; i < n; i++) {
            if (data[i] == null) {
                continue;
            }
            var v = data[i] as Float;
            var x = _linePointX(gx, gw, n1, i);
            var py = _linePointY(y, gh, v, minV, range, ghf);
            if (py < y) {
                py = y;
            }
            // Callers pass fewer points than pixels, so consecutive x values always differ (dx >= 1).
            var dx = prevX - x;
            if (prevX >= 0 && i - prevI <= maxGap) {
                // < not <=: prevX's column was already drawn last iteration.
                for (var px = x; px < prevX; px++) {
                    var lerpV =
                        v + ((px - x).toFloat() * (prevV - v)) / dx.toFloat();
                    dc.setStroke(
                        ColorUtils.withAlpha(
                            ColorUtils.gradColor(
                                colorIdx,
                                NumUtils.fracClamp(lerpV, gradMinV, gradRange)
                            ),
                            _areaOpacity
                        )
                    );
                    dc.drawLine(
                        px,
                        py + ((px - x) * (prevPY - py)) / dx,
                        px,
                        fillBottom
                    );
                }
            } else {
                if (prevX >= 0 && _debugGraphGaps) {
                    dc.setColor(GRAYS[2], Graphics.COLOR_TRANSPARENT);
                    for (var gpx = x; gpx < prevX; gpx++) {
                        dc.drawLine(
                            gpx,
                            py + ((gpx - x) * (prevPY - py)) / dx,
                            gpx,
                            fillBottom
                        );
                    }
                }
                dc.setStroke(
                    ColorUtils.withAlpha(
                        ColorUtils.gradColor(
                            colorIdx,
                            NumUtils.fracClamp(v, gradMinV, gradRange)
                        ),
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
        var core = _drawForecastGraphCore(
            dc,
            cx,
            y,
            hours,
            labelColor,
            valueColor,
            lineColor,
            graphType,
            label,
            fieldConst,
            all,
            minRange,
            60,
            -1
        );
        if (core == null) {
            return;
        }
        if (viewMode == VIEW_GRAPH_VALUE) {
            var endX = _drawGraphValueLabel(
                dc,
                _graphX + _graphW + _charW,
                y + (_fh - _smallFh) / 2 - 1,
                fieldConst,
                _graphValueStr(fieldConst, core[0], valueMode, fallbackValue),
                ColorUtils.colorFromIdx(valueColor)
            );
            _drawValueModeLabel(dc, endX, y, valueMode);
        }
    }

    private function _drawNowcastRow(
        dc as Dc,
        cx as Number,
        y as Number,
        li as Number,
        labelColor as Number,
        valueColor as Number
    ) as Void {
        var stepMin = NOWCAST_STEP_SEC / SECS_PER_MIN;
        var core = _drawForecastGraphCore(
            dc,
            cx,
            y,
            _linePeriodMin[li] / stepMin,
            labelColor,
            valueColor,
            _lineGraphColor[li],
            _lineGraphType[li],
            "Rain Amount",
            FIELD_WX_NOWCAST,
            _nowcast.data,
            1.0,
            stepMin,
            _nowcast.ageSec()
        );
        if (core == null || _lineViewMode[li] != VIEW_GRAPH_VALUE) {
            return;
        }
        var valueMode = _lineValueMode[li];
        var all = _nowcast.data as Array<Float>;
        var unit = _units.graphFieldUnit(FIELD_WX_NOWCAST);
        var valStr = "-";
        if (valueMode == 1) {
            if (all[0] != null) {
                valStr =
                    _units.formatGraphLabel(FIELD_WX_NOWCAST, all[0] as Float) +
                    unit;
            }
        } else if (valueMode == 2) {
            valStr = _units.formatGraphLabel(FIELD_WX_NOWCAST, core[2]) + unit;
        } else {
            valStr = _nowcast.nextChange(core[0].size());
        }
        var endX = _drawGraphValueLabel(
            dc,
            _graphX + _graphW + _charW,
            y + (_fh - _smallFh) / 2 - 1,
            FIELD_WX_NOWCAST,
            valStr,
            ColorUtils.colorFromIdx(valueColor)
        );
        if (valueMode == 1) {
            _drawValueModeLabel(dc, endX, y, 0);
        } else if (valueMode == 2) {
            // "m" already means Midpoint, so the max tag is "x".
            _drawValueTag(dc, endX, y, "x", 4);
        }
    }

    // Shared by the bars and the day labels so labels stay centred under their bars.
    private function _dailySlot(
        gx as Number,
        gw as Number,
        i as Number,
        n as Number
    ) as [Number, Number] {
        var slotX = gx + (i * gw) / n;
        var bw = gx + ((i + 1) * gw) / n - slotX - (i < n - 1 ? 1 : 0);
        return [slotX, bw < 1 ? 1 : bw];
    }

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
        var slot = _dailySlot(gx, gw, i, n);
        var slotX = slot[0];
        var bw = slot[1];
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
            _drawDashed(
                dc,
                gx + (si * gw) / n - 1,
                y,
                gh,
                true,
                false,
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
            _glowRect(
                dc,
                r[0],
                r[1],
                r[2],
                r[3],
                ColorUtils.gradColor(
                    colorIdx,
                    NumUtils.fracClamp((hiV + loV) / 2.0, gradMinV, gradRange)
                )
            );
        }
    }

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
            hdc.setColor(
                _glowColor(
                    ColorUtils.gradColor(
                        colorIdx,
                        NumUtils.fracClamp(
                            (hiV + loV) / 2.0,
                            gradMinV,
                            gradRange
                        )
                    )
                ),
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
        var style = GraphUtils.style(GRAPH_BAR, colorIdx, n, 0);
        var pair = _graphs.pairGet(_graphs.bmp, cacheKey, style);
        var crispRef = pair[0] as Graphics.BufferedBitmapReference?;
        var glowRef = pair[1] as Graphics.BufferedBitmapReference?;
        var crispBmp = Bitmaps.resolveRef(crispRef);
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
        var glowBmp = Bitmaps.resolveRef(glowRef);
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
            _graphs.bmp.put(cacheKey, [crispRef, glowRef, style] as Array);
        }
        return [crispBmp, glowBmp];
    }

    private function _drawDailyNoData(
        dc as Dc,
        cx as Number,
        y as Number,
        labelColor as Number,
        valueColor as Number
    ) as Void {
        _rowBuf[0] = "Day Fcst";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        _drawGraphNoData(dc, _graphX, _graphW, y, _graphH);
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
        var highs = _wx.dailyHigh;
        var lows = _wx.dailyLow;
        if (highs == null || lows == null) {
            _drawDailyNoData(dc, cx, y, labelColor, valueColor);
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
            _drawDailyNoData(dc, cx, y, labelColor, valueColor);
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
            _drawDailyNoData(dc, cx, y, labelColor, valueColor);
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
        var gr = FieldMeta.gradRange(
            FIELD_WX_FCST_TEMP,
            colorIdx,
            allMin,
            range
        );
        var gradMinV = gr[0];
        var gradRange = gr[1];
        _rowBuf[0] = "Day Fcst";
        _rowBuf[1] = "";
        _drawRow(dc, cx, y, _rowBuf, labelColor, valueColor);
        var dailyCacheKey = GraphUtils.packKey(_graphW, FIELD_WX_FCST_DAILY, n);
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
                _graphs.bmpDrawOk
            );
        if (!cacheHit) {
            _haloSuppressed = true;
            try {
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
            } finally {
                _haloSuppressed = false;
            }
        } else {
            var dailyGlowBmp = dailyBmps[1] as Graphics.BufferedBitmap?;
            if (dailyGlowBmp != null) {
                var dailyHdc = _activeHaloDc();
                if (dailyHdc != null) {
                    Bitmaps.tryDraw(
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
        var maxFrac = NumUtils.fracClamp(allMax, gradMinV, gradRange);
        var minFrac = NumUtils.fracClamp(allMin, gradMinV, gradRange);
        _glowText(
            dc,
            _graphX - 4,
            y - 4,
            _fontTiny,
            _units.formatGraphLabel(FIELD_WX_FCST_TEMP, allMax),
            Graphics.TEXT_JUSTIFY_RIGHT,
            _graphLabelColor(colorIdx, isGrad, maxFrac)
        );
        _glowText(
            dc,
            _graphX - 4,
            y + _graphH - _tinyFh + 4,
            _fontTiny,
            _units.formatGraphLabel(FIELD_WX_FCST_TEMP, allMin),
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
            var slot = _dailySlot(_graphX, _graphW, di, n);
            _glowText(
                dc,
                slot[0] + slot[1] / 2,
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
                vx = _drawSmallTempNum(
                    dc,
                    vx,
                    vy,
                    _units.tempStr0(allMax),
                    valColor
                );
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
                vx = _drawSmallTempNum(
                    dc,
                    vx,
                    vy,
                    _units.tempStr0(allMin),
                    valColor
                );
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    _units.tempUnit,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
            } else {
                var tStr = _wx.temp;
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
                    tStr = _units.tempStr0(
                        cnt > 0 ? sum / cnt.toFloat() : 0.0 as Float
                    );
                } else if (valueMode == 3) {
                    tStr = _units.tempStr0((allMin + allMax) / 2.0);
                }
                vx = _drawSmallTempNum(dc, vx, vy, tStr, valColor);
                _glowText(
                    dc,
                    vx,
                    vy,
                    _fontSmall,
                    _units.tempUnit,
                    Graphics.TEXT_JUSTIFY_LEFT,
                    valColor
                );
                _drawValueModeLabel(
                    dc,
                    vx + dc.getTextWidthInPixels(_units.tempUnit, _fontSmall),
                    y,
                    valueMode
                );
            }
        }
    }

    // Returns whether the bitmap was drawn - false means the fallback already drew crisp+glow directly, so skip a separate glow restore.
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
        maxGap as Number,
        field as Number
    ) as Boolean {
        if (
            bmp == null ||
            !_drawCachedGraphBitmap(dc, _graphX, y, bmp, cacheKey, drawOkCache)
        ) {
            // Per-point glow on a live draw trips the watchdog on device; this path only runs while the bitmap pool is failing.
            _haloSuppressed = true;
            try {
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
                if (field == FIELD_HR) {
                    _drawHrZones(dc, _graphX, _graphW, y, _graphH, minV, range);
                }
            } finally {
                _haloSuppressed = false;
            }
            return false;
        }
        return true;
    }

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
        maxGap as Number,
        field as Number
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
            maxGap,
            field
        );
        var glowBmp = bmps[1] as Graphics.BufferedBitmap?;
        if (!cacheHit || glowBmp == null) {
            return;
        }
        var hdc = _activeHaloDc();
        if (hdc == null) {
            return;
        }
        Bitmaps.tryDraw(
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
        if (graphType == GRAPH_BAR) {
            _drawBars(
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
            return;
        }
        if (graphType == GRAPH_AREA) {
            _drawAreaLine(
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
            if (!_areaShowLine) {
                return;
            }
        }
        _drawGraphLine(
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
        var cacheKey = GraphUtils.packKey(_graphW, field, periodMin);
        var rawData = data;
        var barCount0 = 0;
        if (graphType == GRAPH_BAR) {
            barCount0 = _resolveBarCount(
                field,
                periodMin,
                _graphW,
                barGroupDensity
            );
            if (barCount0 > 0 && barCount0 < data.size()) {
                data = _graphs.groupBarData(
                    cacheKey,
                    cacheKey,
                    data,
                    barCount0,
                    barAgg
                );
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
        var gr = FieldMeta.gradRange(field, lineColor, minV, range);
        var gradMinV = gr[0];
        var gradRange = gr[1];
        var maxFrac = NumUtils.fracClamp(maxV, gradMinV, gradRange);
        var minFrac = NumUtils.fracClamp(minV, gradMinV, gradRange);

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
            maxGap,
            barCount0 > 0 ? barAgg : 0
        );
        _drawGraphRowGlow(
            dc,
            graphBmps,
            cacheKey,
            _graphs.bmpDrawOk,
            graphType,
            lineColor,
            data,
            y,
            minV,
            range,
            gradMinV,
            gradRange,
            maxGap,
            field
        );
        _drawRowAxes(dc, y);
        var eff = _graphs.resolveEffPeriod(cacheKey, periodMin);
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
            var valEndX = _drawGraphValueLabel(
                dc,
                valX,
                valY,
                field,
                _graphValueStr(field, rawData, valueMode, valueStr),
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
                    ? _units.altStr(a.altitude as Float)
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
            _rowBuf[1] = _units.optDistStr(_comp.weeklyRun);
            return true;
        }
        if (field == FIELD_WEEKLY_BIKE) {
            _rowBuf[0] = "Week Bike";
            _rowBuf[1] = _units.optDistStr(_comp.weeklyBike);
            return true;
        }
        if (field == FIELD_CLIMB_DAY) {
            _rowBuf[0] = "Climb Day";
            var info = _amInfo;
            _rowBuf[1] =
                info != null && info.metersClimbed != null
                    ? _units.altStr(info.metersClimbed as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_DESCENT_DAY) {
            _rowBuf[0] = "Descent Day";
            var info = _amInfo;
            _rowBuf[1] =
                info != null && info.metersDescended != null
                    ? _units.altStr(info.metersDescended as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_SOLAR) {
            _rowBuf[0] = "Solar Input";
            _rowBuf[1] = _solarStr();
            return true;
        }
        if (field == FIELD_WEEKLY_DISTANCES) {
            _rowBuf[0] = "Run+Bike";
            _rowBuf[1] =
                _units.optDistStr(_comp.weeklyRun) +
                " | " +
                _units.optDistStr(_comp.weeklyBike);
            return true;
        }
        if (field == FIELD_SOLAR_BATTERY) {
            _rowBuf[0] = "Solar/Bat";
            _rowBuf[1] = _solarStr() + " | " + _batText;
            return true;
        }
        return false;
    }

    private function _hrStr() as String {
        var a = _acInfo;
        return a != null && a.currentHeartRate != null
            ? (a.currentHeartRate as Number).toString() + " bpm"
            : "-";
    }

    private function _spo2Str() as String {
        var a = _acInfo;
        return a != null && a.currentOxygenSaturation != null
            ? (a.currentOxygenSaturation as Number).format("%.0f") + "%"
            : "-";
    }

    private function _respStr() as String {
        var info = _amInfo;
        return info != null && info.respirationRate != null
            ? (info.respirationRate as Number).toString() + "/m"
            : "-";
    }

    private function _recoveryStr() as String {
        var info = _amInfo;
        return info != null && info.timeToRecovery != null
            ? (info.timeToRecovery as Number).toString() + "h"
            : "-";
    }

    private function _sleepStr() as String {
        return _comp.sleepScore != null
            ? (_comp.sleepScore as Number).toString()
            : "-";
    }

    private function _trainingStr() as String {
        return _comp.trainingStatus != null
            ? Formatters.trainingStatusStr(_comp.trainingStatus as String)
            : "-";
    }

    private function _solarStr() as String {
        return _comp.solar != null
            ? (_comp.solar as Number).toString() + "%"
            : "-";
    }

    private function _getHealthFieldParts(field as Number) as Boolean {
        if (field == FIELD_HR) {
            _rowBuf[0] = "Heart";
            _rowBuf[1] = _hrStr();
            return true;
        }
        if (field == FIELD_SPO2) {
            _rowBuf[0] = "SpO2";
            _rowBuf[1] = _spo2Str();
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
            _rowBuf[1] = _respStr();
            return true;
        }
        if (field == FIELD_RECOVERY) {
            _rowBuf[0] = "Recovery";
            _rowBuf[1] = _recoveryStr();
            return true;
        }
        if (field == FIELD_WRIST_TEMP) {
            _rowBuf[0] = "Wrist Temp";
            _rowBuf[1] = _cachedTempWrist;
            return true;
        }
        if (field == FIELD_SLEEP) {
            _rowBuf[0] = "Sleep";
            _rowBuf[1] = _sleepStr();
            return true;
        }
        if (field == FIELD_VO2_MAX) {
            _rowBuf[0] = "VO2 Max";
            _rowBuf[1] = _profile.vo2Max;
            return true;
        }
        if (field == FIELD_TRAINING_STATUS) {
            _rowBuf[0] = "Training";
            _rowBuf[1] = _trainingStr();
            return true;
        }
        if (field == FIELD_HR_SPO2) {
            _rowBuf[0] = "HR+SpO2";
            _rowBuf[1] = _hrStr() + " | " + _spo2Str();
            return true;
        }
        if (field == FIELD_BODY_BAT_STRESS) {
            _rowBuf[0] = "Body+Stress";
            _rowBuf[1] = _cachedBodyBat + " | " + _cachedStress;
            return true;
        }
        if (field == FIELD_BODY_BAT_RECOVERY) {
            _rowBuf[0] = "Body+Recov";
            _rowBuf[1] = _cachedBodyBat + " | " + _recoveryStr();
            return true;
        }
        if (field == FIELD_STRESS_RECOVERY) {
            _rowBuf[0] = "Stress+Rec";
            _rowBuf[1] = _cachedStress + " | " + _recoveryStr();
            return true;
        }
        if (field == FIELD_RESP_SPO2) {
            _rowBuf[0] = "Resp+SpO2";
            _rowBuf[1] = _respStr() + " | " + _spo2Str();
            return true;
        }
        if (field == FIELD_VO2_TRAINING) {
            _rowBuf[0] = "VO2+Train";
            _rowBuf[1] = _profile.vo2Max + " " + _trainingStr();
            return true;
        }
        if (field == FIELD_HR_RESTING_BOTH) {
            _rowBuf[0] = "HR Rest/Avg";
            _rowBuf[1] = _profile.restingHR + " | " + _profile.avgRestingHR;
            return true;
        }
        if (field == FIELD_BODY_BAT_REST_HR) {
            _rowBuf[0] = "Bat+RestHR";
            _rowBuf[1] = _cachedBodyBat + " | " + _profile.restingHR;
            return true;
        }
        if (field == FIELD_SLEEP_RECOVERY) {
            _rowBuf[0] = "Sleep+Rec";
            _rowBuf[1] = _sleepStr() + " | " + _recoveryStr();
            return true;
        }
        if (field == FIELD_HR_RESTING) {
            _rowBuf[0] = "HR Rest";
            _rowBuf[1] = _profile.restingHR;
            return true;
        }
        if (field == FIELD_HR_RESTING_AVG) {
            _rowBuf[0] = "HR RestAvg";
            _rowBuf[1] = _profile.avgRestingHR;
            return true;
        }
        return false;
    }

    private function _getScheduleFieldParts(field as Number) as Boolean {
        if (field == FIELD_SUNRISE) {
            _rowBuf[0] = "Sunrise";
            _rowBuf[1] = Formatters.optTime(_comp.sunrise);
            return true;
        }
        if (field == FIELD_SUNSET) {
            _rowBuf[0] = "Sunset";
            _rowBuf[1] = Formatters.optTime(_comp.sunset);
            return true;
        }
        if (field == FIELD_SUNRISE_SUNSET) {
            _rowBuf[0] = "Sunrise+Set";
            _rowBuf[1] =
                Formatters.optTime(_comp.sunrise) +
                " / " +
                Formatters.optTime(_comp.sunset);
            return true;
        }
        if (field == FIELD_CALENDAR) {
            _rowBuf[0] = "Calendar";
            _rowBuf[1] =
                _comp.calendar != null ? _comp.calendar as String : "-";
            return true;
        }
        if (field == FIELD_SLEEP_TIME) {
            _rowBuf[0] = "Bedtime";
            _rowBuf[1] = _profile.sleepTime;
            return true;
        }
        if (field == FIELD_WAKE_TIME) {
            _rowBuf[0] = "Wake Time";
            _rowBuf[1] = _profile.wakeTime;
            return true;
        }
        if (field == FIELD_SLEEP_SCHEDULE) {
            _rowBuf[0] = "Sleep Sched";
            _rowBuf[1] = _profile.sleepTime + " | " + _profile.wakeTime;
            return true;
        }
        if (field == FIELD_NOTIFICATIONS) {
            _rowBuf[0] = "Notifs";
            _rowBuf[1] =
                _comp.notifications != null
                    ? (_comp.notifications as Number).toString()
                    : "-";
            return true;
        }
        return false;
    }

    private function _getRaceFieldParts(field as Number) as Boolean {
        if (field == FIELD_RACE_5K) {
            _rowBuf[0] = "Race 5K";
            _rowBuf[1] =
                _comp.race5k != null
                    ? Formatters.secsToRace(_comp.race5k as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_10K) {
            _rowBuf[0] = "Race 10K";
            _rowBuf[1] =
                _comp.race10k != null
                    ? Formatters.secsToRace(_comp.race10k as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_HALF) {
            _rowBuf[0] = "Race Half";
            _rowBuf[1] =
                _comp.raceHalf != null
                    ? Formatters.secsToRace(_comp.raceHalf as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_MARATHON) {
            _rowBuf[0] = "Race Mar";
            _rowBuf[1] =
                _comp.raceMarathon != null
                    ? Formatters.secsToRace(_comp.raceMarathon as Number)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_PACE_5K) {
            _rowBuf[0] = "5k Pace";
            _rowBuf[1] =
                _comp.racePace5k != null
                    ? _units.formatPace(_comp.racePace5k as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_PACE_10K) {
            _rowBuf[0] = "10k Pace";
            _rowBuf[1] =
                _comp.racePace10k != null
                    ? _units.formatPace(_comp.racePace10k as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_PACE_HALF) {
            _rowBuf[0] = "Half Pace";
            _rowBuf[1] =
                _comp.racePaceHalf != null
                    ? _units.formatPace(_comp.racePaceHalf as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_RACE_PACE_MARATHON) {
            _rowBuf[0] = "Mar Pace";
            _rowBuf[1] =
                _comp.racePaceMarathon != null
                    ? _units.formatPace(_comp.racePaceMarathon as Float)
                    : "-";
            return true;
        }
        return false;
    }

    private function _getWeatherCurrentFieldParts(field as Number) as Boolean {
        if (field == FIELD_WX_PRECIP) {
            _rowBuf[0] = "Rain %";
            _rowBuf[1] = _wx.precip;
            return true;
        }
        if (field == FIELD_WX_WIND) {
            _rowBuf[0] = "Wind Speed";
            _rowBuf[1] = _wx.wind;
            return true;
        }
        if (field == FIELD_WX_UV) {
            _rowBuf[0] = "UV Index";
            _rowBuf[1] = _wx.uv;
            return true;
        }
        if (field == FIELD_WX_COND) {
            _rowBuf[0] = "Weather";
            _rowBuf[1] = _wx.cond;
            return true;
        }
        if (field == FIELD_WX_COND_PRECIP) {
            _rowBuf[0] = "Cond+Rain";
            _rowBuf[1] = _wx.cond + " | " + _wx.precip;
            return true;
        }
        if (field == FIELD_WX_WIND_PRECIP) {
            _rowBuf[0] = "Rain+Wind";
            _rowBuf[1] = _wx.precip + " | " + _wx.wind;
            return true;
        }
        if (field == FIELD_WX_TEMP) {
            _rowBuf[0] = "Temp";
            _rowBuf[1] = _wx.temp + _units.tempUnit;
            return true;
        }
        if (field == FIELD_WX_FEELS) {
            _rowBuf[0] = "Feels Like";
            _rowBuf[1] = _wx.feels + _units.tempUnit;
            return true;
        }
        if (field == FIELD_WX_TEMP_COND) {
            _rowBuf[0] = "Temp+Cond";
            _rowBuf[1] = _wx.temp + _units.tempUnit + " | " + _wx.cond;
            return true;
        }
        if (field == FIELD_WX_TEMP_WIND) {
            _rowBuf[0] = "Temp+Wind";
            _rowBuf[1] = _wx.temp + _units.tempUnit + " | " + _wx.wind;
            return true;
        }
        if (field == FIELD_WX_TEMP_UV) {
            _rowBuf[0] = "Temp+UV";
            _rowBuf[1] = _wx.temp + _units.tempUnit + " | " + _wx.uv;
            return true;
        }
        if (field == FIELD_WX_UV_PRECIP) {
            _rowBuf[0] = "UV+Rain";
            _rowBuf[1] = _wx.uv + " | " + _wx.precip;
            return true;
        }
        if (field == FIELD_WX_UV_WIND) {
            _rowBuf[0] = "UV+Wind";
            _rowBuf[1] = _wx.uv + " | " + _wx.wind;
            return true;
        }
        if (field == FIELD_WX_HUMIDITY) {
            _rowBuf[0] = "Humidity";
            _rowBuf[1] = _wx.humidity;
            return true;
        }
        if (field == FIELD_WX_DEW_POINT) {
            _rowBuf[0] = "Dew Point";
            _rowBuf[1] = _wx.dewPoint + _units.tempUnit;
            return true;
        }
        if (field == FIELD_WX_VISIBILITY) {
            _rowBuf[0] = "Visibility";
            _rowBuf[1] = _wx.visibility;
            return true;
        }
        if (field == FIELD_WX_CLOUD) {
            _rowBuf[0] = "Cloud Cover";
            _rowBuf[1] = _wx.cloudCover;
            return true;
        }
        if (field == FIELD_WX_HEAT_INDEX) {
            _rowBuf[0] = "Heat Index";
            _rowBuf[1] = _wx.heatIndex + _units.tempUnit;
            return true;
        }
        if (field == FIELD_WX_HUMIDITY_PRECIP) {
            _rowBuf[0] = "Rain+Hum";
            _rowBuf[1] = _wx.precip + " | " + _wx.humidity;
            return true;
        }
        if (field == FIELD_WX_CLOUD_PRECIP) {
            _rowBuf[0] = "Rain+Cloud";
            _rowBuf[1] = _wx.precip + " | " + _wx.cloudCover;
            return true;
        }
        if (field == FIELD_WX_COND_CLOUD) {
            _rowBuf[0] = "Cond+Cloud";
            _rowBuf[1] = _wx.cond + " | " + _wx.cloudCover;
            return true;
        }
        if (field == FIELD_WX_SEA_PRESS) {
            _rowBuf[0] = "Sea Press";
            _rowBuf[1] =
                _comp.seaLevelPressure != null
                    ? _units.pressureStr(_comp.seaLevelPressure as Float)
                    : "-";
            return true;
        }
        if (field == FIELD_WX_OBS_TIME) {
            _rowBuf[0] = "WX Age";
            _rowBuf[1] = _wx.obsAge;
            return true;
        }
        return false;
    }

    // FIELD_WX_FCST_TEMP/PRECIP/DAILY/WIND/HUMIDITY/UV/CLOUD are handled entirely by _drawLineRowWeatherForecast - they never reach this function.
    private function _getWeatherForecastFieldParts(field as Number) as Boolean {
        if (field == FIELD_WX_COND_FCST_1D) {
            _rowBuf[0] = "Cond/+1d";
            _rowBuf[1] =
                _wx.cond + " | " + Formatters.optCond(_comp.fcstCond1d);
            return true;
        }
        if (field == FIELD_WX_FCST_COND_12D) {
            _rowBuf[0] = "+1d/+2d";
            _rowBuf[1] =
                Formatters.optCond(_comp.fcstCond1d) +
                " | " +
                Formatters.optCond(_comp.fcstCond2d);
            return true;
        }
        if (field == FIELD_WX_FCST_COND_1D) {
            _rowBuf[0] = "Fcst +1d";
            _rowBuf[1] = Formatters.optCond(_comp.fcstCond1d);
            return true;
        }
        if (field == FIELD_WX_FCST_COND_2D) {
            _rowBuf[0] = "Fcst +2d";
            _rowBuf[1] = Formatters.optCond(_comp.fcstCond2d);
            return true;
        }
        if (field == FIELD_WX_FCST_COND_3D) {
            _rowBuf[0] = "Fcst +3d";
            _rowBuf[1] = Formatters.optCond(_comp.fcstCond3d);
            return true;
        }
        return false;
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
        _pointSamplesDeferred = false;
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
                    (d instanceof Lang.Float
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
                _cachedTempWrist = _units.tempStr(
                    NumUtils.numToFloat(sample.data as Numeric)
                );
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
                var pa = NumUtils.numToFloat(s1.data as Numeric);
                _cachedPressure = _units.pressureStr(pa);
                // The trend scan below can walk up to 30 min of samples; skip it on the wake frame and keep the last-known trend.
                if (_deferThisFrame) {
                    _deferredWorkPending = true;
                    _pointSamplesDeferred = true;
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
                    if (oldest != s1) {
                        var opa = NumUtils.numToFloat(oldest.data as Numeric);
                        _cachedPressureTrend =
                            pa - opa > 100.0 ? 1 : pa - opa < -100.0 ? -1 : 0;
                    } else {
                        _cachedPressureTrend = 0;
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
                _cachedElevation = _units.altStr(
                    NumUtils.numToFloat(sample.data as Numeric)
                );
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
                        sd instanceof Lang.Float
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
        if (nowMin == _wx.lastMin) {
            return;
        }
        if (!_needsWeatherCurrent) {
            _wx.lastMin = nowMin;
            return;
        }
        if (_deferThisFrame && _wx.fetchedMin >= 0) {
            // Same one-frame defer as complications - reuse stale weather data on wake, refresh on the follow-up requestUpdate().
            _deferredWorkPending = true;
            return;
        }
        _wx.lastMin = nowMin;
        _wx.fetchedMin = nowMin;
        if (_needsForecast) {
            var changed = _wx.refreshForecast(nowMin);
            for (var i = 0; i < changed.size(); i++) {
                _graphs.invalidateField(changed[i]);
            }
        }
        var c = Weather.getCurrentConditions();
        if (c == null) {
            return;
        }
        if (_needsNowcast && c.observationLocationPosition != null) {
            _nowcast.setLocation(
                c.observationLocationPosition as Position.Location
            );
        }
        _wx.refreshCurrent(c, _units);
    }

    public function reloadNowcast() as Void {
        if (_nowcast.reload()) {
            _graphs.invalidateField(FIELD_WX_NOWCAST);
        }
        if (_needsNowcast) {
            _nowcast.schedule();
        }
    }

    private function _refreshNowcast() as Void {
        if (!_nowcast.isDue(_nowUnixMin)) {
            return;
        }
        // Only deferred while data is on screen, so the wake frame never shows an empty graph.
        if (_deferThisFrame && _nowcast.data != null) {
            _deferredWorkPending = true;
            return;
        }
        if (_nowcast.refresh(_nowUnixMin)) {
            _graphs.invalidateField(FIELD_WX_NOWCAST);
        }
    }

    public function advanceRotation() as Boolean {
        if (!_rotation.advance(Time.now().value())) {
            return false;
        }
        WatchUi.requestUpdate();
        return true;
    }

    public function onEnterSleep() as Void {
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
        _rotation.reset(Time.now().value());
        WatchUi.requestUpdate();
    }
}
