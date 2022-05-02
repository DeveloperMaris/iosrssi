//
//  XCTestCase.swift
//  
//
//  Created by Maris Lagzdins on 02/05/2022.
//

import ArgumentParser
import XCTest
@testable import iOSRSSI

extension XCTestCase {
    func parse<A>(_ type: A.Type, _ arguments: [String]) throws -> A where A: ParsableCommand {
        try XCTUnwrap(RootCommand.parseAsRoot(arguments) as? A)
    }
}
