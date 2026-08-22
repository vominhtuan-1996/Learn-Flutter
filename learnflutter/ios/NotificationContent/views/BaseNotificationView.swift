import UIKit
import UserNotifications

/// Protocol chung cho tất cả notification view types.
protocol NotificationViewType: UIView {
    func apply(notification: UNNotification)
    /// Callback để ViewController update preferredContentSize sau khi expand/collapse
    var onSizeChanged: (() -> Void)? { get set }
}

/// Màu sắc dùng chung
enum NotifColor {
    static let indigo   = UIColor(red: 0.388, green: 0.400, blue: 0.945, alpha: 1) // #6366F1
    static let green    = UIColor(red: 0.133, green: 0.545, blue: 0.133, alpha: 1) // #22A722
    static let orange   = UIColor(red: 0.914, green: 0.353, blue: 0.047, alpha: 1) // #EA580C
    static let red      = UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1) // #EF4444
    static let gray     = UIColor(red: 0.427, green: 0.451, blue: 0.502, alpha: 1) // #6B7280
    static let text     = UIColor(red: 0.067, green: 0.094, blue: 0.153, alpha: 1) // #111827
    static let subtext  = UIColor(red: 0.427, green: 0.451, blue: 0.502, alpha: 1) // #6B7280
    static let border   = UIColor(red: 0.898, green: 0.910, blue: 0.922, alpha: 1) // #E5E7EB
    static let bg       = UIColor(red: 0.976, green: 0.980, blue: 0.992, alpha: 1) // #F9FAFB
}

/// Helper tạo label nhanh
func makeLabel(size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = NotifColor.text, lines: Int = 1) -> UILabel {
    let l = UILabel()
    l.font = .systemFont(ofSize: size, weight: weight)
    l.textColor = color
    l.numberOfLines = lines
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
}

/// Helper tạo button nhanh
func makeBtn(title: String, bg: UIColor, fg: UIColor) -> UIButton {
    let btn = UIButton(type: .system)
    btn.setTitle(title, for: .normal)
    btn.backgroundColor = bg
    btn.setTitleColor(fg, for: .normal)
    btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
    btn.layer.cornerRadius = 6
    btn.clipsToBounds = true
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
}

/// Format time từ notification
func notifTime(_ notification: UNNotification) -> String {
    let fmt = DateFormatter()
    fmt.dateFormat = "HH:mm"
    return fmt.string(from: notification.date)
}

/// Tạo horizontal stack nhanh
func hstack(_ views: [UIView], spacing: CGFloat = 8) -> UIStackView {
    let s = UIStackView(arrangedSubviews: views)
    s.axis = .horizontal
    s.spacing = spacing
    s.distribution = .fillEqually
    s.translatesAutoresizingMaskIntoConstraints = false
    return s
}
