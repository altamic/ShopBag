//
//  CheckoutViewController.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 23/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//

import UIKit

class CheckoutViewController: UITableViewController {
  let lineItemCellIdentifier = "LineItemIdentifier"
  
  var lineItems = [LineItem]()
  
  var currencyRatios = [Currency: Double]()
  
  let segmentedButtonCurrencyOrder: [Int: Currency] = [0: .usd, 1: .eur, 2: .chf, 3: .gbp]
  
  let apiClient = URLSessionNetworkClient()
  
  @IBOutlet weak var currencySelectionView: UISegmentedControl!
  
  @IBOutlet weak var totalPriceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    disableSelectCurrencyButton()
    getCurrencyRates()
    updateTotalPrice()
  }
  
  @IBAction func currencySelectedChangedAction(_ sender: UISegmentedControl) {
    setProductsCurrency(segmentedButtonIndex:  sender.selectedSegmentIndex)
    tableView.reloadData()
    updateTotalPrice()
  }
  
  private func setProductsCurrency(segmentedButtonIndex: Int) {
    if let currency = segmentedButtonCurrencyOrder[segmentedButtonIndex],
        let ratio = currencyRatios[currency] {
      Product.CURRENCY_RATIO = ratio
      Product.CURRENCY_NAME = currency
    }
    else {
      currencySelectionView.selectedSegmentIndex = 0
      currencySelectionView.isEnabled = false
    }
  }
  
  @IBAction func refreshRatesAction(_ sender: UIBarButtonItem) {    disableSelectCurrencyButton()
    getCurrencyRates()
  }
  
  // MARK: - Table view data source  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return lineItems.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: lineItemCellIdentifier, for: indexPath) as! LineItemTableViewCell
    
    cell.configure(with: lineItems[indexPath.row])

    cell.minusOneBlock = {
      self.addAndSetPrice(-1, indexPath: indexPath, cell: cell)
      self.updateTotalPrice()
    }
    
    cell.addOneBlock = {
      self.addAndSetPrice(1, indexPath: indexPath, cell: cell)
      self.updateTotalPrice()
    }
    
    return cell
  }

  private func addAndSetPrice(_ plusOrMinusOne: Int, indexPath: IndexPath,
                              cell: LineItemTableViewCell) {
    guard plusOrMinusOne == 1 || plusOrMinusOne == -1 else { return }
    let currentQuantity = self.lineItems[indexPath.row].quantity
    self.lineItems[indexPath.row].quantity = plusOrMinusOne == 1 ? min(9, currentQuantity + 1) :
                                                                    max(1, currentQuantity - 1)
    cell.quantity.text = "\(self.lineItems[indexPath.row].quantity)"
    cell.priceView.text = formatCurrency(value: self.lineItems[indexPath.row].subTotal(), currencyCode: Product.CURRENCY_NAME)
  }
  
  private func updateTotalPrice() {
    let total = LineItem.computeTotal(of: lineItems)
    self.totalPriceLabel.text = formatCurrency(value: total, currencyCode: Product.CURRENCY_NAME)
  }
  
  private func getCurrencyRates() {
    let getRatesEndpoint = ApiRouter.getRatesFor(currencies:  ["EUR","CHF","GBP"])
    apiClient.request(to: getRatesEndpoint) { (result: Result<Currencies>) in
      switch result {
      case .success(let currencyRates):
        if currencyRates.success {
          let dateTime = Date(timeIntervalSince1970: TimeInterval(currencyRates.timestamp))
          print("JSON API call success: updated rates at \(dateTime)")
          
          self.currencyRatios = self.loadRates(from: currencyRates.quotes)
          print(self.currencyRatios)
          
          self.enableSelectCurrencyButton()
        }
        else {
          self.disableSelectCurrencyButton()
        }
      case .failure(let error):
        print("JSON API call failed: \(error.localizedDescription)")
        self.disableSelectCurrencyButton()
      }
    }
  }
  
  func loadRates(from quotes: [String: Double]) -> [Currency: Double] {
    let initialValue: [Currency: Double] = [.usd: 1.0]
    
    return quotes.reduce(initialValue) { (acc, item) in
      let key = item.key
      let index = key.index(key.startIndex, offsetBy: 3)
      let currencyString = String(describing: key[index...])
      return acc.merge(with: [Currency(rawValue: currencyString)!: item.value])
    }
  }
  
  func disableSelectCurrencyButton() {
    DispatchQueue.main.async {
      let indexes: [Currency: Int] = [.usd: 0, .eur: 1, .chf: 2, .gbp: 3]
      self.currencySelectionView.selectedSegmentIndex = indexes[Product.CURRENCY_NAME]!
      self.currencySelectionView.isEnabled = false
    }
  }
  
  func enableSelectCurrencyButton() {
    DispatchQueue.main.async {
      self.currencySelectionView.isEnabled = true
      self.tableView.reloadData()
      self.updateTotalPrice()
    }
  }
}
