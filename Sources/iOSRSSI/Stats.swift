//
//  Stats.swift
//  
//
//  Created by Maris Lagzdins on 22/03/2022.
//

import Foundation

/// A structure containing all the necessary statistics information.
struct Stats: Encodable {
    var date: Date
    var network: String = "WIFI"
    var ssid: String
    var measurement: String = "RSSI"
    var value: String

    enum CodingKeys: String, CodingKey {
        case date
        case time
        case network
        case ssid
        case measurement
        case value = "-dBm"
    }

    func encode(to encoder: Encoder) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss.SSS"

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dateFormatter.string(from: date), forKey: .date)
        try container.encode(timeFormatter.string(from: date), forKey: .time)
        try container.encode(network, forKey: .network)
        try container.encode(ssid, forKey: .ssid)
        try container.encode(measurement, forKey: .measurement)
        try container.encode(value, forKey: .value)
    }
}
