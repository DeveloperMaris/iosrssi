//
//  RootCommand.swift
//  
//
//  Created by Maris Lagzdins on 22/03/2022.
//

import ArgumentParser

struct RootCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "iosrssi",
        abstract: """
            A Swift command-line tool to parse iOS device sysdiagnose \
            log files and retrieve the wifi network RSSI statistics.
            """,
        version: "1.6.0",
        subcommands: [ParseCommand.self]
    )

    init() { }
}
