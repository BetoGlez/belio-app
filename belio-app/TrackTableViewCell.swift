//
//  TrackTableViewCell.swift
//  belio-app
//
//  Created by Alberto González Hernández on 14/01/21.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    
    static let identifier = "TrackTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "TrackTableViewCell", bundle: nil)
    }
    
    public func setTrackData(trackTitle: String, trackArtist: String, trackArtwork: NSData) {
        trackTitleLabel.text = trackTitle
        trackArtistLabel.text = trackArtist
        let artworkImg = UIImage(data: trackArtwork as Data)
        trackArtworkImgView.image = artworkImg
    }

    @IBOutlet var trackArtworkImgView: UIImageView!
    @IBOutlet var trackTitleLabel: UILabel!
    @IBOutlet var trackArtistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        trackArtworkImgView.contentMode = .scaleAspectFit
        trackArtworkImgView.layer.cornerRadius = 5.0
        trackArtworkImgView.layer.borderWidth = 0.2
        trackArtworkImgView.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
