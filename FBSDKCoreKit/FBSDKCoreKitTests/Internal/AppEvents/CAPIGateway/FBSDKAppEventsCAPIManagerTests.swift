/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

@testable import FBSDKCoreKit
import TestTools
import XCTest

final class FBSDKAppEventsCAPIManagerTests: XCTestCase {

  enum Values {
    static let datasetID = "id123"
    static let accessKey = "key123"
    static let capiGatewayURL = "www.123.com"
  }

  let factory = TestGraphRequestFactory()
  let settings = TestSettings()

  override func setUp() {
    super.setUp()

    FBSDKAppEventsCAPIManager.shared.configure(factory: factory, settings: settings)
  }

  func testConfigure() {
    XCTAssertIdentical(
      factory as AnyObject,
      FBSDKAppEventsCAPIManager.shared.factory,
      "Should configure with the expected graph request factory"
    )
    XCTAssertEqual(
      settings,
      FBSDKAppEventsCAPIManager.shared.settings as? TestSettings,
      "Should configure with the expected settings"
    )
  }

  func testRecordEventWithoutAppID() {
    settings.appID = nil

    FBSDKAppEventsCAPIManager.shared.enable()
    FBSDKAppEventsCAPIManager.shared.recordEvent([:])
    XCTAssertTrue(
      factory.capturedRequests.isEmpty,
      "Should not send graph request when app id is nil"
    )
  }

  func testEnable() {
    settings.appID = "123"

    FBSDKAppEventsCAPIManager.shared.enable()
    XCTAssertTrue(
      FBSDKAppEventsCAPIManager.shared.isSDKGKEnabled,
      "CAPI should be enabled"
    )
  }

  func testRecordEventWithoutLoadingError() {
    settings.appID = "123"

    FBSDKAppEventsCAPIManager.shared.enable()
    FBSDKAppEventsCAPIManager.shared.recordEvent([:])
    guard let completion = factory.capturedRequests.first?.capturedCompletionHandler else {
      return XCTFail("Should start a request with a completion handler")
    }
    completion(
      nil,
      [
        "data": [
          [
            "is_enabled": false,
            "access_key": Values.accessKey,
            "dataset_id": Values.datasetID,
            "endpoint": Values.capiGatewayURL,
          ],
        ],
      ],
      nil
    )
    XCTAssertEqual(
      FBSDKTransformerGraphRequestFactory.shared.credentials?.accessKey,
      Values.accessKey,
      "Credential's access key should be the same as that in the setting request"
    )
    XCTAssertEqual(
      FBSDKTransformerGraphRequestFactory.shared.credentials?.datasetID,
      Values.datasetID,
      "Credential's access key should be the same as that in the setting request"
    )
    XCTAssertEqual(
      FBSDKTransformerGraphRequestFactory.shared.credentials?.capiGatewayURL,
      Values.capiGatewayURL,
      "Credential's access key should be the same as that in the setting request"
    )
  }
}
