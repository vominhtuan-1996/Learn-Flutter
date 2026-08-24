import UIKit
import UserNotifications

final class PromoNotificationView: UIView, NotificationViewType {

    @IBOutlet weak var titleLabel:    UILabel!
    @IBOutlet weak var bodyLabel:     UILabel!
    @IBOutlet weak var expandButton:  UIButton!
    @IBOutlet weak var ctaButton:     UIButton!
    @IBOutlet weak var headerView:    UIView!

    var onOpen:        (() -> Void)?
    var onDismiss:     (() -> Void)?
    var onSizeChanged: (() -> Void)?

    private var isExpanded    = false
    private var headerGradient: CAGradientLayer?

    static func fromXib() -> PromoNotificationView {
        let nib = UINib(nibName: "PromoNotificationView", bundle: Bundle(for: PromoNotificationView.self))
        return nib.instantiate(withOwner: nil, options: nil).first as! PromoNotificationView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlass()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        headerGradient?.frame = headerView.bounds
    }

    func apply(notification: UNNotification) {
        let c = notification.request.content
        titleLabel.text = c.title.isEmpty ? "Khuyến mãi" : c.title
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

    @IBAction func didTapCTA(_ sender: Any) { onOpen?() }

    // MARK: - Liquid Glass
    private func applyLiquidGlass() {
        let tint = NotifColor.indigo
        LiquidGlass.applyBackground(to: self, tint: tint)

        // Glass gradient header — indigo → purple
        headerGradient = LiquidGlass.applyGlassHeader(
            to: headerView,
            colors: [NotifColor.indigo, NotifColor.purple]
        )

        LiquidGlass.styleButton(ctaButton, tint: tint)

        titleLabel.textColor   = .white
        titleLabel.font        = .systemFont(ofSize: 16, weight: .bold)
        bodyLabel.textColor    = .label
        bodyLabel.font         = .systemFont(ofSize: 13, weight: .regular)

        // Badge label — keep white pill style (found via tag or subview traversal)
        if let badge = headerView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            badge.layer.cornerRadius = 4
            badge.layer.cornerCurve = .continuous
            badge.clipsToBounds = true
            badge.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            badge.textColor = .white
            badge.layer.borderWidth = 0.5
            badge.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        }

        expandButton.setTitleColor(tint, for: .normal)
        expandButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        expandButton.isHidden = true
    }
}
