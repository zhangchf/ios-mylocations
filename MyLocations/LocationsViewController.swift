//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 26/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit
import CoreData

class LocationsViewController: UITableViewController {
    let TAG = "LocationsViewController: "
    
//    var locations = [Location]()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = Location.entity()
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedRequestController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: gManagedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Locations")
        
        fetchedRequestController.delegate = self
        return fetchedRequestController
    }()
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        
        performFetch()
        
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        
        tableView.sectionHeaderHeight = 28
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name.uppercased()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.IDENTIFIER_LOCATIONS_TABLE_VIEW_CELL, for: indexPath) as! LocationCell
        
        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
        
        return cell        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            gManagedObjectContext.delete(location)
            location.removePhotoFile()
            
            do {
                try gManagedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14, width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clear
        
        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
        view.addSubview(label)
        view.addSubview(separator)
        
        return view
    }
    
//    // MARK: - Fetch data
//    func fetchLocations() {
//        let fetchRequest = NSFetchRequest<Location>()
//        fetchRequest.entity = Location.entity()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//        do {
//            locations = try gManagedObjectContext.fetch(fetchRequest)
//        } catch {
//            fatalCoreDataError(error)
//        }
//    }
    
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SEGUE_ID_EDIT_LOCATION {
            let clickedCell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: clickedCell)
            
            if let indexPath = indexPath {
                let navigationController = segue.destination as! UINavigationController
                let locationDetailsController = navigationController.topViewController as! LocationDetailsViewController
                
                locationDetailsController.locationToEdit = fetchedResultsController.object(at: indexPath)
            }
            
        }
    }
}

extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(TAG + "controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(TAG + "controllerDidChangeContent")
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print(TAG + "NSFetchedResultsChange Insert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print(TAG + "NSFetchedResultsChange Delete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print(TAG + "NSFetchedResultsChange Update (object)")
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? LocationCell {
                let location = controller.object(at: indexPath) as! Location
                cell.configure(for: location)
            }
        case .move:
            print(TAG + "NSFetchedResultsChange Move (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print(TAG + "NSFetchedResultsChange Insert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print(TAG + "NSFetchedResultsChange Insert (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print(TAG + "NSFetchedResultsChange Update (section)")
        case .move:
            print(TAG + "NSFetchedResultsChange Move (section)")
        }
    }
    
}
