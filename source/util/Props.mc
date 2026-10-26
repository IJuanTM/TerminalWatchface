import Toybox.Application.Properties;
import Toybox.Lang;

module Props {
    function getNum(key as String, defaultVal as Number) as Number {
        try {
            var val = Properties.getValue(key);
            if (val instanceof Lang.Number) {
                return val as Number;
            }
        } catch (e instanceof Lang.Exception) {}
        return defaultVal;
    }

    function getBool(key as String, defaultVal as Boolean) as Boolean {
        try {
            var val = Properties.getValue(key);
            if (val instanceof Lang.Boolean) {
                return val as Boolean;
            }
        } catch (e instanceof Lang.Exception) {}
        return defaultVal;
    }
}
