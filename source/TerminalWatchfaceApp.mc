import Toybox.Application;
import Toybox.Lang;
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
        return [_view, new TerminalWatchfaceDelegate(_view)];
    }

    public function onSettingsChanged() as Void {
        if (_view != null) {
            var v = _view as TerminalWatchfaceView;
            v.reloadFont();
            v.invalidateSettings();
        }
        WatchUi.requestUpdate();
    }
}
