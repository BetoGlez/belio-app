//
//  CommonFunctions.swift
//  belio-app
//
//  Created by Alberto González Hernández on 15/01/21.
//

import Foundation
import UIKit

class CommonFunctions {
    
    public func composeTrackId(musicTrackData: MusicTrack) -> String {
        return "TRK_\(musicTrackData.durationInSeconds)_\(musicTrackData.title.replacingOccurrences(of: " ", with: ""))_\(musicTrackData.album.replacingOccurrences(of: " ", with: ""))"
    }
    
    public func getNewTrack(currentTrack: MusicTrack, option: String) -> MusicTrack {
        let currentTrackIndex = musicLibraryList.firstIndex(where: { $0.id == currentTrack.id })!
        var newTrackIndex = 0
        if option == "next" {
            if currentTrackIndex >= musicLibraryList.count - 1 {
                newTrackIndex = 0
            } else {
                newTrackIndex = currentTrackIndex + 1
            }
        } else if option == "previous" {
            if currentTrackIndex <= 0 {
                newTrackIndex = musicLibraryList.count - 1
            } else {
                newTrackIndex = currentTrackIndex - 1
            }
        }
        return musicLibraryList[newTrackIndex]
    }
        
    public func convertSecondsToMinutesSeconds (seconds : Int) -> (String, String) {
        let sec = (seconds % 3600) % 60
        return (String((seconds % 3600) / 60), (String(sec).count < 2 ? "0\(sec)" : String(sec)))
    }
    
    public func isStringEmpty(text: String) -> Bool {
        return text.replacingOccurrences(of: " ", with: "").isEmpty
    }
    
    public func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

// Extensions

extension UIImage {

    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }

}
