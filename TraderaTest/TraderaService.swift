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
extension SequenceType where Generator.Element == Category {
    func dotPath() -> String {
        //return self.description.joinWithSeparator(".")
        //let strings=self as! [String]
        let strings=self.map{ (category) -> String in
            return category.name
        }
        return strings.joinWithSeparator(".")
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
/////////////////////////////////////////////////////////////
// Utökning av Array (eller Collection för att få en del av//
// NSDictionarys funktionalitet. Används för att kunna     //
// sätta värden i nästlade listor när XML-dokument parsas. //
/////////////////////////////////////////////////////////////
extension MutableCollectionType where Generator.Element==Category {
    mutating func setValue(val:Category, forKeyPath keyPath:[Category]) {
        var cats=self as! [Category]
        if keyPath.isEmpty {
            cats.append(val)
            // Sortering verkar onödig då kategorierna returneras i alfabetisk ordning
            /*
            cats.sortInPlace() {
                return $0.name.localizedCompare($1.name)==NSComparisonResult.OrderedAscending
            }*/
            self=cats as! Self
            return
        }
        var path=keyPath
        let first=path.removeFirst()
        guard let index=self.indexOf(first) as? Int else {
            return
        }
        if cats[index].sub==nil {
            cats[index].sub=[]
        }
        cats[index].sub?.setValue(val, forKeyPath: path)
        self=cats as! Self
    }
}
/////////////////////////////////////////////////////////////
// Utökning av Dictionary för att få en del av             //
// NSDictionarys funktionalitet. Används för att kunna     //
// sätta värden i nästlade listor när XML-dokument parsas. //
/////////////////////////////////////////////////////////////
extension Dictionary {
    public mutating func setValue(val:String, forKeyPath keyPath:[String]) {
        if keyPath.isEmpty {return}
        var path=keyPath
        //print("setValue anropades med värde \(val) och sökväg \(path.dotPath())")
        let first=path.removeFirst()
        guard let key=first as? Key else {print("Ogiltig nyckel!"); return}
        if path.isEmpty {
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
// tolkar SOAP-data som hämtats av URLConnection.      //
/////////////////////////////////////////////////////////
class TraderaService {
    static let appid=Secrets.appid
    static let servicekey=Secrets.servicekey
    static let publickey=Secrets.publickey
    static let schenkerkey=Secrets.schenkerkey
    static var secretkey=NSUUID().UUIDString
    static let path:NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    static let loginFile:String=path.stringByAppendingPathComponent("login.plist")
    static let publicServiceURL="http://api.tradera.com/v3/PublicService.asmx"
    static let searchServiceURL="http://api.tradera.com/v3/searchservice.asmx"
    static let restrictedServiceURL="http://api.tradera.com/v3/restrictedservice.asmx"
    static let loginURL="http://api.tradera.com/tokenlogin.aspx?appId=\(appid)&pkey=\(publickey)&skey=\(secretkey)"
    static let schenkerURL="http://privpakservices.schenker.nu/package/package_1.3/packageservices.asmx"
    static let xmlns:String="\"http://api.tradera.com\""
    static var sandbox=true
    static let dateformatter=NSDateFormatter()
    static let currency=NSNumberFormatter()
    static var categories:[Category]?
    enum notifications:String {
        case didFinishParsing,
        gotTime,
        gotItem,
        didFinishSearching,
        gotCategories,
        gotToken,
        gotSchenker,
        gotUserByAlias,
        gotUserInfo,
        gotItemFieldValues,
        gotAddItemResult
    }
    static let preamble="<?xml version=\"1.0\" encoding=\"utf-8\"?>        <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    static let header=String(format:"\(preamble)    <soap:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\"></ConfigurationHeader>    </soap:Header>",appid,servicekey)
    static var authheader:String { get {
        guard let token=TraderaSession.token, id=TraderaSession.user?.id
            else {return ""}
        return String(format:"\(preamble)    <soap:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <AuthorizationHeader xmlns=\"http://api.tradera.com\">   <UserId>%d</UserId> <Token>%@</Token>    </AuthorizationHeader>   <ConfigurationHeader xmlns=\"http://api.tradera.com\"></ConfigurationHeader>    </soap:Header>",appid,servicekey,id,token)
        }
    }
    
    ///// INIT /////
    init(){
        TraderaService.dateformatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSS"
        TraderaService.currency.numberStyle=NSNumberFormatterStyle.CurrencyStyle
        TraderaService.currency.minimumFractionDigits=0
    }
    ///// GETOFFICIALTIME /////
    func getOfficialTime() -> String {
        var req=[String:AnyObject]()
        req["soap:Body"]="<soap:GetOfficalTime/>"
        return XMLRequest(req)
    }
    ///// SEARCH /////
    func search(term:String) -> String {
        var req=[String:AnyObject]()
        var opts=["query":term]
        opts["categoryId"]="0"
        opts["pageNumber"]="1"
        opts["orderBy"]="Relevance"
        req["soap:Body"]=["Search xmlns=\"http://api.tradera.com\"":opts]
        return XMLRequest(req)
    }
    ///// GETITEM /////
    func getItem(id:Int) -> String {
        let opts=["itemId":String(id)]
        let req=["soap:Body":["GetItem xmlns=\"http://api.tradera.com\"":opts]]
        return XMLRequest(req)
    }
    ///// GETCATEGORIES /////
    func getCategories() -> String {
        var req=[String:AnyObject]()
        req["soap:Body"]="<soap:GetCategories/>"
        return XMLRequest(req)
    }
    ///// GETITEMFIELDVALUES /////
    func getItemFieldValues() -> String {
        let req=["soap:Body":"<GetItemFieldValues xmlns=\"http://api.tradera.com\" />"]
        let xml=XMLRequest(req)
        print(xml)
        return xml
    }
    
    ///// FETCHTOKEN /////
    func fetchToken() -> String {
        let opts=["userId":"\(TraderaSession.authid)","secretKey":TraderaService.secretkey]
        let req=["soap:Body":["FetchToken xmlns=\"http://api.tradera.com\"":opts]]
        let xml=XMLRequest(req)
        //print("XMLRequest=\(xml)")
        return xml
    }
    
    ///// GETUSERBYALIAS /////
    func getUserByAlias(username:String) -> String {
        let opts=["alias":username]
        let req=["soap:Body":["GetUserByAlias xmlns=\"http://api.tradera.com\"":opts]]
        let xml=XMLRequest(req)
        //print("XMLRequest=\(xml)")
        return xml
    }
    
    ///// GETUSERINFO /////
    func getUserInfo(userid:Int) -> String {
        //let token=TraderaSession.token
        //let id=String(TraderaSession.user?.id)
        //let auth=["UserId":id, "Token":token]
        TraderaSession.authid=userid
        let req=["soap:Body":"<GetUserInfo xmlns=\"http://api.tradera.com\" />"]
        let xml=XMLRequest(req, header:TraderaService.authheader)
        print(xml)
        return xml
    }
    ///// ITEMREQUEST /////
    func itemRequest(auction:[String:AnyObject]) -> String {
        let opts=["itemRequest":auction]
        let req=["soap:Body":["AddItem xmlns=\"http://api.tradera.com\"":opts]]
        let xml=XMLRequest(req, header: TraderaService.authheader)
        return xml
    }
    
    ///// SEARCHCOLLECTIONPOINT /////
    func schenker(postcode:String) -> String {
        var req=[String:AnyObject]()
        req["ns1:customerID"]="1"
        req["ns1:key"]=TraderaService.schenkerkey
        req["ns1:paramID"]="0"
        req["ns1:postcode"]=postcode
        req["ns1:address"]=""
        req["ns1:city"]=""
        req["ns1:maxhits"]="1"
        req=["ns1:SearchCollectionPoint":req]
        req=["SOAP-ENV:Body":req]
        //print(schenkerXMLRequest(req))
        return schenkerXMLRequest(req)
    }
    ///// SCHENKERXMLREQUEST /////
    func schenkerXMLRequest(dict:[String:AnyObject]) -> String {
        var xml="<?xml version=\"1.0\" encoding=\"UTF-8\"?>        <SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"http://privpakservices.schenker.nu/\">"
        for (key,value) in dict {
            xml+=XMLTree([key:value])
        }
        xml+="</SOAP-ENV:Envelope>"
        //print(xml)
        return xml
    }
    ///// XMLREQUEST /////
    func XMLRequest(dict:[String:AnyObject], header:String = TraderaService.header) -> String {
        //var xml="\(TraderaService.header)"
        var xml="\(header)"
        for (key,value) in dict {
            print("key=\(key)\nvalue=\(value)")
            xml+=XMLTree([key:value])
        }
        xml+="</soap:Envelope>"
        //print(xml)
        return xml
    }
    ///// XMLTREE /////
    func XMLTree(dict:[String:AnyObject]) -> String {
        var text=""
        for (key,value) in dict {
            switch value {
            case let element as String:
                //print("element as String: \(key) = \(value)")
                let tag="<\(key)>\(element)</\(key)>\n"
                text+=tag
            case let element as Int:
                //print("element as Int: \(key) = \(value)")
                let tag="<\(key)>\(element)</\(key)>\n"
                text+=tag
            case let element as [String:AnyObject]:
                //print("element as [String:AnyObject]: \(key) = \(value)")
                text+="<\(key)>\(XMLTree(element))</\(key.componentsSeparatedByString(" ")[0])>\n"
            case let elements as [[String:AnyObject]]:
                //print("element as [[String:AnyObject]]: \(key) = \(value)")
                text+="<\(key)>\n"
                for element in elements {
                    text+="\(XMLTree(element))\n"
                }
                text+="</\(key.componentsSeparatedByString(" ")[0])>\n"
 
            default:
                print("***Ogiltigt format på listan! \(key) = (\(value))")
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
        var currentElement:String?
        var currentItem=[String:String]()
        var errors=0
        var incomplete=0
        let session:TraderaSession
        var delegate:XMLParser?
        
        init(session:TraderaSession) {
            self.session=session
            super.init()
            self.delegate=self
        }
        func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
            //print("parser.didStartElement: \(elementName) = \(currentElement)")
            currentElementName=elementName
            currentElement=nil
            switch elementName {
            case "GetOfficalTimeResult":
                delegate=timeParser(session: session)
                parser.delegate=delegate
            case"SearchResult":
                delegate=searchParser(session: session)
                parser.delegate=delegate
            case "GetItemResult":
                delegate=auctionParser(session: session, parent: self)
                parser.delegate=delegate
            case "GetCategoriesResult":
                delegate=categoriesParser(session: session, parent: self)
                parser.delegate=delegate
            case "FetchTokenResponse":
                delegate=tokenParser(session: session)
                parser.delegate=delegate
            case "GetUserByAliasResult","GetUserInfoResult":
                delegate=aliasParser(session: session, parent: self)
                parser.delegate=delegate
            case "SearchCollectionPointResult":
                delegate=schenkerParser(session: session, parent: self)
                parser.delegate=delegate
            case "GetItemFieldValuesResult":
                delegate=itemFieldValuesParser(session: session, parent: self)
                parser.delegate=delegate
            case "AddItemResponse":
                delegate=addItemParser(session: session, parent: self)
                parser.delegate=delegate
            case "soap:Fault":
                print("*** SOAP-fel! ***")
                errors+=1
                delegate=errorParser(session: session)
                parser.delegate=delegate
            default:
                //print("Hoppar över element: \(elementName)")
                break
            }
        }
        func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            //print("parser.didEndElement: \(elementName)")
            //print("\(elementName)=\(currentItem[elementName])")
        }
        func parser(parser: NSXMLParser, foundCharacters string: String) {
            currentElement=(currentElement ?? "")+string
        }
        func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
            print("Parsningsfel!")
            errors+=1
        }
        
        //////////// timeParser ////////////
        // Läser in tiden och konverterar //
        // till NSDate i TraderaSession.  //
        ////////////////////////////////////
        class errorParser:XMLParser {
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                switch elementName {
                case "faultcode":
                    print("Felkod: \(currentElement)")
                case "faultstring":
                    print("Felbeskrivning: \(currentElement)")
                default:
                    print("Övrigt meddelande: \(elementName) = \(currentElement)")
                }
                currentElement=nil
            }
        }

        //////////// timeParser ////////////
        // Läser in tiden och konverterar //
        // till NSDate i TraderaSession.  //
        ////////////////////////////////////
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
                    session.notifications.postNotificationName(TraderaService.notifications.gotTime.rawValue, object: nil)
                }
            }
        }
        //////////// searchParser ////////////
        // Läser in sökresultat till listan //
        // items i TraderaSession.          //
        //////////////////////////////////////
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
                if elementName=="SearchResult" {
                    session.notifications.postNotificationName(TraderaService.notifications.didFinishSearching.rawValue, object: self)
                }
            }
        }
        //////////// auctionParser ////////////
        // Läser in en enskild auktion.      //
        ///////////////////////////////////////
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
                currentElement=nil
            }
            //// didEndElement ////
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                //print("->path=\(path)")
                if elementName=="GetItemResult" {
                    print("Hittade slut på GetItemResult")
                    print("item=\(item)")
                    makeItem()
                    parser.delegate=parent
                }
                //if elementName == "LongDescription" {path.popLast();return} // mindre skräp i konsolen
                guard let element=currentElement
                    else {
                        //print("Försökte sätta \(path.dotPath()) till nil-värde")
                        path.popLast(); return}
                item.setValue(element, forKeyPath: path)
                
                if elementName==path.last {
                    path.popLast()
                }
                currentElement=nil
                //print("<-path=\(path)")
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
                    traderaItem.longDescription=item["LongDescription"] as? String
                    traderaItem.imageLink=item["ImageLinks"]?["string"] as? String
                    session.notifications.postNotificationName(TraderaService.notifications.gotItem.rawValue, object: traderaItem)
                }
                else {print("Misslyckades med att skapa auktionsobjekt")}
            }
        }
        //////// categoriesParser ////////
        // Läser in alla kategorier.    //
        //////////////////////////////////
        class categoriesParser:XMLParser {
            let parent:XMLParser?
            var categories=[Category]()
            var path=[Category]()
            
            init(session: TraderaSession, parent:XMLParser) {
                self.parent=parent
                let maincat=Category("Alla kategorier", 0)
                categories.append(maincat)
                path.append(maincat)
                super.init(session: session)
            }
            //// didStartElement ////
            override func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
                guard let id=attributeDict["Id"], let name=attributeDict["Name"] else {
                    print("Hittade inga giltiga attribut!"); return
                }
                let category=Category(name, id)
                //print("path=\(path.dotPath())")
                categories.setValue(category, forKeyPath: path)
                path.append(category)
                currentElement=nil
            }

            //// didEndElement ////
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                path.popLast()
                if elementName=="GetCategoriesResult" {
                    print("Hittade slut på GetCategoriesResult")
                    print("categories=\(categories)")
                    TraderaService.categories=categories
                    session.notifications.postNotificationName(TraderaService.notifications.gotCategories.rawValue, object: nil)
                    parser.delegate=parent
                }
            }
        }
        //////////// tokenParser ///////////
        // Läser in inloggningsnyckel och //
        // lägger in i TraderaSession.    //
        ////////////////////////////////////
        class tokenParser:XMLParser {
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                print("tokenParser: \(elementName)=\(currentElement)")
                if elementName=="AuthToken" {
                    print("Mottog authToken: \(currentElement)")
                    //session.token=currentElement
                    TraderaSession.token=currentElement
                    session.notifications.postNotificationName(TraderaService.notifications.gotToken.rawValue, object: nil)
                }
            }
        }
        //////////// aliasParser ///////////
        // Hämtar användarid (en int)     //
        // baserat på användarens alias.  //
        ////////////////////////////////////
        class aliasParser:XMLParser {
            let parent:XMLParser?
            var user=[String:String]()
            
            init(session:TraderaSession, parent:XMLParser) {
                self.parent=parent
                super.init(session: session)
            }
            //// didEndElement ////
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                print("aliasParser: \(elementName)=\(currentElement)")
                user[elementName]=currentElement
                if elementName == "GetUserByAliasResult" {
                    print("Slut på GetUserByAliasResult")
                    session.notifications.postNotificationName(TraderaService.notifications.gotUserByAlias.rawValue, object: TraderaUser(fromDict: user))
                }
                if elementName == "GetUserInfoResult" {
                    print("Slut på GetUserInfoResult")
                    session.notifications.postNotificationName(TraderaService.notifications.gotUserInfo.rawValue, object: TraderaUser(fromDict: user))
                }
            }
        }
        //////////// itemFieldValuesParser ////////////
        // Läser in betalnings- och fraktalternativ. //
        ///////////////////////////////////////////////
        class itemFieldValuesParser:XMLParser {
            let parent:XMLParser?
            var results=[String:[[String:String]]]()
            var path:String=""
            var item:[String:String]?
            
            init(session: TraderaSession, parent:XMLParser) {
                self.parent=parent
                super.init(session: session)
            }
            //// didStartElement ////
            override func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
                if path == "" {
                    path=elementName
                    //print("path=\(path)")
                    item=[String:String]()
                    currentElement=nil
                }
            }
            //// didEndElement ////
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                print("itemFieldValuesParser.didEndElement: \(elementName) = \(currentElement)")
                print("path=\(path)")
                switch elementName {
                case path:
                    //print("Lägger till objekt på sökväg \(path):")
                    //print(item)
                    if results[path]==nil {results[path]=[[String:String]]()}
                    results[path]?.append(item!)
                    path=""
                    item=nil
                case "GetItemFieldValuesResult":
                    print("*** Slut på GetItemFieldValuesResult ***")
                    print(results)
                    session.notifications.postNotificationName(TraderaService.notifications.gotItemFieldValues.rawValue, object: results)
                    delegate=parent
                default:
                    item?[elementName]=currentElement
                }
                currentElement=nil
            }
        }
        
        ///////////// addItemParser /////////////
        // Ser om en auktion kunde läggas upp. //
        /////////////////////////////////////////
        class addItemParser:XMLParser {
            let parent:XMLParser?
            var response=[String:String]()
            var responseOK=false
            
            init(session: TraderaSession, parent:XMLParser) {
                self.parent=parent
                super.init(session: session)
            }
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                switch elementName {
                    case "RequestId":
                        response["RequestId"]=currentElement
                    case "ItemId":
                        response["ItemId"]=currentElement
                    case "AddItemResult":
                        responseOK=true
                    default:
                        break
                }
                currentElement=nil
                if responseOK {
                    session.notifications.postNotificationName(TraderaService.notifications.gotAddItemResult.rawValue, object: response)
                }
            }
        }

        ///////// schenkerParser /////////////
        // Läser in närmaste Schenkerombud. //
        //////////////////////////////////////
        class schenkerParser:XMLParser {
            let parent:XMLParser?
            var collectionpoint=[String:String]()
            
            init(session: TraderaSession, parent:XMLParser) {
                self.parent=parent
                super.init(session: session)
            }
            //// didStartElement ////
            override func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
                currentElement=nil
            }
            
            //// didEndElement ////
            override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
                if elementName=="SearchCollectionPointResult" {
                    print("Hittade slut på SearchCollectionPointResult")
                    print("Ombudets info: \(collectionpoint)")
                    session.notifications.postNotificationName(TraderaService.notifications.gotSchenker.rawValue, object: collectionpoint)
                    parser.delegate=parent
                    return
                }
                collectionpoint[elementName]=currentElement
            }
        }
    }
    ///////////////////////////////////////////////////////////
    // URLConnection hanterar asynkron hämtning av SOAP-data //
    // från Tradera och delegerar tolkningen till XMLParser. //
    // NSURLConnection verkar ha ersatts av NSURLSession     //
    // men vi kör på URLConnection för bakåtkompatibilitet.  //
    ///////////////////////////////////////////////////////////
    class URLConnection:NSObject,NSURLConnectionDelegate {
        var mutableData:NSMutableData=NSMutableData()
        var currentElementName:NSString=""
        var errors=0
        var incomplete=0
        let session:TraderaSession?

        init(message:String, action:String, session:TraderaSession, url urlString:String) {
            self.session=session
            let url=NSURL(string:urlString)
            let request=NSMutableURLRequest(URL: url!)
            let msgLength=message.characters.count
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
            request.addValue(action, forHTTPHeaderField: "SOAPAction")
            request.HTTPMethod="POST"
            request.HTTPBody=message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            super.init()
            let connection=NSURLConnection(request: request, delegate: self, startImmediately: true)
            connection!.start()
            if(connection==true) {
                print("connection==true")
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
            print("\(#function): data=\(NSString(data:mutableData, encoding: NSUTF8StringEncoding))")
            let xmlParser=NSXMLParser(data: mutableData)
            let parserDelegate=TraderaService.XMLParser(session: session!)
            xmlParser.delegate=parserDelegate
            if xmlParser.parse() {
                print("Parsningen avslutades.")
                session?.notifications.postNotificationName(TraderaService.notifications.didFinishParsing.rawValue, object: self)
            }
            xmlParser.shouldResolveExternalEntities=true
        }
    }
}