//
//  UserAddress.swift
//  FireFlight
//
//  Created by Kobe McKee on 8/27/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import Foundation

struct UserAddress: Codable {
    
    var latitude: Double
    var longitude: Double
    var address: String
    var label: String?
    var radius: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case address
        case label = "address_label"
        case radius
    }
    
}



