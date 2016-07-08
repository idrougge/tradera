//
//  SelectCategoryViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-29.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class SelectCategoryViewController: UIViewController, UITableViewDelegate {
    ///// OUTLETS /////
    @IBOutlet weak var categoryTableView: UITableView!
    ///// IVARS /////
    var parent:CreateAuctionViewController?
    let tableViewDataSource=CategoryTableViewDataSource()
    
    ///// VIEWDIDLOAD /////
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(NSString(string: #file).lastPathComponent).\(#function)")
        // Do any additional setup after loading the view.
        tableViewDataSource.categories=TraderaService.categories
        categoryTableView.registerNib(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        //categoryTableView.delegate=tableViewDataSource
        categoryTableView.delegate=self
        categoryTableView.dataSource=tableViewDataSource
        categoryTableView.reloadData()
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row=indexPath.row
        print("\(NSString(string: #file).lastPathComponent).\(#function) didSelectRow: \(row)")
        tableView.reloadData()
        if tableViewDataSource.categories?[row].sub == nil {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        }
        tableViewDataSource.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        self.title=tableViewDataSource.path.last?.description
    }
    
    override func viewWillDisappear(animated: Bool) {
        parent?.categoryButton.setTitle(tableViewDataSource.path.last?.name, forState: .Normal)
    }

}
