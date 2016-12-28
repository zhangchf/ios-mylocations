//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 12/20/16.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    let TAG = "LocationDetailsViewController: "

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var observer: Any!
    
    var image: UIImage?
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                placemark = location.placemark
                date = location.date
            }
        }
    }
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var descriptionText = ""
    var categoryName = Constants.categories[0]
    var date = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationDetails()
        print(TAG, "date: \(date)")
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        listenForBackgroundNotification()
    }
    
    deinit {
        print(TAG, "deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
    }
    
    func initLocationDetails() {
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                showImage(image: location.photoImage)
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = string(fromDate: date)
    }

    
    func hideKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)
        if let indexPath = indexPath, indexPath.section == 0 && indexPath.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: Any) {
        saveAndClose() {
            print("date: \(date)")
            
            let hudView = HudView.hud(inView: navigationController!.view, animated: true)
            if locationToEdit != nil {
                hudView.text = "Updated"
            } else {
                hudView.text = "Tagged"
            }
            
            afterDelay(0.6) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func saveAndClose(with closeAction: () -> ()) {
        let location: Location
        if locationToEdit != nil {
            location = locationToEdit!
        } else {
            location = Location(context: gManagedObjectContext)
            location.photoID = nil
        }
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.write(to: location.photoUrl, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        do {
            try gManagedObjectContext.save()
            closeAction()
        } catch {
            fatalCoreDataError(error)
        }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " " }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " " }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    func string(fromDate date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
            case (2, 2):
                addressLabel.frame.size.width = view.bounds.width - 105 - 15
                addressLabel.sizeToFit()
                addressLabel.frame.origin.x = view.bounds.width - addressLabel.frame.width - 15
                return addressLabel.frame.height + 20
            case (1, _):
                if !imageView.isHidden {
                    return imageView.frame.height + 20
                }
            default: break
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SEGUE_ID_CATEGORY_PICKER {
            let categoryPickerViewController = segue.destination as! CategoryPickerViewController
            categoryPickerViewController.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let categoryPickerViewController = segue.source as! CategoryPickerViewController
        categoryName = categoryPickerViewController.selectedCategoryName
        
        categoryLabel.text = categoryName
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            _ in
            self.takePhotoWithCamera()
        })
        alertController.addAction(takePhotoAction)
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {
            _ in
            self.choosePhotoFromLibrary()
        })
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        showImage(image: image)
        
        dismiss(animated: true, completion: nil)
    }
    
    func showImage(image: UIImage?) {
        if let image = image {
            imageView.image = image
            imageView.isHidden = false
            let imageViewWidth: CGFloat = 260
            let imageViewHeight = imageViewWidth * image.size.height / image.size.width
            imageView.frame = CGRect(x: 10, y: 10, width: imageViewWidth, height: imageViewHeight)
            imageLabel.isHidden = true
            tableView.reloadData()
        }
    }
}

extension LocationDetailsViewController {
    
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main, using: {
            [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: true, completion: nil)
                }
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        })
    }
}
