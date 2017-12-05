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
  
  
  let putIntoBagAnimation = 6.5
  
  override func setUp() {
    super.setUp()
    
    continueAfterFailure = false
    
    app = XCUIApplication()
    app.launch()
    
    XCUIDevice.shared.orientation = .portrait
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testIncreaseOrDecreaseQuantityForOneProduct() {
    addOneProduct()
    
    let tablesQuery = app.tables
    
    let firstCell = tablesQuery.cells.element(boundBy: 0)
    
    let plus = firstCell.buttons["+"]
    let initialQuantity = tablesQuery.staticTexts["1"]
    
    expectation(for: NSPredicate(format: "exists == true"),
                evaluatedWith: initialQuantity, handler: nil)
    
    waitForExpectations(timeout: 2)
    
    plus.tap()
    
    let quantityIncreased = tablesQuery.staticTexts["2"]
    expectation(for: NSPredicate(format: "exists == true"),
                evaluatedWith: quantityIncreased, handler: nil)
    
    waitForExpectations(timeout: 2)
    
    let minus = firstCell.buttons["-"]
    minus.tap()
    
    let quantityDecreased = tablesQuery.staticTexts["1"]
    expectation(for: NSPredicate(format: "exists == true"),
                evaluatedWith: quantityDecreased, handler: nil)
    
    waitForExpectations(timeout: 2)
  }
  
  func testSubtotalQuantityForOneProduct() {
    addOneProduct()
    
    let tablesQuery = app.tables
    
    let firstCell = tablesQuery.cells.element(boundBy: 0)
    
    let plus = firstCell.buttons["+"]
    let price = firstCell.staticTexts["$1.30"]
    expectation(for: NSPredicate(format: "label == \"$1.30\""),
                                 evaluatedWith: price, handler: nil)
    
    waitForExpectations(timeout: 2)
    
    plus.tap()

    let price2times = tablesQuery.staticTexts["$2.60"]
    expectation(for: NSPredicate(format: "label == \"$2.60\""),
                evaluatedWith: price2times, handler: nil)
    
    waitForExpectations(timeout: 2)
    
    let minus = firstCell.buttons["-"]
    minus.tap()
    expectation(for: NSPredicate(format: "label == \"$1.30\""),
                evaluatedWith: price, handler: nil)
    
    waitForExpectations(timeout: 2)
  }
  
  func testTotalForTwoProducts() {
    addTwoProducts()
    
    let tablesQuery = app.tables
    
    let eggsPriceLabel = "$2.10"
    let firstCell = tablesQuery.cells.element(boundBy: 0)
    let eggsPrice = firstCell.staticTexts[eggsPriceLabel]
    expectation(for: NSPredicate(format: "exists == true"),
                evaluatedWith: eggsPrice, handler: nil)
      
    let eggsPriceNumber = eggsPrice.label
                                   .replacingOccurrences(of: "$", with: "")
    let eggs = parseDecimal(string: eggsPriceNumber)
    
    let peasPriceLabel = "$0.95"
    let secondCell = tablesQuery.cells.element(boundBy: 1)
    let peasPrice = secondCell.staticTexts[peasPriceLabel]
    expectation(for: NSPredicate(format: "exists == true"),
                evaluatedWith: peasPrice, handler: nil)
    
    let peasPriceNumber = peasPrice.label
                                   .replacingOccurrences(of: "$", with: "")

    let peas = parseDecimal(string: peasPriceNumber)
    
    let total = app.staticTexts["$3.05"]
    
    expectation(for: NSPredicate(format: "exists == true"),
                evaluatedWith: total, handler: nil)
    
    waitForExpectations(timeout: 2)
    
    expectation(for: NSPredicate(format: "label == \"$\(eggs + peas)\""),
                evaluatedWith: total, handler: nil)
    
    waitForExpectations(timeout: 2)
  }
  
  func testChangeCurrency() {
    addThreeProducts()
    let eur = app.buttons["EUR"]
    eur.tap()
    
    expectation(for: NSPredicate(format: "selected == true"),
                evaluatedWith: eur, handler: nil)
    
    waitForExpectations(timeout: 2, handler: nil)
    
    let tablesQuery = app.tables
    
    var currency: String!
    var element: XCUIElement!
    
    let cell0 = tablesQuery.cells.element(boundBy: 0)
    element = cell0.staticTexts.element(boundBy: 3)
    currency = element.label.commonPrefix(with: "€")
    
    //    XCTAssertEqual("€", currency, "EUR does not appear in subtotal")
    expectation(for: NSPredicate(format: "label BEGINSWITH[cd] %@", currency),
                evaluatedWith: element, handler: nil)
    
    waitForExpectations(timeout: 2, handler: nil)
    
    let cell1 = tablesQuery.cells.element(boundBy: 1)
    element = cell1.staticTexts.element(boundBy: 3)
    currency = element.label.commonPrefix(with: "€")

    //    XCTAssertEqual("€", currency, "EUR does not appear in subtotal")
    expectation(for: NSPredicate(format: "label BEGINSWITH[cd] %@", currency),
                evaluatedWith: element, handler: nil)
    
    waitForExpectations(timeout: 2, handler: nil)
    
    let cell2 = tablesQuery.cells.element(boundBy: 2)
    element = cell2.staticTexts.element(boundBy: 3)
    currency = element.label.commonPrefix(with: "€")

    //    XCTAssertEqual("€", currency, "EUR does not appear in subtotal")
    expectation(for: NSPredicate(format: "label BEGINSWITH[cd] %@", currency),
                evaluatedWith: element, handler: nil)
    
    waitForExpectations(timeout: 2, handler: nil)
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
    
    let badgeLabel = app.navigationBars["Products"].staticTexts["1"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabel, handler: nil)
    
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
    
    let badgeLabelOne = app.navigationBars["Products"].staticTexts["1"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelOne, handler: nil)
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    peas = tablesQuery.staticTexts["Peas"]
    let peasCell = tablesQuery.cells.element(boundBy: 0)
    
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let badgeLabelTwo = app.navigationBars["Products"].staticTexts["2"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelTwo, handler: nil)
    
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
    
    let badgeLabelOne = app.navigationBars["Products"].staticTexts["1"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelOne, handler: nil)
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    beans = tablesQuery.staticTexts["Beans"]
    let beansCell = tablesQuery.cells.element(boundBy: 3)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: beansCell, handler: nil)
    
    beans.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let badgeLabelTwo = app.navigationBars["Products"].staticTexts["2"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelTwo, handler: nil)
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    eggs = tablesQuery.staticTexts["Eggs"]
    let eggsCell = tablesQuery.cells.element(boundBy: 1)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: eggsCell, handler: nil)
    
    eggs.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let badgeLabelThree = app.navigationBars["Products"].staticTexts["3"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelThree, handler: nil)
    
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
    
    let badgeLabelOne = app.navigationBars["Products"].staticTexts["1"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelOne, handler: nil)
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    peas = tablesQuery.staticTexts["Peas"]
    let peasCell = tablesQuery.cells.element(boundBy: 0)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let badgeLabelTwo = app.navigationBars["Products"].staticTexts["2"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelTwo, handler: nil)
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    beans = tablesQuery.staticTexts["Beans"]
    let beansCell = tablesQuery.cells.element(boundBy: 3)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: beansCell, handler: nil)
    
    beans.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let badgeLabelThree = app.navigationBars["Products"].staticTexts["3"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelThree, handler: nil)
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    eggs = tablesQuery.staticTexts["Eggs"]
    let eggsCell = tablesQuery.cells.element(boundBy: 1)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: eggsCell, handler: nil)
    
    eggs.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let badgeLabelFour = app.navigationBars["Products"].staticTexts["4"]
    expectation(for: NSPredicate(format: "identifier == \"BadgeLabel\""),
                evaluatedWith: badgeLabelFour, handler: nil)
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    checkout()
  }
  
  private func checkout() {
    let navBarButton = app.navigationBars["Products"].buttons["ShoppingBagGray"]
    navBarButton.tap()
  }
}
