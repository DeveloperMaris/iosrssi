//
//  Parse.swift
//  
//
//  Created by Maris Lagzdins on 22/03/2022.
//

import ArgumentParser
import CodableCSV
import Foundation

struct Parse: ParsableCommand {
    private static let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // We need to be able to parse 03/11/2022 11:24:59.908
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss.SSS"
        return formatter
    }()

    public static let configuration = CommandConfiguration(
        abstract: "Parse the wifi sysdiagnose log file to retrieve RSSI statistics."
    )

    @Argument(help: "The input file path for the sysdiagnose file")
    private var input: String

    @Argument(help: "The output file path for the parsed result file, should be a .csv format file")
    private var output: String

    @Option(name: .shortAndLong, help: "The starting date and time of the logs when to start parsing. Format is \"MM/dd/yyyy HH:mm:ss.SSS\". For example: 03/11/2022 11:40:13.277")
    private var since: String?

    @Option(name: .shortAndLong, help: "The ending date and time of the logs when to stop parsing. Format is \"MM/dd/yyyy HH:mm:ss.SSS\". For example: 03/11/2022 14:50:09.002")
    private var till: String?

    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose = false

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()

        if verbose {
            print("Input file path: \(input)")
            print("Output file path: \(output)")
            print("Received since date: \(String(describing: since))")
            print("Received till date: \(String(describing: till))")
        }

        // Generate URLs.
        let inputURL = URL(fileURLWithPath: input)
        let outputURL = URL(fileURLWithPath: output)

        // Generate start and end dates if necessary.
        let startDate: Date = date(fromTerminal: since) ?? .distantPast
        let endDate: Date = date(fromTerminal: till) ?? .distantFuture

        if verbose {
            print("Using since date: \(String(describing: startDate))")
            print("Using till date: \(String(describing: endDate))")
        }

        // Parse the statistics and write to an output file.
        do {
            let content = try read(fileAt: inputURL)
            let statistics = try parse(content, since: startDate, till: endDate)
            try writeAsCSV(statistics, inFile: outputURL)

            print("File successfully parsed.")
            print("Retrieved \(statistics.count) records.")

        } catch {
            print("File parsing failed.")
            if verbose {
                print("Error: \(error.localizedDescription)")
            }
        }

        if verbose {
            let diff = CFAbsoluteTimeGetCurrent() - start
            print("Total time passed: \(diff) seconds.")
        }
    }

    /// A method to parse text and returns back a list of statistical records.
    /// - Parameters:
    ///   - text: Text to parse.
    ///   - startDate: A parsing start date.
    ///   - endDate: A parsing end date.
    /// - Returns: List of statistical records.
    func parse(
        _ text: String,
        since startDate: Date = .distantPast,
        till endDate: Date = .distantFuture
    ) throws -> [Stats] {
        var statistics: [Stats] = []

        let regexPattern = #"(.*)\s__WiFiLQAMgrLogStats\((.*):.*: Rssi:\s(-?\d{1,3})\s"#
        let matches = try getMatches(to: regexPattern, from: text)

        for match in matches {
            guard let rawDate = getValue(in: match.range(at: 1), from: text) else {
                if verbose {
                    print("Warning: Ignoring current match because of missing date value.")
                }
                continue
            }

            guard let date = date(fromLog: rawDate) else {
                if verbose {
                    print("Warning: Can't parse date: \(rawDate)")
                }
                continue
            }

            guard date > startDate else {
                continue
            }

            guard date < endDate else {
                // No need to continue, because all the logs are sorted by the time in the ascending order.
                break
            }

            guard let wifi = getValue(in: match.range(at: 2), from: text) else {
                if verbose {
                    print("Warning: Ignoring current match because of missing wifi value.")
                }
                continue
            }

            guard let rssi = getValue(in: match.range(at: 3), from: text) else {
                if verbose {
                    print("Warning: Ignoring current match because of missing rssi value.")
                }
                continue
            }

            let stats = Stats(date: date, ssid: wifi, value: rssi)
            statistics.append(stats)
        }

        return statistics
    }

    /// A method to read string content from file.
    /// - Parameter url: File path location.
    /// - Returns: Content of the file.
    func read(fileAt url: URL) throws -> String {
        return try String(contentsOf: url)
    }

    /// Write statistical records into a CSV format file.
    /// - Parameters:
    ///   - statistics: List of statistical records.
    ///   - url: Path to the output file.
    ///   - formatter: Statistical record entity date formatter.
    func writeAsCSV(
        _ statistics: [Stats],
        inFile url: URL
    ) throws {
        let encoder = CSVEncoder()
        encoder.headers = ["date", "time", "network", "ssid", "measurement", "-dBm"]
        try encoder.encode(statistics, into: url)
    }

    /// Retrieves matching parts of the text by filtering it with provided regex pattern.
    /// - Parameters:
    ///   - regexPattern: Regex pattern.
    ///   - text: Whole string text.
    /// - Returns: List of matches from the regex.
    func getMatches(to regexPattern: String, from text: String) throws -> [NSTextCheckingResult] {
        let range = NSRange(location: 0, length: text.utf16.count)
        let regex = try NSRegularExpression(pattern: regexPattern)
        return regex.matches(in: text, options: [], range: range)
    }

    /// Retrieves specific range of string out of provided string.
    /// - Parameters:
    ///   - range: Provided range.
    ///   - text: Whole text.
    /// - Returns: Retrieved string value from the provided range, if exists.
    func getValue(in range: NSRange, from text: String) -> String? {
        if let substringRange = Range(range, in: text) {
            let capture = String(text[substringRange])
            return capture
        }

        return nil
    }

    /// A method to create a date instance from the raw string read from the log file.
    /// - Parameter date: Raw string date.
    /// - Returns: Date instance.
    func date(fromLog string: String) -> Date? {
        Self.inputDateFormatter.date(from: string)
    }

    /// A method to create a date instance from the raw string received from Terminal input.
    /// - Parameter string: Raw string date.
    /// - Returns: Date instance.
    func date(fromTerminal string: String?) -> Date? {
        guard let string = string else {
            return nil
        }

        return Self.inputDateFormatter.date(from: string)
    }
}
