import UIKit
import UserNotifications

final class WarningNotificationView: UIView, NotificationViewType {

    @IBOutlet weak var iconView:      UIImageView!
    @IBOutlet weak var titleLabel:    UILabel!
    @IBOutlet weak var bodyLabel:     UILabel!
    @IBOutlet weak var expandButton:  UIButton!
    @IBOutlet weak var viewButton:    UIButton!
    @IBOutlet weak var skipButton:    UIButton!
    @IBOutlet weak var headerBanner:  UIView!

    var onOpen:        (() -> Void)?
    var onDismiss:     (() -> Void)?
    var onSizeChanged: (() -> Void)?

    private var isExpanded    = false
    private var headerGradient: CAGradientLayer?

    static func fromXib() -> WarningNotificationView {
        let nib = UINib(nibName: "WarningNotificationView", bundle: Bundle(for: WarningNotificationView.self))
        return nib.instantiate(withOwner: nil, options: nil).first as! WarningNotificationView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlass()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let banner = headerBanner {
            headerGradient?.frame = banner.bounds
        }
    }

    func apply(notification: UNNotification) {
        let c = notification.request.content
        titleLabel.text = c.title.isEmpty ? "Cảnh báo" : c.title
        bodyLabel.text  = c.body
        layoutIfNeeded()
        let needsExpand = bodyLabel.intrinsicContentSize.height > bodyLabel.font.lineHeight * 2 + 4
        expandButton.isHidden = !needsExpand
    }

    @IBAction func toggleExpand(_ sender: Any) {
        isExpanded.toggle()
        bodyLabel.numberOfLines = isExpanded ? 0 : 2
        expandButton.setTitle(isExpanded ? "Thu gọn ▴" : "Xem thêm ▾", for: .normal)
        onSizeChanged?()
    }

    @IBAction func didTapView(_ sender: Any) { onOpen?() }
    @IBAction func didTapSkip(_ sender: Any)  { onDismiss?() }

    // MARK: - Liquid Glass
    private func applyLiquidGlass() {
        let tint = NotifColor.orange
        LiquidGlass.applyBackground(to: self, tint: tint)

        // Glass gradient header — replace solid orange banner
        if let banner = headerBanner {
            headerGradient = LiquidGlass.applyGlassHeader(
                to: banner,
                colors: [NotifColor.orange, NotifColor.amber]
            )
        }

        LiquidGlass.styleIcon(iconView, name: "exclamationmark.triangle.fill", tint: .white, pointSize: 20)
        iconView.tintColor = .white
        LiquidGlass.styleButton(viewButton, tint: tint)
        LiquidGlass.styleButton(skipButton, tint: tint, secondary: true)

        titleLabel.textColor   = .white
        titleLabel.font        = .systemFont(ofSize: 14, weight: .semibold)
        bodyLabel.textColor    = .label
        bodyLabel.font         = .systemFont(ofSize: 13, weight: .regular)

        expandButton.setTitleColor(tint, for: .normal)
        expandButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        expandButton.isHidden = true
    }
}
