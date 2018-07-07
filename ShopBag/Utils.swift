//
//  Utils.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 22/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

func formatCurrency(value: Decimal, currencyCode: Currency = .usd) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .currency
  formatter.currencyCode = currencyCode.rawValue
  formatter.maximumFractionDigits = 2
  formatter.locale = Locale(identifier: "en_US")
  let result = formatter.string(from: value as NSDecimalNumber)
  return result ?? "--"
}

extension Dictionary {
  func merge(with: [Key: Value]) -> [Key: Value] {
    var copy = self
    for (k, v) in with {
      copy[k] = v
    }
    return copy
  }
}

@IBDesignable
class UIPaddingLabel: UILabel {
  
  private var _padding: CGFloat = 0.0;
  
  public var padding: CGFloat {
    
    get { return _padding; }
    set {
      _padding = newValue;
      
      paddingTop = _padding;
      paddingLeft = _padding;
      paddingBottom = _padding;
      paddingRight = _padding;
    }
  }
  
  @IBInspectable var paddingTop: CGFloat = 0.0;
  @IBInspectable var paddingLeft: CGFloat = 0.0;
  @IBInspectable var paddingBottom: CGFloat = 0.0;
  @IBInspectable var paddingRight: CGFloat = 0.0;
  
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: paddingTop, left: paddingLeft,
                              bottom: paddingBottom, right: paddingRight);
    super.drawText(in: UIEdgeInsetsInsetRect(rect, insets));
  }
  
  override var intrinsicContentSize: CGSize {
    get {
      var intrinsicSuperViewContentSize = super.intrinsicContentSize;
      intrinsicSuperViewContentSize.height += paddingTop + paddingBottom;
      intrinsicSuperViewContentSize.width += paddingLeft + paddingRight;
      return intrinsicSuperViewContentSize;
    }
  }
}

