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
    let dateformatter=NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(NSString(string: #file).lastPathComponent).\(#function)")
        // Do any additional setup after loading the view.
        //dateformatter.dateFormat="MM-dd HH:mm"
        dateformatter.dateStyle = .MediumStyle
        dateformatter.timeStyle = .ShortStyle
        guard let startingTime=parent?.startingTime, endingTime=parent?.endingTime else {
            print("Ingen giltig tid i moderkontrollern!")
            return
        }
        startingDatePicker.date=startingTime
        endingDatePicker.date=endingTime
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("\(#function)")
        //let startingTime=startingDatePicker.date.description
        let startingTime=dateformatter.stringFromDate(startingDatePicker.date)
        let endingTime=dateformatter.stringFromDate(endingDatePicker.date)
        parent?.startingTimeButton.setTitle(startingTime, forState: UIControlState.Normal)
        parent?.endingTimeButton.setTitle(endingTime, forState: UIControlState.Normal)
        parent?.item["startingTime"]=startingDatePicker.date.description
        parent?.item["endingTime"]=endingDatePicker.date.description
        parent?.startingTime=startingDatePicker.date
        parent?.endingTime=endingDatePicker.date
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
