//
//  DailyTemperature.swift
//  WeatherCharts
//
//  Created by Daniel Slone on 8/6/2022.
//

import Foundation

struct DailyTemperature: Identifiable {
    let day: Date
    let min: Double
    let max: Double
    let id: String
}

extension Array where Element == DailyTemperature {
    func temperatureRange() -> ClosedRange<Int> {
        let min = map(\.min).min() ?? .zero
        let max = map(\.max).max() ?? .zero

        // As we want to have a whole double scale, we will round the min down 4.6 -> 4
        // and round the max up 15.4 -> 16
        return Int(min.rounded(.down))...Int(max.rounded(.up))
    }
}
