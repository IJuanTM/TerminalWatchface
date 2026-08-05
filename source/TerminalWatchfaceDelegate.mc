import Toybox.Lang;
import Toybox.WatchUi;

// onPress (touch-and-hold) is the only live input hook a watch face gets - no pushView/menus/onKey.
class TerminalWatchfaceDelegate extends WatchUi.WatchFaceDelegate {
    private var _view as TerminalWatchfaceView;

    public function initialize(view as TerminalWatchfaceView) {
        WatchFaceDelegate.initialize();
        _view = view;
    }

    public function onPress(clickEvent as WatchUi.ClickEvent) as Boolean {
        return _view.advanceRotation();
    }
}
