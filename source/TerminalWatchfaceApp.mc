import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TerminalWatchfaceApp extends Application.AppBase {
    private var _view as TerminalWatchfaceView?;

    public function initialize() {
        AppBase.initialize();
    }

    public function onStart(state as Dictionary?) as Void {}

    public function onStop(state as Dictionary?) as Void {}

    public function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new $.TerminalWatchfaceView();
        return [
            _view,
            new $.TerminalWatchfaceDelegate(_view as TerminalWatchfaceView),
        ];
    }

    public function onSettingsChanged() as Void {
        if (_view != null) {
            (_view as TerminalWatchfaceView).reloadFont();
        }
        WatchUi.requestUpdate();
    }
}

class TerminalWatchfaceDelegate extends WatchUi.WatchFaceDelegate {
    private var _view as TerminalWatchfaceView;
    private var _lastTapMs as Number = 0;

    public function initialize(view as TerminalWatchfaceView) {
        WatchFaceDelegate.initialize();
        _view = view;
    }

    public function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_LEFT) {
            _view.advanceScreen(1);
        } else if (dir == WatchUi.SWIPE_RIGHT) {
            _view.advanceScreen(-1);
        }
        return true;
    }

    public function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        if (_view.tapAt(coords[0], coords[1])) {
            _lastTapMs = 0;
            return true;
        }
        var now = System.getTimer();
        if (now - _lastTapMs < 500) {
            _view.advanceScreen(1);
            _lastTapMs = 0;
        } else {
            _lastTapMs = now;
        }
        return true;
    }
}
