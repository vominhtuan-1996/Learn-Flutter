import UIKit
import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices
import AVFoundation

// MARK: - Constants (must match SwiftReceiveSharingIntentPlugin)
private let kSchemePrefix    = "ShareMedia"
private let kUserDefaultsKey = "ShareKey"
private let kAppGroupIdKey   = "AppGroupId"

// MARK: - Internal media model (matches plugin's SharedMediaFile JSON)
private class SharedMediaFile: Codable {
    var path: String
    var mimeType: String?
    var thumbnail: String?
    var duration: Double?
    var type: SharedMediaType

    init(path: String, mimeType: String? = nil, thumbnail: String? = nil,
         duration: Double? = nil, type: SharedMediaType) {
        self.path = path; self.mimeType = mimeType
        self.thumbnail = thumbnail; self.duration = duration; self.type = type
    }
}

private enum SharedMediaType: String, Codable, CaseIterable {
    case image, video, text, file, url

    var utIdentifier: String {
        if #available(iOS 14.0, *) {
            switch self {
            case .image: return UTType.image.identifier
            case .video: return UTType.movie.identifier
            case .text:  return UTType.text.identifier
            case .file:  return UTType.fileURL.identifier
            case .url:   return UTType.url.identifier
            }
        }
        switch self {
        case .image: return "public.image"
        case .video: return "public.movie"
        case .text:  return "public.text"
        case .file:  return "public.file-url"
        case .url:   return "public.url"
        }
    }
}

// MARK: - ShareViewController
class ShareViewController: UIViewController {

    private var appGroupId = ""
    private var hostAppBundleId = ""
    private var sharedMedia: [SharedMediaFile] = []
    private var previewItems: [SharePreviewItem] = []
    private var hostingController: UIHostingController<ShareView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadIds()
        view.backgroundColor = .clear
        loadSharedItems()
    }

    // MARK: - Load shared items from extension context
    private func loadSharedItems() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            showUI(); return
        }
        let attachments = items.flatMap { $0.attachments ?? [] }
        guard !attachments.isEmpty else { showUI(); return }

        let group = DispatchGroup()
        for (index, provider) in attachments.enumerated() {
            for type in SharedMediaType.allCases {
                if provider.hasItemConformingToTypeIdentifier(type.utIdentifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: type.utIdentifier) { [weak self] data, error in
                        defer { group.leave() }
                        guard let self, error == nil else { return }
                        switch type {
                        case .text:
                            if let text = data as? String {
                                self.sharedMedia.append(SharedMediaFile(path: text, mimeType: "text/plain", type: .text))
                                if let coord = parseLocationURL(text) {
                                    self.previewItems.append(SharePreviewItem(type: .location, value: text, coordinate: coord))
                                } else {
                                    self.previewItems.append(SharePreviewItem(type: .text, value: text))
                                }
                            }
                        case .url:
                            if let url = data as? URL {
                                let urlStr = url.absoluteString
                                self.sharedMedia.append(SharedMediaFile(path: urlStr, type: .url))
                                if let coord = parseLocationURL(urlStr) {
                                    self.previewItems.append(SharePreviewItem(type: .location, value: urlStr, coordinate: coord))
                                } else {
                                    self.previewItems.append(SharePreviewItem(type: .url, value: urlStr))
                                }
                            }
                        default:
                            if let url = data as? URL {
                                self.handleFile(url: url, type: type)
                            } else if let image = data as? UIImage, type == .image {
                                self.handleUIImage(image)
                            }
                        }
                    }
                    break
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.showUI()
        }
    }

    // MARK: - Show SwiftUI preview sheet
    private func showUI() {
        let shareView = ShareView(
            items: previewItems,
            onShare: { [weak self] in self?.saveAndRedirect() },
            onCancel: { [weak self] in self?.cancel() }
        )
        let hc = UIHostingController(rootView: shareView)
        hc.view.backgroundColor = .clear
        addChild(hc)
        view.addSubview(hc.view)
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hc.didMove(toParent: self)
        hostingController = hc
    }

    // MARK: - Actions
    private func saveAndRedirect() {
        guard let userDefaults = UserDefaults(suiteName: appGroupId),
              let data = try? JSONEncoder().encode(sharedMedia) else { cancel(); return }
        userDefaults.set(data, forKey: kUserDefaultsKey)
        userDefaults.synchronize()
        openHostApp()
    }

    private func cancel() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func openHostApp() {
        guard let url = URL(string: "\(kSchemePrefix)-\(hostAppBundleId):share") else { cancel(); return }
        var responder: UIResponder? = self
        if #available(iOS 18.0, *) {
            while responder != nil {
                if let app = responder as? UIApplication {
                    app.open(url, options: [:], completionHandler: nil); break
                }
                responder = responder?.next
            }
        } else {
            let sel = sel_registerName("openURL:")
            while responder != nil {
                if responder?.responds(to: sel) == true { _ = responder?.perform(sel, with: url); break }
                responder = responder?.next
            }
        }
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    // MARK: - File helpers
    private func handleFile(url: URL, type: SharedMediaType) {
        let name = url.lastPathComponent.isEmpty ? "\(UUID()).ext" : url.lastPathComponent
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else { return }
        let dest = container.appendingPathComponent(name)
        if copyFile(at: url, to: dest) {
            let decoded = dest.absoluteString.removingPercentEncoding ?? dest.absoluteString
            sharedMedia.append(SharedMediaFile(path: decoded, mimeType: url.mimeType, type: type))
            let pType: SharePreviewItem.ShareItemType = type == .image ? .image : type == .video ? .file : .file
            previewItems.append(SharePreviewItem(type: pType, value: dest.path))
        }
    }

    private func handleUIImage(_ image: UIImage) {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else { return }
        let dest = container.appendingPathComponent("TempImage-\(UUID()).png")
        if let data = image.pngData() {
            try? data.write(to: dest)
            let decoded = dest.absoluteString.removingPercentEncoding ?? dest.absoluteString
            sharedMedia.append(SharedMediaFile(path: decoded, mimeType: "image/png", type: .image))
            previewItems.append(SharePreviewItem(type: .image, value: dest.path))
        }
    }

    private func copyFile(at src: URL, to dst: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dst.path) { try FileManager.default.removeItem(at: dst) }
            try FileManager.default.copyItem(at: src, to: dst)
            return true
        } catch { return false }
    }

    private func loadIds() {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let lastDot = bundleId.lastIndex(of: ".") ?? bundleId.endIndex
        hostAppBundleId = String(bundleId[..<lastDot])
        let defaultGroup = "group.\(hostAppBundleId)"
        appGroupId = (Bundle.main.object(forInfoDictionaryKey: kAppGroupIdKey) as? String) ?? defaultGroup
    }
}

// MARK: - URL mime helper
private extension URL {
    var mimeType: String {
        if #available(iOS 14.0, *) {
            return UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        }
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue(),
           let mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mime as String
        }
        return "application/octet-stream"
    }
}
