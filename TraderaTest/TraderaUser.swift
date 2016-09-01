//
//  TraderaUser.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-08-30.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import Foundation

class TraderaUser: CustomStringConvertible {
    let id:Int
    let username:String
    var name:String?
    var email:String?
    var mobile:String?
    let rating:Int
    let postnr:String
    let city:String
    let country:String

    init(id:Int, username:String, rating:Int, postnr:String, city:String, country:String) {
        self.id=id
        self.username=username
        self.rating=rating
        self.postnr=postnr
        self.city=city
        self.country=country
        print("Skapade användare \"\(username)\" med id \(id)")
    }
    convenience init?(fromDict user:[String:String]) {
        print("TraderaUser.fromDict: \(user)")
        guard let id=user["Id"],
            let alias=user["Alias"],
            //let totalrating=user["TotalRating"],
            let zipcode=user["ZipCode"],
            let city=user["City"],
            let country=user["CountryName"]
            else {
                print("Kunde inte skapa användare!")
                return nil
        }
        let totalrating=user["TotalRating"] ?? "0"
        self.init(id:Int(id)!, username:alias, rating:Int(totalrating)!, postnr:zipcode, city:city, country:country)
        //let fname=user["FirstName"] ?? "Okänt"
        //let lname=user["LastName"] ?? "namn"
        guard let fname=user["FirstName"], lname=user["LastName"]
            else {print("Hittade inget namn");return}
        self.name=fname+" "+lname
        self.mobile=user["MobilePhoneNumber"]
        self.email=user["Email"]
    }
    
    var description: String {
        return "TraderaUser \(username) >> id: \(id), ort: \(city)"
    }
}