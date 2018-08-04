//
//  ApiRouter.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 04/08/2018.
//  Copyright © 2018 altamic. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
  case options = "OPTIONS"
  case get = "GET"
  case head = "HEAD"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
  case trace = "TRACE"
  case connect = "CONNECT"
}

public enum ApiRouter: URLRequestConvertible {
  public static let BaseUrlString = "http://apilayer.net"
  public static let Token = "069020abea25d11b6f595ffe728488fe"
  
  case getRatesFor(currencies: [String])
  // Add here other APIs if needed

  var method: HTTPMethod {
    switch self {
    case .getRatesFor:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .getRatesFor:
      return "/api/live"
    }
  }
  
  var url: URL? {
    let url = URL(string: ApiRouter.BaseUrlString)!
    
    switch self {
    case let .getRatesFor(currencies):
      let commaJoinedCurrencies = currencies.joined(separator: ",")
      guard !commaJoinedCurrencies.isEmpty,
        var components = URLComponents(url: url.appendingPathComponent(path),
                                       resolvingAgainstBaseURL: false)
        else {
          return url
      }
      
      components.queryItems = [ URLQueryItem(name: "currencies", value: commaJoinedCurrencies),
                                URLQueryItem(name: "access_key", value: ApiRouter.Token) ]
      return components.url
    }
  }
  
  public func asURLRequest() -> URLRequest {
    var request = URLRequest(url: url!,
                             cachePolicy: .reloadIgnoringLocalCacheData,
                             timeoutInterval: 3.0)
    request.httpMethod = method.rawValue
    
    return request
  }
}

public enum ApiError: Error {
  case notFound // 404
  case serverError(Int) // 5xx
  case requestError // 4xx
  case responseFormatInvalid(String)
  case connectionError(Error)
  case invalidURL(url: URL?)
  case invalidHeader([AnyHashable: Any])
}
