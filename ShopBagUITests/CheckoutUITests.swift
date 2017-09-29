//
//  CheckoutUITests.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 27/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import XCTest

class CheckoutUITests: XCTestCase {
  
  var app: XCUIApplication!
  
  var beans: XCUIElement!
  var eggs: XCUIElement!
  var milk: XCUIElement!
  var peas: XCUIElement!
  
  
  let putIntoBagAnimation = 4.5
  
  override func setUp() {
    super.setUp()
    
    continueAfterFailure = false
    
    app = XCUIApplication()
    app.launch()
    
    XCUIDevice.shared().orientation = .portrait
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testIncreaseOrDecreaseQuantityForOneProduct() {
    addOneProduct()
    
    let tablesQuery = app.tables
    
    let firstCell = tablesQuery.cells.element(boundBy: 0)
    
    let plus = firstCell.buttons["+"]
    let one = tablesQuery.staticTexts["1"]
    
    expectation(for: NSPredicate(format: "exists == true"),
                evaluatedWith: one, handler: nil)
    
    plus.tap()
    
    waitForExpectations(timeout: 2)
    
    let quantityIncreased = tablesQuery.staticTexts["2"]
    XCTAssertEqual("2", quantityIncreased.label, "Quantity has not been increased")
    
    let minus = firstCell.buttons["-"]
    expectation(for: NSPredicate(format: "exists == true"),
                evaluatedWith: quantityIncreased, handler: nil)
    
    minus.tap()
    
    waitForExpectations(timeout: 2)
    
    XCTAssertEqual("1", one.label, "Quantity has not been increased")
  }
  
  func testSubtotalQuantityForOneProduct() {
    addOneProduct()
    
    let tablesQuery = app.tables
    
    let firstCell = tablesQuery.cells.element(boundBy: 0)
    
    let plus = firstCell.buttons["+"]
    let price = firstCell.staticTexts["$1.30"]
    XCTAssertEqual("$1.30", price.label, "Price does not correspond to initial one")
    
    let price2times = tablesQuery.staticTexts["$2.60"]
    expectation(for: NSPredicate(format: "label == \"$2.60\""),
                evaluatedWith: price2times, handler: nil)
    plus.tap()

    waitForExpectations(timeout: 1.0)
    
    let minus = firstCell.buttons["-"]
    expectation(for: NSPredicate(format: "label == \"$1.30\""),
                evaluatedWith: price, handler: nil)
    
    minus.tap()
    waitForExpectations(timeout: 1.0)
  }
  
  func testTotalForTwoProducts() {
    addTwoProducts()
    
    let tablesQuery = app.tables
    
    let eggsPrice = "$2.10"
    let firstCell = tablesQuery.cells.element(boundBy: 0)
    let eggs = parseDecimal(string: firstCell.staticTexts[eggsPrice].label)
    
    let peasPrice = "$0.95"
    let secondCell = tablesQuery.cells.element(boundBy: 1)
    let peas = parseDecimal(string: secondCell.staticTexts[peasPrice].label)
    
    let total = parseDecimal(string: app.staticTexts["$3.05"].label)
    
    XCTAssertEqual(eggs + peas, total, "Total is not correct")
  }
  
  func testChangeCurrency() {
    addThreeProducts()
    let eur = app.buttons["EUR"]
    eur.tap()
    
    let tablesQuery = app.tables
    
    var currency: String!
    
    let cell0 = tablesQuery.cells.element(boundBy: 0)
    currency = cell0.staticTexts.element(boundBy: 3).label.commonPrefix(with: "€")
    
    XCTAssertEqual("€", currency, "EUR does not appear in subtotal")
    
    let cell1 = tablesQuery.cells.element(boundBy: 1)
    currency = cell1.staticTexts.element(boundBy: 3).label.commonPrefix(with: "€")
    XCTAssertEqual("€", currency, "EUR does not appear in subtotal")
    
    let cell2 = tablesQuery.cells.element(boundBy: 2)
    currency = cell2.staticTexts.element(boundBy: 3).label.commonPrefix(with: "€")
    XCTAssertEqual("€", currency, "EUR does not appear in subtotal")
  }
  
  func testClickRefreshRates() {
    addFourProducts()
    
    let navBarButton = app.navigationBars["Checkout"].buttons["Refresh"]
    
    let gbp = app.buttons["GBP"]
    
    if isInternetAvailable() {
      expectation(for: NSPredicate(format: "isEnabled == true"),
                  evaluatedWith: gbp, handler: nil)
      
      navBarButton.tap()
      
      waitForExpectations(timeout: 5.0)
    } else {
      expectation(for: NSPredicate(format: "isEnabled == false"),
                  evaluatedWith: gbp, handler: nil)
      
      navBarButton.tap()
      
      waitForExpectations(timeout: 5.0)
    }
  }
  
  private func parseDecimal(string: String) -> Decimal {
    let numberString = string.replacingOccurrences(of: "$€£CHF", with: "")
    return Decimal(string: numberString) ?? Decimal(0.0)
  }
  
  private func addOneProduct() {
    let tablesQuery = app.tables
    
    milk = tablesQuery.staticTexts["Milk"]
    let milkCell = tablesQuery.cells.element(boundBy: 2)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: milkCell, handler: nil)
    
    milk.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    checkout()
  }
  
  private func addTwoProducts() {
    let tablesQuery = app.tables
    
    eggs = tablesQuery.staticTexts["Eggs"]
    let eggsCell = tablesQuery.cells.element(boundBy: 1)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: eggsCell, handler: nil)
    
    eggs.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    peas = tablesQuery.staticTexts["Peas"]
    let peasCell = tablesQuery.cells.element(boundBy: 0)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    checkout()
  }
  
  private func addThreeProducts() {
    let tablesQuery = app.tables
    
    peas = tablesQuery.staticTexts["Peas"]
    let peasCell = tablesQuery.cells.element(boundBy: 0)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    beans = tablesQuery.staticTexts["Beans"]
    let beansCell = tablesQuery.cells.element(boundBy: 3)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: beansCell, handler: nil)
    
    beans.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    eggs = tablesQuery.staticTexts["Eggs"]
    let eggsCell = tablesQuery.cells.element(boundBy: 1)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: eggsCell, handler: nil)
    
    eggs.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    checkout()
  }
  
  private func addFourProducts() {
    let tablesQuery = app.tables
    
    milk = tablesQuery.staticTexts["Milk"]
    let milkCell = tablesQuery.cells.element(boundBy: 2)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: milkCell, handler: nil)
    
    milk.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    peas = tablesQuery.staticTexts["Peas"]
    let peasCell = tablesQuery.cells.element(boundBy: 0)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    beans = tablesQuery.staticTexts["Beans"]
    let beansCell = tablesQuery.cells.element(boundBy: 3)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: beansCell, handler: nil)
    
    beans.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    eggs = tablesQuery.staticTexts["Eggs"]
    let eggsCell = tablesQuery.cells.element(boundBy: 1)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: eggsCell, handler: nil)
    
    eggs.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    checkout()
  }
  
  private func checkout() {
    let navBarButton = app.navigationBars["Products"].buttons["ShoppingBagGray"]
    navBarButton.tap()
  }
}
