// GENERATED FILE - DO NOT EDIT. Regenerate with `python scripts/generate_resources.py`.

import Toybox.Complications;
import Toybox.Lang;

const CACHE_KEY_HI_SHIFT = 21;
const CACHE_KEY_LO_SHIFT = 11;
const CACHE_KEY_MASK = 0x3ff;
const CACHE_KEY_PERIOD_MASK = 0x7ff;

const FIELD_NONE = 0;

// --- Fitness / Health (1-50) ---
const FIELD_STEPS = 1;
const FIELD_FLOORS = 2;
const FIELD_MOVE_BAR = 3;
const FIELD_HR = 4;
const FIELD_SPO2 = 5;
const FIELD_RESP = 6;
const FIELD_BODY_BAT = 7;
const FIELD_STRESS = 8;
const FIELD_RECOVERY = 9;
const FIELD_SLEEP = 10;
const FIELD_VO2_MAX = 11;
const FIELD_TRAINING_STATUS = 12;
const FIELD_WRIST_TEMP = 13;
const FIELD_HR_RESTING = 14;
const FIELD_HR_RESTING_AVG = 15;
const FIELD_HR_RESTING_BOTH = 16;
const FIELD_HR_SPO2 = 17;
const FIELD_RESP_SPO2 = 18;
const FIELD_BODY_BAT_STRESS = 19;
const FIELD_BODY_BAT_RECOVERY = 20;
const FIELD_STRESS_RECOVERY = 21;
const FIELD_VO2_TRAINING = 22;
const FIELD_BODY_BAT_REST_HR = 23;
const FIELD_SLEEP_RECOVERY = 24;

// --- Calories / Distance / Speed (51-100) ---
const FIELD_CALORIES = 51;
const FIELD_DISTANCE = 52;
const FIELD_ACTIVE_MIN_DAY = 53;
const FIELD_INTENSITY_MIN = 54;

// --- Altitude / Pressure (101-150) ---
const FIELD_ALTITUDE = 101;
const FIELD_ELEVATION = 102;
const FIELD_PRESSURE = 103;

// --- Race Predictors (151-200) ---
const FIELD_RACE_5K = 151;
const FIELD_RACE_10K = 152;
const FIELD_RACE_HALF = 153;
const FIELD_RACE_MARATHON = 154;
const FIELD_RACE_PACE_5K = 155;
const FIELD_RACE_PACE_10K = 156;
const FIELD_RACE_PACE_HALF = 157;
const FIELD_RACE_PACE_MARATHON = 158;

// --- Ascent / Descent (201-250) ---
const FIELD_CLIMB_DAY = 201;
const FIELD_DESCENT_DAY = 202;
const FIELD_CLIMB_DESCEND_DAY = 203;

// --- Weekly (251-300) ---
const FIELD_WEEKLY_RUN = 251;
const FIELD_WEEKLY_BIKE = 252;
const FIELD_WEEKLY_DISTANCES = 253;

// --- Time / Calendar (301-350) ---
const FIELD_SUNRISE = 301;
const FIELD_SUNSET = 302;
const FIELD_SUNRISE_SUNSET = 303;
const FIELD_CALENDAR = 304;
const FIELD_SLEEP_TIME = 305;
const FIELD_WAKE_TIME = 306;
const FIELD_SLEEP_SCHEDULE = 307;

// --- Weather: current (351-400) ---
const FIELD_WX_TEMP = 351;
const FIELD_WX_FEELS = 352;
const FIELD_WX_COND = 353;
const FIELD_WX_PRECIP = 354;
const FIELD_WX_WIND = 355;
const FIELD_WX_UV = 356;
const FIELD_WX_CLOUD = 357;
const FIELD_WX_HUMIDITY = 358;
const FIELD_WX_DEW_POINT = 359;
const FIELD_WX_VISIBILITY = 360;
const FIELD_WX_HEAT_INDEX = 361;
const FIELD_WX_HIGH_LOW = 362;

// --- Weather: combos (401-450) ---
const FIELD_WX_TEMP_COND = 401;
const FIELD_WX_TEMP_PRECIP = 402;
const FIELD_WX_TEMP_WIND = 403;
const FIELD_WX_TEMP_UV = 404;
const FIELD_WX_TEMP_HUMIDITY = 405;
const FIELD_WX_TEMP_HIGH_LOW = 406;
const FIELD_WX_COND_PRECIP = 407;
const FIELD_WX_WIND_PRECIP = 408;
const FIELD_WX_UV_PRECIP = 409;
const FIELD_WX_CLOUD_PRECIP = 410;
const FIELD_WX_HUMIDITY_PRECIP = 411;
const FIELD_WX_UV_WIND = 412;
const FIELD_WX_HUMIDITY_DEW = 413;
const FIELD_WX_COND_CLOUD = 414;

// --- Weather: forecast (451-500) ---
const FIELD_WX_FCST_TEMP = 451;
const FIELD_WX_FCST_DAILY = 452;
const FIELD_WX_FCST_PRECIP = 453;
const FIELD_WX_FCST_WIND = 454;
const FIELD_WX_FCST_UV = 455;
const FIELD_WX_FCST_CLOUD = 456;
const FIELD_WX_FCST_HUMIDITY = 457;
const FIELD_WX_NOWCAST = 458;

// --- Weather: forecast conditions (501-550) ---
const FIELD_WX_FCST_COND_1D = 501;
const FIELD_WX_FCST_COND_2D = 502;
const FIELD_WX_FCST_COND_3D = 503;
const FIELD_WX_COND_FCST_1D = 504;
const FIELD_WX_FCST_COND_12D = 505;

// --- Weather: station (551-600) ---
const FIELD_WX_SEA_PRESS = 551;
const FIELD_WX_OBS_TIME = 552;

// --- Watch / System (601-650) ---
const FIELD_NOTIFICATIONS = 601;
const FIELD_SOLAR = 602;
const FIELD_SOLAR_BATTERY = 603;

// Rotation phase p (1..size) reads slot ROTATE_SLOT_NAMES[p - 1]; phase 0 is PS_PRIMARY.
const ROTATE_SLOT_NAMES =
    ["2", "3", "4", "5"] as Array<String>;

// Index is the SecondaryField property value.
const GRAPH_SEC_FIELDS = [
    FIELD_HR,
    FIELD_SPO2,
    FIELD_BODY_BAT,
    FIELD_STRESS,
    FIELD_WRIST_TEMP,
    FIELD_ELEVATION,
    FIELD_PRESSURE,
] as Array<Number>;

// Property keys; see the key comment in generate_resources.py.
const P_FONT_CHOICE = "f";
const P_COLOR_THEME = "t";
const P_SCANLINES = "s";
const P_GLOW_INTENSITY = "g";
const P_BG_BACKLIGHT = "b";
const P_FLICKER_ENABLED = "k";
const P_LEFT_PADDING = "p";
const P_AREA_OPACITY = "o";
const P_AREA_SHOW_LINE = "a";
const P_SHOW_BATTERY_DAYS = "y";
const P_SHOW_SECONDS = "c";
const P_SHOW_YEAR = "r";
const P_DATE_FORMAT = "d";
const P_WATCH_COMMAND_STYLE = "w";
const P_ROTATE_INTERVAL = "i";
const P_ROTATE_INTERVAL_ALT = "j";
const P_ROTATION_MODE = "m";
const P_LINE1_LABEL_COLOR = "l1";
const P_LINE1_VALUE_COLOR = "v1";
const P_LINE2_LABEL_COLOR = "l2";
const P_LINE2_VALUE_COLOR = "v2";
const P_SHOW_VERSION = "v";
const P_DEBUG_GRAPH_GAPS = "x";
const P_UNIT_DISTANCE = "u";
const P_UNIT_TEMPERATURE = "e";
const P_UNIT_ELEVATION = "h";
const P_UNIT_PACE = "n";
const P_UNIT_PRESSURE = "q";

const PP_L3 = "x";
const PP_L4 = "y";
const PP_L5 = "z";
const PP_STEPS = "s";
const PP_FLOORS = "f";
const PP_CALORIES = "c";
const PP_DISTANCE = "d";
const PP_ACTIVE_MIN_DAY = "a";
const PP_INTENSITY_MIN = "i";
const PP_HR = "h";
const PP_SPO2 = "o";
const PP_BODY_BAT = "b";
const PP_STRESS = "t";
const PP_TEMP_WRIST = "w";
const PP_ELEVATION = "e";
const PP_PRESSURE = "p";
const PP_WX_FORECAST = "k";
const PP_WX_FORECAST_PRECIP = "r";
const PP_WX_FORECAST_WIND = "n";
const PP_WX_FORECAST_UV = "u";
const PP_WX_FORECAST_CLOUD = "g";
const PP_WX_FORECAST_HUMIDITY = "m";
const PP_WX_FORECAST_DAILY = "j";
const PP_WX_NOWCAST = "q";

const PS_GRAPH_MODE = "m";
const PS_GRAPH_VALUE_MODE = "g";
const PS_VALUE_MODE = "v";
const PS_SECONDARY_TYPE = "t";
const PS_SECONDARY_FIELD = "f";
const PS_SECONDARY_COLOR = "e";
const PS_TIME_FRAME = "j";
const PS_GRAPH_COLOR = "c";
const PS_GRAPH_WIDTH = "w";
const PS_SHOW_BAR = "h";
const PS_SHOW_BAR_VALUE = "b";
const PS_BAR_COLOR = "k";
const PS_BAR_WIDTH = "x";
const PS_BAR_GOAL = "q";
const PS_ENABLED = "n";
const PS_LABEL_COLOR = "l";
const PS_VALUE_COLOR = "a";
const PS_VIEW_MODE = "y";
const PS_DAYS = "d";
const PS_BAR_GROUP = "u";
const PS_BAR_GROUP_AGG = "z";
const PS_FETCH_INTERVAL = "i";
const PS_PRIMARY = "1";

module FieldTables {
    function lineSlotDefaultField(
        pk as String,
        slotName as String
    ) as Number {
        if (pk.equals("x")) {
            if (slotName.equals("1")) {
                return FIELD_WX_FCST_TEMP;
            }
            if (slotName.equals("2")) {
                return FIELD_WX_NOWCAST;
            }
            if (slotName.equals("3")) {
                return FIELD_WX_COND_CLOUD;
            }
            if (slotName.equals("4")) {
                return FIELD_WX_UV_WIND;
            }
            if (slotName.equals("5")) {
                return FIELD_WX_FCST_DAILY;
            }
        }
        if (pk.equals("y")) {
            if (slotName.equals("1")) {
                return FIELD_STEPS;
            }
            if (slotName.equals("2")) {
                return FIELD_ELEVATION;
            }
            if (slotName.equals("3")) {
                return FIELD_DISTANCE;
            }
            if (slotName.equals("4")) {
                return FIELD_FLOORS;
            }
            if (slotName.equals("5")) {
                return FIELD_CLIMB_DESCEND_DAY;
            }
        }
        if (pk.equals("z")) {
            if (slotName.equals("1")) {
                return FIELD_HR;
            }
            if (slotName.equals("2")) {
                return FIELD_STRESS;
            }
            if (slotName.equals("3")) {
                return FIELD_BODY_BAT;
            }
            if (slotName.equals("4")) {
                return FIELD_ACTIVE_MIN_DAY;
            }
            if (slotName.equals("5")) {
                return FIELD_INTENSITY_MIN;
            }
        }
        return FIELD_NONE;
    }

    function lineLabelColorDefault(pk as String) as Number {
        if (pk.equals("x")) {
            return 6;
        }
        if (pk.equals("y")) {
            return 1;
        }
        if (pk.equals("z")) {
            return 5;
        }
        return 8;
    }

    // [mode, timeFrameMin, graphColor, valueMode, secField]
    function graphDefaults(
        field as Number
    ) as [Number, Number, Number, Number, Number] {
        switch (field) {
            case FIELD_HR:
                return [3, 60, 5, 0, 2];
            case FIELD_SPO2:
                return [6, 240, 6, 2, 0];
            case FIELD_BODY_BAT:
                return [6, 240, 11, 0, 3];
            case FIELD_STRESS:
                return [3, 120, 10, 1, 0];
            case FIELD_WRIST_TEMP:
                return [3, 60, 16, 1, 0];
            case FIELD_ELEVATION:
                return [6, 360, 1, 0, 6];
            case FIELD_PRESSURE:
                return [3, 120, 2, 1, 5];
            default:
                return [0, 60, 0, 0, 0];
        }
    }

    function needs(field as Number) as Number {
        switch (field) {
            case FIELD_WX_NOWCAST:
                return NEED_NOWCAST;
            case FIELD_HR:
            case FIELD_SPO2:
            case FIELD_ALTITUDE:
            case FIELD_HR_SPO2:
                return NEED_LIVE_ACTIVITY;
            case FIELD_RESP_SPO2:
                return NEED_LIVE_ACTIVITY | NEED_AM;
            case FIELD_STEPS:
            case FIELD_FLOORS:
            case FIELD_CALORIES:
            case FIELD_DISTANCE:
            case FIELD_ACTIVE_MIN_DAY:
            case FIELD_INTENSITY_MIN:
            case FIELD_MOVE_BAR:
            case FIELD_CLIMB_DESCEND_DAY:
            case FIELD_CLIMB_DAY:
            case FIELD_DESCENT_DAY:
            case FIELD_RESP:
            case FIELD_RECOVERY:
            case FIELD_BODY_BAT_RECOVERY:
            case FIELD_STRESS:
            case FIELD_BODY_BAT_STRESS:
            case FIELD_STRESS_RECOVERY:
            case FIELD_SLEEP_RECOVERY:
                return NEED_AM;
            case FIELD_WX_FCST_TEMP:
            case FIELD_WX_FCST_PRECIP:
            case FIELD_WX_FCST_DAILY:
            case FIELD_WX_FCST_WIND:
            case FIELD_WX_FCST_HUMIDITY:
            case FIELD_WX_FCST_UV:
            case FIELD_WX_FCST_CLOUD:
                return NEED_FORECAST;
            case FIELD_WX_PRECIP:
            case FIELD_WX_WIND:
            case FIELD_WX_UV:
            case FIELD_WX_COND:
            case FIELD_WX_COND_PRECIP:
            case FIELD_WX_WIND_PRECIP:
            case FIELD_WX_TEMP:
            case FIELD_WX_FEELS:
            case FIELD_WX_TEMP_COND:
            case FIELD_WX_TEMP_WIND:
            case FIELD_WX_TEMP_UV:
            case FIELD_WX_UV_PRECIP:
            case FIELD_WX_UV_WIND:
            case FIELD_WX_TEMP_HIGH_LOW:
            case FIELD_WX_HUMIDITY:
            case FIELD_WX_DEW_POINT:
            case FIELD_WX_VISIBILITY:
            case FIELD_WX_CLOUD:
            case FIELD_WX_HIGH_LOW:
            case FIELD_WX_HUMIDITY_DEW:
            case FIELD_WX_HEAT_INDEX:
            case FIELD_WX_TEMP_HUMIDITY:
            case FIELD_WX_TEMP_PRECIP:
            case FIELD_WX_HUMIDITY_PRECIP:
            case FIELD_WX_CLOUD_PRECIP:
            case FIELD_WX_COND_CLOUD:
            case FIELD_WX_OBS_TIME:
            case FIELD_WX_COND_FCST_1D:
                return NEED_WX_CURRENT;
            default:
                return 0;
        }
    }

    function compTypes(
        field as Number
    ) as Array<Complications.Type>? {
        switch (field) {
            case FIELD_WEEKLY_RUN:
                return [
                    Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE,
                ] as Array<Complications.Type>;
            case FIELD_WEEKLY_BIKE:
                return [
                    Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE,
                ] as Array<Complications.Type>;
            case FIELD_WEEKLY_DISTANCES:
                return [
                    Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE,
                    Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE,
                ] as Array<Complications.Type>;
            case FIELD_SOLAR:
            case FIELD_SOLAR_BATTERY:
                return [
                    Complications.COMPLICATION_TYPE_SOLAR_INPUT,
                ] as Array<Complications.Type>;
            case FIELD_SLEEP:
            case FIELD_SLEEP_RECOVERY:
                return [
                    Complications.COMPLICATION_TYPE_SLEEP_SCORE,
                ] as Array<Complications.Type>;
            case FIELD_TRAINING_STATUS:
            case FIELD_VO2_TRAINING:
                return [
                    Complications.COMPLICATION_TYPE_TRAINING_STATUS,
                ] as Array<Complications.Type>;
            case FIELD_SUNRISE:
                return [
                    Complications.COMPLICATION_TYPE_SUNRISE,
                ] as Array<Complications.Type>;
            case FIELD_SUNSET:
                return [
                    Complications.COMPLICATION_TYPE_SUNSET,
                ] as Array<Complications.Type>;
            case FIELD_SUNRISE_SUNSET:
                return [
                    Complications.COMPLICATION_TYPE_SUNRISE,
                    Complications.COMPLICATION_TYPE_SUNSET,
                ] as Array<Complications.Type>;
            case FIELD_CALENDAR:
                return [
                    Complications.COMPLICATION_TYPE_CALENDAR_EVENTS,
                ] as Array<Complications.Type>;
            case FIELD_NOTIFICATIONS:
                return [
                    Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT,
                ] as Array<Complications.Type>;
            case FIELD_RACE_5K:
                return [
                    Complications.COMPLICATION_TYPE_RACE_PREDICTOR_5K,
                ] as Array<Complications.Type>;
            case FIELD_RACE_10K:
                return [
                    Complications.COMPLICATION_TYPE_RACE_PREDICTOR_10K,
                ] as Array<Complications.Type>;
            case FIELD_RACE_HALF:
                return [
                    Complications.COMPLICATION_TYPE_RACE_PREDICTOR_HALF_MARATHON,
                ] as Array<Complications.Type>;
            case FIELD_RACE_MARATHON:
                return [
                    Complications.COMPLICATION_TYPE_RACE_PREDICTOR_MARATHON,
                ] as Array<Complications.Type>;
            case FIELD_RACE_PACE_5K:
                return [
                    Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_5K,
                ] as Array<Complications.Type>;
            case FIELD_RACE_PACE_10K:
                return [
                    Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_10K,
                ] as Array<Complications.Type>;
            case FIELD_RACE_PACE_HALF:
                return [
                    Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_HALF_MARATHON,
                ] as Array<Complications.Type>;
            case FIELD_RACE_PACE_MARATHON:
                return [
                    Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_MARATHON,
                ] as Array<Complications.Type>;
            case FIELD_WX_SEA_PRESS:
                return [
                    Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE,
                ] as Array<Complications.Type>;
            case FIELD_WX_COND_FCST_1D:
            case FIELD_WX_FCST_COND_1D:
                return [
                    Complications.COMPLICATION_TYPE_FORECAST_WEATHER_1DAY,
                ] as Array<Complications.Type>;
            case FIELD_WX_FCST_COND_12D:
                return [
                    Complications.COMPLICATION_TYPE_FORECAST_WEATHER_1DAY,
                    Complications.COMPLICATION_TYPE_FORECAST_WEATHER_2DAY,
                ] as Array<Complications.Type>;
            case FIELD_WX_FCST_COND_2D:
                return [
                    Complications.COMPLICATION_TYPE_FORECAST_WEATHER_2DAY,
                ] as Array<Complications.Type>;
            case FIELD_WX_FCST_COND_3D:
                return [
                    Complications.COMPLICATION_TYPE_FORECAST_WEATHER_3DAY,
                ] as Array<Complications.Type>;
            default:
                return null;
        }
    }
}
