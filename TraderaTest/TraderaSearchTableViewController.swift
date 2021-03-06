//
//  TraderaSearchTableViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-19.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class TraderaSearchTableViewController: UITableViewController {

    var session:TraderaSession?
    var items:[TraderaItem]?
    let currency=NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        view.backgroundColor=UIColor.yellowColor()
        currency.numberStyle=NSNumberFormatterStyle.CurrencyStyle
        currency.minimumFractionDigits=0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("TraderaSearchTableViewController.tableView(): \(items?.count)")
        return items?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TraderaSearchTableViewCell", forIndexPath: indexPath) as! TraderaSearchTableViewCell
        let row=indexPath.row
        // Det är (ganska) säkert att använda utropstecknet här då numberOfRowsInSection returnerat 0 om items=nil
        cell.descriptionLabel.text=items![row].shortDescription
        cell.priceLabel.text=currency.stringFromNumber(items![row].maxBid)
        print("bildstorlek: \(cell.itemImage.image?.size)")
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! TraderaSearchTableViewCell
        cell.itemImage.imageFromURL(items![indexPath.row].thumbnailLink)
    }
 
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue(\(segue.identifier))")
        switch segue.identifier! {
        case "ShowItemSegue":
            print("Växlar till visning av enskild auktion")
            let vc=segue.destinationViewController as! TraderaItemViewController
            vc.session=session
            if let cell=sender as? TraderaSearchTableViewCell {
                let row=tableView.indexPathForCell(cell)!.row
                let id=items?[row].id
                let _=TraderaService.URLConnection(message: session!.service.getItem(id!), action: "\"http://api.tradera.com/GetItem\"", session: session!, url: TraderaService.publicServiceURL)

            }
        default: print("Okänd segue: \(segue.identifier)")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
