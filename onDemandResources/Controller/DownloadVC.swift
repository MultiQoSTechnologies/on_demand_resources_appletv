//
//  DownloadVC.swift
//  standardTimeTV
//
//  Created by MQI-2 on 08/07/24.
//

import CircleProgressBar
import Lottie
import UIKit

class DownloadVC: UIViewController {

    @IBOutlet private weak var processer: CircleProgressBar!
    @IBOutlet private weak var loaderView: LottieAnimationView!
    @IBOutlet private weak var animationView: UIView!
    
    var downloadTask: URLSessionDownloadTask?
    var session: URLSession!
    var resourceRequest: NSBundleResourceRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(Progress.fractionCompleted),
            let progress = object as? Progress
        {
            let progressSoFar = progress.fractionCompleted
            DispatchQueue.main.async {
                let persentage = progressSoFar * 100
                print("Download progress: \(persentage)%")
                if persentage >= 99 {
                    self.showDownloadAnimation()
                } else {
                    self.processer.setProgress(
                        CGFloat(progressSoFar), animated: true)
                }
            }
        }
    }

    // MARK: - Memory Management -
    deinit {
        if let resourceRequest = self.resourceRequest {
            resourceRequest.progress.removeObserver(
                self, forKeyPath: #keyPath(Progress.fractionCompleted),
                context: nil)
        }
        print("### deinit -> \(self.className)")
    }
}

// MARK: - Initialization -
extension DownloadVC {
    private func initialization() {
        let isInstalled: Bool = AppUserDefaults[.isInstall] ?? false
        
        AppLogs.debugPrint("isInstalled : \(isInstalled)")
        
        if !isInstalled {
            showProgreess()
        } else {
            showDownloadAnimation()
        }
        
        processer.hintTextColor = UIColor.black
        processer.setProgress(0, animated: false)

        self.loadResourceWithTag()
    }
    
    func showProgreess() {
        processer.isHidden = false
        animationView.isHidden = true
        loaderView.stop()
    }
    
    func showDownloadAnimation() {
        processer.isHidden = true
        animationView.isHidden = false
        loaderView.loopMode = .repeat(.infinity)
        loaderView.play()
    }

    func loadResourceWithTag() {
        
        resourceRequest = NSBundleResourceRequest(tags: ["resources"])

        // Check for sufficient disk space before downloading (8050 meand up to 8gb)
        if !isEnoughDiskSpaceAvailable(minimumRequiredMB: 8050) {
            showDownloadErrorAlert(
                error: NSError(
                    domain: "Download Error", code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Not enough disk space."
                    ])
            )
            return
        }

        resourceRequest?.progress.addObserver(
            self,
            forKeyPath: #keyPath(Progress.fractionCompleted),
            options: [.new],
            context: nil)

        AppUserDefaults[.isInstall] = true
        guard let resourceRequest = resourceRequest else { return }
        self.downloadVideo(with: resourceRequest)
    }

    func downloadVideo(with resourceRequest: NSBundleResourceRequest) {
        resourceRequest.beginAccessingResources { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                print(
                    "Error accessing resources: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showDownloadErrorAlert(error: error)
                }
                return
            }

            DispatchQueue.main.async {
                AppUserDefaults[.downloadFinish] = true
                self.initVideoPlayer()
            }
        }
    }

    private func initVideoPlayer() {
        guard
            let videoPlayerVC = VideoPlayerVC.instantiateFrom(
                appStoryboard: .main)
        else {
            return
        }

        UIApplication.appDelegate?.setWindowRootViewController(
            rootVC: UINavigationController(rootViewController: videoPlayerVC),
            animated: true
        )
    }
}

// MARK: - Error Handling & Utilities -
extension DownloadVC {
    private func showDownloadErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Download Failed",
            message:
                "An error occurred while downloading resources: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "Retry", style: .default,
                handler: { _ in
                    self.loadResourceWithTag()  // Retry download
                }))
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    private func isEnoughDiskSpaceAvailable(minimumRequiredMB: Int) -> Bool {
        let fileManager = FileManager.default
        if let systemAttributes = try? fileManager.attributesOfFileSystem(
            forPath: NSHomeDirectory()),
            let freeSize = systemAttributes[.systemFreeSize] as? Int64
        {
            return freeSize > Int64(minimumRequiredMB * 1024 * 1024)
        }
        return false
    }

    func cancelDownload() {
        resourceRequest?.progress.cancel()
        resourceRequest = nil
        processer.setProgress(0, animated: false)
    }
}

