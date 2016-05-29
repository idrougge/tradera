//
//  Types.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-27.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation
///////////////// Category //////////////////
// Category innehåller en Traderakategoris //
// namn och id-nummer. För att kunna lägga //
// kategorierna i en samling krävs att     //
// Hashable-protokollet implementeras.     //
/////////////////////////////////////////////
struct Category:Hashable,CustomStringConvertible{
    let name:String
    let id:Int
    var sub:[Category]?
    init(_ name:String, _ id:String) {
        self.name=name
        self.id=Int(id)!
    }
    init(_ name:String, _ id:Int) {
        self.name=name
        self.id=id
    }
    var hashValue:Int {
        get {
            return id.hashValue
        }
    }
    var description:String {
        return name
    }
}
//////////// Category:Equatable /////////////
// Protkollet Hashable kräver också att    //
// protokollet Equatable implementeras,    //
// och det måste göras globalt och inte    //
// inuti den klass som berörs eftersom     //
// Apple är klantskallar.                  //
/////////////////////////////////////////////
func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.hashValue==rhs.hashValue
}
