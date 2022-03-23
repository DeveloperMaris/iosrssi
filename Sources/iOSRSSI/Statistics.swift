//
//  Statistics.swift
//  
//
//  Created by Maris Lagzdins on 22/03/2022.
//

import ArgumentParser

struct Statistics: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "iosrssi",
        abstract: """
            A Swift command-line tool to parse iOS device sysdiagnose \
            log files and retrieve the wifi network RSSI statistics.
            """,
        subcommands: [Parse.self]
    )

    init() { }
}
