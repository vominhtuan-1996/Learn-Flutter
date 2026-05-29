import ARKit
import Flutter
import UIKit

/// Routes `scanner_channel` method calls to a presented `ScannerViewController`.
final class ScannerBridge {

    static let shared = ScannerBridge()

    static let channelName = "learnflutter/scanner"

    private weak var scannerVC: ScannerViewController?

    private init() {}

    func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: ScannerBridge.channelName,
                                           binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
    }

    private var topController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
            .map { deepest($0) }
    }

    private func deepest(_ vc: UIViewController) -> UIViewController {
        if let presented = vc.presentedViewController { return deepest(presented) }
        return vc
    }

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSupported":
            result(ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh))

        case "startScan":
            guard let presenter = topController, scannerVC == nil else {
                result(FlutterError(code: "ALREADY_RUNNING",
                                    message: "Scanner is already running",
                                    details: nil))
                return
            }
            let vc = ScannerViewController()
            vc.modalPresentationStyle = .fullScreen
            scannerVC = vc
            presenter.present(vc, animated: true) { result(true) }

        case "stopScan":
            scannerVC?.dismiss(animated: true) { [weak self] in
                self?.scannerVC = nil
                result(true)
            }
            if scannerVC == nil { result(false) }

        case "exportScan":
            guard let vc = scannerVC else {
                result(FlutterError(code: "NOT_RUNNING",
                                    message: "Scanner is not running",
                                    details: nil))
                return
            }
            let args = call.arguments as? [String: Any]
            let format = (args?["format"] as? String) ?? "obj"
            vc.exportModel(format: format) { outcome in
                switch outcome {
                case .success(let path):
                    result(path)
                case .failure(let err):
                    result(FlutterError(code: "EXPORT_FAILED",
                                        message: err.localizedDescription,
                                        details: nil))
                }
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

