//
//  UtilsTests.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 27/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import XCTest

@testable import ShopBag

class UtilsTests: XCTestCase {
  
  var formatter: NumberFormatter!
  
  var paddingLabel: UIPaddingLabel!
  
  override func setUp() {
    super.setUp()
    
    formatter = {
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.maximumFractionDigits = 2
      formatter.locale = Locale(identifier: "en_US")
      return formatter
    }()

    paddingLabel = UIPaddingLabel()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testFormatCurrencyWithDefaultCurrency() {
    let amount = Decimal(12.32)
    let formattedCurrency = formatCurrency(value: amount)
    XCTAssertEqual("$\(amount)", formattedCurrency, "USD Dollar not formatted properly")
  }
  
  func testFormatCurrencyWithSpecifiedCurrency() {
    let currencies: [Currency: String] = [.usd: "$",
                                          .eur: "€",
                                          .chf: "CHF",
                                          .gbp: "£"]
    
    let amount = Decimal(0.93)
    
    currencies.forEach { (currency, symbol) in
      let formattedCurrency = formatCurrency(value: amount, currencyCode: currency)
      XCTAssertEqual("\(symbol)\(amount)", formattedCurrency, "\(currency.rawValue) not formatted properly")
    }
  }
  
  func testMergeWithDisjointKeys() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["x": 10, "y": 20, "z": 30]
    
    let keys = Set([dict1.keys, dict2.keys].joined())
    
    let merge = dict1.merge(with: dict2)
    
    XCTAssertEqual(keys, Set(merge.keys), "Some key was missing after the merge")
  }
  
  func testMergeWithCommonKeys() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["x": 10, "b": 20, "z": 30, "c": 40]
    
    let keys = Set([dict1.keys, dict2.keys].joined())
    
    let merge = dict1.merge(with: dict2)
    
    XCTAssertEqual(keys, Set(merge.keys), "Some key was missing after the merge")
  }
  
  func testMergeWithCommonKeysLastOneKeyWins() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["x": 10, "b": 20, "z": 30, "c": 40]
    
    let merge = dict1.merge(with: dict2)
    
    XCTAssertEqual(40, merge["c"], "Some value was originally preserved")
    XCTAssertEqual(20, merge["b"], "Some value was originally preserved")
  }

  
  func testUIPaddingLabelPaddingIsZero() {
    XCTAssertEqual(0.0, paddingLabel.padding, "Padding is not zero")
  }
  
  func testUIPaddingLabelPaddingCanBeSetToZero() {
    paddingLabel.padding = 0
    XCTAssertEqual(0.0, paddingLabel.padding, "Padding is not zero")
  }
  
  func testUIPaddingLabelIntrinsicContentSize() {
    let zeroSize = CGSize(width: 0.0, height: 0.0)
    XCTAssertEqual(zeroSize, paddingLabel.intrinsicContentSize, "Has intrinsic content size different than zero")
  }
  
  func testUIPaddingLabelDrawText() {
    let rect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    
    paddingLabel.drawText(in: rect) // Not sure how to test that
  }
}
