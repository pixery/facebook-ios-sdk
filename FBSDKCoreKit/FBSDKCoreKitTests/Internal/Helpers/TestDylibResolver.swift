/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation

@objcMembers
final class TestDylibResolver: NSObject, FBSDKDynamicFrameworkResolving {
  var stubSafariViewControllerClass: AnyClass?
  var didLoadSafariViewControllerClass = false

  func safariViewControllerClass() -> AnyClass? {
    didLoadSafariViewControllerClass = true
    return stubSafariViewControllerClass
  }
}
