import UIKit
import UserNotifications
import UserNotificationsUI
import os.log

enum NotifCategory {
    static let info    = "NOTIF_INFO"
    static let success = "NOTIF_SUCCESS"
    static let warning = "NOTIF_WARNING"
    static let promo   = "NOTIF_PROMO"
    static let image   = "NOTIF_IMAGE"
}

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    private var contentView: (UIView & NotificationViewType)?

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("🟢 NotifExt viewDidLoad", log: .default, type: .info)
        view.backgroundColor = .clear
        // Initial size — update sau khi content set
        preferredContentSize = CGSize(width: 0, height: 180)
    }

    // MARK: - UNNotificationContentExtension

    func didReceive(_ notification: UNNotification) {
        let cat = notification.request.content.categoryIdentifier
        os_log("🟢 NotifExt didReceive category=%{public}@ title=%{public}@",
               log: .default, type: .error, cat,
               notification.request.content.title)
        contentView?.removeFromSuperview()
        contentView = nil

        let category = notification.request.content.categoryIdentifier
        let v = makeView(for: category)

        // Use screen width — view.bounds may be zero at this point
        let w = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        v.frame = CGRect(x: 0, y: 0, width: w, height: 200)
        v.autoresizingMask = [.flexibleWidth]
        view.addSubview(v)

        v.onSizeChanged = { [weak self] in self?.resizeToFit() }
        v.apply(notification: notification)
        contentView = v

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
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
        let w = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        let targetSize = CGSize(width: w, height: UIView.layoutFittingCompressedSize.height)
        let h = v.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        let finalH = max(h, 120)
        preferredContentSize = CGSize(width: w, height: finalH)
        v.frame = CGRect(x: 0, y: 0, width: w, height: finalH)
    }

    private func makeView(for category: String) -> UIView & NotificationViewType {
        let open: () -> Void    = { [weak self] in self?.extensionContext?.performNotificationDefaultAction() }
        let dismiss: () -> Void = { [weak self] in self?.extensionContext?.dismissNotificationContentExtension() }

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
        case NotifCategory.image:
            let v = ImageNotificationView.make()
            v.onOpen    = open
            v.onDismiss = dismiss
            return v
        default:
            let v = InfoNotificationView.fromXib()
            v.onOpen    = open
            v.onDismiss = dismiss
            return v
        }
    }
}
