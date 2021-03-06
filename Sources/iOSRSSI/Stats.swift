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
    var rssi: Int
    var snr: Int
    var txRate: Measurement<UnitInformationStorage>
    var rxRate: Measurement<UnitInformationStorage>

    var noise: Int {
        rssi - snr
    }

    enum CodingKeys: String, CodingKey {
        case date
        case time
        case network
        case ssid
        case rssi
        case noise
        case snr
        case txRate = "TxRate"
        case rxRate = "RxRate"
    }

    func encode(to encoder: Encoder) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss.SSS"

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.groupingSeparator = ""
        numberFormatter.decimalSeparator = "."

        let txRate = NSNumber(value: self.txRate.converted(to: .megabits).value)
        let rxRate = NSNumber(value: self.rxRate.converted(to: .megabits).value)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dateFormatter.string(from: date), forKey: .date)
        try container.encode(timeFormatter.string(from: date), forKey: .time)
        try container.encode(network, forKey: .network)
        try container.encode(ssid, forKey: .ssid)
        try container.encode(rssi, forKey: .rssi)
        try container.encode(noise, forKey: .noise)
        try container.encode(snr, forKey: .snr)
        try container.encode(numberFormatter.string(from: txRate), forKey: .txRate)
        try container.encode(numberFormatter.string(from: rxRate), forKey: .rxRate)
    }
}
