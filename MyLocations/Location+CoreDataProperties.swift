//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 22/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation



extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String
    @NSManaged public var longitude: Double
    @NSManaged public var placemark: CLPlacemark?

}
