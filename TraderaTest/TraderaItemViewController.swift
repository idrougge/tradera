//
//  TraderaItemViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-21.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class TraderaItemViewController: UIViewController {

    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var highestBidLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    var item:TraderaItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let item=item
            else {
                shortDescriptionLabel.text="Kunde inte hitta något TraderaItem!"
                return
        }
        shortDescriptionLabel.text=item.shortDescription
        highestBidLabel.text=String(item.maxBid)
        itemImageView.imageFromURL(item.thumbnailLink)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
