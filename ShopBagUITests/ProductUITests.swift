
//
//  ShopBagUITests.swift
//  ShopBagUITests
//
//  Created by Michelangelo Altamore on 22/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import XCTest

class ProductUITests: XCTestCase {
  
  var app: XCUIApplication!
  
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
  
  func testShoppingBagIsPresent() {
    let navBar = app.navigationBars["Products"].buttons["ShoppingBagGray"]
    
    expectation(for: NSPredicate(format: "exists == true"),
                                  evaluatedWith: navBar, handler: nil)
    
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Eggs"].tap()
    
    let animationDuration = 4.5
    waitForExpectations(timeout: animationDuration)
  }

  func testAlertShownAfterTapOnNavBarButtonWhenNoProductSelected() {
    addUIInterruptionMonitor(withDescription: "") { (alert) -> Bool in
      return true
    }
    
    let navBar = app.navigationBars["Products"].buttons["ShoppingBagGray"]
    
    navBar.tap()
    
    XCTAssert(app.staticTexts["Please select at least one product"].exists)
  }
  
  
  func testUserInteractionDisabledDuringAnimation() {
    let tablesQuery = app.tables
    let putIntoBagAnimation = 4.5
    
    // Select All
    let peas = tablesQuery.staticTexts["Peas"]
    let peasCell = tablesQuery.cells.element(boundBy: 0)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    peas.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation / 3)
  }
  
  func testAddAllIntoShoppingBag() {
    let tablesQuery = app.tables
    let putIntoBagAnimation = 4.5
    let removeFromBagAnimation = 1.0
    
    // Select All
    let peas = tablesQuery.staticTexts["Peas"]
    let peasCell = tablesQuery.cells.element(boundBy: 0)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let eggs = tablesQuery.staticTexts["Eggs"]
    let eggsCell = tablesQuery.cells.element(boundBy: 1)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: eggsCell, handler: nil)
    
    eggs.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let milk = tablesQuery.staticTexts["Milk"]
    let milkCell = tablesQuery.cells.element(boundBy: 2)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: milkCell, handler: nil)
    
    milk.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    let beans = tablesQuery.staticTexts["Beans"]
    let beansCell = tablesQuery.cells.element(boundBy: 3)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: beansCell, handler: nil)
    
    beans.tap()
    
    waitForExpectations(timeout: putIntoBagAnimation)
    
    // Deselect all
    expectation(for: NSPredicate(format: "isSelected == false"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()

    waitForExpectations(timeout: removeFromBagAnimation)
    
    expectation(for: NSPredicate(format: "isSelected == false"),
                evaluatedWith: eggsCell, handler: nil)
    
    eggs.tap()
    
    waitForExpectations(timeout: removeFromBagAnimation)
    
    expectation(for: NSPredicate(format: "isSelected == false"),
                evaluatedWith: milkCell, handler: nil)
    
    milk.tap()
    
    waitForExpectations(timeout: removeFromBagAnimation)
    
    expectation(for: NSPredicate(format: "isSelected == false"),
                evaluatedWith: beansCell, handler: nil)
    
    beans.tap()
    
    waitForExpectations(timeout: removeFromBagAnimation)
  }

  func testAddAndRemoveItemIntoOrFromShoppingBag() {
    let tablesQuery = app.tables
    let peas = tablesQuery.staticTexts["Peas"]
    let peasCell = tablesQuery.cells.element(boundBy: 0)
    expectation(for: NSPredicate(format: "isSelected == true"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    
    let putIntoBagAnimation = 4.5
    waitForExpectations(timeout: putIntoBagAnimation)
    
    expectation(for: NSPredicate(format: "isSelected == false"),
                evaluatedWith: peasCell, handler: nil)
    
    peas.tap()
    
    let removeFromBagAnimation = 1.0
    waitForExpectations(timeout: removeFromBagAnimation)
  }

  func testBadgeIsVisibleWhenAtLeastOneProductIsSelected() {
    //TODO
  }

  func testBadgeIsIncreasedByOneAfterAnimationEnds() {
    //TODO
  }
  
  func testBagdeIsDecreasedByOneAfterSelectedCellIsDeselected() {
    //TODO
  }
}
