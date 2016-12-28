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
        // Initialization code
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
            if let subThoroughfare = placemark.subThoroughfare {
                addressText += subThoroughfare + " "
            }
            if let thoroughfare = placemark.thoroughfare {
                addressText += thoroughfare + ","
            }
            if let locality = placemark.locality {
                addressText += locality
            }
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
            return UIImage()
        }
    }

}
