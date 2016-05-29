//
//  ViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-16.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
// obs alla protokollen ovan
    @IBOutlet weak var resultField: UITextField!
    var mutableData:NSMutableData=NSMutableData()
    var currentElementName:NSString=""
    let session=TraderaSession()
    //let service=session.service
    @IBOutlet weak var tableview: UITableView!
    let categoryDelegate=CategoryTableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hämta kategorier
        let _=TraderaService.URLConnection(message: session.service.getCategories(), action: "\"http://api.tradera.com/GetCategories\"", session: session, url: TraderaService.publicServiceURL)
        tableview.delegate=categoryDelegate
        tableview.dataSource=categoryDelegate
        
        tableview.registerNib(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        resultField.resignFirstResponder()
        session.notifications.addObserver(self, selector: #selector(didReceiveNotification), name: TraderaService.notifications.didFinishParsing.rawValue, object: nil)
        session.notifications.addObserver(self, selector: #selector(showSearch), name: TraderaService.notifications.didFinishSearching.rawValue, object: nil)
        session.notifications.addObserver(self, selector: #selector(showTime), name: TraderaService.notifications.gotTime.rawValue, object: nil)
        session.notifications.addObserver(self, selector: #selector(reloadCategories), name: TraderaService.notifications.gotCategories.rawValue, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveNotification(notification:NSNotification) {
        print("ViewController mottog anrop \"\(notification.name)\" till NSNotificationCenter!")
        print("objekt: \(notification.object)")
    }
    func reloadCategories() {
        print("Läser in kategorierna igen")
        categoryDelegate.categories=TraderaService.categories
        tableview.reloadData()
    }
    func showTime() {
        print("Mottog tidsuppdatering")
        resultField.text=session.time
    }

    @IBAction func sendButton(sender: AnyObject) {
        //let connection=TraderaService.URLConnection(message: service.getCategories(), action: "\"http://api.tradera.com/GetCategories\"", session: session, url: TraderaService.publicServiceURL)
        let _=TraderaService.URLConnection(message: session.service.search(resultField.text!), action: "\"http://api.tradera.com/Search\"", session: session, url: TraderaService.searchServiceURL)
        // Uppkopplingen är asynkron
    }
   
    @IBAction func showList(sender: AnyObject) {
        sendButton("")
        //performSegueWithIdentifier("ShowSearchResultsSegue", sender: view)
    }
    func showSearch() {
        print("Sökresultat hittades")
        performSegueWithIdentifier("ShowSearchResultsSegue", sender: view)
    }

    @IBAction func getTime(sender: AnyObject) {
        let _=TraderaService.URLConnection(message: session.service.getOfficialTime(), action: "\"http://api.tradera.com/GetOfficalTime\"", session: session, url: TraderaService.publicServiceURL)
        resultField.text=session.time
    }
    
    @IBAction func showItem(sender: AnyObject) {
        guard let id=session.items.last?.id
            else {print("Hittade inget id!");return}
        let _=TraderaService.URLConnection(message: session.service.getItem(id), action: "\"http://api.tradera.com/GetItem\"", session: session, url: TraderaService.publicServiceURL)
        //performSegueWithIdentifier("ShowItemSegue", sender: self)
    }
    
    @IBAction func clearItems(sender: AnyObject) {
        session.items=[]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue(\(segue.identifier))")
        switch segue.identifier! {
        case "ShowSearchResultsSegue":
            print("Växlar till visning av sökresultat")
            let vc=segue.destinationViewController as! TraderaSearchTableViewController
            vc.session=session
            print("session.items: \(session.items)")
            vc.items=session.items
        case "ShowItemSegue":
            print("Växlar till visning av enskild auktion")
            //let vc=segue.destinationViewController as! TraderaItemViewController
            //vc.item=session.items.last
        default: print("Okänd segue: \(segue.identifier)")
        }
    }
}

