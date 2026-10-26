import Toybox.Lang;
import Toybox.Time;

// Which rotation phase (0 = main, 1..maxPhase = alternate slots) is on screen, by timer, by press, or both.
class Rotation {
    private var _mainSec as Number = 5;
    private var _altSec as Number = 5;
    private var _maxPhase as Number = ROTATE_SLOT_NAMES.size();
    private var _mode as Number = ROTATION_HYBRID;
    private var _manualPhase as Number = 0;
    private var _anchorSec as Number = -1;

    public function initialize() {}

    public function configure() as Void {
        var ri = Props.getNum(P_ROTATE_INTERVAL, 5);
        if (ri < 1) {
            ri = 1;
        }
        _mainSec = ri;
        var ra = Props.getNum(P_ROTATE_INTERVAL_ALT, 0);
        _altSec = ra > 0 ? ra : _mainSec;
        var rm = Props.getNum(P_ROTATION_MODE, ROTATION_HYBRID);
        if (rm < ROTATION_AUTOMATIC || rm > ROTATION_HYBRID) {
            rm = ROTATION_HYBRID;
        }
        if (rm != _mode) {
            _mode = rm;
            // Same "start fresh" treatment as a wake, so a mode switch never resumes from a stale anchor.
            reset(Time.now().value());
        }
        _maxPhase = 0;
        var e3 = Props.getBool(PP_L3 + PS_ENABLED, true);
        var e4 = Props.getBool(PP_L4 + PS_ENABLED, true);
        var e5 = Props.getBool(PP_L5 + PS_ENABLED, true);
        for (var p = ROTATE_SLOT_NAMES.size() - 1; p >= 0; p--) {
            var sn = ROTATE_SLOT_NAMES[p];
            if (
                (e3 && _slotUsed(PP_L3, sn)) ||
                (e4 && _slotUsed(PP_L4, sn)) ||
                (e5 && _slotUsed(PP_L5, sn))
            ) {
                _maxPhase = p + 1;
                break;
            }
        }
    }

    public function phase(nowSec as Number) as Number {
        if (_mode == ROTATION_MANUAL) {
            return _manualPhase > _maxPhase ? _maxPhase : _manualPhase;
        }
        if (_anchorSec < 0) {
            _anchorSec = nowSec;
        }
        return _phaseFromElapsed(nowSec - _anchorSec);
    }

    // Returns false in automatic mode, where a press has nothing to advance.
    public function advance(nowSec as Number) as Boolean {
        if (_mode == ROTATION_AUTOMATIC) {
            return false;
        }
        if (_mode == ROTATION_MANUAL) {
            _manualPhase = _manualPhase >= _maxPhase ? 0 : _manualPhase + 1;
        } else {
            var cur = phase(nowSec);
            _jumpTo(cur >= _maxPhase ? 0 : cur + 1, nowSec);
        }
        return true;
    }

    public function reset(nowSec as Number) as Void {
        _manualPhase = 0;
        _jumpTo(0, nowSec);
    }

    private function _slotUsed(pk as String, sn as String) as Boolean {
        return FieldMeta.slotField(pk, sn) != FIELD_NONE;
    }

    private function _phaseFromElapsed(elapsedSec as Number) as Number {
        var cycle = _mainSec + _maxPhase * _altSec;
        var pos = elapsedSec % cycle;
        if (pos < 0) {
            pos += cycle;
        }
        if (pos < _mainSec) {
            return 0;
        }
        pos -= _mainSec;
        return pos / _altSec + 1;
    }

    private function _jumpTo(target as Number, nowSec as Number) as Void {
        if (target <= 0) {
            _anchorSec = nowSec;
            return;
        }
        _anchorSec = nowSec - (_mainSec + (target - 1) * _altSec);
    }
}
