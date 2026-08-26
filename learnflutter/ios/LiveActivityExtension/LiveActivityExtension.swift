import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen View

struct LiveActivityLockScreenView: View {
    let attributes: LiveActivityAttributes
    let state: LiveActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bicycle.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(attributes.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(attributes.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(state.eta)
                        .font(.headline)
                        .foregroundStyle(.blue)
                    Text("còn lại")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: state.progress)
                .tint(.blue)
                .scaleEffect(x: 1, y: 1.5)

            Text(state.status)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

// MARK: - Widget Configuration

struct LiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            // Lock Screen / Notification banner
            LiveActivityLockScreenView(
                attributes: context.attributes,
                state: context.state
            )
            .activityBackgroundTint(Color(.systemBackground))

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded — user taps Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "bicycle.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.eta)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        ProgressView(value: context.state.progress)
                            .tint(.blue)
                        Text(context.state.status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Image(systemName: "bicycle.circle.fill")
                    .foregroundStyle(.blue)
            } compactTrailing: {
                Text(context.state.eta)
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.blue)
            } minimal: {
                Image(systemName: "bicycle.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
    }
}
