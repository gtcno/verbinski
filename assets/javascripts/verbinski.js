
console.log("Verbinski (the weather widget) has been loaded!");

function getIcon(iconKey) {
  var prefix = "/assets/climacons/svg/";
  var ext = ".svg";

  if (!iconKey) {
    return prefix + "Cloud-Refresh" + ext;
  }

  var key = iconKey.replace(/-/g, "_");
  var iconMap = {
    clear_day: "Sun",
    clear_night: "Moon",
    rain: "Cloud-Rain",
    snow: "Snowflake",
    sleet: "Cloud-Hail",
    wind: "Wind",
    fog: "Cloud-Fog-Alt",
    cloudy: "Cloud",
    partly_cloudy_day: "Cloud-Sun",
    partly_cloudy_night: "Cloud-Moon"
  }
  var fullPath = prefix + iconMap[key] + ext;
  return fullPath;
}

