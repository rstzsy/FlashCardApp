import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
    let date: Date
    let streakDays: Int
    let completedDays: [String]
}

struct StreakProvider: TimelineProvider {
    let appGroupId = "group.com.mofu.flashcardApp"

    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streakDays: 7, completedDays: ["Mon", "Tue", "Wed"])
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func loadEntry() -> StreakEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let streak = defaults?.integer(forKey: "streak_days") ?? 0
        let daysStr = defaults?.string(forKey: "completed_days") ?? ""
        let days = daysStr.isEmpty ? [] : daysStr.split(separator: ",").map { String($0) }
        return StreakEntry(date: Date(), streakDays: streak, completedDays: days)
    }
}

struct ConfettiDot: Identifiable {
    let id = Int.random(in: 0...999999)
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
    let rotation: Double
}

struct FlashcardWidgetView: View {
    var entry: StreakEntry
    static let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    static let confetti: [ConfettiDot] = [
        ConfettiDot(x: 0.06, y: 0.15, size: 6, color: Color(red: 1, green: 0.42, blue: 0.42), rotation: 20),
        ConfettiDot(x: 0.14, y: 0.55, size: 5, color: Color(red: 1, green: 0.85, blue: 0.24), rotation: 60),
        ConfettiDot(x: 0.92, y: 0.20, size: 6, color: Color(red: 0.30, green: 0.80, blue: 0.47), rotation: -15),
        ConfettiDot(x: 0.88, y: 0.65, size: 5, color: Color(red: 0.30, green: 0.59, blue: 1.0), rotation: 40),
        ConfettiDot(x: 0.04, y: 0.80, size: 5, color: Color(red: 1, green: 0.57, blue: 0.19), rotation: -30),
        ConfettiDot(x: 0.95, y: 0.85, size: 6, color: Color(red: 0.64, green: 0.61, blue: 1.0), rotation: 10),
    ]

    var body: some View {
        ZStack {
            ForEach(Self.confetti) { dot in
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(dot.color)
                        .frame(width: dot.size, height: dot.size * 0.5)
                        .rotationEffect(.degrees(dot.rotation))
                        .position(x: geo.size.width * dot.x, y: geo.size.height * dot.y)
                }
            }

            VStack(spacing: 6) {
                Image("MascotHappy")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)

                HStack(spacing: 4) {
                    Text("You're on a")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black.opacity(0.85))

                    Text("\(entry.streakDays)")
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color(red: 0xF5/255, green: 0xA6/255, blue: 0x23/255))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("day streak!")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black.opacity(0.85))
                }

                HStack(spacing: 7) {
                    ForEach(Self.weekDays, id: \.self) { day in
                        VStack(spacing: 2) {
                            Circle()
                                .fill(entry.completedDays.contains(day)
                                      ? Color(red: 0x1E/255, green: 0x88/255, blue: 0xE5/255)
                                      : Color.white.opacity(0.5))
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(entry.completedDays.contains(day) ? 0 : 0.6), lineWidth: 1)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(entry.completedDays.contains(day) ? .white : .white.opacity(0.5))
                                )
                            Text(day)
                                .font(.system(size: 7, weight: .semibold))
                                .foregroundColor(.black.opacity(0.55))
                        }
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(red: 0xBD/255, green: 0xE8/255, blue: 0xF5/255)
        }
    }
}

struct FlashcardWidget: Widget {
    let kind: String = "FlashcardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            FlashcardWidgetView(entry: entry)
        }
        .configurationDisplayName("Study Streak")
        .description("Xem streak học tập của bạn ngay trên màn hình chính.")
        .supportedFamilies([.systemMedium])
    }
}
