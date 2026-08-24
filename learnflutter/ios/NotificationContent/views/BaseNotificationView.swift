import UIKit
import UserNotifications

// MARK: - Protocol

protocol NotificationViewType: UIView {
    func apply(notification: UNNotification)
    var onSizeChanged: (() -> Void)? { get set }
}

// MARK: - Liquid Glass Palette

enum NotifColor {
    static let indigo  = UIColor(red: 0.388, green: 0.400, blue: 0.945, alpha: 1)
    static let green   = UIColor(red: 0.133, green: 0.545, blue: 0.133, alpha: 1)
    static let orange  = UIColor(red: 0.914, green: 0.353, blue: 0.047, alpha: 1)
    static let purple  = UIColor(red: 0.576, green: 0.322, blue: 0.871, alpha: 1)
    static let amber   = UIColor(red: 0.95,  green: 0.60,  blue: 0.10,  alpha: 1)
}

// MARK: - Liquid Glass Kit

enum LiquidGlass {

    /// Frosted glass background + subtle tint overlay. Inserts blur as first subview.
    static func applyBackground(to view: UIView, tint: UIColor) {
        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)

        let tintOverlay = UIView(frame: view.bounds)
        tintOverlay.backgroundColor = tint.withAlphaComponent(0.06)
        tintOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.contentView.addSubview(tintOverlay)
    }

    /// Pill-shaped glass button — primary (tinted) or secondary (neutral fill).
    static func styleButton(_ btn: UIButton, tint: UIColor, secondary: Bool = false) {
        btn.layer.cornerRadius = 14
        btn.layer.cornerCurve = .continuous
        btn.clipsToBounds = true

        if secondary {
            btn.backgroundColor = UIColor.secondarySystemFill
            btn.setTitleColor(.secondaryLabel, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
            btn.layer.borderWidth = 0.5
            btn.layer.borderColor = UIColor.separator.cgColor
        } else {
            btn.backgroundColor = tint.withAlphaComponent(0.13)
            btn.setTitleColor(tint, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            btn.layer.borderWidth = 0.5
            btn.layer.borderColor = tint.withAlphaComponent(0.40).cgColor
        }
    }

    /// SF Symbol with consistent size + tint. Uses hierarchical rendering on iOS 15+.
    static func styleIcon(_ iv: UIImageView, name: String, tint: UIColor, pointSize: CGFloat = 28) {
        if #available(iOS 15.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
                .applying(UIImage.SymbolConfiguration(hierarchicalColor: tint))
            iv.image = UIImage(systemName: name, withConfiguration: config)
        } else {
            iv.image = UIImage(systemName: name,
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium))
        }
        iv.tintColor = tint
    }

    /// Glass gradient header — replaces solid colored banner.
    /// Returns the CAGradientLayer so caller can update frame in layoutSubviews.
    @discardableResult
    static func applyGlassHeader(to view: UIView, colors: [UIColor]) -> CAGradientLayer {
        view.backgroundColor = .clear

        let grad = CAGradientLayer()
        grad.colors = colors.map { $0.withAlphaComponent(0.88).cgColor }
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)

        // Frosted sheen overlay — sits above gradient, below icon/label subviews
        let sheen = UIView(frame: view.bounds)
        sheen.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        sheen.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(sheen, at: 0)

        // Bottom highlight line
        let line = UIView(frame: CGRect(x: 0, y: view.bounds.height - 0.5,
                                        width: view.bounds.width, height: 0.5))
        line.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        line.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(line)

        return grad
    }
}

// MARK: - Shared Helpers

func notifTime(_ notification: UNNotification) -> String {
    let fmt = DateFormatter()
    fmt.dateFormat = "HH:mm"
    return fmt.string(from: notification.date)
}
