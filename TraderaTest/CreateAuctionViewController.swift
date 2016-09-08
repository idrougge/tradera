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
    //var item=[String:String]()
    var startingTime:NSDate?
    var endingTime:NSDate?
    var category:Int?
    var itemFieldValues=[String:[String]]()
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
        endingTime=NSDate(timeIntervalSinceNow: 7*24*60*60)
        endingTimeButton.setTitle(endingTime?.description, forState: .Normal)
        let datepicker=UIDatePicker()
        //startingBidTextField.inputView=datepicker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        print("createAuction: \(itemFieldValues)")
        let calendar=NSCalendar.currentCalendar()
        let todaysDate=calendar.startOfDayForDate(NSDate())
        guard let endingTime=endingTime
            else {
                popupAlert("Du måste välja en sluttid för auktionen.")
                return
        }
        let duration=calendar.components(.Day, fromDate: todaysDate, toDate: endingTime, options: .MatchFirst).day
        print("Auktionen går ut \(endingTime) och varar \(duration) dagar")

        guard let itemAttributes=itemFieldValues["ItemAttributes"] where itemFieldValues["ItemAttributes"]?.count>0
            else {
                popupAlert("Du måste ange om objektet är nytt eller begagnat.")
                return
        }
        guard let paymentTypes=itemFieldValues["PaymentTypes"] where itemFieldValues["PaymentTypes"]?.count>0, let shippingTypes=itemFieldValues["ShippingTypes"] where itemFieldValues["ShippingTypes"]?.count>0
            else {
                popupAlert("Du måste ange frakt- och betalningsalternativ.")
                return
        }
        guard let startPrice=Int(startingBidTextField.text!)
            else {
                popupAlert("Ange ett startpris.")
                return
        }
        guard let title=shortDescriptionTextField.text, description=longDescriptionTextView.text
            else {
                popupAlert("Du måste ange en titel och en beskrivning på auktionen.")
                return
        }
        guard let categoryId=category
            else {
                popupAlert("Du måste välja en kategori för auktionen.")
                return
        }
        var auction=[String:AnyObject]()
        auction["Title"]=title
        auction["Description"]=description
        auction["CategoryId"]=categoryId
        auction["Duration"]=duration
        //auction["ItemAttributes"]=["int":itemAttributes.first]
        let attributeInts=["int":itemAttributes.first!]
        auction["ItemAttributes"]=attributeInts
        //auction["PaymentOptionIds"]=paymentTypes
        var paymentOptionIds=[[String:String]]()
        _=paymentTypes.map{
            paymentOptionIds.append(["int":$0])
        }
        auction["PaymentOptionIds"]=paymentOptionIds
        //auction["ShippingOptions"]=shippingTypes
        //auction["ShippingOptions"]=[String:[String:String]]()
        var shippingOptions=[[String:[String:String]]]()
        _=shippingTypes.map{shippingOptions.append(["ItemShipping":["ShippingOptionId":$0,"Cost":"0"]])}
        auction["ShippingOptions"]=shippingOptions
        auction["StartPrice"]=startPrice
        // Här fristilar vi lite
        auction["ItemType"]=1
        if buyNowTextField.text != nil {
            auction["BuyItNowPrice"]=buyNowTextField.text
        }
        auction["Restarts"]=0
        auction["AcceptedBidderId"]=1
        
        print("auction = \(auction)")
        let xml=session.service.itemRequest(auction)
        print("XML=\(xml)")
        session.notifications.addObserver(self, selector: #selector(gotAddItemResult), name: TraderaService.notifications.gotAddItemResult.rawValue, object: nil)
        let _=TraderaService.URLConnection(message: xml, action: "\"http://api.tradera.com/AddItem\"", session: session, url: TraderaService.restrictedServiceURL)
    }
    
    func popupAlert(message:String, title:String="Kan inte lägga upp auktion") {
        let alert=UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil))
        presentViewController(alert, animated: true, completion: nil)

    }
    
    func gotAddItemResult(notification:NSNotification) {
        guard let result=notification.object as? [String:String]
            else {return}
        guard let itemId=result["ItemId"], requestId=result["RequestId"]
            else {
                popupAlert("Hittade inget request-ID eller item-ID.")
                return
        }
        print("Auktionen lades upp med id \(itemId). Begäran fick id \(requestId).")
        popupAlert("Auktionen lades upp med id \(itemId). Begäran fick id \(requestId). Ett sista anrop behöver göras för att lägga in auktionen i systemet.", title: "Skapade auktion")
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
            vc.parent=self
        default:
            print("Okänd segue!")
        }
    }


}
