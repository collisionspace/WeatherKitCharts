//
//  ContentView.swift
//  WeatherCharts
//
//  Created by Daniel Slone on 8/6/2022.
//

import SwiftUI
import Charts

struct ContentView: View {
    @ObservedObject var fetcher: WeatherFetcher

    init(fetcher: WeatherFetcher = WeatherFetcher()) {
        self.fetcher = fetcher
    }

    var body: some View {
        VStack {
            Text("Melbourne daily temps")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            Chart(fetcher.dailyTemperatures) { daily in
                // Can replace with BarMark, RuleMark, and AreaMark
                RuleMark(
                    x: .value("Day", daily.day, unit: .day),
                    yStart: .value("High temperature", daily.max),
                    yEnd: .value("Low temperature", daily.min)
                )
                .foregroundStyle(.gray)
                .lineStyle(StrokeStyle(lineWidth: 5))

                PointMark(
                    x: .value("Day", daily.day, unit: .day),
                    y: .value("Low temperature", daily.min)
                )
                .foregroundStyle(by: .value("Low", daily.min))

                PointMark(
                    x: .value("Day", daily.day, unit: .day),
                    y: .value("High temperature", daily.max)
                )
                .foregroundStyle(by: .value("High", daily.max))
            }
            .chartYScale(domain: fetcher.dailyTemperatures.temperatureRange())
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(.all, 16)
        .task {
            await fetcher.fetchDaily()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fetcher: WeatherFetcher(
            dailyTemperatures: [
                .init(day: .date(year: 2022, month: 5, day: 5), min: 5.6, max: 15.4, id: UUID().uuidString),
                .init(day: .date(year: 2022, month: 5, day: 6), min: 8, max: 12, id: UUID().uuidString),
                .init(day: .date(year: 2022, month: 5, day: 7), min: 7, max: 16.2, id: UUID().uuidString),
                .init(day: .date(year: 2022, month: 5, day: 8), min: 7.5, max: 11, id: UUID().uuidString),
                .init(day: .date(year: 2022, month: 5, day: 9), min: 9.35, max: 14.8, id: UUID().uuidString)
            ]
        ))
    }
}

private extension Date {
    static func date(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(
            from: DateComponents(year: year, month: month, day: day)
        ) ?? Date()
    }
}
