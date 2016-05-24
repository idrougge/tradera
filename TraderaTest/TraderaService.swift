//
//  TraderaService.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-18.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation
//////////////////////////////////////////////
// XMLParserProtocol används av XMLParser   //
// som är en intern klass i TraderaService. //
//////////////////////////////////////////////
protocol XMLParserProtocol: NSXMLParserDelegate {
    var session:TraderaSession{get}
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    func parser(parser: NSXMLParser, foundCharacters string: String)
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError)
}
/////////////////////////////////////////////////////////
// Utökning av SequenceType (Array, Dictionary o s v)  //
// för att returnera en sökväg separerad med punkter   //
// för användning med NSDictionary(value:forIndexPath) //
/////////////////////////////////////////////////////////
extension SequenceType where Generator.Element == String {
    func dotPath() -> String {
        return self.joinWithSeparator(".")
    }
}
///////////////////////////////////////////////////////////
// Utökning av UIImageView för att ladda bilder från URL //
///////////////////////////////////////////////////////////
import UIKit // UIKit krävs för UIImageView
extension UIImageView {
    public func imageFromURL(urlstring:String) {
        if let url=NSURL(string: urlstring) {
            let request=NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()){
                (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
                if let data=data {
                    self.image=UIImage(data: data)
                }
            }
        }
    }
}
////////////////////////////////////////////////////////////
// Utökning av Dictionary för att få en del av            //
// NSDictionarys funktionalitet. Används för att kunna    //
// sätta värden i nästlade listor när XML-dokument parsas //
////////////////////////////////////////////////////////////
extension Dictionary {
    public mutating func setValue(val:String, forKeyPath:[String]) {
        if forKeyPath.isEmpty {return}
        var path=forKeyPath
        //print("setValue anropades med värde \(val) och sökväg \(path.dotPath())")
        let first=path.removeFirst()
        guard let key=first as? Key else {print("Ogiltig nyckel!"); return}
        if path.isEmpty { //, let key=first as? Key {
            self[key]=val as? Value
        }
        else {
            var newDict=[String:AnyObject]()
            if let subDict=self[key] as? [String:AnyObject] {
                //print("Hittade sublista")
                newDict=subDict
            }
            else {
                //print("Kunde inte hitta sublista!")
                newDict=[String:AnyObject]()
            }
            newDict.setValue(val, forKeyPath: path)
            self[key]=newDict as? Value
        }
    }
}
/////////////////////////////////////////////////////////
// TraderaService innehåller nödvändiga konstanter för //
// att kunna skapa SOAP-meddelanden till Tradera samt  //
// tillhörande funktioner.                             //
//                                                     //
// Här finns även en lista med meddelanden till        //
// NSNotificationCenter och en NSDateFormatter för att //
// konvertera datumsträngar till NSDate-objekt.        //
//                                                     //
// TraderaService har även interna klasser:            //
// XMLParser med tillhörande interna klasser           //
// tolkar SOAP-data som hämtats av URLConnection       //
/////////////////////////////////////////////////////////
class TraderaService {
    static let appid=1589
    static let servicekey="52227af6-11f2-4b9a-b321-0c6b97d24d76"
    static let publickey="4e1c7c27-b028-4a34-a61e-0775030a24d1"
    static let publicServiceURL="http://api.tradera.com/v3/PublicService.asmx"
    static let searchServiceURL="http://api.tradera.com/v3/searchservice.asmx"
    static let xmlns:String="\"http://api.tradera.com\""
    static let dateformatter=NSDateFormatter()
    struct notifications {
        static let didFinishParsing="didFinishParsing"
    }
    static let preamble="<?xml version=\"1.0\" encoding=\"utf-8\"?>        <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    static let header=String(format:"\(preamble)    <soap:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\"></ConfigurationHeader>    </soap:Header>",appid,servicekey)
    
    ///// INIT /////
    init(){
        TraderaService.dateformatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSS"
    }
    ///// GETOFFICIALTIME /////
    func getOfficialTime() -> String {
        var req=[String:AnyObject]()
        req["soap:Body"]="<soap:GetOfficalTime/>"
        print("req=\(req)")
        return XMLRequest(req)
    }
    ///// SEARCH /////
    func search(term:String) -> String {
        var req=[String:AnyObject]()
        var opts=["query":term]
        opts["categoryId"]="0"
        opts["pageNumber"]="1"
        opts["orderBy"]="Relevance"
        //req["Body"]=["Search xmlns=\"http://api.tradera.com\"":opts]
        req["soap:Body"]=["Search xmlns=\"http://api.tradera.com\"":opts]
        print("req=\(req)")
        print(XMLTree(req))
        return XMLRequest(req)
    }
    ///// GETITEM /////
    func getItem(id:Int) -> String {
        let opts=["itemId":String(id)]
        let req=["soap:Body":["GetItem xmlns=\"http://api.tradera.com\"":opts]]
        print("req=\(req)")
        print(XMLTree(req))
        return XMLRequest(req)
    }
    ///// XMLREQUEST /////
    func XMLRequest(dict:[String:AnyObject]) -> String {
        var xml="\(TraderaService.header)"
        for (key,value) in dict {
            print("key=\(key)\nvalue=\(value)")
            xml+=XMLTree([key:value])
        }
        xml+="</soap:Envelope>"
        print(xml)
        return xml
    }
    ///// XMLTREE /////
    func XMLTree(dict:[String:AnyObject]) -> String {
        var text=""
        for (key,value) in dict {
            switch value {
            case let element as String:
                let tag="<\(key)>\(element)</\(key)>\n"
                text+=tag
            case let element as [String:AnyObject]:
                text+="<\(key)>\(XMLTree(element))</\(key.componentsSeparatedByString(" ")[0])>"
            default:
                print("***Ogiltigt format på listan! (\(value))")
            }
        }
        return text
    }
    ////////////////////////////////////////////////////////////
    // XMLParser är grundklassen för tolkning av SOAP-data.   //
    // Klassen följer XMLParserProtocol definierat ovan.      //
    // När parsern stöter på särskilda nyckelord delegeras    //
    // vidare parsning till någon av de interna subklasserna. //
    ////////////////////////////////////////////////////////////
    class XMLParser:NSObject, XMLParserProtocol {
        var currentElementName:NSString=""
        //var currentElement=""
        var currentElement:String?
        //var foundItem=false
        var currentItem=[String:String]()
        var errors=0
        var incomplete=0
        var items:[TraderaItem]?
        let session:TraderaSession
        var delegate:XMLParser?
        
        init(session:TraderaSession) {
            self.session=session
            super.init()
            self.delegate=self
        }
        func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
            print("parser.didStartElement: \(elementName)")
            currentElementName=elementName
            currentElement=nil
            if elementName=="GetOfficalTimeResult" {
                delegate=timeParser(session: session)
                parser.delegate=delegate
            }
            if elementName=="SearchResult" {
                delegate=searchParser(session: session)
                parser.delegate=delegate
            }
            if elementName=="GetItemResult" {
                delegate=auctionParser(session: session, parent: self)
                parser.delegate=delegate
            }
        }
        func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            print("parser.didEndElement: \(elementName)")
            print("\(elementName)=\(currentItem[elementName])")
        }
        func parser(parser: NSXMLParser, foundCharacters string: String) {
            currentElement=(currentElement ?? "")+string
        }
        func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
            print("Parsningsfel!")
            errors+=1
        }
        //////////// timeParser ////////////
        class timeParser:XMLParser {
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                if elementName=="GetOfficalTimeResult" {
                    let currentTime=NSDate()
                    print("currentTime=\(currentTime)")
                    let dateformatter=NSDateFormatter()
                    dateformatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSS"
                    guard let timedate=dateformatter.dateFromString(currentElement!)
                        else {print("Fel: Kunde inte konvertera datumstämpel!");return}
                    print("timedate=\(timedate)")
                    session.time=String(timedate)
                }
            }
        }
        //////////// searchParser ////////////
        class searchParser:XMLParser {
            var item=[String:String]()
            
            //// didStartElement ////
            override func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
                print("searchParser.didStartElement: \(elementName)")
                currentElement=nil
                if elementName=="Items" {
                    item=[String:String ]()
                }
            }
            //// didEndElement ////
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                item[elementName]=currentElement
                if elementName=="Items" {
                    print("item=\(item)")
                    if let searchItem=TraderaItem(fromDict: item) {
                        session.items.append(searchItem)
                    }
                }
            }
        }
        //////////// auctionParser ////////////
        class auctionParser:XMLParser {
            let parent:XMLParser?
            var item=[String:AnyObject]()
            var seller=[String:String]()
            var path=[String]()
            var lastElementName=""
            
            init(session: TraderaSession, parent:XMLParser) {
                self.parent=parent
                super.init(session: session)
            }
            //// didStartElement ////
            override func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
                path.append(elementName)
                print("path=\(path.dotPath())")
                //item.setValue("", forKeyPath: path.dotPath())
                //item.setValue("bla", forKeyPath: path)
                //print("item=\(item)")
                currentElement=nil
            }
            //// didEndElement ////
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                print("->path=\(path)")
                if elementName=="GetItemResult" {
                    print("Hittade slut på GetItemResult")
                    print("item=\(item)")
                    makeItem()
                    parser.delegate=parent
                }
                if elementName == "LongDescription" {path.popLast();return} // debug t v
                print("\(elementName) bör vara \(currentElement ?? "tom")")

                guard let element=currentElement
                    else {print("Försökte sätta \(path.dotPath()) till nil-värde"); path.popLast(); return}
                item.setValue(element, forKeyPath: path)
                
                if elementName==path.last {
                    path.popLast()
                }
                print("item=\(item)")
                currentElement=nil
                print("<-path=\(path)")
            }
            func makeItem() {
                var auctionItem=[String:String]()
                auctionItem["Id"]=item["Id"] as? String
                auctionItem["ShortDescription"]=item["ShortDescription"] as? String
                auctionItem["SellerId"]=item["Seller"]?["Id"] as? String
                auctionItem["SellerAlias"]=item["Seller"]?["Alias"] as? String
                auctionItem["MaxBid"]=item["MaxBid"] as? String
                auctionItem["ThumbnailLink"]=item["ThumbnailLink"] as? String
                auctionItem["SellerDsrAverage"]=item["Seller"]?["TotalRating"] as? String
                auctionItem["EndDate"]=item["EndDate"] as? String
                auctionItem["NextBid"]=item["NextBid"] as? String
                auctionItem["HasBids"]=item["TotalBids"] as? String
                auctionItem["IsEnded"]=item["Status"]?["Ended"] as? String
                auctionItem["ItemType"]=item["ItemType"] as? String
                auctionItem["BuyItNowPrice"]=item["BuyItNowPrice"] as? String
                print("auctionItem=\(auctionItem)")
                if let traderaItem=TraderaItem(fromDict: auctionItem) {
                    print("Lyckades skapa auktionsobjekt")
                }
                else {print("Misslyckades med att skapa auktionsobjekt")}
            }
        }
    }
    ///////////////////////////////////////////////////////////
    // URLConnection hanterar asynkron hämtning av SOAP-data //
    // från Tradera och delegerar tolkningen till XMLParser. //
    ///////////////////////////////////////////////////////////
    class URLConnection:NSObject,NSURLConnectionDelegate {
        var mutableData:NSMutableData=NSMutableData()
        var currentElementName:NSString=""
        //let service=TraderaService()
        //var items:[TraderaItem]?
        //var items=[TraderaItem]()
        var errors=0
        var incomplete=0
        //let session=TraderaSession()
        let session:TraderaSession?

        init(message:String, action:String, session:TraderaSession, url urlString:String) {
            self.session=session
            //let urlString=TraderaService.searchServiceURL
            let url=NSURL(string:urlString)
            let request=NSMutableURLRequest(URL: url!)
            let msgLength=message.characters.count
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
            //request.addValue("\"http://api.tradera.com/Search\"", forHTTPHeaderField: "SOAPAction")
            request.addValue(action, forHTTPHeaderField: "SOAPAction")
            request.HTTPMethod="POST"
            //request.HTTPBody=soapMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            request.HTTPBody=message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            // NSURLConnection verkar ha ersatts av NSURLSession
            super.init()
            let connection=NSURLConnection(request: request, delegate: self, startImmediately: true)
            connection!.start()
            if(connection==true) {
                print("connection==true")
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
            let response=NSString(data: mutableData, encoding: NSUTF8StringEncoding)
            print("response: \(response)")
            let xmlParser=NSXMLParser(data: mutableData)
            //xmlParser.delegate=self
            let parserDelegate=TraderaService.XMLParser(session: session!)
            //xmlParser.delegate=TraderaService.XMLParser(session: session)
            xmlParser.delegate=parserDelegate
            //xmlParser.delegate=service.XMLParser(session: session)
            if xmlParser.parse() {
                print("Parsningen avslutades.")
                session?.notifications.postNotificationName("notification", object: self)
                session?.notifications.postNotificationName(TraderaService.notifications.didFinishParsing, object: self)
            }
            xmlParser.shouldResolveExternalEntities=true
        }
    }
}