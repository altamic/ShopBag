//
//  LineItemTests.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 22/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import XCTest
@testable import ShopBag

class LineItemTests: XCTestCase {
  
  var peas, eggs, milk, beans: Product!
  
  var products, productsOrderedByName: [Product]!
  var productsSet: Set<Product>!
  
  var oneProduct, twoProducts, threeProducts, fourProducts: [Product]!
  var possibleProducts: [[Product]]!
  
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
    
    productsSet = { Set(products) }()
    
    productsOrderedByName = Set(products).sorted(by: { (l, r) -> Bool in
      l.name < r.name
    })
    
    possibleProducts = permutations(products) // there are n! products :)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testProductsAreOrderedByName() {
    let orderedNames = products.map { (p) in p.name }.sorted()
    
    let lineItems = LineItem.orderedByNames(from: productsSet)
    
    orderedNames.enumerated().forEach { (item: (offset: Int, element: String)) in
      let productNameLineItem = lineItems[item.offset].product.name
      XCTAssertEqual(item.element, productNameLineItem, "#\(item.element) #\(item.offset) is not ordered by name")
    }
  }
  
  func testSubTotal() {
    let quantity = sample(Array(1...9))
    let product  = sample(products)
    
    let lineItem = LineItem(product: product, quantity: quantity)
    
    XCTAssertEqual(Decimal(quantity) * product.price(), lineItem.subTotal(), "SubTotal is not computed correctly")
  }
  
  func testSubTotalIsNonNegative() {
    let quantity = sample(Array(-9 ... -1))
    let product  = sample(products)
    
    let lineItem = LineItem(product: product, quantity: quantity)
    
    XCTAssertLessThanOrEqual(0, lineItem.subTotal(), "SubTotal is non negative")
  }
  
  func testSubTotalSystematically() {
    possibleProducts.forEach { (products) in
      let lineItems = LineItem.orderedByNames(from: Set(products))
      lineItems.forEach{ (element) in
        let quantity = sample(Array(-9 ... 9))
        var lineItem = element
        lineItem.quantity = quantity
        
        if quantity > 0 {
          XCTAssertEqual(Decimal(quantity) * lineItem.product.price(),lineItem.subTotal(), "SubTotal is not computed correctly")
        } else {
          XCTAssertEqual(Decimal(0) * lineItem.product.price(), lineItem.subTotal(), "SubTotal is not computed correctly")
        }
      }
    }
  }
  
  func testTotal() {
    let range = 1 ..< sample(Array(1...20))
    let emptyLineItem = [LineItem]()
    
    let lineItems = range.reduce(emptyLineItem) { (acc: [LineItem], itemNumber: Int) -> [LineItem] in
      let quantity = sample(Array(0 ... 9))
      let productName = "Product #\(itemNumber)"
      let productUnit = "Unit of Product #\(itemNumber)"
      let price = sample([1.43, 0.74, 2.13, 1.19, 3.42, 4.32])
      let productToAppend = Product(name: productName,
                                    unit: productUnit,
                                    priceInDollars: Decimal(price))
      let lineItemToAppend = LineItem(product: productToAppend,
                                      quantity: quantity)
      
      return acc + [lineItemToAppend]
    }
    
    let total = lineItems.reduce(Decimal(0)) { (acc, lineItem) -> Decimal in
      return acc + lineItem.subTotal()
    }
    
    XCTAssertEqual(total, LineItem.computeTotal(of: lineItems), "Total is not computed correctly")
    
  }
  
  func testTotalWithDifferentCurrency() {
    Product.CURRENCY_RATIO = ratioEur
    Product.CURRENCY_NAME  = currencyEur
    
    let range = 1 ..< sample(Array(1...20))
    let emptyLineItem = [LineItem]()
    
    let lineItems = range.reduce(emptyLineItem) { (acc, itemNumber) -> [LineItem] in
      let quantity = sample(Array(0 ... 9))
      let productName = "Product #\(itemNumber)"
      let productUnit = "Unit of Product #\(itemNumber)"
      let price = sample([1.43, 0.74, 2.13, 1.19, 3.42, 4.32])
      let productToAppend = Product(name: productName,
                                    unit: productUnit,
                                    priceInDollars: Decimal(price))
      let lineItemToAppend = LineItem(product: productToAppend,
                                      quantity: quantity)
      
      return acc + [lineItemToAppend]
    }
    
    let total = lineItems.reduce(Decimal(0)) { (acc, lineItem) -> Decimal in
      return acc + lineItem.subTotal()
    }
    
    XCTAssertEqual(total, LineItem.computeTotal(of: lineItems), "Total is not computed correctly")
  }
}
