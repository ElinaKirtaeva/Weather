//
//  CurrentWeather.swift
//  Weather
//
//  Created by Элина Рупова on 04.02.2022.
//

import Foundation

struct CurrentWeather {
    let cityname: String
    let temperature: Double
    var temperatureString: String {
        return String(format: "%.0f", temperature) + "˚C"
    }
    let feelsLike: Double
    var feelsLikeString: String { 
        return "Feels like \(String(format: "%.0f", feelsLike)) ˚C"
    }
    let conditionCode: Int
    
    var iconNameString: String {
        switch conditionCode {
        case 200...232: return "thunder"
        case 300...321: return "rain" //small rain
        case 500...521: return "rain"
        case 600...622: return "snow"
        case 701...781: return "cloud" //mist
        case 800:
            if backgroundNameString == "night" {
                return "moon"
            } else {
                return "sun"
            }
        case 801...804: return "cloud"
        default:
            return "nosign"
        }
    }
    
    let dt: Int
    let timezone: Int
    var localDate: Date {
        let localTime = dt + timezone
        return Date(timeIntervalSince1970: TimeInterval(localTime))
    }
    var localHour: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return Int(dateFormatter.string(from: localDate)) ?? 0
    }
    
    var backgroundNameString: String {
        switch localHour {
        case 5...11: return "morning"
        case 12...16: return "day"
        case 17...23: return "evening"
        default:
            return "night"
        }
    }
    
    var timeOfDay: String {
        return "Good \(backgroundNameString)!"
    }
    let country: String

    init?(currentWeatherData: CurrentWeatherData) {
        cityname = currentWeatherData.name
        temperature = currentWeatherData.main.temp
        feelsLike = currentWeatherData.main.feelsLike
        conditionCode = currentWeatherData.weather.first!.id
        country = currentWeatherData.sys.country
        dt = currentWeatherData.dt
        timezone = currentWeatherData.timezone
    }
}
