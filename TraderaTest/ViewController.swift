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
    let service=TraderaService()
    //var items:[TraderaItem]?
    var items=[TraderaItem]()
    var errors=0
    var incomplete=0
    let session=TraderaSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //print(TraderaService.publickey)
        //print(TraderaService.header)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendButton(sender: AnyObject) {
        
        let traderaTimeMessage=service.search()
        let urlString=TraderaService.searchServiceURL
        let url=NSURL(string:urlString)
        let request=NSMutableURLRequest(URL: url!)
        let msgLength=traderaTimeMessage.characters.count
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        request.addValue("\"http://api.tradera.com/Search\"", forHTTPHeaderField: "SOAPAction")
        request.HTTPMethod="POST"
        //request.HTTPBody=soapMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody=traderaTimeMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        // NSURLConnection verkar ha ersatts av NSURLSession
        //let connection=NSURLConnection(request: request, delegate: self, startImmediately: true)
        //connection!.start()
        /*
        if(connection==true) {
            //var mutableData:Void=NSMutableData.initialize()
        }
        */
        let connection=TraderaService.URLConnection(message: service.search(), action: "\"http://api.tradera.com/Search\"", session: session, url: TraderaService.searchServiceURL)
        
    }
   
    @IBAction func showList(sender: AnyObject) {
        performSegueWithIdentifier("ShowSearchResultsSegue", sender: view)
    }
    
    @IBAction func showTime(sender: AnyObject) {
        let traderaTimeMessage=service.getOfficialTime()
        let urlString=TraderaService.publicServiceURL
        let url=NSURL(string:urlString)
        let request=NSMutableURLRequest(URL: url!)
        let msgLength=traderaTimeMessage.characters.count
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        request.addValue("\"http://api.tradera.com/GetOfficalTime\"", forHTTPHeaderField: "SOAPAction")
        request.HTTPMethod="POST"
        request.HTTPBody=traderaTimeMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let connection=NSURLConnection(request: request, delegate: self, startImmediately: true)
        connection!.start()
        if(connection==true) {
            print("Kopplade upp")
        }
        resultField.text=session.time
    }
    
    @IBAction func showItem(sender: AnyObject) {
        //guard let id=items.last?.id
        guard let id=session.items.last?.id
            else {print("Hittade inget id!");return}
        let traderaMessage=service.getItem(id)
        let urlString=TraderaService.publicServiceURL
        let url=NSURL(string: urlString)
        let request=NSMutableURLRequest(URL: url!)
        let msgLength=traderaMessage.characters.count
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        //request.addValue("\"http://api.tradera.com/GetItem\"", forHTTPHeaderField: "SOAPAction")
        request.HTTPMethod="POST"
        //request.HTTPBody=soapMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody=traderaMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        //let connection=NSURLConnection(request: request, delegate: self, startImmediately: true)
        let connection=TraderaService.URLConnection(message: service.getItem(id), action: "\"http://api.tradera.com/GetItem\"", session: session, url: TraderaService.publicServiceURL)
        //connection!.start()
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
            print("session.items: \(session.items)")
            vc.items=session.items
        case "ShowItemSegue":
            print("Växlar till visning av enskild auktion")
            let vc=segue.destinationViewController as! TraderaItemViewController
            vc.item=session.items.last
        default: print("Okänd segue: \(segue.identifier)")
        }
    }
}

