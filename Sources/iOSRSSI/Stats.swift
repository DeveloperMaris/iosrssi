//
//  Stats.swift
//  
//
//  Created by Maris Lagzdins on 22/03/2022.
//

import Foundation

/// A structure containing all the necessary statistics information.
struct Stats: Codable {
    var date: Date
    var rssi: String
    var ssid: String
}
