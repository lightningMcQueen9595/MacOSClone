import SwiftUI

struct WeatherAppView: View {
    @State private var selectedCity = 0
    @State private var animateIcon = false

    let cities: [WeatherData] = [
        WeatherData(city: "San Francisco", temp: 62, condition: "Partly Cloudy", icon: "cloud.sun.fill",
                    high: 68, low: 54, humidity: 72, wind: 12,
                    hourly: [59, 60, 62, 64, 65, 66, 65, 63, 60, 58],
                    daily: [
                        DailyForecast(day: "Mon", icon: "sun.max.fill",       high: 68, low: 54),
                        DailyForecast(day: "Tue", icon: "cloud.sun.fill",     high: 66, low: 52),
                        DailyForecast(day: "Wed", icon: "cloud.rain.fill",    high: 60, low: 50),
                        DailyForecast(day: "Thu", icon: "cloud.drizzle.fill", high: 61, low: 51),
                        DailyForecast(day: "Fri", icon: "sun.max.fill",       high: 70, low: 55)
                    ]),
        WeatherData(city: "New York", temp: 45, condition: "Snowy", icon: "cloud.snow.fill",
                    high: 48, low: 38, humidity: 85, wind: 18,
                    hourly: [40, 42, 44, 45, 47, 46, 44, 43, 41, 39],
                    daily: [
                        DailyForecast(day: "Mon", icon: "cloud.snow.fill",    high: 48, low: 38),
                        DailyForecast(day: "Tue", icon: "cloud.fill",         high: 50, low: 40),
                        DailyForecast(day: "Wed", icon: "cloud.sun.fill",     high: 52, low: 41),
                        DailyForecast(day: "Thu", icon: "sun.max.fill",       high: 55, low: 43),
                        DailyForecast(day: "Fri", icon: "sun.max.fill",       high: 58, low: 45)
                    ]),
        WeatherData(city: "Miami", temp: 84, condition: "Sunny", icon: "sun.max.fill",
                    high: 88, low: 76, humidity: 80, wind: 8,
                    hourly: [78, 80, 83, 84, 87, 88, 86, 84, 81, 79],
                    daily: [
                        DailyForecast(day: "Mon", icon: "sun.max.fill",    high: 88, low: 76),
                        DailyForecast(day: "Tue", icon: "sun.max.fill",    high: 89, low: 77),
                        DailyForecast(day: "Wed", icon: "cloud.sun.fill",  high: 85, low: 75),
                        DailyForecast(day: "Thu", icon: "cloud.rain.fill", high: 80, low: 73),
                        DailyForecast(day: "Fri", icon: "sun.max.fill",    high: 87, low: 76)
                    ])
    ]

    var city: WeatherData { cities[selectedCity] }

    var bgGradient: LinearGradient {
        switch city.condition {
        case "Sunny":
            return LinearGradient(colors: [Color(red: 0.98, green: 0.72, blue: 0.22), Color(red: 0.98, green: 0.55, blue: 0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Snowy":
            return LinearGradient(colors: [Color(red: 0.6, green: 0.75, blue: 0.95), Color(red: 0.4, green: 0.58, blue: 0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color(red: 0.35, green: 0.55, blue: 0.80), Color(red: 0.20, green: 0.40, blue: 0.68)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var body: some View {
        ZStack {
            bgGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // City Picker
                    Picker("City", selection: $selectedCity) {
                        ForEach(cities.indices, id: \.self) { i in
                            Text(cities[i].city).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(12)

                    // Main weather card
                    VStack(spacing: 4) {
                        Text(city.city)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                        Image(systemName: city.icon)
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 72))
                            .shadow(radius: 8)
                            .scaleEffect(animateIcon ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
                            .padding(.vertical, 8)
                        Text("\(city.temp)°")
                            .font(.system(size: 64, weight: .thin))
                            .foregroundStyle(.white)
                        Text(city.condition)
                            .font(.system(size: 17))
                            .foregroundStyle(.white.opacity(0.85))
                        Text("H:\(city.high)°  L:\(city.low)°")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .padding(.bottom, 16)

                    // Hourly Forecast
                    WeatherCard {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                let hours = ["Now", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM"]
                                ForEach(city.hourly.indices, id: \.self) { i in
                                    VStack(spacing: 6) {
                                        Text(hours[i])
                                            .font(.caption2)
                                            .foregroundStyle(.white.opacity(0.7))
                                        Image(systemName: city.icon)
                                            .symbolRenderingMode(.multicolor)
                                            .font(.system(size: 18))
                                        Text("\(city.hourly[i])°")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }

                    // 5-Day Forecast
                    WeatherCard {
                        VStack(spacing: 0) {
                            ForEach(city.daily) { day in
                                HStack {
                                    Text(day.day)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white)
                                        .frame(width: 40, alignment: .leading)
                                    Image(systemName: day.icon)
                                        .symbolRenderingMode(.multicolor)
                                        .font(.system(size: 18))
                                    Spacer()
                                    Text("\(day.low)°")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.6))
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(LinearGradient(colors: [.blue.opacity(0.5), .orange.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: 60, height: 4)
                                    Text("\(day.high)°")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white)
                                }
                                .padding(.vertical, 8)
                                if day.id != city.daily.last?.id {
                                    Divider().background(.white.opacity(0.2))
                                }
                            }
                        }
                    }

                    // Humidity & Wind
                    HStack(spacing: 8) {
                        WeatherStatCard(icon: "drop.fill", label: "Humidity", value: "\(city.humidity)%")
                        WeatherStatCard(icon: "wind",      label: "Wind",     value: "\(city.wind) mph")
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 8)
            }
        }
        .onAppear { animateIcon = true }
    }
}

struct WeatherCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding(12)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.bottom, 8)
    }
}

struct WeatherStatCard: View {
    let icon: String
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct WeatherData {
    let city: String
    let temp: Int
    let condition: String
    let icon: String
    let high: Int
    let low: Int
    let humidity: Int
    let wind: Int
    let hourly: [Int]
    let daily: [DailyForecast]
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let day: String
    let icon: String
    let high: Int
    let low: Int
}
