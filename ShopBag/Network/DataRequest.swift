//
//  DataRequest.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 04/08/2018.
//  Copyright © 2018 altamic. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public protocol URLRequestConvertible {
  func asURLRequest() -> URLRequest
}

public protocol NetworkClient: class {
  func request<T: Decodable>(to target: URLRequestConvertible, completion: ((Result<T>) -> Void)?)
  func request<T: Decodable>(to target: URLRequestConvertible, decoder: JSONDecoder, completion: ((Result<T>) -> Void)?)
}

public final class URLSessionNetworkClient: NetworkClient {
  
  public var session = URLSession.shared
  
  public func request<T: Decodable>(to target: URLRequestConvertible, completion: ((Result<T>) -> Void)?) {
    let defaultDecoder = JSONDecoder()
    request(to: target, decoder: defaultDecoder, completion: completion)
  }
  
  public func request<T: Decodable>(to target: URLRequestConvertible, decoder: JSONDecoder, completion: ((Result<T>) -> Void)?) {
    let urlRequest = target.asURLRequest()
    let task = session.dataTask(with: urlRequest) { data, urlResponse, error in
      if let error = error {
        completion?(.failure(error))
      } else if let data = data {
        do {
          let decodedData = try decoder.decode(T.self, from: data)
          completion?(.success(decodedData))
        } catch {
          completion?(.failure(error))
        }
      }
    }
    task.resume()
  }
}

protocol DecoderProtocol {
  func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

extension JSONDecoder: DecoderProtocol { }

