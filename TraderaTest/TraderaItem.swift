//
//  TraderaItem.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-18.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation
class TraderaItem {
    let id:Int
    let shortDescription:String
    let buyItNowPrice:Float?
    let sellerId:Int
    let sellerAlias:String
    let maxBid:Float
    let thumbnailLink:String
    let sellerDsrAverage:Float
    let endDate:String
    let nextBid:Float
    let hasBids:Bool
    let isEnded:Bool
    let itemType:String
    
    init(id:Int,
        shortDescription:String,
        buyItNowPrice:Float?,
        sellerId:Int,
        sellerAlias:String,
        maxBid:Float,
        thumbnailLink:String,
        sellerDsrAverage:Float,
        endDate:String,
        nextBid:Float,
        hasBids:Bool,
        isEnded:Bool,
        itemType:String){
        self.id=id
        self.shortDescription=shortDescription
        self.buyItNowPrice=buyItNowPrice
        self.sellerId=sellerId
        self.sellerAlias=sellerAlias
        self.maxBid=maxBid
        self.thumbnailLink=thumbnailLink
        self.sellerDsrAverage=sellerDsrAverage
        self.endDate=endDate
        self.nextBid=nextBid
        self.hasBids=hasBids
        self.isEnded=hasBids
        self.itemType=itemType
    }
    convenience init?(fromDict item:[String:String]) {
        guard let id=item["Id"],
            let shortDescription=item["ShortDescription"],
            let sellerId=item["SellerId"],
            let sellerAlias=item["SellerAlias"],
            let maxBid=item["MaxBid"],
            let thumbnailLink=item["ThumbnailLink"],
            let sellerDsrAverage=item["SellerDsrAverage"],
            let endDate=item["EndDate"],
            let nextBid=item["NextBid"],
            let hasBids=item["HasBids"],
            let isEnded=item["IsEnded"],
            let itemType=item["ItemType"]
        else {
            print("TraderaItem kunde inte konvertera Items-dict")
            return nil
        }
        let buyItNowPrice=item["BuyItNowPrice"] ?? "0"
/*
        let hasBidsBool=NSString(string: hasBids).boolValue
        let isEndedBool=NSString(string: isEnded).boolValue
        let idInt=Int(id)
        let sellerIdInt=Int(sellerId)
*/
//        guard let sellerIdInt=Int(sellerId)
        //guard let sellerIdInt=Int(item["SellerId"] as? String)
        //    else {return}
        
        self.init(id: Int(id)!, shortDescription: shortDescription, buyItNowPrice: Float(buyItNowPrice), sellerId: Int(sellerId)!, sellerAlias: sellerAlias, maxBid: Float(maxBid)!, thumbnailLink: thumbnailLink, sellerDsrAverage: Float(sellerDsrAverage)!, endDate: endDate, nextBid: Float(nextBid)!, hasBids: NSString(string:hasBids).boolValue, isEnded: NSString(string:isEnded).boolValue, itemType: itemType)
    }
}
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