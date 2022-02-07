//
//  CurrentWeatherData.swift
//  Weather
//
//  Created by Элина Рупова on 04.02.2022.
//

import Foundation

struct CurrentWeatherData: Decodable {

        let weather: [Weather]
        let main: Main
        let sys: Sys
        let name: String
        let dt: Int
        let timezone: Int
}

// MARK: - Main
struct Main: Decodable {
    let temp, feelsLike: Double
    enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
        }
}

// MARK: - Sys
struct Sys: Decodable {
    let country: String
}

// MARK: - Weather
struct Weather: Decodable {
    
    let id: Int

}
