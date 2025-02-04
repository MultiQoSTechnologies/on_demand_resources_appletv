//
//  AppDelegate.swift
//  onDemandResources
//
//  Created by MQS_2 on 04/02/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIApplication.window
        self.window?.backgroundColor = UIColor.white
        
        self.window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
        
        self.initHomeController()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }
}

extension AppDelegate {
    
    // Initiated the introduction screen
    func initIntroductionController() {
        
        guard let introductionVC = IntroductionVC.instantiateFrom(appStoryboard: .main) else{
            return
        }
        
        setWindowRootViewController(
            rootVC: UINavigationController(rootViewController: introductionVC),
            animated: true
        )
        
        return
    }
    
    // Initiated the downloadVC screen
    func initDownloadController() {
        
        guard let downloadVC = DownloadVC.instantiateFrom(appStoryboard: .main) else{
            return
        }
        
        setWindowRootViewController(
            rootVC: UINavigationController(rootViewController: downloadVC),
            animated: true
        )
        
        return
    }
    
    // Initiated the downloadVC screen
    func initVideoPlayerController() {
        
        guard let videoPlayerVC = VideoPlayerVC.instantiateFrom(appStoryboard: .main) else{
            return
        }
        
        setWindowRootViewController(
            rootVC: UINavigationController(rootViewController: videoPlayerVC),
            animated: true
        )
        
        return
    }
    
    func getVideoURL(fileName: String) -> URL? {
        // Get the document directory path
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        // Construct the URL for the video file
        let videoURL = documentDirectory?.appendingPathComponent(fileName)
        
        // Check if the file exists at the URL
        if FileManager.default.fileExists(atPath: videoURL?.path ?? "") {
            return videoURL
        } else {
            return nil
        }
    }
    
    // Initiated the Home screen
    func initHomeController() {
        
        if let downloadFinish: Bool = AppUserDefaults[.downloadFinish], downloadFinish {
            self.initVideoPlayerController()
        } else {
            if let download: Bool = AppUserDefaults[.isInstall], download {
                self.initDownloadController()
            } else {
                self.initIntroductionController()
            }
        }
    }
    
}


extension AppDelegate {
    func setWindowRootViewController(rootVC:UIViewController?, animated:Bool, completion: ((Bool) -> Void)? = nil) {
        guard rootVC != nil,
              let window = self.window else {
            return
        }
        
        UIView.transition(
            with: window,
            duration: animated ? 0.6 : 0.0,
            options: .transitionCrossDissolve,
            animations: {
                
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = rootVC
                UIView.setAnimationsEnabled(oldState)
                
            }) { (finished) in
                
                if let handler = completion {
                    handler(true)
                }
            }
    }
}
