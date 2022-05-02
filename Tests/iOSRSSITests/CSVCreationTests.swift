//
//  CSVCreationTests.swift
//  
//
//  Created by Maris Lagzdins on 02/05/2022.
//

import XCTest
@testable import iOSRSSI

class CSVCreationTests: XCTestCase {
    private static let fileName = "iosrssi-temporary-test.csv"

    private var csvSampleData1: Data!
    private var csvSampleData2: Data!

    override func setUp() {
        super.setUp()
        csvSampleData1 = """
            date,time,network,ssid,rssi,noise,snr,TxRate,RxRate
            2022-03-11,11:24:59.908,WIFI,demo,-80,-120,40,15000,60000

            """.data(using: .utf8)!

        csvSampleData2 = """
            date,time,network,ssid,rssi,noise,snr,TxRate,RxRate
            2022-03-11,11:24:59.908,WIFI,demo,-80,-120,40,15000,60000
            2022-03-11,11:24:59.908,WIFI,demo,-70,-110,40,14000,50000

            """.data(using: .utf8)!
    }

    override func tearDownWithError() throws {
        super.tearDown()

        /*
         Some tests will create a temporary file in the file system,
         so we need to cleanup these test artefacts if they exist.
         */
        let fileManager = FileManager()
        let fileURL = fileManager.temporaryDirectory.appendingPathComponent(Self.fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    func testStatisticsRecordEncodingIntoCSVFormat() throws {
        // Given
        let sampleData = self.csvSampleData1
        let date = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 24,
                second: 59,
                nanosecond: 908_000_000
            ).date
        )
        let stats: [Stats] = [.init(date: date, ssid: "demo", rssi: "-80", snr: "40", txRate: "15000", rxRate: "60000")]
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let data = try sut.encodeStatisticsAsCSV(stats)

        // Then
        XCTAssertEqual(sampleData, data, "Encoded data should be identical to the loaded sample data.")
    }

    func testMultipleStatisticsRecordEncodingIntoCSVFormat() throws {
        // Given
        let sampleData = self.csvSampleData2
        let date = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 24,
                second: 59,
                nanosecond: 908_000_000
            ).date
        )
        let stats: [Stats] = [
            .init(date: date, ssid: "demo", rssi: "-80", snr: "40", txRate: "15000", rxRate: "60000"),
            .init(date: date, ssid: "demo", rssi: "-70", snr: "40", txRate: "14000", rxRate: "50000"),
        ]
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let data = try sut.encodeStatisticsAsCSV(stats)

        // Then
        XCTAssertEqual(sampleData, data, "Encoded data should be identical to the loaded sample data.")
    }

    func testCSVFileCreationInFileSystem() throws {
        // Given
        let fileManager = FileManager()
        let fileURL = fileManager.temporaryDirectory.appendingPathComponent(Self.fileName)
        let stats: [Stats] = [.init(date: .init(), ssid: "demo", rssi: "-80", snr: "40", txRate: "15000", rxRate: "60000")]
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        XCTAssertFalse(fileManager.fileExists(atPath: fileURL.path), "File does not exist.")

        // When
        try sut.write(stats, as: .csv, inFile: fileURL)

        // Then
        XCTAssertTrue(fileManager.fileExists(atPath: fileURL.path), "File does not exist.")
    }

    func testCSVFileContent() throws {
        // Given
        let fileManager = FileManager()
        let fileURL = fileManager.temporaryDirectory.appendingPathComponent(Self.fileName)
        let stats: [Stats] = [.init(date: .init(), ssid: "demo", rssi: "-80", snr: "40", txRate: "15000", rxRate: "60000")]
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        try sut.write(stats, as: .csv, inFile: fileURL)

        // Then
        let dataOfFile = try Data(contentsOf: fileURL)
        let providedData = try sut.encodeStatisticsAsCSV(stats)

        XCTAssertEqual(dataOfFile, providedData, "Encoded data should be identical to the loaded data.")
    }
}
