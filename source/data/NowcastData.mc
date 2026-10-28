import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Time;

// Foreground side of the rain nowcast: slices the background service's stored series to "now" and keeps its temporal event registered.
class NowcastData {
    public var data as Array<Float>? = null;
    private var _startSec as Number = 0;
    private var _raw as Array<Storage.ValueType>? = null;
    // Slot index into _raw that data starts at; -2 forces a rebuild.
    private var _idx as Number = -2;
    private var _lastMin as Number = -1;
    private var _loc as String = "";
    private var _onWake as Boolean = true;
    private var _intervalSec as Number = 300;
    // Set once a shown field has asked for data, so a wake only fetches while the nowcast is in use.
    private var _active as Boolean = false;

    public function initialize() {
        _loadSettings();
    }

    // Each data-changing call returns true so the caller can drop the graph caches keyed on the old data.
    public function reload() as Boolean {
        var raw = Storage.getValue("rnData");
        _raw = raw instanceof Lang.Array ? raw : null;
        _idx = -2;
        return _slice();
    }

    public function isDue(nowMin as Number) as Boolean {
        return _lastMin != nowMin;
    }

    public function refresh(nowMin as Number) as Boolean {
        _lastMin = nowMin;
        var changed = _slice();
        schedule();
        return changed;
    }

    // Re-registered on the next field resolve if a slot still shows the nowcast.
    public function invalidate() as Void {
        _lastMin = -1;
        _idx = -2;
        _active = false;
        Background.deleteTemporalEvent();
        _loadSettings();
    }

    // Periodic: without data, a one-shot Moment fetches as soon as the platform's 5-minute spacing allows;
    // with data, the repeating Duration takes over, counted from that fetch.
    // On wake: only ever an immediate one-shot, so nothing fires while the screen is off.
    public function schedule() as Void {
        _active = true;
        var reg = Background.getTemporalEventRegisteredTime();
        if (_onWake) {
            if (reg instanceof Time.Duration) {
                Background.deleteTemporalEvent();
            }
            _registerOneShot(
                data != null ? _intervalSec : NOWCAST_STEP_SEC,
                false
            );
            return;
        }
        if (data != null) {
            if (!(reg instanceof Time.Duration)) {
                Background.registerForTemporalEvent(
                    new Time.Duration(_intervalSec)
                );
            }
            return;
        }
        _registerOneShot(NOWCAST_STEP_SEC, true);
    }

    public function onWake() as Void {
        if (_active && _onWake) {
            schedule();
        }
    }

    public function setLocation(loc as Position.Location) as Void {
        var deg = loc.toDegrees();
        var lat = deg[0].toFloat();
        var lon = deg[1].toFloat();
        var key = lat.format("%.2f") + lon.format("%.2f");
        if (!key.equals(_loc)) {
            _loc = key;
            Storage.setValue("rnLoc", [lat, lon]);
        }
    }

    public function nextChange(n as Number) as String {
        var all = data as Array<Float>;
        if (all[0] == null) {
            return "-";
        }
        var raining = (all[0] as Float) >= NOWCAST_RAIN_MMH;
        for (var i = 1; i < n; i++) {
            var v = all[i];
            if (v != null && v >= NOWCAST_RAIN_MMH != raining) {
                var mins =
                    (_startSec + i * NOWCAST_STEP_SEC - Time.now().value()) /
                    SECS_PER_MIN;
                return (
                    (raining ? "stop " : "rain ") +
                    (mins < 0 ? 0 : mins).toString() +
                    "m"
                );
            }
        }
        return raining ? "rain" : "dry";
    }

    // gapSec is at least NOWCAST_STEP_SEC, the platform's minimum spacing, which throws if broken.
    private function _registerOneShot(
        gapSec as Number,
        allowFuture as Boolean
    ) as Void {
        var now = Time.now();
        var reg = Background.getTemporalEventRegisteredTime();
        if (
            reg instanceof Time.Moment &&
            (reg as Time.Moment).value() > now.value() - SECS_PER_MIN
        ) {
            return;
        }
        var last = Background.getLastTemporalEventTime();
        if (last == null) {
            // Null doesn't prove no event ran recently, and the platform still enforces its 5-minute spacing.
            try {
                Background.registerForTemporalEvent(now);
            } catch (e instanceof Background.InvalidBackgroundTimeException) {
                Background.registerForTemporalEvent(
                    now.add(new Time.Duration(NOWCAST_STEP_SEC))
                );
            }
            return;
        }
        var next = last.add(new Time.Duration(gapSec));
        if (allowFuture || next.value() <= now.value()) {
            Background.registerForTemporalEvent(next);
        }
    }

    private function _loadSettings() as Void {
        _onWake = Props.getNum(PP_WX_NOWCAST + PS_FETCH_MODE, 0) == 0;
        var m = Props.getNum(PP_WX_NOWCAST + PS_FETCH_INTERVAL, 5);
        _intervalSec = (m < 5 ? 5 : m) * SECS_PER_MIN;
    }

    // Rebuilt only when the current slot moves, so the identity-keyed graph caches survive between steps.
    private function _slice() as Boolean {
        var raw = _raw;
        var idx = -1;
        if (raw != null && raw.size() > 1) {
            idx = (Time.now().value() - (raw[0] as Number)) / NOWCAST_STEP_SEC;
            if (idx < 0) {
                idx = 0;
            }
            if (idx >= raw.size() - 1) {
                idx = -1;
            }
        }
        if (idx == _idx) {
            return false;
        }
        _idx = idx;
        data = null;
        if (raw != null && idx >= 0) {
            _startSec = (raw[0] as Number) + idx * NOWCAST_STEP_SEC;
            var n = raw.size() - 1 - idx;
            var arr = new Array<Float>[n];
            for (var i = 0; i < n; i++) {
                arr[i] = raw[1 + idx + i] as Float?;
            }
            data = arr;
        }
        return true;
    }
}
