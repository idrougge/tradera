//
//  SchenkerViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-29.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class SchenkerViewController: UIViewController {

    var session:TraderaSession?
    var collectionpoint:[String:String]?
    @IBOutlet weak var collectionPointNameLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        session?.notifications.addObserver(self, selector: #selector(update), name: TraderaService.notifications.gotSchenker.rawValue, object: nil)
        //let _=TraderaService.URLConnection(message: session!.service.schenker("28140"), action: "\"http://privpakservices.schenker.nu/SearchCollectionPoint\"", session: session!, url: TraderaService.schenkerURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func update(notification:NSNotification) {
        collectionpoint=notification.object as? [String:String]
        collectionPointNameLabel.text=collectionpoint?["DisplayName"]
        streetLabel.text=collectionpoint?["AddressLine1"]
        cityLabel.text=collectionpoint?["City"]
    }
    func search() {
        let _=TraderaService.URLConnection(message: session!.service.schenker(searchTextField.text!), action: "\"http://privpakservices.schenker.nu/SearchCollectionPoint\"", session: session!, url: TraderaService.schenkerURL)
    }
    @IBAction func SearchButton(sender: AnyObject) {
        search()
    }
    @IBAction func SearchTextField(sender: AnyObject) {
        search()
    }
}
