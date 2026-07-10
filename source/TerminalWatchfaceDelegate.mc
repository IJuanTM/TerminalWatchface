import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Properties;

// Long-press cycles the active screen - watch faces can't push views/menus,
// and onPress is the only live input hook WatchFaceDelegate offers.
class TerminalWatchfaceDelegate extends WatchUi.WatchFaceDelegate {
    private var _view as TerminalWatchfaceView;

    public function initialize(view as TerminalWatchfaceView) {
        WatchFaceDelegate.initialize();
        _view = view;
    }

    public function onPress(clickEvent as WatchUi.ClickEvent) as Boolean {
        var cur = Properties.getValue("aScr");
        var next = ((cur instanceof Number ? cur as Number : 0) + 1) % 3;
        // Screen 1 is always enabled; skip screens 2/3 if the user disabled them.
        var tries = 0;
        while (next != 0 && tries < 2) {
            var v = Properties.getValue("s" + (next + 1).toString() + "En");
            var enabled = v instanceof Boolean && (v as Boolean);
            if (enabled) {
                break;
            }
            next = (next + 1) % 3;
            tries++;
        }
        Properties.setValue("aScr", next);
        _view.invalidateSettings();
        WatchUi.requestUpdate();
        return true;
    }
}
