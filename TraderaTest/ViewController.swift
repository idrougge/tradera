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
    @IBOutlet weak var celsiusField: UITextField!
    var mutableData:NSMutableData=NSMutableData()
    var currentElementName:NSString=""
    let tra=TraderaService()
    var items:[TraderaItem]?
    var errors=0
    var incomplete=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //print(TraderaService.publickey)
        //print(TraderaService.header)
        //print(tra.getOfficialTime())
        tra.getOfficialTime()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendButton(sender: AnyObject) {
        //let celsius=celsiusField.text
        //let soapMessage="<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><CelsiusToFahrenheit xmlns='http://www.w3schools.com/xml/'><Celsius>\(celsius!)</Celsius></CelsiusToFahrenheit></soap12:Body></soap12:Envelope>"
        //let traderaTimeMessage="<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"http://api.tradera.com\"> <SOAP-ENV:Header>   <AuthenticationHeader xmlns=\"http://api.tradera.com\">        <AppId>1589</AppId>        <AppKey>52227af6-11f2-4b9a-b321-0c6b97d24d76</AppKey>        </AuthenticationHeader> </SOAP-ENV:Header> <SOAP-ENV:Body><ns1:GetOfficalTime/></SOAP-ENV:Body></SOAP-ENV:Envelope>"
        let traderaTimeMessage=tra.getOfficialTime()
        //print("traderaTimeMessage=\(traderaTimeMessage)")
        //print("soapMessage: \(soapMessage)")
        //let urlString="http://www.w3schools.com/xml/tempconvert.asmx"
        //let urlString="http://api.tradera.com/v3/PublicService.asmx"
        let urlString="http://api.tradera.com/v3/searchservice.asmx"
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
        let connection=NSURLConnection(request: request, delegate: self, startImmediately: true)
        connection!.start()
        if(connection==true) {
            //var mutableData:Void=NSMutableData.initialize()
        }
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
        //let response=NSString(data: mutableData, encoding: NSUTF8StringEncoding)
        //print("response: \(response)")
        let xmlParser=NSXMLParser(data: mutableData)
        xmlParser.delegate=self
        xmlParser.parse()
        xmlParser.shouldResolveExternalEntities=true
    }
    //var currentItem:TraderaItem?
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
            celsiusField.text=string
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
                items?.append(traderaItem)
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
}

