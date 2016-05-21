//
//  TraderaService.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-18.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation

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
    
    //static let preamble="<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"http://api.tradera.com\">"
    static let preamble="<?xml version=\"1.0\" encoding=\"utf-8\"?>        <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//    static let header=String(format:"\(preamble)    <SOAP-ENV:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\">    <Sandbox>int</Sandbox><MaxResultAge>int</MaxResultAge>    </ConfigurationHeader>    </SOAP-ENV:Header>",appid,servicekey)
    //static let header=String(format:"\(preamble)    <SOAP-ENV:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\"></ConfigurationHeader>    </SOAP-ENV:Header>",appid,servicekey)
    static let header=String(format:"\(preamble)    <soap:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\"></ConfigurationHeader>    </soap:Header>",appid,servicekey)
    //let traderaTimeMessage="<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"http://api.tradera.com\"> <SOAP-ENV:Header>   <AuthenticationHeader xmlns=\"http://api.tradera.com\">        <AppId>1589</AppId>        <AppKey>52227af6-11f2-4b9a-b321-0c6b97d24d76</AppKey>        </AuthenticationHeader> </SOAP-ENV:Header> <SOAP-ENV:Body><ns1:GetOfficalTime/></SOAP-ENV:Body></SOAP-ENV:Envelope>"

    func getOfficialTime() -> String {
        var req=[String:AnyObject]()
        req["soap:Body"]="<soap:GetOfficalTime/>"
        print("req=\(req)")
        return XMLRequest(req)
    }
    func search() -> String {
        var req=[String:AnyObject]()
        var opts=["query":"Amiga"]
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
    class XMLParser:NSObject, NSXMLParserDelegate {
        //var currentElementName=""
        var currentElementName:NSString=""
        var foundItem=false
        var currentItem=[String:String]()
        var errors=0
        var incomplete=0
        var items:[TraderaItem]?
        let session:TraderaSession
        
        init(session:TraderaSession) {
            self.session=session
            self.items=session.items
        }
        // Används av NSXMLParserDelegate
        func parser(parser:NSXMLParser, didStartElement elementName:String, namespaceURI:String?, qualifiedName qName:String?, attributes attributeDict:[String:String]) {
            print("parser.didStartElement: \(elementName)")
            currentElementName=elementName
            if elementName=="Items" {
                print("Hittade Item-tagg")
                foundItem=true
                currentItem=[String:String]()
            }
        }
        // Används av NSXMLParserDelegate
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
        
        // Används av NSXMLParserDelegate
        func parser(parser:NSXMLParser, didEndElement elementName:String, namespaceURI:String?, qualifiedName qName:String?) {
            print("parser.didEndElement: \(elementName)")
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
        }
        
        func parser(parser: NSXMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
            print("parser.foundExternalEntityDeclarationWithName: \(name)")
        }

    }
}