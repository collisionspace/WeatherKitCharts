//
//  WeatherFetcher.swift
//  WeatherCharts
//
//  Created by Daniel Slone on 8/6/2022.
//

import Foundation
import WeatherKit
import CoreLocation

final class WeatherFetcher: ObservableObject {
    @Published var dailyTemperatures: [DailyTemperature] = []

    init(dailyTemperatures: [DailyTemperature] = []) {
        self.dailyTemperatures = dailyTemperatures
    }

    func fetchDaily() async {
        // Stops previews from fetching live weather data
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        let weatherService = WeatherService()
        let melbourne = CLLocation(latitude: -37.815018, longitude: 144.946014)

        let weather = try! await weatherService.weather(for: melbourne)
        
        let dailyForecasts = weather.dailyForecast.forecast

        let dailyTemperatures = Array(dailyForecasts.prefix(5)).map {
            DailyTemperature(
                day: $0.date,
                min: $0.lowTemperature.value,
                max: $0.highTemperature.value,
                id: UUID().uuidString
            )
        }

        DispatchQueue.main.async {
            self.dailyTemperatures = dailyTemperatures
        }
    }
}
