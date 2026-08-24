import UIKit
import UserNotifications

final class SuccessNotificationView: UIView, NotificationViewType {

    @IBOutlet weak var iconView:      UIImageView!
    @IBOutlet weak var titleLabel:    UILabel!
    @IBOutlet weak var bodyLabel:     UILabel!
    @IBOutlet weak var expandButton:  UIButton!
    @IBOutlet weak var okButton:      UIButton!

    var onDismiss:     (() -> Void)?
    var onSizeChanged: (() -> Void)?
    var onOpen:        (() -> Void)?

    private var isExpanded = false

    static func fromXib() -> SuccessNotificationView {
        let nib = UINib(nibName: "SuccessNotificationView", bundle: Bundle(for: SuccessNotificationView.self))
        return nib.instantiate(withOwner: nil, options: nil).first as! SuccessNotificationView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlass()
    }

    func apply(notification: UNNotification) {
        let c = notification.request.content
        titleLabel.text = c.title.isEmpty ? "Thành công" : c.title
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

    @IBAction func didTapOK(_ sender: Any) { onDismiss?() }

    // MARK: - Liquid Glass
    private func applyLiquidGlass() {
        let tint = NotifColor.green
        LiquidGlass.applyBackground(to: self, tint: tint)
        LiquidGlass.styleIcon(iconView, name: "checkmark.circle.fill", tint: tint, pointSize: 40)
        LiquidGlass.styleButton(okButton, tint: tint)

        titleLabel.textColor   = .label
        titleLabel.font        = .systemFont(ofSize: 15, weight: .semibold)
        bodyLabel.textColor    = .secondaryLabel
        bodyLabel.font         = .systemFont(ofSize: 13, weight: .regular)

        expandButton.setTitleColor(tint, for: .normal)
        expandButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        expandButton.isHidden = true
    }
}
