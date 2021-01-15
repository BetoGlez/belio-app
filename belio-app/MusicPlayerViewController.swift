//
//  MusicPlayerViewController.swift
//  belio-app
//
//  Created by Alberto González Hernández on 14/01/21.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var trackArtworkImgView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var musicVolumeSlider: UISlider!
    
    public let musicPlayerManager = MusicPlayerManager()
    public var currentTrack: MusicTrack = MusicTrack();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initMusicPlayerData()
    }
    
    private func initMusicPlayerData() {
        let artworkImg = UIImage(data: currentTrack.artwork! as Data)
        trackArtworkImgView.image = artworkImg
        trackTitleLabel.text = currentTrack.title
        trackArtistLabel.text = currentTrack.artist
        remainingTimeLabel.text = currentTrack.duration
        currentTimeLabel.text = "0:00"
        musicVolumeSlider.value = 0.75
        
        if !currentTrack.soundpathURL!.absoluteString.isEmpty {
            musicPlayerManager.playSong(soundpathURL: currentTrack.soundpathURL!, playerDelegate: self)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
