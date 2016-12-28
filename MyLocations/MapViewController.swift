//
//  MapViewController.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 26/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    let TAG = "MapViewController: "

    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [Location]()
    
    // NSManagedObjectContext
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main, using: {
                notification in
                if self.isViewLoaded {
                    self.updateLocations()
                }
                
                if let dictionary = notification.userInfo {
                    print(self.TAG, dictionary["inserted"] ?? "No inserted")
                    print(self.TAG, dictionary["deleted"] ?? "No deleted")
                    print(self.TAG, dictionary["updated"] ?? "No updated")
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = gManagedObjectContext
        
        updateLocations()
        if !locations.isEmpty {
            showLocations()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
    func updateLocations() {
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = Location.entity()
        
        mapView.removeAnnotations(locations)
        locations = try! managedObjectContext!.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }
    
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            region = MKCoordinateRegionMakeWithDistance(annotations[0].coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpanMake(abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegionMake(center, span)
        }
        
        return mapView.regionThatFits(region)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SEGUE_ID_EDIT_LOCATION_FROM_MAP, let button = sender as? UIButton {
            
            let navigationController = segue.destination as! UINavigationController
            let locationDetailsController = navigationController.topViewController as! LocationDetailsViewController
            locationDetailsController.locationToEdit = locations[button.tag]
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {
            return nil
        }
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails(_:)), for: .touchUpInside)
            
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }
        
        return annotationView
    }
    
    func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.SEGUE_ID_EDIT_LOCATION_FROM_MAP, sender: sender)
    }
}

extension MapViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
