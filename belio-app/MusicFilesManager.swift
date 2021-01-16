//
//  MusicFilesManager.swift
//  belio-app
//
//  Created by Alberto González Hernández on 15/01/21.
//

import Foundation
import AVFoundation

struct MusicTrack {
    var id = ""
    var title = ""
    var artist = ""
    var album = ""
    var durationInSeconds: Int = -1
    var artwork: NSData? = nil
    var soundpathURL = URL(string: "")
}

class MusicFilesManager {
    
    private let commonFunctions = CommonFunctions();
    
    public init() {
        print("Music Files Manager init")
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
            print("Duration: \(musicTrackData.durationInSeconds)\n")
            
            musicLibraryList.append(musicTrackData)
        }
        
        return musicLibraryList
    }
    
    private func composeMusicTrackData(soundpathURL: URL) -> MusicTrack {
        var musicTrackData: MusicTrack = MusicTrack()
        let playerItem = AVPlayerItem(url: soundpathURL)
        musicTrackData.durationInSeconds = Int(round(playerItem.asset.duration.seconds))
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
                    default:
                        print("Not recognized key: \(auioItemValue)")
                }
            }
        }
        musicTrackData.id = commonFunctions.composeTrackId(musicTrackData: musicTrackData)
        return musicTrackData
    }
}
