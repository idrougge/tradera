//
//  SelectCategoryViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-29.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class SelectCategoryViewController: UIViewController {

    var parent:CreateAuctionViewController?
    let tableViewDelegate=CategoryTableViewDataSource()
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(NSString(string: #file).lastPathComponent).\(#function)")
        // Do any additional setup after loading the view.
        tableViewDelegate.categories=TraderaService.categories
        categoryTableView.registerNib(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        categoryTableView.delegate=tableViewDelegate
        categoryTableView.dataSource=tableViewDelegate
        categoryTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        parent?.categoryButton.setTitle(tableViewDelegate.path.last?.name, forState: .Normal)
    }

}
