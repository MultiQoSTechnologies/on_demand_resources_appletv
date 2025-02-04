//
//  VideoPlayerVC.swift
//  standardTimeTV
//
//  Created by MQI-2 on 11/09/24.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerVC: UIViewController {
    
    @IBOutlet weak var btnSpeaker: UIButton!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItemObserver: NSKeyValueObservation?
    
    var resourceRequest: NSBundleResourceRequest?
        
    var currentVideoIndex = 0
    var currentPlaybackTime: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVideoPlayer), name: Notification.Name("UpdateVideoPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        configureAudioSession()
        self.view.bringSubviewToFront(btnSpeaker)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resourceRequest = NSBundleResourceRequest(tags: ["resources"])

        Task { @MainActor in
            try? await resourceRequest?.beginAccessingResources()
            self.playVideo()
        }
        

    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        if presses.first?.type == .select {
            print("Center button (Select) pressed")
            // Handle your action here
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == .select {
            print("Center button released")
        }
        super.pressesEnded(presses, with: event)
    }
    
    deinit {
        print("### deinit -> \(self)")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func appWillEnterForeground() {
        print("appWillEnterForeground called =============")
        player?.play()
        configureAudioSession()
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    @objc func updateVideoPlayer() {
        player?.play()
    }
    
    
    func playVideo(seekTime: Double = 0.0) {
        guard let videoURL = Bundle.main.url(forResource: "BigBuckBunny", withExtension: "mp4") else {
            print("Video file not found")
            return
        }
        
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = view.bounds
        
        if let playerLayer = playerLayer {
            view.layer.sublayerTransform = CATransform3DIdentity
            view.layer.addSublayer(playerLayer)
        }
        
        print("seekTime: \(seekTime)")
        
        player?.seek(to: CMTime(seconds: seekTime, preferredTimescale: 1), completionHandler: { [weak self] _ in
            self?.player?.play()
        })
        
        addPlayerItemObserver()
        addEndObserver()
        self.view.bringSubviewToFront(btnSpeaker)
    }
    
    func addPlayerItemObserver() {
        if let playerItem = player?.currentItem {
            playerItemObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] (item, _) in
                self?.playerItemStatusDidChange(status: item.status)
            }
        }
    }
    
    func addEndObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    @objc func playerDidFinishPlaying() {
            playVideo(seekTime: 0.0)
    }
    
    private func playerItemStatusDidChange(status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            print("Player item is ready to play.")
        case .failed:
            print("Player item failed.")
        case .unknown:
            print("Player item status is unknown.")
        @unknown default:
            print("Player item status is unknown.")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.playerLayer?.frame = self.view.bounds
        }, completion: nil)
    }
    
    @IBAction func btnSpeakerTapped(_ sender: Any) {
        btnSpeaker.isSelected = !btnSpeaker.isSelected
        if btnSpeaker.isSelected {
            btnSpeaker.setImage(.icMuted, for: .normal)
        } else {
            btnSpeaker.setImage(.icUnmuted, for: .normal)
        }
        player?.isMuted = !(player?.isMuted ?? false)
    }
    
}

