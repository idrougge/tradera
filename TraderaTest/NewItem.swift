//
//  NewItem.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-09-01.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation

struct NewItem {
    let title:String
    let categoryId:String
    let duration:String
    let restarts=0
    let startPrice:String
    let reservePrice=1
    let buyItNowPrice=1
    let description:String
    let shippingOption1:[String:AnyObject]
    let shippingOption2:[String:AnyObject]
    let paymentOptions:[String:String]
    let acceptedBidderId=1
    let itemType:Int
}