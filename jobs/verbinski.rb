require 'date'
require 'net/https'
require 'json'

# Forecast API Key from https://developer.forecast.io
forecast_api_key = ""

# Latitude, Longitude for location
forecast_location_lat = ""
forecast_location_long = ""

# Unit Format
forecast_units = "ca" # like "si", except windSpeed is in kph

def time_to_str(time_obj)
  """ format: 5 pm """
  return Time.at(time_obj).strftime "%-l %P"
end

def time_to_str_minutes(time_obj)
  """ format: 5:38 pm """
  return Time.at(time_obj).strftime "%-l:%M %P"
end
  
def day_to_str(time_obj)
  """ format: Sun, Jan 9 """
  return Time.at(time_obj).strftime "%b %-e (%a)"
end
  
SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.forecast.io", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"))
  forecast = JSON.parse(response.body)  

  # current
  currently = forecast["currently"]
  currently_temp = currently["temperature"].round
  currently_summary = currently["summary"]
  currently_humidity_raw = currently["humidity"] * 100
  currently_humidity = currently_humidity_raw.round
  currently_wind_speed = currently["windSpeed"].round
  currently_wind_speed != 0 ? currently_wind_bearing = currently["windBearing"] : currently_wind_bearing = 0
  currently_icon = currently["icon"]

  # today
  today = forecast["daily"]["data"][0]
  next_24_hours = forecast["hourly"]["summary"]
  daily_high = today["temperatureMax"].round
  daily_high_time = time_to_str(today["temperatureMaxTime"])
  daily_low = today["temperatureMin"].round
  daily_low_time = time_to_str(today["temperatureMinTime"])
  daily_sunrise_time = time_to_str_minutes(today["sunriseTime"])
  daily_sunset_time = time_to_str_minutes(today["sunsetTime"])
  daily_icon = today["icon"]

  this_week = []
  for day in (1..7) 
    day = forecast["daily"]["data"][day]
    this_day = {
      max_temp: day["temperatureMax"].round,
      min_temp: day["temperatureMin"].round,
      time: day_to_str(day["time"]),
      icon: day["icon"]
    }
    this_week.push(this_day)
  end

  send_event('verbinski', { 
    currently_temp: currently_temp, 
    currently_summary: "#{currently_summary}",
    currently_humidity: "#{currently_humidity}&#37;",
    currently_wind_speed: "#{currently_wind_speed}",
    currently_wind_bearing: "#{currently_wind_bearing}",
    currently_icon: "#{currently_icon}",
    daily_summary: "#{next_24_hours}",
    daily_high: daily_high,
    daily_high_time: "#{daily_high_time}",
    daily_low: daily_low,
    daily_low_time: "#{daily_low_time}",
    daily_sunrise_time: "#{daily_sunrise_time}",
    daily_sunset_time: "#{daily_sunset_time}",
    daily_icon: "#{daily_icon}",
    upcoming_week: this_week,
  })
end
