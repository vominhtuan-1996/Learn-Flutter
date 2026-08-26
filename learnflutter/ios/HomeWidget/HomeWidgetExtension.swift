import WidgetKit
import SwiftUI

// MARK: - Data Model

struct StatItem: Codable, Identifiable {
    var id: String { label }
    let label: String
    let value: String
}

struct WidgetData {
    let userName: String
    let balance: String
    let stats: [StatItem]
    let lastUpdated: String

    static let placeholder = WidgetData(
        userName: "Nguyễn Văn A",
        balance: "1,234,567 ₫",
        stats: [
            StatItem(label: "Đơn hàng", value: "12"),
            StatItem(label: "Điểm thưởng", value: "850"),
            StatItem(label: "Voucher", value: "3"),
            StatItem(label: "Thông báo", value: "5"),
        ],
        lastUpdated: "25/08/2026 14:30"
    )
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    private let appGroupId = "group.com.fpt.isc.prod.HomeWidget"

    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: .now, data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(WidgetEntry(date: .now, data: load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = WidgetEntry(date: .now, data: load())
        // Fallback refresh mỗi 15 phút; Flutter app trigger ngay khi có data mới
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func load() -> WidgetData {
        let d = UserDefaults(suiteName: appGroupId)
        let userName    = d?.string(forKey: "user_name")    ?? "—"
        let balance     = d?.string(forKey: "balance")      ?? "—"
        let lastUpdated = d?.string(forKey: "last_updated") ?? "—"

        var stats: [StatItem] = []
        if let raw = d?.string(forKey: "stats"),
           let data = raw.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([StatItem].self, from: data) {
            stats = decoded
        }
        return WidgetData(userName: userName, balance: balance, stats: stats, lastUpdated: lastUpdated)
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Views

struct AvatarView: View {
    let initial: String
    var body: some View {
        Circle()
            .fill(LinearGradient(
                colors: [Color(hex: "4F8EF7"), Color(hex: "1A5FD4")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
            .frame(width: 42, height: 42)
            .overlay(
                Text(initial)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}

struct StatCardView: View {
    let item: StatItem
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(item.label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.secondary.opacity(0.12))
        .cornerRadius(12)
    }
}

struct HomeWidgetEntryView: View {
    let entry: WidgetEntry

    private var initial: String {
        String(entry.data.userName.unicodeScalars.first.map(Character.init) ?? "-")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                AvatarView(initial: initial)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.data.userName)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                    Text("Tài khoản")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)

            // Balance
            Text(entry.data.balance)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.horizontal, 18)
                .padding(.top, 8)

            Text("Số dư khả dụng")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .padding(.horizontal, 18)
                .padding(.top, 2)

            Divider()
                .padding(.horizontal, 18)
                .padding(.vertical, 12)

            // Stats Grid
            if !entry.data.stats.isEmpty {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(entry.data.stats) { stat in
                        StatCardView(item: stat)
                    }
                }
                .padding(.horizontal, 18)
            }

            Spacer()

            // Footer
            Text("Cập nhật: \(entry.data.lastUpdated)")
                .font(.system(size: 10))
                .foregroundColor(Color.secondary.opacity(0.6))
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
        }
        .background(Color.primary.colorInvert())
    }
}

// MARK: - Widget Entry Point

struct HomeWidget: Widget {
    let kind = "HomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HomeWidgetEntryView(entry: entry)
                .modifier(WidgetBackgroundModifier())
        }
        .configurationDisplayName("Tổng quan")
        .description("Xem số dư và thống kê tài khoản.")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Backward Compat

struct WidgetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(.background, for: .widget)
        } else {
            content
        }
    }
}

// MARK: - Helpers

extension Color {
    init(hex: String) {
        let v = Int(hex, radix: 16) ?? 0
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8) & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    HomeWidget()
} timeline: {
    WidgetEntry(date: .now, data: .placeholder)
}
