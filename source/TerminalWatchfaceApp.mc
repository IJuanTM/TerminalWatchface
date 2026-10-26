import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:background)
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

    public function getServiceDelegate() as [System.ServiceDelegate] {
        return [new RainNowcastService()];
    }

    // A failed fetch arrives as a response code; the last good forecast stays.
    public function onBackgroundData(
        data as Application.PersistableType
    ) as Void {
        if (!(data instanceof Lang.Array)) {
            return;
        }
        Storage.setValue("rnData", data);
        if (_view != null) {
            (_view as TerminalWatchfaceView).reloadNowcast();
        }
        WatchUi.requestUpdate();
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
