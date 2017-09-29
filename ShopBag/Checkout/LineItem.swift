//
//  LineItem.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 22/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import Foundation

struct LineItem {
  let product: Product
  var quantity: Int
  
  init(product: Product, quantity: Int = 1) {
    self.product = product
    self.quantity = quantity
  }
  
  public func subTotal() -> Decimal {
    return product.price() * Decimal(max(0, quantity))
  }
  
  public static func orderedByNames(from productsSet: Set<Product>) -> [LineItem] {
    let sortedProducts = productsSet.sorted {
      a, b in
      return a.name < b.name
    }
    return sortedProducts.map { product in LineItem(product: product) }
  }
  
  public static func computeTotal(of allItems: [LineItem]) -> Decimal {
    return allItems.map { (lineItem) in lineItem.subTotal() }
      .reduce(Decimal(0)) { (acc, subTotal)  in
        acc + subTotal
    }
  }
}
