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
    } else {
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
    let urlString = "http://apilayer.net/api/live?currencies=EUR,CHF,GBP&access_key=069020abea25d11b6f595ffe728488fe" // NOTE: in the real world access_key would be out of band
    
    let url = URL(string: urlString)!
    
    let request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringLocalCacheData,
                             timeoutInterval: 3.0)
    
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: apiHandler)
    task.resume()
  }
  
  
  private func apiHandler(data: Data?, response: URLResponse?, error: Error?) {
    let msg = "JSON API call failed:"
    if error != nil {
      print("\(msg) \(error!.localizedDescription)")
      disableSelectCurrencyButton()
      return
    }
    
    guard let httpStatus = response as? HTTPURLResponse,
      httpStatus.statusCode >= 200,
      httpStatus.statusCode <= 299 else {
      // check for http errors
      print("\(msg) HTTP status code should be 2xx")
        print("response = \(String(describing: response))")
      disableSelectCurrencyButton()
      return
    }
    
    do {
      guard let data = data else {
        print("\(msg) HTTP body contains no data")
        disableSelectCurrencyButton()
        return
      }
      guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        print("\(msg) Error deserializing JSON")
        disableSelectCurrencyButton()
        return
      }
      
      /*
      {
        "success": true,
        "terms": "https://currencylayer.com/terms",
        "privacy": "https://currencylayer.com/privacy",
        "timestamp": 1506365047,
        "source": "USD",
        "quotes": {
          "USDEUR": 0.844201,
          "USDCHF": 0.966899,
          "USDGBP": 0.74238
        }
      }
      */
      
      if let success = json["success"] as? Bool,
        success,
        let quotes = json["quotes"] as? [String: Double],
        let timestamp = json["timestamp"] as? Int {
        let initialValue: [Currency: Double] = [.usd: 1.0]
        self.currencyRatios = quotes.reduce(initialValue) { (acc, item) in
          let key = item.key
          let index = key.index(key.startIndex, offsetBy: 3) // What an awful Swift API ..and no: I will not use a String extension!!
          let currencyString = String(describing: key.substring(from: index))
          return acc.merge(with: [Currency(rawValue: currencyString)! : (1.0 / item.value)])
        }
        
        let dateTime = Date(timeIntervalSince1970: TimeInterval(timestamp))
        print("JSON API call success: updated rates at \(dateTime)")
        print(self.currencyRatios)
        enableSelectCurrencyButton()
      }
      else {
        print("\(msg) Response has no success status or no quotes are present")
        disableSelectCurrencyButton()
        return
      }
      
    } catch let error as NSError {
      print(error.debugDescription)
      disableSelectCurrencyButton()
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
