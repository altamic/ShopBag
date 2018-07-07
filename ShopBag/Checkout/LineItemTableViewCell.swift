//
//  LineItemTableViewCell.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 23/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import UIKit

protocol LineItemConfigurable {
  func configure(with lineItem: LineItem)
}

class LineItemTableViewCell: UITableViewCell {
  
  @IBOutlet weak var iconView: UIImageView!
  
  @IBOutlet weak var priceView: UILabel!
  
  @IBOutlet weak var nameView: UILabel!
  
  @IBOutlet weak var unitView: UILabel!
  
  @IBOutlet weak var quantity: UILabel!
  
  var addOneBlock: (()-> Void)?
  var minusOneBlock: (()-> Void)?
  
  @IBAction func minusOneAction() {
    self.minusOneBlock?()
  }
  
  @IBAction func plusOneAction() {
    self.addOneBlock?()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}

extension LineItemTableViewCell: LineItemConfigurable {
  func configure(with lineItem: LineItem) {
    self.nameView.text = lineItem.product.name
    self.unitView.text = lineItem.product.unit
    self.priceView.text = formatCurrency(value: lineItem.subTotal(), currencyCode: Product.CURRENCY_NAME)
    self.iconView.image = lineItem.product.image
    self.quantity.text = "\(lineItem.quantity)"
  }
}


