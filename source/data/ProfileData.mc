import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;

// Display-ready user profile values, refreshed once per interactive minute.
class ProfileData {
    public var vo2Max as String = "-";
    public var restingHR as String = "-";
    public var avgRestingHR as String = "-";
    public var sleepTime as String = "-";
    public var wakeTime as String = "-";
    public var hrZones as Array<Number>? = null;

    public function initialize() {}

    public function refresh() as Void {
        var profile = UserProfile.getProfile();
        var vo2 = profile.vo2maxRunning;
        if (vo2 == null) {
            vo2 = profile.vo2maxCycling;
        }
        vo2Max = vo2 != null ? (vo2 as Number).toString() : "-";
        if (profile has :restingHeartRate && profile.restingHeartRate != null) {
            restingHR = (profile.restingHeartRate as Number).toString();
        } else {
            restingHR = "-";
        }
        if (
            profile has :averageRestingHeartRate &&
            profile.averageRestingHeartRate != null
        ) {
            avgRestingHR = (
                profile.averageRestingHeartRate as Number
            ).toString();
        } else {
            avgRestingHR = "-";
        }
        sleepTime =
            profile has :upcomingSleepTime && profile.upcomingSleepTime != null
                ? _hhmm(profile.upcomingSleepTime as Time.Moment)
                : "-";
        wakeTime =
            profile has :upcomingWakeTime && profile.upcomingWakeTime != null
                ? _hhmm(profile.upcomingWakeTime as Time.Moment)
                : "-";
        // UserProfile.Profile has no hrZones field - zones come from this module function instead.
        try {
            hrZones = UserProfile.getHeartRateZones(
                UserProfile.HR_ZONE_SPORT_GENERIC
            );
        } catch (e instanceof Lang.Exception) {
            hrZones = null;
        }
    }

    private function _hhmm(m as Time.Moment) as String {
        var info = Gregorian.info(m, Time.FORMAT_SHORT) as Gregorian.Info;
        return (
            (info.hour as Number).format("%02d") +
            ":" +
            (info.min as Number).format("%02d")
        );
    }
}
