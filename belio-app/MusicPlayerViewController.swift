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
    private var isLyricsViewMode = false;
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
    @IBOutlet weak var searchLyricsButton: UIButton!
    @IBOutlet weak var lyricsTextView: UITextView!
    
    public var currentTrack: MusicTrack = MusicTrack();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lyricsTextView.alpha = 0
        setUiElementsAlpha(alphaValue: 0)
        musicVolumeSlider.value = MusicPlayerViewController.INITIAL_VOLUME_SLIDER
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initMusicPlayerData(currentTrackData: currentTrack)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removePeriodicTimeObserver()
    }
    
    private func initMusicPlayerData(currentTrackData: MusicTrack) {
        initPlayer(currentTrackData: currentTrackData)
        initScreenUi(currentTrackData: currentTrackData)
                
        if !currentTrackData.soundpathURL!.absoluteString.isEmpty {
            playTrack()
        }
    }
    
    private func initPlayer(currentTrackData: MusicTrack) {
        do {
            let playerItem = AVPlayerItem(url: currentTrackData.soundpathURL!)
            audioPlayer = AVPlayer(playerItem: playerItem)
            audioPlayer.volume = musicVolumeSlider.value
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.playback, options: [AVAudioSession.CategoryOptions.mixWithOthers])
            try audioSession.setActive(true)

            addPeriodicTimeObserver(currentTrackData: currentTrackData)
        } catch {
            print(error)
        }
    }
    
    private func addPeriodicTimeObserver(currentTrackData: MusicTrack) {
        // Notify every second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        timeObserverToken = audioPlayer.addPeriodicTimeObserver(forInterval: time,
                                                          queue: .main) {
            [weak self] time in
            // update current track values
            self!.setCurrentTrackTimeValues(time: time, currentTrackData: currentTrackData)
        }
    }
    
    private func setCurrentTrackTimeValues(time: CMTime, currentTrackData: MusicTrack) {
        let currentTimeInSeconds = Int(round(time.seconds))
        let (currMinutes,currSecs) = commonFunctions.convertSecondsToMinutesSeconds(seconds: currentTimeInSeconds)
        let (remMinutes,remSecs) = commonFunctions.convertSecondsToMinutesSeconds(seconds: currentTrackData.durationInSeconds - currentTimeInSeconds)
        currentTimeLabel.text = "\(currMinutes):\(currSecs)"
        remainingTimeLabel.text = "-\(remMinutes):\(remSecs)"
        timeProgressSlider.value = Float(currentTimeInSeconds) / Float(currentTrackData.durationInSeconds)
        if currentTimeInSeconds >= currentTrackData.durationInSeconds && isPlaying {
            changeTrack(option: "next")
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            audioPlayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func initScreenUi(currentTrackData: MusicTrack) {
        let artworkImg = UIImage(data: currentTrackData.artwork! as Data)
        trackArtworkImgView.image = artworkImg
        trackTitleLabel.text = currentTrackData.title
        trackArtistLabel.text = currentTrackData.artist
        let thumbImg = commonFunctions.resizeImage(image: UIImage(systemName: "circle.fill")!, targetSize: CGSize(width: 10.0, height: 10.0))
        timeProgressSlider.setThumbImage(thumbImg.maskWithColor(color: UIColor.lightGray), for: .normal)
        lyricsTextView.text = currentTrack.lyrics
        lyricsTextView.layer.cornerRadius = 5.0
        lyricsTextView.backgroundColor = UIColor.black
        lyricsTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        UIView.animate(withDuration: 0.3) {
            self.setUiElementsAlpha(alphaValue: 1)
        }
    }
    
    private func playTrack() {
        isPlaying = true
        audioPlayer.play()
        let buttonImg = UIImage(systemName: "pause.fill")
        playPauseButton.setImage(buttonImg, for: .normal)
        if isLyricsViewMode {
            toggleLyricsView()
        }
        UIView.animate(withDuration: 0.25) {
            self.trackArtworkImgView.alpha = 1
        }
    }
    
    private func pauseTrack() {
        isPlaying = false
        audioPlayer.pause()
        let buttonImg = UIImage(systemName: "play.fill")
        playPauseButton.setImage(buttonImg, for: .normal)
        if isLyricsViewMode {
            toggleLyricsView()
        }
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
        self.searchLyricsButton.alpha = alphaValue * 0.9
    }
    
    private func changeTrack(option: String) {
        if isLyricsViewMode {
            toggleLyricsView()
        }
        var newCurrentTrack: MusicTrack;
        if option == "next" {
            newCurrentTrack = commonFunctions.getNewTrack(currentTrack: currentTrack, option: "next")
        } else {
            // Previous option
            newCurrentTrack = commonFunctions.getNewTrack(currentTrack: currentTrack, option: "previous")
        }
        
        // UI Fade
        self.trackArtworkImgView.alpha = 0
        self.trackTitleLabel.alpha = 0
        self.trackArtistLabel.alpha = 0
        
        audioPlayer.pause()
        removePeriodicTimeObserver()
        currentTrack = newCurrentTrack
        
        // UI Fade
        UIView.animate(withDuration: 0.3) {
            self.trackArtworkImgView.alpha = 1
            self.trackTitleLabel.alpha = 1
            self.trackArtistLabel.alpha = 1
        }
        
        initMusicPlayerData(currentTrackData: newCurrentTrack)
    }
    
    private func toggleLyricsView() {
        if !isLyricsViewMode {
            setCurrentTrackLyricsData()
            searchLyricsButton.setTitle("Hide lyrics", for: .normal)
            trackArtworkImgView.alpha = 0
            lyricsTextView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.lyricsTextView.alpha = 0.8
            }
        } else {
            searchLyricsButton.setTitle("Show lyrics", for: .normal)
            trackArtworkImgView.alpha = 0
            lyricsTextView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.trackArtworkImgView.alpha = 1
            }
        }
        isLyricsViewMode = !isLyricsViewMode
    }
    
    private func setCurrentTrackLyricsData() {
        if currentTrack.lyrics.isEmpty {
            let composedRequestUrl: String = "https://api.lyrics.ovh/v1/\(currentTrack.artist)/\(currentTrack.title)"
            let url = URL(string: commonFunctions.replaceWhiteCharacters(stringToReplace: composedRequestUrl))
            if url != nil {
                var request = URLRequest(url: url!)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {

                        let lyricData = Data(dataString.utf8)

                        do {
                            if let json = try JSONSerialization.jsonObject(with: lyricData, options: []) as? [String: Any] {
                                DispatchQueue.main.async {
                                    var currentTrackLyrics = "\n\n No lyrics found for \n\n \(self.currentTrack.title) \n \(self.currentTrack.artist)"
                                    if let trackLyrics = json["lyrics"] as? String {
                                        if !trackLyrics.isEmpty {
                                            currentTrackLyrics = trackLyrics
                                            self.currentTrack.lyrics = trackLyrics
                                            self.commonFunctions.saveLyricToGeneralList(trackId: self.currentTrack.id, lyric: trackLyrics)
                                        }
                                    }
                                    self.lyricsTextView.text = currentTrackLyrics
                                }
                            }
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.lyricsTextView.text = "\n\n No lyrics found for \n\n \(self.currentTrack.title) \n \(self.currentTrack.artist)"
                            }
                        }
                    }
                }
                task.resume()
            } else {
                self.lyricsTextView.text = "\n\n No lyrics found for \n\n \(self.currentTrack.title) \n \(self.currentTrack.artist)"
            }
        } else {
            self.lyricsTextView.text = currentTrack.lyrics
        }
    }
    
    @IBAction func togglePlayPause(_ sender: UIButton) {
        if isPlaying {
            pauseTrack()
        } else {
            playTrack()
        }
    }
    
    @IBAction func changeNextTrack(_ sender: UIButton) {
        changeTrack(option: "next")
    }
    
    @IBAction func changePreviousTrack(_ sender: UIButton) {
        changeTrack(option: "previous")
    }

    @IBAction func changeVolumeSlider(_ sender: UISlider) {
        audioPlayer.volume = sender.value
    }
    
    @IBAction func setCurrentTrackTime(_ sender: UISlider) {
        let newCurrentTimeSeconds = Float64(sender.value) * Float64(currentTrack.durationInSeconds)
        let newCurrentTime = CMTimeMakeWithSeconds(newCurrentTimeSeconds, preferredTimescale: audioPlayer.currentTime().timescale)
        audioPlayer.seek(to: newCurrentTime)
    }
    
    @IBAction func onStartChangingCurrentTrackTime(_ sender: UISlider) {
        pauseTrack()
    }
    
    @IBAction func onEndChangingCurrentTrackTime(_ sender: UISlider) {
        playTrack()
    }
    @IBAction func searchLyrics(_ sender: UIButton) {
        toggleLyricsView()
    }
}
