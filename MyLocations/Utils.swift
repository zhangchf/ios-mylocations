//
//  Utils.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 20/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData


let gPersistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DataModel")
    container.loadPersistentStores(completionHandler: {
        storeDescription, error in
        if let error = error {
            fatalError("Couldn't load data store: \(error)")
        }
    })
    return container
}()

let gManagedObjectContext: NSManagedObjectContext = gPersistentContainer.viewContext


let gApplicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)
    return paths[0]
}()


let gAppLibraryDirectory: URL = {
    let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
    return paths[0]
}()


let gManagedObjectContextSaveDidFailNotificationName = NSNotification.Name("ManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print(" Fatal error: \(error)")
    NotificationCenter.default.post(name: gManagedObjectContextSaveDidFailNotificationName, object: nil)
}



class Utils {
    
    class func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        return line1 + "\n" + line2
    }

}
