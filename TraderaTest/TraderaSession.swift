//
//  TraderaSession.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-20.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation

//////////////////////////////////////////////////
// TraderaSession hanterar globala data för den //
// aktuella sessionen såsom klocka, inloggning  //
// och listor över mottagna sökresultat.        //
//////////////////////////////////////////////////

class TraderaSession {
    let service=TraderaService()
    var token:String?
    var time:String?
    var items=[TraderaItem]()
    let notifications=NSNotificationCenter()
}