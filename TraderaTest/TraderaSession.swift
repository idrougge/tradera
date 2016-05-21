//
//  TraderaSession.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-20.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation

class TraderaSession {
    let service=TraderaService()
    var token:String?
    //var items:[TraderaItem]?
    var items=[TraderaItem]()
    // De här behöver flyttas till lämpligt ställe sen
    var description:String?
    var imageLink:String?
}