import UIKit
import UserNotifications

final class ImageNotificationView: UIView, NotificationViewType {

    var onOpen:        (() -> Void)?
    var onDismiss:     (() -> Void)?
    var onSizeChanged: (() -> Void)?

    // MARK: - Subviews
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.layer.cornerCurve = .continuous
        iv.backgroundColor = UIColor.secondarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let spinnerView: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.translatesAutoresizingMaskIntoConstraints = false
        s.hidesWhenStopped = true
        return s
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.lineBreakMode = .byWordWrapping
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var openButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Xem ngay", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        LiquidGlass.styleButton(b, tint: NotifColor.indigo)
        b.addTarget(self, action: #selector(didTapOpen), for: .touchUpInside)
        return b
    }()

    private lazy var dismissButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Bỏ qua", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        LiquidGlass.styleButton(b, tint: NotifColor.indigo, secondary: true)
        b.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        return b
    }()

    private var imageHeightConstraint: NSLayoutConstraint?
    private var imageTask: URLSessionDataTask?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    static func make() -> ImageNotificationView {
        ImageNotificationView(frame: .zero)
    }

    // MARK: - NotificationViewType
    func apply(notification: UNNotification) {
        let c = notification.request.content
        titleLabel.text = c.title.isEmpty ? "Thông báo" : c.title
        bodyLabel.text  = c.body

        // Image URL passed via payload (stored in userInfo["payload"] by flutter_local_notifications)
        let urlString = c.userInfo["payload"] as? String
                     ?? c.userInfo["image_url"] as? String
        loadImage(from: urlString)
    }

    // MARK: - Setup
    private func setup() {
        LiquidGlass.applyBackground(to: self, tint: NotifColor.indigo)

        let btnStack = UIStackView(arrangedSubviews: [openButton, dismissButton])
        btnStack.axis = .horizontal
        btnStack.spacing = 8
        btnStack.distribution = .fillEqually
        btnStack.translatesAutoresizingMaskIntoConstraints = false

        [imageView, spinnerView, titleLabel, bodyLabel, btnStack].forEach { addSubview($0) }

        let imgH = NSLayoutConstraint(
            item: imageView, attribute: .height,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1, constant: 180
        )
        imgH.priority = .defaultHigh
        imageHeightConstraint = imgH

        NSLayoutConstraint.activate([
            imgH,
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            spinnerView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            btnStack.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 10),
            btnStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            btnStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            btnStack.heightAnchor.constraint(equalToConstant: 40),
            btnStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])

        spinnerView.startAnimating()
    }

    // MARK: - Image Loading
    private func loadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            // No URL — collapse image area
            imageHeightConstraint?.constant = 0
            spinnerView.stopAnimating()
            return
        }

        spinnerView.startAnimating()
        imageTask?.cancel()
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", forHTTPHeaderField: "User-Agent")
        request.setValue(url.host.map { "https://\($0)" } ?? "", forHTTPHeaderField: "Referer")
        imageTask = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.spinnerView.stopAnimating()
                if let data = data, let img = UIImage(data: data) {
                    self.imageView.image = img
                    // Resize height proportionally (max 220, min 120)
                    let ratio = img.size.height / max(img.size.width, 1)
                    let w = self.imageView.bounds.width > 0
                        ? self.imageView.bounds.width
                        : UIScreen.main.bounds.width - 24
                    let h = min(max(w * ratio, 120), 220)
                    self.imageHeightConstraint?.constant = h
                } else {
                    // Load failed — collapse image area
                    self.imageHeightConstraint?.constant = 0
                }
                self.onSizeChanged?()
            }
        }
        imageTask?.resume()
    }

    // MARK: - Actions
    @objc private func didTapOpen()    { onOpen?() }
    @objc private func didTapDismiss() { onDismiss?() }
}
