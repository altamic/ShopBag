//
//  ProductTableViewCell.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 22/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import UIKit

protocol ProductConfigurable {
  func configure(with product: Product)
}

class ProductTableViewCell: UITableViewCell {
  
  @IBOutlet weak var iconView: UIImageView!
  
  @IBOutlet weak var priceView: UILabel!
  
  @IBOutlet weak var nameView: UILabel!
  
  @IBOutlet weak var unitView: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
}

extension ProductTableViewCell: ProductConfigurable {
  func configure(with product: Product) {
    self.nameView.text = product.name
    self.unitView.text = product.unit
    self.priceView.text = formatCurrency(value: product.price(), currencyCode: Product.CURRENCY_NAME)
    self.iconView.image = product.image
  }
}
