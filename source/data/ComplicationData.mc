import Toybox.Complications;
import Toybox.Lang;

// Latest value of every complication a field reads; null until the platform has published one.
class ComplicationData {
    public var sleepScore as Number? = null;
    public var sunrise as Number? = null;
    public var sunset as Number? = null;
    public var calendar as String? = null;
    public var weeklyRun as Float? = null;
    public var weeklyBike as Float? = null;
    public var trainingStatus as String? = null;
    public var race5k as Number? = null;
    public var race10k as Number? = null;
    public var raceHalf as Number? = null;
    public var raceMarathon as Number? = null;
    public var notifications as Number? = null;
    public var racePace5k as Float? = null;
    public var racePace10k as Float? = null;
    public var racePaceHalf as Float? = null;
    public var racePaceMarathon as Float? = null;
    public var solar as Number? = null;
    public var fcstCond1d as Number? = null;
    public var fcstCond2d as Number? = null;
    public var fcstCond3d as Number? = null;
    public var seaLevelPressure as Float? = null;
    // Ids the platform refused to subscribe, read on every poll instead.
    private var _polled as Array<Complications.Id> =
        [] as Array<Complications.Id>;
    private var _callbackSet as Boolean = false;

    public function initialize() {}

    public function subscribe(types as Array<Complications.Type>) as Void {
        if (!_callbackSet) {
            Complications.registerComplicationChangeCallback(
                method(:onChanged)
            );
            _callbackSet = true;
        }
        Complications.unsubscribeFromAllUpdates();
        _polled = [] as Array<Complications.Id>;
        for (var i = 0; i < types.size(); i++) {
            var id = new Complications.Id(types[i]);
            var ok = false;
            try {
                ok = Complications.subscribeToUpdates(id);
            } catch (e instanceof Lang.Exception) {}
            if (!ok) {
                _polled.add(id);
            }
            onChanged(id);
        }
    }

    public function poll() as Void {
        for (var i = 0; i < _polled.size(); i++) {
            onChanged(_polled[i]);
        }
    }

    public function onChanged(id as Complications.Id) as Void {
        var comp = null;
        try {
            comp = Complications.getComplication(id);
        } catch (e instanceof Lang.Exception) {
            return;
        }
        _store(id.getType(), comp.value);
    }

    private function _store(
        t as Complications.Type,
        v as Complications.Value?
    ) as Void {
        if (t == Complications.COMPLICATION_TYPE_SLEEP_SCORE) {
            sleepScore = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_SUNRISE) {
            sunrise = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_SUNSET) {
            sunset = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_CALENDAR_EVENTS) {
            calendar = v != null ? v.toString() : null;
        } else if (t == Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE) {
            weeklyRun =
                v != null ? (v as Complications.RangeValue).toFloat() : null;
        } else if (t == Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE) {
            weeklyBike =
                v != null ? (v as Complications.RangeValue).toFloat() : null;
        } else if (t == Complications.COMPLICATION_TYPE_TRAINING_STATUS) {
            trainingStatus = v != null ? v.toString() : null;
        } else if (t == Complications.COMPLICATION_TYPE_RACE_PREDICTOR_5K) {
            race5k = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_RACE_PREDICTOR_10K) {
            race10k = v as Number;
        } else if (
            t == Complications.COMPLICATION_TYPE_RACE_PREDICTOR_HALF_MARATHON
        ) {
            raceHalf = v as Number;
        } else if (
            t == Complications.COMPLICATION_TYPE_RACE_PREDICTOR_MARATHON
        ) {
            raceMarathon = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT) {
            notifications = v as Number;
        } else if (
            t == Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_5K
        ) {
            racePace5k = v as Float;
        } else if (
            t == Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_10K
        ) {
            racePace10k = v as Float;
        } else if (
            t ==
            Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_HALF_MARATHON
        ) {
            racePaceHalf = v as Float;
        } else if (
            t == Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_MARATHON
        ) {
            racePaceMarathon = v as Float;
        } else if (t == Complications.COMPLICATION_TYPE_SOLAR_INPUT) {
            solar = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_FORECAST_WEATHER_1DAY) {
            fcstCond1d = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_FORECAST_WEATHER_2DAY) {
            fcstCond2d = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_FORECAST_WEATHER_3DAY) {
            fcstCond3d = v as Number;
        } else if (t == Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE) {
            seaLevelPressure = v as Float;
        }
    }
}
