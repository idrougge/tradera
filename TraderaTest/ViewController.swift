//
//  ViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-16.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, NSURLConnectionDelegate, NSXMLParserDelegate {
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
        TraderaService.URLConnection(message: service.search(), action: "\"http://api.tradera.com/Search\"", session: session)
        
    }

    // Används av NSURLConnectionDataDelegate
    func connection(connection:NSURLConnection!,didReceiveResponse response:NSURLResponse!) {
        mutableData.length=0
    }
    // Används av NSURLConnectionDataDelegate
    func connection(connection:NSURLConnection!,didReceiveData data:NSData!) {
        mutableData.appendData(data)
    }
    // Används av NSURLConnectionDataDelegate
    func connectionDidFinishLoading(connection:NSURLConnection) {
        let response=NSString(data: mutableData, encoding: NSUTF8StringEncoding)
        print("response: \(response)")
        let xmlParser=NSXMLParser(data: mutableData)
        //xmlParser.delegate=self
        let parserDelegate=TraderaService.XMLParser(session: session)
        //xmlParser.delegate=TraderaService.XMLParser(session: session)
        xmlParser.delegate=parserDelegate
        //xmlParser.delegate=service.XMLParser(session: session)
        xmlParser.parse()
        xmlParser.shouldResolveExternalEntities=true
    }

    var currentItem=[String:String]()
    var foundItem=false

    // Används av NSXMLParserDelegate
    func parser(parser:NSXMLParser, didStartElement elementName:String, namespaceURI:String?, qualifiedName qName:String?, attributes attributeDict:[String:String]) {
        currentElementName=elementName
        if elementName=="Items" {
            print("Hittade Item-tagg")
            foundItem=true
            currentItem=[String:String]()
        }
    }
    // Används av NSXMLParserDelegate
    func parser(parser:NSXMLParser, foundCharacters string:String) {
        if currentElementName=="GetOfficalTimeResult" {
            resultField.text=string
            let currentTime=NSDate()
            print("currentTime=\(currentTime)")
            let dateformatter=NSDateFormatter()
            dateformatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSS"
            guard let timedate=dateformatter.dateFromString(string)
                else {print("Fel: Kunde inte konvertera datumstämpel!");return}
            print("timedate=\(timedate)")
            print("väntetid: \(5*NSEC_PER_SEC)")
            dispatch_after(5*NSEC_PER_SEC, dispatch_get_main_queue()){
                print("currentTime=\(currentTime)")}
        }
        if currentElementName=="TotalNumberOfItems" {
            print("Hittade \(string) sökträffar")
        }
        if foundItem {
            var data=""
            if let oldData=currentItem[currentElementName as String] {
                data=oldData+string
                incomplete+=1
            }
            else {
                data=string
            }
            currentItem[currentElementName as String]=data
        }
    }
    
    // Används av NSXMLParserDelegate
    func parser(parser:NSXMLParser, didEndElement elementName:String, namespaceURI:String?, qualifiedName qName:String?) {
        if elementName=="Items" {
            print("Hittade slut på Items-tagg")
            print(currentItem)
            //if let hasBids=currentItem["HasBids"] {} // funkar
            //guard let hasBids=currentItem["HasBids"] // funkar
            //    else {print("Kunde inte konvertera HasBids");return}
            guard let _=currentItem["HasBids"],
                let _=currentItem["IsEnded"] // funkar
                else {print("___Kunde inte konvertera Items-XML: hasBids=\(currentItem["HasBids"]) ; isEnded=\(currentItem["IsEnded"])");return}
            if let traderaItem=TraderaItem(fromDict: currentItem) {
                print("Lyckades skapa auktionsobjekt:")
                print("ID \(traderaItem.id): \(traderaItem.shortDescription)")
                items.append(traderaItem)
                print("Inlagda objekt: \(items.count)")
            }
            else {
                print("Misslyckades att skapa auktionsobjekt!")
                errors+=1
            }
            print("Antal ofullständiga data: \(incomplete)")
            print("Antal felaktiga objekt: \(errors)")
            foundItem=false
        }
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
        request.addValue("\"http://api.tradera.com/GetItem\"", forHTTPHeaderField: "SOAPAction")
        request.HTTPMethod="POST"
        request.HTTPBody=traderaMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let connection=NSURLConnection(request: request, delegate: self, startImmediately: true)
        connection!.start()
        performSegueWithIdentifier("ShowItemSegue", sender: self)
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

