//
//  ProductTests.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 22/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import XCTest
@testable import ShopBag

class ProductTests: XCTestCase {
  
  var peas, eggs, milk, beans: Product!
  var products, productsOrderedByName: [Product]!
  
  var currencyEur: Currency = .eur
  var ratioEur = 1.177
  
  let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale(identifier: "en_US")
    return formatter
  }()
  
  override func setUp() {
    super.setUp()
    
    peas = Product(name: "Peas", unit: "per bag",
                   priceInDollars: 0.95, image: #imageLiteral(resourceName: "PeasBag"))
    
    eggs = Product(name: "Eggs", unit: "per dozen",
                   priceInDollars: 2.10, image: #imageLiteral(resourceName: "DozenEggs"))
    
    milk = Product(name: "Milk", unit: "per bottle",
                   priceInDollars: 1.30, image: #imageLiteral(resourceName: "MilkBottle"))
    
    beans = Product(name: "Beans", unit: "per can",
                    priceInDollars: 0.73, image: #imageLiteral(resourceName: "BeansCan"))
    
    products = [peas, eggs, milk, beans]

  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testPriceWithUnitaryRatio() {
    let beansPrice = Decimal(0.73)
    Product.CURRENCY_RATIO = 1.0
    
    let result = beans.price()
    XCTAssertEqual(beansPrice, result , "Expected price is \(beansPrice), found \(result)")
  }
  
  func testPriceWithNonUnitaryRatio() {
    Product.CURRENCY_RATIO = ratioEur
    let beansPrice = Decimal(0.73) * Decimal(ratioEur)
    
    let result = beans.price()
    XCTAssertEqual(beansPrice, result , "Expected price is \(beansPrice), found \(result)")
  }
  
  func testPriceDefaultFormat() {
    Product.CURRENCY_RATIO = 1.0
    Product.CURRENCY_NAME  = .usd
    formatter.currencyCode = Currency.usd.rawValue
    let formattedBeansPrice = formatter.string(from: beans.price() as NSNumber)!
    
    let result = formatCurrency(value: beans.price())
    XCTAssertEqual(formattedBeansPrice, result, "Expected formatted price is \(formattedBeansPrice), found \(result)")
  }
  
  func testVoidProductInfo() {
    let null = Product()
    
    XCTAssertEqual(null.name, "--")
    XCTAssertEqual(null.unit, "--")
    XCTAssertEqual(null.priceInDollars, 0.0)
    XCTAssertEqual(null.price(), 0.0)
  }
  
  func testPriceDifferentCurrency() {
    Product.CURRENCY_RATIO = ratioEur
    Product.CURRENCY_NAME  = currencyEur
    
    formatter.currencyCode = currencyEur.rawValue
    let formattedBeansPrice = formatter.string(from: beans.price() as NSNumber)!
    
    let result = formatCurrency(value: beans.price())
    XCTAssertNotEqual(formattedBeansPrice, result , "Expected formatted price is $ found \(currencyEur.rawValue)")
  }
  
  func testPriceDifferentFormat() {
    Product.CURRENCY_RATIO = ratioEur
    Product.CURRENCY_NAME  = currencyEur
    
    formatter.currencyCode = currencyEur.rawValue
    let formattedBeansPrice = formatter.string(from: beans.price() as NSNumber)!
    
    let result = formatCurrency(value: beans.price(),
                                currencyCode: currencyEur)
    XCTAssertEqual(formattedBeansPrice, result , "Expected formatted price is \(formattedBeansPrice), found \(result)")
  }
  
  func testProductEquality() {
    let otherEggs = Product(name: "Eggs", unit: "per dozen",
                            priceInDollars: 2.10,
                            image: #imageLiteral(resourceName: "DozenEggs")) // no easy #copy() in Swift

    
    XCTAssertEqual(eggs, otherEggs , "Expected equality does not hold for the same product")
  }
  
  func testProductUnequalityWithPrice() {
    let eggsPlusEpsilon = Product(name: "Eggs", unit: "per dozen",
                                  priceInDollars: Decimal(2.10 + 0.01),
                                  image: #imageLiteral(resourceName: "DozenEggs"))
    
    XCTAssertNotEqual(eggs, eggsPlusEpsilon , "Expected unequality does not hold for different prices")
  }
  
  func testProductUnequalityWithName() {
    let zygote = Product(name: "Zygote", unit: "per dozen",
                                  priceInDollars: 2.10,
                                  image: #imageLiteral(resourceName: "DozenEggs"))
    
    XCTAssertNotEqual(eggs, zygote , "Expected unequality does not hold for different names")
  }
  
  func testProductEqualityByHashValue() {
    let otherEggs = Product(name: "Eggs", unit: "per dozen",
                            priceInDollars: 2.10,
                            image: #imageLiteral(resourceName: "DozenEggs")) // no easy #copy() in Swift
    
    
    XCTAssertEqual(eggs.hashValue, otherEggs.hashValue , "Expected equality does not hold for the same product")
  }
}

