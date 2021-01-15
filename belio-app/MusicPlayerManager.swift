//
//  MusicPlayerManager.swift
//  belio-app
//
//  Created by Alberto González Hernández on 15/01/21.
//

import Foundation
import AVFoundation

class MusicPlayerManager {
    
    private var audioPlayer: AVAudioPlayer!
    
    public init() {
        print("Music Player Manager init")
    }
    
    public func playSong(soundpathURL: URL, playerDelegate: AVAudioPlayerDelegate) {
        audioPlayer = try! AVAudioPlayer(contentsOf: soundpathURL)
        audioPlayer.volume = 1.0
        audioPlayer.delegate = playerDelegate
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    public func composeMusicLibraryList(fileTracks: [String], documentsPath: URL) -> [MusicTrack] {
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
        musicTrackData.duration = "\(durMin):\(String(durSec).count < 2 ? "0\(durSec)" : String(durSec))"
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
    
    private func convertSecondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
      return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
