//
//  MusicPlayerViewController.swift
//  belio-app
//
//  Created by Alberto González Hernández on 14/01/21.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    private static let INITIAL_VOLUME_SLIDER: Float = 0.9
    
    private let commonFunctions = CommonFunctions();
    private var isPlaying = false;
    private var audioPlayer: AVPlayer!
    private var timeObserverToken: Any?
    
    @IBOutlet weak var trackArtworkImgView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var timeProgressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var previousTrackButton: UIButton!
    @IBOutlet weak var musicVolumeSlider: UISlider!
    
    public var currentTrack: MusicTrack = MusicTrack();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUiElementsAlpha(alphaValue: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initMusicPlayerData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removePeriodicTimeObserver()
    }
    
    private func initMusicPlayerData() {
        initPlayer()
        initScreenUi()
                
        if !currentTrack.soundpathURL!.absoluteString.isEmpty {
            playTrack()
        }
    }
    
    private func initPlayer() {
        do {
            let playerItem = AVPlayerItem(url: currentTrack.soundpathURL!)
            audioPlayer = AVPlayer(playerItem: playerItem)
            audioPlayer.volume = MusicPlayerViewController.INITIAL_VOLUME_SLIDER
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.playback, options: [AVAudioSession.CategoryOptions.mixWithOthers])
            try audioSession.setActive(true)

            addPeriodicTimeObserver()
        } catch {
            print(error)
        }
    }
    
    private func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        timeObserverToken = audioPlayer.addPeriodicTimeObserver(forInterval: time,
                                                          queue: .main) {
            [weak self] time in
            // update current track values
            self!.setCurrentTrackTimeValues(time: time)
        }
    }
    
    private func setCurrentTrackTimeValues(time: CMTime) {
        let currentTimeInSeconds = Int(round(time.seconds))
        let (currMinutes,currSecs) = commonFunctions.convertSecondsToMinutesSeconds(seconds: currentTimeInSeconds)
        let (remMinutes,remSecs) = commonFunctions.convertSecondsToMinutesSeconds(seconds: currentTrack.durationInSeconds - currentTimeInSeconds)
        currentTimeLabel.text = "\(currMinutes):\(currSecs)"
        remainingTimeLabel.text = "-\(remMinutes):\(remSecs)"
        timeProgressSlider.value = Float(currentTimeInSeconds) / Float(currentTrack.durationInSeconds)
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            audioPlayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func initScreenUi() {
        let artworkImg = UIImage(data: currentTrack.artwork! as Data)
        trackArtworkImgView.image = artworkImg
        trackTitleLabel.text = currentTrack.title
        trackArtistLabel.text = currentTrack.artist
        let thumbImg = commonFunctions.resizeImage(image: UIImage(systemName: "circle.fill")!, targetSize: CGSize(width: 10.0, height: 10.0))
        timeProgressSlider.setThumbImage(thumbImg.maskWithColor(color: UIColor.lightGray), for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.setUiElementsAlpha(alphaValue: 1)
        }
        musicVolumeSlider.value = MusicPlayerViewController.INITIAL_VOLUME_SLIDER
    }
    
    private func playTrack() {
        isPlaying = true
        audioPlayer.play()
        let buttonImg = UIImage(systemName: "pause.fill")
        playPauseButton.setImage(buttonImg, for: .normal)
        UIView.animate(withDuration: 0.25) {
            self.trackArtworkImgView.alpha = 1
        }
    }
    
    private func pauseTrack() {
        isPlaying = false
        audioPlayer.pause()
        let buttonImg = UIImage(systemName: "play.fill")
        playPauseButton.setImage(buttonImg, for: .normal)
        UIView.animate(withDuration: 0.25) {
            self.trackArtworkImgView.alpha = 0.7
        }
    }
    
    private func setUiElementsAlpha(alphaValue: CGFloat) {
        self.trackArtworkImgView.alpha = alphaValue
        self.trackTitleLabel.alpha = alphaValue
        self.trackArtistLabel.alpha = alphaValue
        self.timeProgressSlider.alpha = alphaValue
        self.currentTimeLabel.alpha = alphaValue * 0.5
        self.remainingTimeLabel.alpha = alphaValue * 0.5
        self.musicVolumeSlider.alpha = alphaValue
        self.playPauseButton.alpha = alphaValue * 0.9
        self.nextTrackButton.alpha = alphaValue * 0.9
        self.previousTrackButton.alpha = alphaValue * 0.9
    }
    
    @IBAction func togglePlayPause(_ sender: UIButton) {
        if isPlaying {
            pauseTrack()
        } else {
            playTrack()
        }
    }
    
    @IBAction func changeVolumeSlider(_ sender: UISlider) {
        audioPlayer.volume = sender.value
    }
    
    @IBAction func setCurrentTrackTime(_ sender: UISlider) {
        let newCurrentTimeSeconds = Float64(sender.value) * Float64(currentTrack.durationInSeconds)
        let newCurrentTime = CMTimeMakeWithSeconds(newCurrentTimeSeconds, preferredTimescale: audioPlayer.currentTime().timescale)
        audioPlayer.seek(to: newCurrentTime)
    }
}
