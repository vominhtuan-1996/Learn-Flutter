import UIKit
import UserNotifications
import UserNotificationsUI

enum NotifCategory {
    static let info    = "NOTIF_INFO"
    static let success = "NOTIF_SUCCESS"
    static let warning = "NOTIF_WARNING"
    static let promo   = "NOTIF_PROMO"
}

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    private var contentView: (UIView & NotificationViewType)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Initial size — update sau khi content set
        preferredContentSize = CGSize(width: 0, height: 180)
    }

    // MARK: - UNNotificationContentExtension

    func didReceive(_ notification: UNNotification) {
        // Xoá view cũ
        contentView?.removeFromSuperview()
        contentView = nil

        let category = notification.request.content.categoryIdentifier
        let v = makeView(for: category)
        view.addSubview(v)

        // Full-fill bằng frame, không dùng Auto Layout để tránh constraint conflict
        v.frame = view.bounds
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        v.onSizeChanged = { [weak self] in self?.resizeToFit() }
        v.apply(notification: notification)
        contentView = v

        // Resize sau khi content đã render
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.resizeToFit()
        }
    }

    func didReceive(_ response: UNNotificationResponse,
                    completionHandler: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        switch response.actionIdentifier {
        case "ACTION_OPEN": completionHandler(.dismissAndForwardAction)
        default:            completionHandler(.dismiss)
        }
    }

    // MARK: - Private

    private func resizeToFit() {
        guard let v = contentView else { return }
        let targetSize = CGSize(
            width: view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let h = v.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        let finalH = max(h, 120)
        preferredContentSize = CGSize(width: view.bounds.width, height: finalH)
        v.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: finalH)
    }

    private func makeView(for category: String) -> UIView & NotificationViewType {
        let open    = { [weak self] in self?.extensionContext?.performNotificationDefaultAction() }
        let dismiss = { [weak self] in self?.extensionContext?.dismissNotificationContentExtension() }

        switch category {
        case NotifCategory.success:
            let v = SuccessNotificationView.fromXib()
            v.onDismiss = dismiss
            return v
        case NotifCategory.warning:
            let v = WarningNotificationView.fromXib()
            v.onOpen    = open
            v.onDismiss = dismiss
            return v
        case NotifCategory.promo:
            let v = PromoNotificationView.fromXib()
            v.onOpen    = open
            return v
        default:
            let v = InfoNotificationView.fromXib()
            v.onOpen    = open
            v.onDismiss = dismiss
            return v
        }
    }
}
