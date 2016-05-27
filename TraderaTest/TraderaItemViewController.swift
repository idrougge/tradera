//
//  TraderaItemViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-21.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class TraderaItemViewController: UIViewController {
    ///// IBOUTLETS /////
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var highestBidLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var descriptionWebView: UIWebView!
    ///// IVARS /////
    var session:TraderaSession?
    ///// VIEWDIDLOAD /////
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        session?.notifications.addObserver(self,
                                           selector: #selector(update),
                                           name: TraderaService.notifications.gotItem.rawValue,
                                           object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    ///////////////////////////////////
    // Lägger in auktionsdata i vyn. //
    ///////////////////////////////////
    func update(notification:NSNotification) {
        print("TraderaItemViewController mottog ett objekt.")
        guard let item=notification.object as? TraderaItem else {
            print("Mottog okänt objekt: \(notification.object)")
            return
        }
        shortDescriptionLabel.text=item.shortDescription
        highestBidLabel.text=TraderaService.currency.stringFromNumber(item.maxBid)
        sellerLabel.text=item.sellerAlias
        if let imageLink=item.imageLink {
            itemImageView.imageFromURL(imageLink)
        }
        else {
            print("Hittade ingen bild!")
        }
        if let longDescription=item.longDescription {
            let html="<head><style type=\"text/css\">body {font-family: \"Helvetica\"; font-size: 16;}</style></head>\(longDescription)"
            //descriptionWebView.loadHTMLString(longDescription, baseURL: nil)
            descriptionWebView.loadHTMLString(html, baseURL: nil)
        }
        
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        print("unwindForSegue: \(unwindSegue.identifier)")
        session?.notifications.removeObserver(self)
        //super.unwindForSegue(unwindSegue, towardsViewController: subsequentVC)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
