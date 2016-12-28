//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 22/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    
    static let USER_DEFAULT_ID_PHOTO = "photoID"
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }
    
    // MARK: - location photo
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoUrl: URL {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue)"
        return gApplicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoUrl.path)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let newID = userDefaults.integer(forKey: USER_DEFAULT_ID_PHOTO) + 1
        userDefaults.set(newID, forKey: USER_DEFAULT_ID_PHOTO)
        userDefaults.synchronize()
        return newID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoUrl)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
}
