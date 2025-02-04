//
//  IntriductionVC.swift
//  onDemandResources
//
//  Created by MQS_2 on 04/02/25.
//

import UIKit

class IntroductionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    private func moveToDownload() {
        guard let downloadVC = DownloadVC.instantiateFrom(appStoryboard: .main) else{
            return
        }
        
        UIApplication.appDelegate?.setWindowRootViewController(
            rootVC: UINavigationController(rootViewController: downloadVC),
            animated: true
        )
    }
}

//MARK: - Action Events -
extension IntroductionVC{
    
    @IBAction private func btnNext(sender: UIButton) {
        self.moveToDownload()
    }
}
