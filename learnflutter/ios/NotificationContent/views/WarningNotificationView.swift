import UIKit
import UserNotifications

final class WarningNotificationView: UIView, NotificationViewType {

    @IBOutlet weak var iconView:     UIImageView!
    @IBOutlet weak var titleLabel:   UILabel!
    @IBOutlet weak var bodyLabel:    UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var viewButton:   UIButton!
    @IBOutlet weak var skipButton:   UIButton!

    var onOpen:        (() -> Void)?
    var onDismiss:     (() -> Void)?
    var onSizeChanged: (() -> Void)?

    private var isExpanded = false

    static func fromXib() -> WarningNotificationView {
        let nib = UINib(nibName: "WarningNotificationView", bundle: Bundle(for: WarningNotificationView.self))
        return nib.instantiate(withOwner: nil, options: nil).first as! WarningNotificationView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iconView.tintColor = .white
        expandButton.isHidden = true
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
}
