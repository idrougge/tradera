//
//  CreateAuctionViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-29.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class CreateAuctionViewController: UIViewController {
    ///// OUTLETS /////
    @IBOutlet weak var shortDescriptionTextField: UITextField!
    @IBOutlet weak var longDescriptionTextView: UITextView!
    @IBOutlet weak var startingTimeButton: UIButton!
    @IBOutlet weak var endingTimeButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    ///// IVARS /////
    var item=[String:String]()
    /////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(NSString(string: #file).lastPathComponent).\(#function)")
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("\(#function): \(segue.identifier)")
        switch segue.identifier! {
        case "SelectStartingTimeSegue", "SelectEndingTimeSegue":
            let vc=segue.destinationViewController as! SelectTimeViewController
            vc.parent=self
        case "SelectCategorySegue":
            let vc=segue.destinationViewController as! SelectCategoryViewController
            vc.parent=self
        default:
            print("Okänd segue!")
        }
    }

    @IBAction func createAuction(sender: AnyObject) {
        //
    }

}
