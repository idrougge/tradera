//
//  Table.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-25.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation
import UIKit

class CategoryTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    //let locale = NSLocale(localeIdentifier: "se")
    var path=[Category]()
    var categories=TraderaService.categories

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let nrOfRows=categories?.count ?? 0
        print("\(#function): numberOfRowsInSection \(section)=\(nrOfRows)")
        return nrOfRows
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("\(#function)")
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("\(#function): row=\(indexPath.row)")
        let cell = tableView.dequeueReusableCellWithIdentifier("shitcell", forIndexPath: indexPath) as! TraderaCategoryTableViewCell
        cell.categoryLabel.text="Kategori \(indexPath.row)"
        cell.categoryLabel.text=categories?[indexPath.row].name
        cell.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row=indexPath.row
        print("Klickade på rad \(row) i sektion \(indexPath.section)")
        print("Hämtar underkategorier till \(categories?[row])")
        guard let selectedCategory=categories?[row] else {
            print("Kunde inte läsa ut subkategori ur TraderaService.categories!")
            return
        }
        guard let cats=selectedCategory.sub else {
            print("Kunde inte läsa ut subkategori ur \(selectedCategory)!")
            return
        }
        print("Underkategorin innehåller \(cats)")
        categories=cats
        tableView.reloadData()
    }
}