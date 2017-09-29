//
//  Product.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 22/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import UIKit

enum Currency: String {
  case usd = "USD"
  case eur = "EUR"
  case chf = "CHF"
  case gbp = "GBP"
}

struct Product: Hashable {
  static var CURRENCY_NAME: Currency = .usd
  static var CURRENCY_RATIO: Double = 1.0
  
  let name: String
  let unit: String
  let priceInDollars: Decimal
  let image: UIImage
  
  init(name: String = "--", unit: String = "--",
       priceInDollars: Decimal = 0.0, image: UIImage = UIImage()) {
    self.name = name
    self.unit = unit
    self.priceInDollars = priceInDollars
    self.image = image
  }
  
  public func price() -> Decimal {
    return priceInDollars * Decimal(Product.CURRENCY_RATIO)
  }
  
  public var hashValue: Int {
    return [self.name.hashValue, self.unit.hashValue,
            self.priceInDollars.hashValue].reduce(5381) {
      ($0 << 5) &+ $0 &+ Int($1)
    }
  }
  
  static func ==(left: Product, right: Product) -> Bool {
    return left.hashValue == right.hashValue
  }
}
