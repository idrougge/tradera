//
//  Table.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-25.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation
import UIKit

//let locale = NSLocale(localeIdentifier: "se")

class CategoryTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let nrOfRows=(TraderaService.categories?.keys.count ?? 0)!
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
        guard let categories=TraderaService.categories else {
            print("Kunde inte läsa ut TraderaService.categories!")
            return cell
        }
        //let cats=[String](categories.keys)
        var cats=[String](categories.keys)
        cats=cats.sort() {
            return $0.localizedCompare($1)==NSComparisonResult.OrderedAscending
        }
        cell.categoryLabel.text=cats[indexPath.row]
        cell.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
}