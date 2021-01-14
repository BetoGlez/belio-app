//
//  ViewController.swift
//  belio-app
//
//  Created by Alberto González Hernández on 13/01/21.
//

import UIKit
import AVFoundation

struct MusicTrack {
    var id = UUID().uuidString
    var title = ""
    var artist = ""
    var album = ""
    var duration = ""
    var artwork: NSData? = nil
    var soundpathURL = URL(string: "")
}

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var currentSongCoverImgView: UIImageView!
    let MP3_FILE_EXTENSION = "mp3"
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadMusicFromFiles()
    }

    private func loadMusicFromFiles() {
        let fileManager = FileManager.default
        // This is th document path, you should store your mp3 files with the complete metadata here
        let documentsPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print("The documents path is: \(documentsPath.path) \n")
                
        do {
            let documentsFiles = try fileManager.contentsOfDirectory(atPath: documentsPath.path)
            let musicFiles = documentsFiles.filter { $0.suffix(3) == MP3_FILE_EXTENSION }
            if musicFiles.count > 0 {
                let musicLibraryList = composeMusicLibraryList(fileTracks: musicFiles, documentsPath: documentsPath)
                // Sample random music play in order to test it works
                let randomTrackPos = Int.random(in: 0..<musicLibraryList.count)
                if !musicLibraryList[randomTrackPos].soundpathURL!.absoluteString.isEmpty {
                    playSong(soundpathURL: musicLibraryList[randomTrackPos].soundpathURL!)
                    
                    if musicLibraryList[randomTrackPos].artwork != nil {
                        let artworkImg = UIImage(data: musicLibraryList[randomTrackPos].artwork! as Data)
                        currentSongCoverImgView.image = artworkImg
                    }
                }
            } else {
                print("There are no music files at the moment")
            }
        } catch {
            print("Error while enumerating files")
        }
    }
    
    private func composeMusicLibraryList(fileTracks: [String], documentsPath: URL) -> [MusicTrack] {
        var musicLibraryList: [MusicTrack] = []
        
        for trackFileName in fileTracks {
            let trackPathURL: URL = documentsPath.appendingPathComponent(trackFileName)
            let musicTrackData: MusicTrack = composeMusicTrackData(soundpathURL: trackPathURL)
            
            // TODO: Test purposes, remove this once list is implemented
            print("Id: \(musicTrackData.id)")
            print("Title: \(musicTrackData.title)")
            print("Artist: \(musicTrackData.artist)")
            print("Album: \(musicTrackData.album)")
            print("Duration: \(musicTrackData.duration)")
            
            musicLibraryList.append(musicTrackData)
        }
        
        return musicLibraryList
    }
    
    private func composeMusicTrackData(soundpathURL: URL) -> MusicTrack {
        var musicTrackData: MusicTrack = MusicTrack()
        let playerItem = AVPlayerItem(url: soundpathURL)
        let songDurationSeconds = Int(round(playerItem.asset.duration.seconds))
        let (durMin,durSec) = convertSecondsToHoursMinutesSeconds(seconds: songDurationSeconds)
        musicTrackData.duration = "\(durMin):\(durSec)"
        musicTrackData.soundpathURL = soundpathURL
        let metadataList = playerItem.asset.commonMetadata
        for item in metadataList {
            if (item.commonKey != nil), let auioItemValue = item.value {
                switch item.commonKey!.rawValue {
                    case "title":
                        musicTrackData.title = auioItemValue as! String
                    case "artist":
                        musicTrackData.artist = auioItemValue as! String
                    case "albumName":
                        musicTrackData.album = auioItemValue as! String
                    case "type":
                        print("Genre: \(auioItemValue)")
                    case "artwork":
                        musicTrackData.artwork = auioItemValue as? NSData
                        print("Artwork: \(auioItemValue)\n")
                    default:
                        print("Not recognized key: \(auioItemValue)")
                }
            }
        }
        return musicTrackData
    }
    
    private func playSong(soundpathURL: URL) {
        audioPlayer = try! AVAudioPlayer(contentsOf: soundpathURL)
        audioPlayer.volume = 1.0
        audioPlayer.delegate = self
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    private func convertSecondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
      return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

