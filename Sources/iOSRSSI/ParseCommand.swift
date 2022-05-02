//
//  ParseCommand.swift
//  
//
//  Created by Maris Lagzdins on 22/03/2022.
//

import ArgumentParser
import CodableCSV
import Foundation

struct ParseCommand: ParsableCommand {
    private static let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // We need to be able to parse 03/11/2022 11:24:59.908
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss.SSS"
        return formatter
    }()

    private static let regexPattern = #"(.*)\s__WiFiLQAMgrLogStats\((.*):.*:\sRssi:\s(-?\d{1,3})\s.*\sSnr:\s(-?\d{1,3})\s.*\sTxRate:\s(\d+)\sRxRate:\s(\d+)\s"#

    public static let configuration = CommandConfiguration(
        commandName: "parse",
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

        verbosePrint("Start parsing...")

        verbosePrint("Input file path: \(input)")
        verbosePrint("Output file path: \(output)")
        verbosePrint("Received since date: \(String(describing: since))")
        verbosePrint("Received till date: \(String(describing: till))")

        // Generate URLs.
        let inputURL = URL(fileURLWithPath: input)
        let outputURL = URL(fileURLWithPath: output)

        // Generate start and end dates if necessary.
        let startDate: Date = date(fromTerminal: since) ?? .distantPast
        let endDate: Date = date(fromTerminal: till) ?? .distantFuture

        verbosePrint("Using since date: \(String(describing: startDate))")
        verbosePrint("Using till date: \(String(describing: endDate))")

        // Parse the statistics and write to an output file.
        do {
            let content = try read(fileAt: inputURL)
            let statistics = try parse(content, since: startDate, till: endDate)
            try write(statistics, as: .csv, inFile: outputURL)

            print("File successfully parsed.")
            print("Retrieved \(statistics.count) records.")

        } catch {
            print("File parsing failed.")
            verbosePrint("Error: \(error.localizedDescription)")
        }

        let diff = CFAbsoluteTimeGetCurrent() - start
        verbosePrint("Total time passed: \(diff) seconds.")
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

        verbosePrint("Info: Start searching for matching text patterns in file.")

        let matches = try getMatches(to: Self.regexPattern, from: text)

        verbosePrint("Info: End searching for matching text patterns in file.")
        verbosePrint("Info: Start retrieving values from matching text patterns.")

        for match in matches {
            guard let rawDate = getValue(in: match.range(at: 1), from: text) else {
                verbosePrint("Warning: Ignoring current match because of missing date value.")
                continue
            }

            let date: Date? = {
                if let match = try? getMatches(to: DatePattern.version1.rawValue, from: rawDate).first {
                    if let value = getValue(in: match.range, from: rawDate) {
                        return DatePattern.dateFormatterForVersion1.date(from: value)
                    }
                } else if let match = try? getMatches(to: DatePattern.version2.rawValue, from: rawDate).first {
                    if let value = getValue(in: match.range, from: rawDate) {
                        return DatePattern.dateFormatterForVersion2.date(from: value)
                    }
                }

                return nil
            }()

            guard let date = date else {
                verbosePrint("Warning: Can't parse date: \(rawDate)")
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
                verbosePrint("Warning: Ignoring current match because of missing wifi value.")
                continue
            }

            guard let rssi = getValue(in: match.range(at: 3), from: text) else {
                verbosePrint("Warning: Ignoring current match because of missing rssi value.")
                continue
            }

            guard let snr = getValue(in: match.range(at: 4), from: text) else {
                verbosePrint("Warning: Ignoring current match because of missing snr value.")
                continue
            }

            guard let txRate = getValue(in: match.range(at: 5), from: text) else {
                verbosePrint("Warning: Ignoring current match because of missing TxRate value.")
                continue
            }

            guard let rxRate = getValue(in: match.range(at: 6), from: text) else {
                verbosePrint("Warning: Ignoring current match because of missing RxRate value.")
                continue
            }

            let stats = Stats(date: date, ssid: wifi, rssi: rssi, snr: snr, txRate: txRate, rxRate: rxRate)
            statistics.append(stats)
        }

        verbosePrint("Info: End retrieving values from matching text patterns.")

        return statistics
    }

    /// A method to read string content from file.
    /// - Parameter url: File path location.
    /// - Returns: Content of the file.
    func read(fileAt url: URL) throws -> String {
        return try String(contentsOf: url)
    }


    func writeAsCSV(
        _ statistics: [Stats],
        inFile url: URL
    ) throws {
        verbosePrint("Info: Start writing statistic in file.")
        let encoder = CSVEncoder()
        encoder.headers = ["date", "time", "network", "ssid", "rssi", "noise", "snr", "TxRate", "RxRate"]
        try encoder.encode(statistics, into: url)
        verbosePrint("Info: End writing statistic in file.")
    }

    /// Write statistical records into a CSV format file.
    /// - Parameters:
    ///   - statistics: List of statistical records.
    ///   - type: The output file format, currently only possibility is the `.csv` format.
    ///   - url: Path to the output file.
    func write(_ statistics: [Stats], as type: OutputFileType, inFile url: URL) throws {
        verbosePrint("Info: Encode statistics as \(type).")
        let data: Data

        switch type {
        case .csv:
            data = try encodeStatisticsAsCSV(statistics)
        }

        verbosePrint("Info: Write statistics in file: \(url).")
        try data.write(to: url)

        verbosePrint("Info: Write statistics succeeded in file: \(url).")
    }

    func encodeStatisticsAsCSV(_ statistics: [Stats]) throws -> Data {
        let encoder = CSVEncoder()
        encoder.headers = ["date", "time", "network", "ssid", "rssi", "noise", "snr", "TxRate", "RxRate"]
        return try encoder.encode(statistics)
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

    /// A method to create a date instance from the raw string received from Terminal input.
    /// - Parameter string: Raw string date.
    /// - Returns: Date instance.
    func date(fromTerminal string: String?) -> Date? {
        guard let string = string else {
            return nil
        }

        return Self.inputDateFormatter.date(from: string)
    }

    private func verbosePrint(_ items: Any...) {
        if verbose {
            Swift.print(CFAbsoluteTimeGetCurrent(), items)
        }
    }
}

extension ParseCommand {
    enum DatePattern: String {
        /// Date pattern for `03/23/2022 12:40:16.307`
        case version1 = #"\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}.\d*"#
        /// Date pattern for `2022-04-05 10:25:59.649357 +0300`
        case version2 = #"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d* \+\d{4}"#
    }
}

extension ParseCommand {
    enum OutputFileType {
        case csv
    }
}

extension ParseCommand.DatePattern {
    static let dateFormatterForVersion1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss.SSS"
        return formatter
    }()

    static let dateFormatterForVersion2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS Z"
        return formatter
    }()
}
