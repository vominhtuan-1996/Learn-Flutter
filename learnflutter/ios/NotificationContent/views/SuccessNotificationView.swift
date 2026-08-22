import UIKit
import UserNotifications

final class SuccessNotificationView: UIView, NotificationViewType {

    @IBOutlet weak var iconView:    UIImageView!
    @IBOutlet weak var titleLabel:  UILabel!
    @IBOutlet weak var bodyLabel:   UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var okButton:    UIButton!

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
        iconView.image = UIImage(systemName: "checkmark.circle.fill")
        iconView.tintColor = NotifColor.green
        expandButton.isHidden = true
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
}
