import UIKit
import UserNotifications

final class InfoNotificationView: UIView, NotificationViewType {

    // MARK: - IBOutlets
    @IBOutlet weak var iconView:    UIImageView!
    @IBOutlet weak var titleLabel:  UILabel!
    @IBOutlet weak var timeLabel:   UILabel!
    @IBOutlet weak var bodyLabel:   UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var openButton:  UIButton!
    @IBOutlet weak var skipButton:  UIButton!

    // MARK: - NotificationViewType
    var onOpen:        (() -> Void)?
    var onDismiss:     (() -> Void)?
    var onSizeChanged: (() -> Void)?

    private var isExpanded = false

    // MARK: - Load from XIB
    static func fromXib() -> InfoNotificationView {
        let nib = UINib(nibName: "InfoNotificationView", bundle: Bundle(for: InfoNotificationView.self))
        return nib.instantiate(withOwner: nil, options: nil).first as! InfoNotificationView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.image = UIImage(systemName: "bell.circle.fill")
        iconView.tintColor = NotifColor.indigo
        expandButton.isHidden = true
    }

    // MARK: - NotificationViewType
    func apply(notification: UNNotification) {
        let c = notification.request.content
        titleLabel.text = c.title.isEmpty ? "Thông báo" : c.title
        bodyLabel.text  = c.body
        timeLabel.text  = notifTime(notification)

        layoutIfNeeded()
        let lineH = bodyLabel.font.lineHeight
        let needsExpand = bodyLabel.intrinsicContentSize.height > lineH * 2 + 4
        expandButton.isHidden = !needsExpand
    }

    // MARK: - IBActions
    @IBAction func toggleExpand(_ sender: Any) {
        isExpanded.toggle()
        bodyLabel.numberOfLines = isExpanded ? 0 : 2
        let title = isExpanded ? "Thu gọn ▴" : "Xem thêm ▾"
        expandButton.setTitle(title, for: .normal)
        onSizeChanged?()
    }

    @IBAction func didTapOpen(_ sender: Any)  { onOpen?() }
    @IBAction func didTapSkip(_ sender: Any)  { onDismiss?() }
}
