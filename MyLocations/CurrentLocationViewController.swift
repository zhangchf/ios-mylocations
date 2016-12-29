//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 12/16/16.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit
import CoreLocation
import QuartzCore
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    @IBOutlet weak var topContainerView: UIView!
    
    // show/hide logo
    var logoVisible = false
    
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(#imageLiteral(resourceName: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        button.center.x = self.view.bounds.width / 2
        button.center.y = 220
        return button
    }()
    
    // sound
    var soundId: SystemSoundID = 0
    
    // LocationManager
    let locationManager = CLLocationManager()
    
    // Location related
    var location: CLLocation?
    var lastLocationError: Error?
    var updatingLocation = false
    var timer: Timer?
    
    // CLGeocoder related
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        loadSoundEffect("Sound.caf")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - IBAction
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            print("requestWhenInUseAuthorization")
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        hideLogoView()
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled() {
            print("before startUpdatingLocation")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print("after startUpdatingLocation")
            updatingLocation = true
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func didTimeOut() {
        print("Timer time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            configureGetButton()
        }
    }
    
    
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations: \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            location = newLocation
            lastLocationError = nil
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
            }
            updateLabels()
            configureGetButton()
            
            if distance > 0 {
                performingReverseGeocoding = false
            }
            
            if !performingReverseGeocoding {
                print("going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        if self.placemark == nil {
                            print("FIRST TIME!")
                            self.playSoundEffect()
                        }
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    self.updateAddress()
                    self.performingReverseGeocoding = false
                    print("Found placemarks: \(placemarks), error:\(error)")
                })
            }
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("Force stop!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
            addressLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as? NSError {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Servies Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = ""
                showLogoView()
            }
            
            messageLabel.text = statusMessage
        }
    }
    
    func configureGetButton() {
        let spinnerTag = 1000
        
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height / 2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                topContainerView.addSubview(spinner)
            }
            
        } else {
            getButton.setTitle("Get My Location", for: .normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
    
    func updateAddress() {
        var addressMsg: String
        if let placemark = placemark {
            addressMsg = string(from: placemark)
        } else if performingReverseGeocoding {
            addressMsg = "Searing for Address..."
        } else if lastGeocodingError != nil {
            addressMsg = "Error Finding Address"
        } else {
            addressMsg = "No Address Found"
        }
        addressLabel.text = addressMsg
    }
    
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        
        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")
        
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }

        
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SEGUE_ID_TAG_LOCATION {
            let navigationController = segue.destination as! UINavigationController
            let locationDetailController = navigationController.topViewController as! LocationDetailsViewController
            locationDetailController.coordinate = location!.coordinate
            locationDetailController.placemark = placemark
            
        }
    }
    
    func showLogoView() {
        if !logoVisible {
            logoVisible = true
            topContainerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        if !logoVisible {
            return
        }
        
        logoVisible = false
        topContainerView.isHidden = false
        
        topContainerView.center.x = view.bounds.width * 2
        topContainerView.center.y = topContainerView.bounds.height / 2 + 40
        
        let centerX = view.bounds.midX
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: topContainerView.center)
        panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: topContainerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        topContainerView.layer.add(panelMover, forKey: "PanelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        topContainerView.layer.removeAllAnimations()
        topContainerView.center.x = view.bounds.size.width / 2
        topContainerView.center.y = topContainerView.bounds.size.height / 2 + 40
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileUrl = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundId)
            if error != kAudioServicesNoError {
                print("Error: \(error), while loading sound at path: \(path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundId)
        soundId = 0
    }

    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundId)
    }

}

