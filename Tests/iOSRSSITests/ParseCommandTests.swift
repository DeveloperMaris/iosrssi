//
//  ParseCommandTests.swift
//  
//
//  Created by Maris Lagzdins on 23/03/2022.
//

import ArgumentParser
import XCTest
@testable import iOSRSSI

class ParseCommandTests: XCTestCase {
    func testTextParsingReturnsNoResults() throws {
        // Given
        let text = """
        03/11/2022 11:25:14.948 __WiFiDeviceManagerEvaluate24GHzInfraNetworkState:isConnected Yes, isTimeSensitiveAppRunning No, isThereTrafficNow No
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result.count, 0, "Result should not contain any item in the list.")
    }

    func testTextParsingReturnsOneResult() throws {
        // Given
        let text = """
        03/11/2022 11:25:14.948 __WiFiDeviceManagerEvaluate24GHzInfraNetworkState:isConnected Yes, isTimeSensitiveAppRunning No, isThereTrafficNow No
        03/11/2022 11:25:14.948 __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result.count, 1, "Result should contain 1 item in the list.")
    }

    func testAlternativeTextParsingReturnsOneResult() throws {
        // Given
        let text = """
        default    2022-04-05 10:23:09.041986 +0300    kernel    postMessageInternal:isPipeOpened:1, msg 39, dataLen 180
        default    2022-04-05 10:23:09.042609 +0300    wifid    __WiFiLQAMgrLogStats(EDGE-F52s:Stationary): Rssi: -51 {-46 -47} Channel: 36 Bandwidth: 80Mhz Snr: 33 Cca: 9 (S:0 O:0 I:0) TxPer: 0.0% (77) BcnPer: 0.0% (59, 53.7%) RxFrms: 81 RxRetryFrames: 0 TxRate: 300000 RxRate: 585000 FBRate: 90000 TxFwFrms: 3 TxFwFail: 0 TxReTrans: 0 time: 218.3secs fgApp: com.apple.Preferences
        default    2022-04-05 10:23:09.043551 +0300    wifid    WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -51 Snr:33 Cca: 9 TxFrames: 77 TxFail: 0 BcnRx: 59 BcnSch: 59  RxFrames: 81 RxRetries: 0 TxRate: 300000 RxRate: 585000 FBRate: 90000 TxFwFrms: 3 TxFwFail:0 TxRetries: 0
        default    2022-04-05 10:23:09.043814 +0300    kernel    LQM-WiFi: Channel Scores  ChanQual Score = 3  TxLoss Score = 5  RxLoss Score = 5  TxLat Score = 5 [1(100 %) / 0(0 %) / 0(0 %) / 0(0 %)] RxLat Score = 5 [0(100 %) / 0(0 %) / 0(0 %) / 0(0 %)]  intermittent-state = 0  single-outage = 2

        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result.count, 1, "Result should contain 1 item in the list.")
    }

    func testTextParsingReturnsMultipleResults() throws {
        // Given
        let text = """
        03/11/2022 11:25:14.948 __WiFiDeviceManagerEvaluate24GHzInfraNetworkState:isConnected Yes, isTimeSensitiveAppRunning No, isThereTrafficNow No
        03/11/2022 11:25:14.948 __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        03/11/2022 11:25:17.000 __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -52 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result.count, 2, "Result should contain 2 items in the list.")
    }

    func testTextParsingReturnsStatistics() throws {
        // Given
        let wifi = "mock-wifi"
        let rssi = "-77"
        let snr = "35"
        let noise = "-112"
        let inputDate = "03/11/2022 11:25:14.948"
        let outputDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 25,
                second: 14,
                nanosecond: 948_000_000
            ).date
        )

        let text = """
        03/11/2022 11:25:14.948 __WiFiDeviceManagerEvaluate24GHzInfraNetworkState:isConnected Yes, isTimeSensitiveAppRunning No, isThereTrafficNow No
        \(inputDate) __WiFiLQAMgrLogStats(\(wifi):Stationary): Rssi: \(rssi) {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: \(snr) Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result[0].date, outputDate, "Result should contain the same date as provided.")
        XCTAssertEqual(result[0].ssid, wifi, "Result should contain the same wifi as provided.")
        XCTAssertEqual(result[0].rssi, rssi, "Result should contain the same rssi as provided.")
        XCTAssertEqual(result[0].noise, noise, "Result should contain the same noise as provided.")
        XCTAssertEqual(result[0].snr, snr, "Result should contain the same snr as provided.")
    }

    func testTextParsingReturnsStatisticsFilteredByStartDate() throws {
        // Given
        let inputDate = "03/11/2022 11:27:16.948"
        let outputDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 27,
                second: 16,
                nanosecond: 948_000_000
            ).date
        )
        let startDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 26,
                second: 14
            ).date
        )

        let text = """
        03/11/2022 11:25:14.948 __WiFiDeviceManagerEvaluate24GHzInfraNetworkState:isConnected Yes, isTimeSensitiveAppRunning No, isThereTrafficNow No
        03/11/2022 11:25:14.948 __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        \(inputDate) __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text, since: startDate)

        // Then
        XCTAssertEqual(result.count, 1, "Result should contain 1 item in the list.")
        XCTAssertEqual(result[0].date, outputDate, "Result should contain the same date as provided.")
    }

    func testTextParsingReturnsStatisticsFilteredByEndDate() throws {
        // Given
        let inputDate = "03/11/2022 11:25:14.948"
        let outputDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 25,
                second: 14,
                nanosecond: 948_000_000
            ).date
        )
        let endDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 26,
                second: 14
            ).date
        )

        let text = """
        03/11/2022 11:25:14.948 __WiFiDeviceManagerEvaluate24GHzInfraNetworkState:isConnected Yes, isTimeSensitiveAppRunning No, isThereTrafficNow No
        \(inputDate) __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        03/11/2022 11:27:16.948 __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text, till: endDate)

        // Then
        XCTAssertEqual(result.count, 1, "Result should contain 1 item in the list.")
        XCTAssertEqual(result[0].date, outputDate, "Result should contain the same date as provided.")
    }

    func testTextParsingReturnsStatisticsFilteredByStartDateAndEndDate() throws {
        // Given
        let inputDate = "03/11/2022 11:27:16.948"
        let outputDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 27,
                second: 16,
                nanosecond: 948_000_000
            ).date
        )
        let startDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 27,
                second: 00
            ).date
        )
        let endDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 28,
                second: 00
            ).date
        )

        let text = """
        03/11/2022 11:25:14.948 __WiFiDeviceManagerEvaluate24GHzInfraNetworkState:isConnected Yes, isTimeSensitiveAppRunning No, isThereTrafficNow No
        03/11/2022 11:25:14.948 __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        \(inputDate) __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        03/11/2022 11:28:16.948 __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text, since: startDate, till: endDate)

        // Then
        XCTAssertEqual(result.count, 1, "Result should contain 1 item in the list.")
        XCTAssertEqual(result[0].date, outputDate, "Result should contain the same date as provided.")
    }

    func testTextParsesOnlyLogMessagesContainingSpecificPhrase() throws {
        // Given
        let inputDate = "03/11/2022 11:28:16.948"
        let outputDate = try XCTUnwrap(
            DateComponents(
                calendar: .current,
                year: 2022,
                month: 03,
                day: 11,
                hour: 11,
                minute: 28,
                second: 16,
                nanosecond: 948_000_000
            ).date
        )

        let text = """
        03/11/2022 11:27:16.948 __WiFiLQAMgrLogStatsIncorrect(mock-wifi:Stationary): Rssi: -42 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        \(inputDate) __WiFiLQAMgrLogStats(mock-wifi:Stationary): Rssi: -43 {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        """
        let sut = try parse(ParseCommand.self, ["parse", "fake-input-file", "fake-output-file"])

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result.count, 1, "Result should contain 1 item in the list.")
        XCTAssertEqual(result[0].date, outputDate, "Result should contain the same date as provided.")
    }

    private func parse<A>(_ type: A.Type, _ arguments: [String]) throws -> A where A: ParsableCommand {
        try XCTUnwrap(RootCommand.parseAsRoot(arguments) as? A)
    }
}
