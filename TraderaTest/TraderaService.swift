//
//  TraderaService.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-18.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation

protocol XMLParserProtocol: NSXMLParserDelegate {
    var session:TraderaSession{get}
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    func parser(parser: NSXMLParser, foundCharacters string: String)
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError)
}
//////////////////////////////////////////////////////////
extension SequenceType where Generator.Element == String {
    func dotPath() -> String {
        return self.joinWithSeparator(".")
    }
}
//////////////////////////////////////////////////////////
import UIKit
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
//////////////////////////////////////////////////////////
extension Dictionary {
    public mutating func setValue(val:String, forKeyPath:[String]) {
        if forKeyPath.isEmpty {return}
        var path=forKeyPath
        print("setValue anropades med värde \(val) och sökväg \(path.dotPath())")
        let first=path.removeFirst()
        guard let key=first as? Key else {print("Ogiltig nyckel!"); return}
        if path.isEmpty { //, let key=first as? Key {
            self[key]=val as? Value
        }
        else {
            var newDict=[String:AnyObject]()
            if let subDict=self[key] as? [String:AnyObject] {
                print("Skapade sublista")
                newDict=subDict
            }
            else {
                print("Kunde inte skapa sublista!")
                newDict=[String:AnyObject]()
            }
            newDict.setValue(val, forKeyPath: path)
            self[key]=newDict as? Value
        }
    }
}
//////////////////////////////////////////////////////////

class TraderaService {
    static let appid=1589
    static let servicekey="52227af6-11f2-4b9a-b321-0c6b97d24d76"
    static let publickey="4e1c7c27-b028-4a34-a61e-0775030a24d1"
    static let publicServiceURL="http://api.tradera.com/v3/PublicService.asmx"
    static let searchServiceURL="http://api.tradera.com/v3/searchservice.asmx"
    static let xmlns:String="\"http://api.tradera.com\""
    static let dateformatter=NSDateFormatter()
    
    init(){
        TraderaService.dateformatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSS"
    }
    
    static let preamble="<?xml version=\"1.0\" encoding=\"utf-8\"?>        <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    static let header=String(format:"\(preamble)    <soap:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\"></ConfigurationHeader>    </soap:Header>",appid,servicekey)

    func getOfficialTime() -> String {
        var req=[String:AnyObject]()
        req["soap:Body"]="<soap:GetOfficalTime/>"
        print("req=\(req)")
        return XMLRequest(req)
    }
    func search() -> String {
        var req=[String:AnyObject]()
        var opts=["query":"Nintendo"]
        opts["categoryId"]="0"
        opts["pageNumber"]="1"
        opts["orderBy"]="Relevance"
        //req["Body"]=["Search xmlns=\"http://api.tradera.com\"":opts]
        req["soap:Body"]=["Search xmlns=\"http://api.tradera.com\"":opts]
        print("req=\(req)")
        print(XMLTree(req))
        return XMLRequest(req)
    }
    
    func getItem(id:Int) -> String {
        let opts=["itemId":String(id)]
        let req=["soap:Body":["GetItem xmlns=\"http://api.tradera.com\"":opts]]
        print("req=\(req)")
        print(XMLTree(req))
        return XMLRequest(req)
    }
    
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
    func XMLTree(dict:[String:AnyObject]) -> String {
        var text=""
        for (key,value) in dict {
            //print("***XMLTree: key=\(key), value=\(value)")
            switch value {
            case let element as String:
                let tag="<\(key)>\(element)</\(key)>\n"
                text+=tag
            case let element as [String:AnyObject]:
                //print("element=\(element)")
                text+="<\(key)>\(XMLTree(element))</\(key.componentsSeparatedByString(" ")[0])>"
            default:
                print("***Ogiltigt format på listan! (\(value))")
            }
        }
        return text
    }
    ///////////////////////////////////////////////
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
                delegate=searchParser(session: session)
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
    ///////////////////////////////////////////////
    //class XMLParser:NSObject, NSXMLParserDelegate {
    class XMLParser_old:NSObject, XMLParserProtocol {
        //var currentElementName=""
        var currentElementName:NSString=""
        var foundItem=false
        var getItemResult=false
        var currentItem=[String:String]()
        var item=[String:String]()
        var seller=[String:String]()
        var errors=0
        var incomplete=0
        var items:[TraderaItem]?
        let session:TraderaSession
        ////// INIT //////
        init(session:TraderaSession) {
            self.session=session
            self.items=session.items
        }
        // didStartElement //
        func parser(parser:NSXMLParser, didStartElement elementName:String, namespaceURI:String?, qualifiedName qName:String?, attributes attributeDict:[String:String]) {
            print("parser.didStartElement: \(elementName)")
            currentElementName=elementName
            if elementName=="Items" {
                print("Hittade Item-tagg")
                foundItem=true
                item=[String:String]()
                currentItem=item
            }
            if elementName=="GetItemResult" {
                print("Hittade GetItemResult-tagg")
                getItemResult=true
                seller=[String:String]()
                item=[String:String]()
                item["bajs"]="korv"
                currentItem=item
                //let auctionDelegate=auctionParser(session: session)
                //parser.delegate=auctionDelegate
                //parser.delegate=self
            }
            if elementName=="Seller" {
                print("Hittade början på Seller-tagg")
                item=currentItem
                currentItem=seller
                seller["hata"]="apa"
                currentItem["piss"]="skit"
                //parser.delegate=self  // Hur funkar det här egentligen? Varifrån kommer "parser"?
            }
        }
        // foundCharacters
        func parser(parser:NSXMLParser, foundCharacters string:String) {
            print("parser.foundCharacters: \(string)")
            if currentElementName=="GetOfficalTimeResult" {
                //resultField.text=string
                let currentTime=NSDate()
                print("currentTime=\(currentTime)")
                let dateformatter=NSDateFormatter()
                dateformatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSS"
                guard let timedate=dateformatter.dateFromString(string)
                    else {print("Fel: Kunde inte konvertera datumstämpel!");return}
                print("timedate=\(timedate)")
                session.time=String(timedate)
            }
            if currentElementName=="TotalNumberOfItems" {
                print("Hittade \(string) sökträffar")
            }
            if foundItem || getItemResult {
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
        func parserDidStartDocument(parser: NSXMLParser) {
            print("parserDidStartDocument:parser")
        }
        func parserDidEndDocument(parser:NSXMLParser) {
            print("parserDidEndDocument:parser")
        }
        func parser(parser: NSXMLParser, didStartMappingPrefix prefix:String, toURI namespaceURI:String) {
            print("parser.didStartMappingPrefix: \(prefix) toURI: \(namespaceURI)")
        }
        func parser(parser: NSXMLParser, parseErrorOccurred parseError:NSError) {
            print("parser.parseErrorOccured: \(parseError.localizedDescription)")
        }
        
        // didEndElement
        func parser(parser:NSXMLParser, didEndElement elementName:String, namespaceURI:String?, qualifiedName qName:String?) {
            print("parser.didEndElement: \(elementName)")
            if elementName=="Items" {
                print("Hittade slut på Items-tagg")
                print(currentItem)
                guard let _=currentItem["HasBids"],
                    let _=currentItem["IsEnded"] // funkar
                    else {print("___Kunde inte konvertera Items-XML: hasBids=\(currentItem["HasBids"]) ; isEnded=\(currentItem["IsEnded"])");return}
                if let traderaItem=TraderaItem(fromDict: currentItem) {
                    print("Lyckades skapa auktionsobjekt:")
                    print("ID \(traderaItem.id): \(traderaItem.shortDescription)")
                    //items?.append(traderaItem)
                    session.items.append(traderaItem)
                    print("Inlagda objekt: \(items?.count)")
                }
                else {
                    print("Misslyckades att skapa auktionsobjekt!")
                    errors+=1
                }
                print("Antal ofullständiga data: \(incomplete)")
                print("Antal felaktiga objekt: \(errors)")
                foundItem=false
            }
            if elementName=="Seller" {
                print("Hittade slut på Seller-tagg")
                print(seller)
                seller=currentItem
                currentItem=item
            }
            if elementName=="GetItemResult" {
                print("Hittade slut på GetItemResult")
                currentItem["ShortDescription"]="Kort beskrivning"
                currentItem["SellerId"]="999"
                currentItem["SellerAlias"]="Försäljare Försäljarsson"
                currentItem["SellerDsrAverage"]="0"
                currentItem["HasBids"]="false"
                currentItem["IsEnded"]="false"
                print(currentItem)
                print("seller=\(seller)")
                if let traderaItem=TraderaItem(fromDict: currentItem) {
                    print("Lyckades skapa auktionsobjekt:")
                    print("ID \(traderaItem.id): \(traderaItem.shortDescription)")
                    //items?.append(traderaItem)
                    session.items.append(traderaItem)
                    print("Inlagda objekt: \(items?.count)")
                }
            }
        }
        
        func parser(parser: NSXMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
            print("parser.foundExternalEntityDeclarationWithName: \(name)")
        }
        ///////////////////////////////
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
            xmlParser.parse()
            xmlParser.shouldResolveExternalEntities=true
        }
    }
}