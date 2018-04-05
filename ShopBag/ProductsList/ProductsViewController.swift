//
//  ViewController.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 22/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import UIKit

class ProductsViewController: UITableViewController {
  
  let productCellIdentifier = "ProductIdentifier"
  let checkoutSegueIdentifier = "CheckoutSegueIdentifier"
  
  lazy var products = [
    Product(name: "Peas", unit: "per bag",
            priceInDollars: 0.95, image: #imageLiteral(resourceName: "PeasBag")),
    
    Product(name: "Eggs", unit: "per dozen",
            priceInDollars: 2.10, image: #imageLiteral(resourceName: "DozenEggs")),
    
    Product(name: "Milk", unit: "per bottle",
            priceInDollars: 1.30, image: #imageLiteral(resourceName: "MilkBottle")),
    
    Product(name: "Beans", unit: "per can",
            priceInDollars: 0.73, image: #imageLiteral(resourceName: "BeansCan"))
  ]
  
  lazy var productsInBag = Set<Product>()
  
  // button
  let shopBagButton: UIButton =  {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    button.setBackgroundImage(#imageLiteral(resourceName: "ShoppingBagGray"), for: .normal)
    return button
  }()
  
  // badge
  lazy var badgeLabel: UILabel = {
    let label = UILabel(frame: CGRect(x: 22, y: -2, width: 11, height: 11))
    label.backgroundColor = UIColor.red
    label.textColor = UIColor.white
    label.font = UIFont.boldSystemFont(ofSize: 7)
    label.textAlignment = .center
    label.text = "0"
    label.accessibilityIdentifier = "BadgeLabel"
    label.layer.cornerRadius = label.bounds.size.height / 2
    label.layer.masksToBounds = true
    label.layer.borderWidth = 1
    label.layer.borderColor = UIColor.white.cgColor
    label.isHidden = true
    return label
  }()
  
  var shopBagBarButton = UIBarButtonItem()
  
  var layer = CALayer()
  var path = UIBezierPath()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // link shopBagButton to action
    shopBagButton.addTarget(self, action: #selector(checkoutAction), for: UIControlEvents.touchUpInside)
      
    // badge label
    shopBagButton.addSubview(badgeLabel)

    // bar button item
    shopBagBarButton = UIBarButtonItem(customView: shopBagButton)
    
    navigationItem.rightBarButtonItem = shopBagBarButton
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == checkoutSegueIdentifier {
      let checkoutViewController = segue.destination as! CheckoutViewController
      checkoutViewController.lineItems = LineItem.orderedByNames(from:productsInBag)
    }
  }

  @objc dynamic func checkoutAction() {
    if productsInBag.count == 0 {
      self.showMessage(message: "Please select at least one product")
    }
    else {
      performSegue(withIdentifier: checkoutSegueIdentifier, sender: self)
    }
  }
  
  func toggleBadgeVisibility() {
    if productsInBag.count > 0 {
      shopBagBarButton.isAccessibilityElement = false
      badgeLabel.isHidden = false
    }
    else {
      shopBagBarButton.isAccessibilityElement = true
      badgeLabel.isHidden = true
    }
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return products.count
  }
  
  override func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: productCellIdentifier, for: indexPath) as! ProductTableViewCell
    
    cell.configure(with: products[indexPath.row])

    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let product = products[indexPath.row]
    
    // put into bag
    productsInBag.insert(product)
    
    // animation
    let image = UIImageView(image: product.image)
    var rect = tableView.rectForRow(at: indexPath)
    rect.origin.y -= tableView.contentOffset.y
    var headRect = image.frame
    headRect.origin.y = rect.origin.y + headRect.origin.y - 64
    
    putIntoBag(headRect, image)
  }
  
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let product = products[indexPath.row]
    
    // remove from bag
    productsInBag.remove(product)
    
    badgeLabel.text = "\(productsInBag.count)"
    
    toggleBadgeVisibility()
    
    // animation
    let image = UIImageView(image: product.image)
    
    let rect = shopBagBarButton.customView!.frame
    removeFromBag(rect, image)
  }
  
  func showMessage(message: String) {
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    self.present(alertController, animated: true, completion: nil)
    
    let delay = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delay) {
      alertController.dismiss(animated: true, completion: nil)
    }
  }
}

extension ProductsViewController: CAAnimationDelegate {
  
  func putIntoBag(_ rect: CGRect, _ image: UIImageView) {
    layer = CALayer()
    layer.contents = image.layer.contents
    layer.contentsGravity = kCAGravityResizeAspectFill
    layer.bounds = rect
    layer.cornerRadius = layer.bounds.height * 0.5
    layer.masksToBounds = true
    layer.position = CGPoint(x: image.center.x, y: rect.minY + 96)
    UIApplication.shared.keyWindow?.layer.addSublayer(layer)
    
    path = UIBezierPath()
    path.move(to: layer.position)
    path.addQuadCurve(to: CGPoint(x: SCREEN_WIDTH - 25, y: 35),
                      controlPoint: CGPoint(x: SCREEN_WIDTH * 0.5, y:
                        rect.origin.y - 80))
    
    putIntoBagAnimation()
  }
  
  func putIntoBagAnimation() {
    tableView.isUserInteractionEnabled = false
    shopBagButton.isUserInteractionEnabled = false
    
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.path = path.cgPath
    animation.rotationMode = kCAAnimationRotateAuto
    
    let bigAnimation = CABasicAnimation(keyPath: "transform.scale")
    bigAnimation.duration = 0.5
    bigAnimation.fromValue = 1
    bigAnimation.toValue = 2
    bigAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    
    let smallAnimation = CABasicAnimation(keyPath: "transform.scale")
    smallAnimation.beginTime = 0.5
    smallAnimation.duration = 1.5
    smallAnimation.fromValue = 2
    smallAnimation.toValue = 0.3
    smallAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    let groupAnimation = CAAnimationGroup()
    groupAnimation.animations = [animation, bigAnimation, smallAnimation]
    groupAnimation.duration = 2
    groupAnimation.isRemovedOnCompletion = false
    groupAnimation.fillMode = kCAFillModeForwards
    groupAnimation.delegate = self
    layer.add(groupAnimation, forKey: "putIntoBag")
  }
  
  func removeFromBag(_ rect: CGRect, _ image: UIImageView) {
    let cartAnimation = CABasicAnimation(keyPath: "transform.translation.y")
    cartAnimation.duration = 0.15
    cartAnimation.fromValue = 5
    cartAnimation.toValue = 0
    cartAnimation.autoreverses = false
    shopBagBarButton.customView?.layer.add(cartAnimation, forKey: "removeFromBag")
  }
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    
    if anim == layer.animation(forKey: "putIntoBag") {
      
      tableView.isUserInteractionEnabled = true
      shopBagButton.isUserInteractionEnabled = true
      
      layer.removeAllAnimations()
      layer.removeFromSuperlayer()
      layer = CALayer()
      
      toggleBadgeVisibility()
      
      let productsCountAnimation = CATransition()
      productsCountAnimation.duration = 0.25
      badgeLabel.text = "\(self.productsInBag.count)"
      badgeLabel.layer.add(productsCountAnimation, forKey: nil)
      
      let cartAnimation = CABasicAnimation(keyPath: "transform.translation.y")
      cartAnimation.duration = 0.15
      cartAnimation.fromValue = -5
      cartAnimation.toValue = 5
      cartAnimation.autoreverses = true
      shopBagBarButton.customView?.layer.add(cartAnimation, forKey: nil)
    }
  }
}

