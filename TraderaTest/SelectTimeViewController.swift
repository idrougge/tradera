//
//  SelectTimeViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-29.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class SelectTimeViewController: UIViewController {

    @IBOutlet weak var startingDatePicker: UIDatePicker!
    @IBOutlet weak var endingDatePicker: UIDatePicker!
    var parent:CreateAuctionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(NSString(string: #file).lastPathComponent).\(#function)")
        // Do any additional setup after loading the view.
        print("parentViewController=\(parentViewController)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func willMoveToParentViewController(parent: UIViewController?) {
        print("\(#function): \(parent)")
        //if parent is CreateAuctionViewController {
        if let vc=parent as? CreateAuctionViewController {
            print("Rätt mamma")
            //let vc=parent as! CreateAuctionViewController
            vc.startingTimeButton.setTitle("ny tid", forState: UIControlState.Normal)
        }
    }
    override func didMoveToParentViewController(parent: UIViewController?) {
        print("\(#function): \(parent)")
        //if parent is CreateAuctionViewController {
        if let vc=parent as? CreateAuctionViewController {
            print("Rätt mamma")
            //let vc=parent as! CreateAuctionViewController
            vc.startingTimeButton.setTitle("ny tid", forState: UIControlState.Normal)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        print("\(#function)")
        let startingTime=startingDatePicker.date.description
        let endingTime=endingDatePicker.date.description
        parent?.endingTimeButton.setTitle(startingTime, forState: UIControlState.Normal)
        parent?.startingTimeButton.setTitle(endingTime, forState: UIControlState.Normal)
        parent?.item["startingTime"]=startingTime
        parent?.item["endingTime"]=endingTime
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
