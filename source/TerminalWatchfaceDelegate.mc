import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Properties;

// Long-press (touch and hold) cycles the active rotation screen. WatchFace
// apps cannot push views/menus (WatchUi.pushView throws
// OperationNotAllowedException for any watch face), and WatchFaceDelegate is
// the only delegate type the runtime accepts here - onPress is its only
// generically usable live input hook.
class TerminalWatchfaceDelegate extends WatchUi.WatchFaceDelegate {
    private var _view as TerminalWatchfaceView;

    public function initialize(view as TerminalWatchfaceView) {
        WatchFaceDelegate.initialize();
        _view = view;
    }

    public function onPress(clickEvent as WatchUi.ClickEvent) as Boolean {
        var cur = Properties.getValue("activeScreen");
        var next = ((cur instanceof Number ? cur as Number : 0) + 1) % 3;
        Properties.setValue("activeScreen", next);
        _view.invalidateSettings();
        WatchUi.requestUpdate();
        return true;
    }
}
