//
//  TraderaService.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-18.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation
//import "KissXML/DDXML"
//import NSXMLNode


class TraderaService {
    static let appid=1589
    static let servicekey="52227af6-11f2-4b9a-b321-0c6b97d24d76"
    static let publickey="4e1c7c27-b028-4a34-a61e-0775030a24d1"
    //static let preamble="<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"http://api.tradera.com\">"
    static let preamble="<?xml version=\"1.0\" encoding=\"utf-8\"?>        <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//    static let header=String(format:"\(preamble)    <SOAP-ENV:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\">    <Sandbox>int</Sandbox><MaxResultAge>int</MaxResultAge>    </ConfigurationHeader>    </SOAP-ENV:Header>",appid,servicekey)
    //static let header=String(format:"\(preamble)    <SOAP-ENV:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\"></ConfigurationHeader>    </SOAP-ENV:Header>",appid,servicekey)
    static let header=String(format:"\(preamble)    <soap:Header>    <AuthenticationHeader xmlns=\"http://api.tradera.com\">    <AppId>%d</AppId>    <AppKey>%@</AppKey>    </AuthenticationHeader>    <ConfigurationHeader xmlns=\"http://api.tradera.com\"></ConfigurationHeader>    </soap:Header>",appid,servicekey)
    //let traderaTimeMessage="<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"http://api.tradera.com\"> <SOAP-ENV:Header>   <AuthenticationHeader xmlns=\"http://api.tradera.com\">        <AppId>1589</AppId>        <AppKey>52227af6-11f2-4b9a-b321-0c6b97d24d76</AppKey>        </AuthenticationHeader> </SOAP-ENV:Header> <SOAP-ENV:Body><ns1:GetOfficalTime/></SOAP-ENV:Body></SOAP-ENV:Envelope>"
    
//    let root=NSXMLElement(name:"root")
//    let bla=NSXMLDocument(root:"root")
    func getOfficialTime__() -> String {
        var req=[String:AnyObject]()
        req["Body"]="<ns1:GetOfficalTime/>"
        req["dictio"]=["val1":"bla","val2":"urk"]
        print("req=\(req)")
        return XMLRequest(req)
    }
    //func search() -> String {
    func getOfficialTime() -> String {
        var req=[String:AnyObject]()
        var opts=["query":"Amiga"]
        opts["categoryId"]="0"
        opts["pageNumber"]="1"
        opts["orderBy"]="Relevance"
        //req["Body"]=["Search xmlns=\"http://api.tradera.com\"":opts]
        req["soap:Body"]=["Search xmlns=\"http://api.tradera.com\"":opts]
        print("req=\(req)")
        let teststr="<?xml version=\"1.0\" encoding=\"utf-8\"?>        <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">        <soap:Header>        <AuthenticationHeader xmlns=\"http://api.tradera.com\">        <AppId>1589</AppId>        <AppKey>52227af6-11f2-4b9a-b321-0c6b97d24d76</AppKey> </AuthenticationHeader>                </soap:Header>        <soap:Body>        <Search xmlns=\"http://api.tradera.com\">        <query>Amiga</query>        <categoryId>0</categoryId>        <pageNumber>1</pageNumber>        <orderBy>Relevance</orderBy>        </Search>        </soap:Body>        </soap:Envelope>"
        print(XMLTree(req))
        //return teststr
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
                if element=="Body" {
                    let tag="soap:Body"
                    text+=tag
                    break
                }
                //let tag="<SOAP-ENV:\(key)>\(element)</SOAP-ENV:\(key)>"
                let tag="<\(key)>\(element)</\(key)>\n"
                text+=tag
            case let element as [String:AnyObject]:
                //print("element=\(element)")
                if key=="Body" {
                    let key="soap:Body"
                    //text+=tag
                    text+="<\(key)>\(XMLTree(element))</\(key)>\n"
                    break
                }
                text+="<\(key)>\(XMLTree(element))</\(key.componentsSeparatedByString(" ")[0])>"
            default:
                print("***Ogiltigt format på listan! (\(value))")
            }
        }
        return text
    }
/*
    func XMLTree(dict:[String:AnyObject]) -> String {
        var text=""
        for (key,value) in dict {
            print("***XMLTree: key=\(key), value=\(value)")
            if let grej=value as? String {
                let tag="<SOAP-ENV:\(key)>\(grej)</SOAP-ENV:\(key)>"
                text+=tag
            }
            if let grejdict=value as? [String:AnyObject] {
                print("grejdict=\(grejdict)")
                text+="<SOAP-ENV:\(key)>\(XMLTree(grejdict))</SOAP-ENV:\(key)>"
            }
        }
        return text
    }
 */
}