//
//  SelectPaymentShippingViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-09-06.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class SelectPaymentShippingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var parent:CreateAuctionViewController!
    var session:TraderaSession!
    var itemFieldValues:[String:[[String:String]]]?
    let optionTypes=["ItemAttributes","ShippingTypes","PaymentTypes"]
    let optionNames=["Skick","Fraktalternativ","Betalningsalternativ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource=self
        tableView.delegate=self
        if itemFieldValues==nil {
            session.notifications.addObserver(self, selector: #selector(didReceiveItemFieldValues), name: TraderaService.notifications.gotItemFieldValues.rawValue, object: nil)
            let _=TraderaService.URLConnection(message: session.service.getItemFieldValues(), action: "\"http://api.tradera.com/GetItemFieldValues\"", session: session, url: TraderaService.publicServiceURL)
        }
        navigationController?.delegate=self // Kan nog tas bort
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        print("navigationController(\(navigationController), willShowViewController: \(viewController), animated: \(animated))")
    }
    
    func didReceiveItemFieldValues(notification:NSNotification) {
        print("didReceiveItemFieldValues mottog objekt:")
        guard let itemFieldValues=notification.object as? [String:[[String:String]]]
        else {
            print("Kunde inte avkoda objekt")
            return
        }
        print(itemFieldValues)
        self.itemFieldValues=itemFieldValues
        tableView.reloadData()
        //session.notifications.removeObserver(self, name: TraderaService.notifications.gotItemFieldValues.rawValue, object: nil)
        session.notifications.removeObserver(self)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return itemFieldValues != nil ? optionTypes.count : 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let itemFieldValues=itemFieldValues, itemField=itemFieldValues[ optionTypes[section] ]
            else {return 0}
        let rows=itemField.count
        print("SelectPaymentShippingViewController.numberOfRowsInSection: \(section) = \(rows)")
        return rows
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return "Sektion \(section)"
        return optionNames[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row=indexPath.row
        let section=indexPath.section
        print("SelectPaymentShippingViewController.tableView.cellForRow: \(row) in section: \(section)")
        let cell = tableView.dequeueReusableCellWithIdentifier("PaymentShippingCell", forIndexPath: indexPath) as! SelectPaymentShippingTableViewCell
        cell.accessoryType = cell.selected ? .Checkmark : .None
        guard let itemFieldValues=itemFieldValues, itemField=itemFieldValues[ optionTypes[section] ], description=itemField[row]["Description"]
            else {
                cell.shitLabel.text="Detta är rad \(row)"
                return cell
        }
        cell.shitLabel.text=description
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row=indexPath.row, section=indexPath.section
        print("Valde cell på rad \(row) i sektion \(section)")
        let choice=itemFieldValues?[ optionTypes[section] ]?[row]["Description"]
        print("Valde \(choice)")
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        //tableView.hidden=true
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func willMoveToParentViewController(parent: UIViewController?) {
        print("willMoveToParentViewController(parent: \(parent))")
        super.willMoveToParentViewController(parent)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Lägg in valen i CreateAuctionViewController
        guard let selectedRows=tableView.indexPathsForSelectedRows
            else {
                super.viewWillDisappear(animated)
                return
        }
        var choices=[String:[String]]()
        for key in optionTypes {
            choices[key]=[String]()
        }
        for indexPath in selectedRows {
            let row=indexPath.row, section=indexPath.section
            let sectionName=optionNames[section]
            let sectionKey=optionTypes[section]
            let rowName=itemFieldValues?[sectionKey]?[row]["Description"]
            let rowId=itemFieldValues?[sectionKey]?[row]["Id"]
            print("Vald rad: \(indexPath.row). \(rowName) (sektion \(indexPath.section). \(sectionName))")
            choices[sectionKey]!.append(rowId!)
        }
        print("choices = \(choices)")
        parent.itemFieldValues=choices
        super.viewWillDisappear(animated)
    }

}
