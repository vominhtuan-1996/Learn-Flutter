import UIKit
import UserNotifications

final class PromoNotificationView: UIView, NotificationViewType {

    @IBOutlet weak var titleLabel:   UILabel!
    @IBOutlet weak var bodyLabel:    UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var ctaButton:    UIButton!
    @IBOutlet weak var headerView:   UIView!

    var onOpen:        (() -> Void)?
    var onDismiss:     (() -> Void)?
    var onSizeChanged: (() -> Void)?

    private var isExpanded    = false
    private let gradientLayer = CAGradientLayer()

    static func fromXib() -> PromoNotificationView {
        let nib = UINib(nibName: "PromoNotificationView", bundle: Bundle(for: PromoNotificationView.self))
        return nib.instantiate(withOwner: nil, options: nil).first as! PromoNotificationView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer.colors = [
            UIColor(red: 0.388, green: 0.400, blue: 0.945, alpha: 1).cgColor,
            UIColor(red: 0.576, green: 0.322, blue: 0.871, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        headerView?.layer.insertSublayer(gradientLayer, at: 0)
        expandButton.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = headerView?.bounds ?? .zero
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
}
