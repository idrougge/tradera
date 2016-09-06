//
//  CreateAuctionViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-29.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class CreateAuctionViewController: UIViewController, UITextFieldDelegate {
    ///// OUTLETS /////
    @IBOutlet weak var shortDescriptionTextField: UITextField!
    @IBOutlet weak var longDescriptionTextView: UITextView!
    @IBOutlet weak var startingTimeButton: UIButton!
    @IBOutlet weak var endingTimeButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var startingBidTextField: UITextField!
    @IBOutlet weak var buyNowTextField: UITextField!

    ///// IVARS /////
    var session:TraderaSession!
    var item=[String:String]()
    var startingTime:NSDate?
    var endingTime:NSDate?
    /////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(NSString(string: #file).lastPathComponent).\(#function)")
        // Do any additional setup after loading the view.
        startingBidTextField.delegate=self
        buyNowTextField.delegate=self
        let tapToHideKeyboard=UITapGestureRecognizer(target: self, action: #selector(textFieldShouldEndEditing))
        view.addGestureRecognizer(tapToHideKeyboard)
        self.navigationController?.title="Hej"
        let datepicker=UIDatePicker()
        startingBidTextField.inputView=datepicker
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
        case "SelectShippingTypesSegue", "SelectPaymentTypesSegue":
            print("Växlar till val av betalnings- och fraktalternativ")
            let vc=segue.destinationViewController as! SelectPaymentShippingViewController
            vc.session=session
        default:
            print("Okänd segue!")
        }
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("\(#function): \(textField)")
        textField.resignFirstResponder()
        return true
    }
    @IBAction func startingBidEditingDidEnd(sender: UITextField) {
        print("\(#function): \(sender.text)")
        sender.resignFirstResponder()
    }
    @IBAction func buyNowEditingDidEnd(sender: UITextField) {
        print("\(#function): \(sender.text)")
        sender.resignFirstResponder()
    }

    @IBAction func createAuction(sender: AnyObject) {
        //
    }

}
