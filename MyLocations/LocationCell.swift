//
//  LocationCell.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 26/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Black theme customization
        backgroundColor = UIColor.black
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        // selectedBackgroundView customization
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        // imageView rounded
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width/2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(for location: Location) {
        
        
        var descriptionText = ""
        if !location.locationDescription.isEmpty {
            descriptionText = location.locationDescription
        } else {
            descriptionText = "(No Description)"
        }
        
        var addressText = ""
        if let placemark = location.placemark {
            addressText.add(text: placemark.subThoroughfare)
            addressText.add(text: placemark.thoroughfare, separatedBy: " ")
            addressText.add(text: placemark.locality, separatedBy: ",")
        } else {
            addressText = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        
        descriptionLabel.text = descriptionText
        addressLabel.text = addressText
        
        photoImageView.image = thumbnail(for: location)
    }
    
    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImage(withBounds: CGSize(width: photoImageView.frame.width, height: photoImageView.frame.height))
        } else {
            return UIImage(named: "No Photo")!
        }
    }

}
