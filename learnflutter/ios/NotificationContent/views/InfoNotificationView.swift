import UIKit
import UserNotifications

final class InfoNotificationView: UIView, NotificationViewType {

    // MARK: - IBOutlets
    @IBOutlet weak var iconView:      UIImageView!
    @IBOutlet weak var titleLabel:    UILabel!
    @IBOutlet weak var timeLabel:     UILabel!
    @IBOutlet weak var bodyLabel:     UILabel!
    @IBOutlet weak var expandButton:  UIButton!
    @IBOutlet weak var openButton:    UIButton!
    @IBOutlet weak var skipButton:    UIButton!

    // MARK: - NotificationViewType
    var onOpen:        (() -> Void)?
    var onDismiss:     (() -> Void)?
    var onSizeChanged: (() -> Void)?

    private var isExpanded = false

    // MARK: - Load
    static func fromXib() -> InfoNotificationView {
        let nib = UINib(nibName: "InfoNotificationView", bundle: Bundle(for: InfoNotificationView.self))
        return nib.instantiate(withOwner: nil, options: nil).first as! InfoNotificationView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlass()
    }

    // MARK: - NotificationViewType
    func apply(notification: UNNotification) {
        let c = notification.request.content
        titleLabel.text = c.title.isEmpty ? "Thông báo" : c.title
        bodyLabel.text  = c.body
        timeLabel.text  = notifTime(notification)

        layoutIfNeeded()
        let needsExpand = bodyLabel.intrinsicContentSize.height > bodyLabel.font.lineHeight * 2 + 4
        expandButton.isHidden = !needsExpand
    }

    // MARK: - IBActions
    @IBAction func toggleExpand(_ sender: Any) {
        isExpanded.toggle()
        bodyLabel.numberOfLines = isExpanded ? 0 : 2
        expandButton.setTitle(isExpanded ? "Thu gọn ▴" : "Xem thêm ▾", for: .normal)
        onSizeChanged?()
    }

    @IBAction func didTapOpen(_ sender: Any) { onOpen?() }
    @IBAction func didTapSkip(_ sender: Any) { onDismiss?() }

    // MARK: - Liquid Glass
    private func applyLiquidGlass() {
        let tint = NotifColor.indigo
        LiquidGlass.applyBackground(to: self, tint: tint)
        LiquidGlass.styleIcon(iconView, name: "bell.circle.fill", tint: tint, pointSize: 26)
        LiquidGlass.styleButton(openButton, tint: tint)
        LiquidGlass.styleButton(skipButton, tint: tint, secondary: true)

        titleLabel.textColor    = .label
        titleLabel.font         = .systemFont(ofSize: 14, weight: .semibold)
        bodyLabel.textColor     = .secondaryLabel
        bodyLabel.font          = .systemFont(ofSize: 13, weight: .regular)
        timeLabel.textColor     = .tertiaryLabel
        timeLabel.font          = .systemFont(ofSize: 11, weight: .regular)

        expandButton.setTitleColor(tint, for: .normal)
        expandButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        expandButton.isHidden = true
    }
}
