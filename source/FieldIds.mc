// GENERATED FILE - DO NOT EDIT.
// Run `python scripts/generate_resources.py` to regenerate from
// FIELD_CATEGORIES in scripts/generate_resources.py.

// Graph cache key bit layout, used by _packGraphKey/_graphKeyHi/
// _graphKeyLo. The high slot and low slot each get 10 bits (0-1023),
// periodMin gets the low 11 bits (0-2047). Field IDs currently span 1-650.
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
