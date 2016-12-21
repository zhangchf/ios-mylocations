//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 21/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    
    let categories = Constants.categories
    
    var selectedCategoryName = ""
    var selectedCategoryIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedCategoryName != "" {
            for i in 0..<categories.count {
                if categories[i] == selectedCategoryName {
                    selectedCategoryIndex = i
                    break
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.IDENTIFIER_CATEGORY_PICKER_TABLE_VIEW_CELL, for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        if let selectedIndex = selectedCategoryIndex, selectedIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("CategoryPicker, didSelectRowAt: \(indexPath.row)")
        if indexPath.row != selectedCategoryIndex {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
            if let selectedCategoryIndex = selectedCategoryIndex, let oldCell = tableView.cellForRow(at: IndexPath(row: selectedCategoryIndex, section: 0)) {
                oldCell.accessoryType = .none
            }
            selectedCategoryIndex = indexPath.row
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("CategoryPicker, prepareForSegue")
        if segue.identifier == Constants.SEGUE_ID_DID_PICK_CATEGORY, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            selectedCategoryIndex = indexPath.row
            selectedCategoryName = categories[selectedCategoryIndex!]
        }
    }

}
