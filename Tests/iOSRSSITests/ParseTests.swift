//
//  ParseTests.swift
//  
//
//  Created by Maris Lagzdins on 23/03/2022.
//

@testable import iOSRSSI
import XCTest

class ParseTests: XCTestCase {
    func testTextParsingReturnsNoResults() throws {
        // Given
        let text = """
        03/11/2022 11:25:14.948 __WiFiDeviceManagerEvaluate24GHzInfraNetworkState:isConnected Yes, isTimeSensitiveAppRunning No, isThereTrafficNow No
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        """
        let sut = Parse()

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
        let sut = Parse()

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
        let sut = Parse()

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result.count, 2, "Result should contain 2 items in the list.")
    }

    func testTextParsingReturnsStatistics() throws {
        // Given
        let wifi = "mock-wifi"
        let rssi = "-77"
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
        \(inputDate) __WiFiLQAMgrLogStats(\(wifi):Stationary): Rssi: \(rssi) {-42 -43} Channel: 6 Bandwidth: 20Mhz Snr: 35 Cca: 35 (S:0 O:16 I:18) TxPer: 0.0% (1) BcnPer: 0.0% (1, 56.5%) RxFrms: 2 RxRetryFrames: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail: 0 TxReTrans: 0 time: 48.3secs fgApp: (null)
        03/11/2022 11:25:14.949 WiFiLQAMgrCopyCoalescedUndispatchedLQMEvent: Rssi: -42 Snr:35 Cca: 35 TxFrames: 1 TxFail: 0 BcnRx: 1 BcnSch: 1  RxFrames: 2 RxRetries: 0 TxRate: 144444 RxRate: 130000 FBRate: 43333 TxFwFrms: 4 TxFwFail:0 TxRetries: 0
        03/11/2022 11:25:15.557 __WiFiVirtualInterfaceProcessAwdlStatisticsEvent: received APPLE80211_M_AWDL_STATISTICS event.
        03/11/2022 11:25:15.557 WiFiMetricsManagerSubmitSDBTDMStats: skipping this metric submission
        """
        let sut = Parse()

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result[0].date, outputDate, "Result should contain the same date as provided.")
        XCTAssertEqual(result[0].rssi, rssi, "Result should contain the same rssi as provided.")
        XCTAssertEqual(result[0].ssid, wifi, "Result should contain the same wifi as provided.")
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
        let sut = Parse()

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
        let sut = Parse()

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
        let sut = Parse()

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
        let sut = Parse()

        // When
        let result = try sut.parse(text)

        // Then
        XCTAssertEqual(result.count, 1, "Result should contain 1 item in the list.")
        XCTAssertEqual(result[0].date, outputDate, "Result should contain the same date as provided.")
    }
}
