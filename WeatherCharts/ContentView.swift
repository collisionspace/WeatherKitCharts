//
//  ContentView.swift
//  WeatherCharts
//
//  Created by Daniel Slone on 8/6/2022.
//

import SwiftUI
import WeatherKit
import CoreLocation
import Charts

struct ContentView: View {
    @ObservedObject var fetcher = WeatherFetcher()

    var body: some View {
        VStack {
            Text("Melbourne daily temps")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            Chart(fetcher.dailyTemperatures) { daily in
                RuleMark(
                    x: .value("Day", daily.day),
                    yStart: .value("High temperature", daily.max),
                    yEnd: .value("Low temperature", daily.min)
                )
                .foregroundStyle(.black)

                PointMark(
                    x: .value("Day", daily.day),
                    y: .value("Low temperature", daily.min)
                )
                .foregroundStyle(by: .value("Low", daily.min))

                PointMark(
                    x: .value("Day", daily.day),
                    y: .value("High temperature", daily.max)
                )
                .foregroundStyle(by: .value("High", daily.max))
            }
        }
        .padding(.all, 32)
        .task {
            await fetcher.fetchDaily()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h a"
    return formatter
}()

struct DailyTemperature: Identifiable {
    let day: Date
    let min: Double
    let max: Double

    var id: String { UUID().uuidString }
}

class WeatherFetcher: ObservableObject {
    @Published var dailyTemperatures: [DailyTemperature] = []

    func fetchDaily() async {
        let weatherService = WeatherService()
        let melbourne = CLLocation(latitude: -37.815018, longitude: 144.946014)

        let weather = try! await weatherService.weather(for: melbourne)
        
        let dailyForecasts = weather.dailyForecast.forecast

        let dailyTemperatures = Array(dailyForecasts.prefix(5)).map {
            DailyTemperature(
                day: $0.date,
                min: $0.lowTemperature.value,
                max: $0.highTemperature.value
            )
        }

        DispatchQueue.main.async {
            self.dailyTemperatures = dailyTemperatures
        }
    }
}
