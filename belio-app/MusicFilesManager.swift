//
//  MusicFilesManager.swift
//  belio-app
//
//  Created by Alberto González Hernández on 15/01/21.
//

import Foundation
import AVFoundation
import UIKit

struct MusicTrack {
    var id = ""
    var title = ""
    var artist = ""
    var album = ""
    var genre = ""
    var durationInSeconds: Int = -1
    var artwork: NSData? = nil
    var soundpathURL = URL(string: "")
    var lyrics = ""
}

class MusicFilesManager {
    
    private let commonFunctions = CommonFunctions();
    private var unknownTrackId: Int = 1;
    
    public init() {
        print("Music Files Manager init")
    }
    
    public func composeMusicLibraryList(fileTracks: [String], documentsPath: URL) -> [MusicTrack] {
        var musicLibraryList: [MusicTrack] = []
        
        for trackFileName in fileTracks {
            let trackPathURL: URL = documentsPath.appendingPathComponent(trackFileName)
            let musicTrackData: MusicTrack = composeMusicTrackData(soundpathURL: trackPathURL)
            
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
                        musicTrackData.genre = auioItemValue as! String
                    case "artwork":
                        musicTrackData.artwork = auioItemValue as? NSData
                    default:
                        print("Not recognized key: \(auioItemValue)")
                }
            }
        }
        musicTrackData.id = commonFunctions.composeTrackId(musicTrackData: musicTrackData)
        return completeTrackPropertiesIfMissing(musicTrackData: musicTrackData)
    }
    
    private func completeTrackPropertiesIfMissing(musicTrackData: MusicTrack) -> MusicTrack {
        var newMusicTrackData = musicTrackData
        newMusicTrackData.title = commonFunctions.isStringEmpty(text: musicTrackData.title) ? "Unknown Song \(unknownTrackId)" :
            musicTrackData.title
        unknownTrackId = commonFunctions.isStringEmpty(text: musicTrackData.title) ? unknownTrackId + 1 : unknownTrackId
        newMusicTrackData.artist = commonFunctions.isStringEmpty(text: musicTrackData.artist) ? "Unknown Artist" : musicTrackData.artist
        newMusicTrackData.album = commonFunctions.isStringEmpty(text: musicTrackData.album) ? "Unknown Album" : musicTrackData.album
        if musicTrackData.artwork == nil {
            let artworkImg: UIImage = UIImage(named: "default-album-cover")!
            newMusicTrackData.artwork = artworkImg.pngData() as NSData?
        }
        if commonFunctions.isStringEmpty(text: musicTrackData.title) || commonFunctions.isStringEmpty(text: musicTrackData.album) {
            newMusicTrackData.id = commonFunctions.composeTrackId(musicTrackData: newMusicTrackData)
        }
        return newMusicTrackData
    }
}
