//
//  Currencies.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 04/08/2018.
//  Copyright © 2018 altamic. All rights reserved.
//

import Foundation

struct Currencies: Decodable {
  enum CodingKeys: String, CodingKey {
    case success
    case terms
    case privacy
    case timestamp
    case source
    case quotes
    case error
  }
  
  struct ErrorContainer: Decodable {
    let code: Int
    let info: String
  }
  
  let success: Bool
  let terms: URL
  let privacy: URL
  let timestamp: Double
  let source: String
  let quotes: [String: Double]
  
  let error: ErrorContainer?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    success = try container.decode(Bool.self, forKey: .success)
    
    if success {
      terms = try container.decode(URL.self, forKey: .terms)
      privacy = try container.decode(URL.self, forKey: .privacy)
      timestamp = try container.decode(Double.self, forKey: .timestamp)
      source = try container.decode(String.self, forKey: .source)
      quotes = try container.decode([String: Double].self, forKey:. quotes)
      error = nil
    }
    else {
      if let error = try container.decodeIfPresent(ErrorContainer.self,
                                                   forKey: .error) {
        throw CurrencyApiError(code: error.code, info: error.info)
      }
      else {
        let defaultError = CurrencyApiError(code: -1, info: "Unexpected Error")
        throw defaultError
      }
    }
  }
}

struct CurrencyApiError: Error {
  let code: Int
  let info: String
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
 
{
  "success": false,
  "error": {
  "code": 202,
  "info": "You have provided one or more invalid Currency Codes. [Required format: currencies=EUR,USD,GBP,...]"
  }
}

*/


