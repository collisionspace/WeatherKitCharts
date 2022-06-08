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
                    yStart: .value("Low temperature", daily.min),
                    yEnd: .value("High temperature", daily.max)
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
//            .chartYScale(range: .init(-2..<11))
            
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

struct HourlyTemperature: Identifiable {
    let temperature: Double
    let time: Date
    let hour: String

    var id: String { UUID().uuidString }
}

struct DailyTemperature: Identifiable {
    let day: Date
    let min: Double
    let max: Double

    var id: String { UUID().uuidString }
}

class WeatherFetcher: ObservableObject {

    @Published var temperatures: [HourlyTemperature] = []
    
    @Published var dailyTemperatures: [DailyTemperature] = []


    func fetchHourly() async {
        let weatherService = WeatherService()
        let melbourne = CLLocation(latitude: -37.815018, longitude: 144.946014)

        let weather = try! await weatherService.weather(for: melbourne)

        let currentWeather = weather.currentWeather
//        print(currentWeather)
        
        let daily = weather.dailyForecast
        print(daily.forecast)

        let hourlyTemp = Array(weather.hourlyForecast.prefix(5)).map {
            HourlyTemperature(
                temperature: $0.temperature.value,
                time: $0.date,
                hour: dateFormatter.string(from: $0.date))
        }
//        print(hourlyTemp)
        DispatchQueue.main.async {
            self.temperatures = hourlyTemp
        }
    }

    func fetchDaily() async {
        let weatherService = WeatherService()
        let melbourne = CLLocation(latitude: -37.815018, longitude: 144.946014)

        let weather = try! await weatherService.weather(for: melbourne)

//        let currentWeather = weather.currentWeather
//        print(currentWeather)
        
        let daily = weather.dailyForecast.forecast
        print(daily)

        let dailyTemp = Array(daily.prefix(5)).map {
            DailyTemperature(
                day: $0.date,
                min: $0.lowTemperature.value,
                max: $0.highTemperature.value
            )
        }
//        print(hourlyTemp)
        DispatchQueue.main.async {
            self.dailyTemperatures = dailyTemp
        }
    }
}
