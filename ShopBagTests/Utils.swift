//
//  Utils.swift
//  ShopBag
//
//  Created by Michelangelo Altamore on 23/09/17.
//  Copyright © 2017 altamic. All rights reserved.
//
import Foundation

func sample<T>(_ array: [T]) -> T {
  let randomNumber = Int(arc4random_uniform(UInt32(array.count)))
  return array[randomNumber]
}

func permutations<T>(_ xs: [T]) -> [[T]] {
  guard let (head, tail) = decompose(xs) else { return [[]] }
  return permutations(tail).flatMap { between(head, $0) }
}

func decompose<T>(_ array: [T]) -> (T, [T])? {
  guard let x = array.first else { return nil }
  return (x, Array(array[1..<array.count]))
}

func between<T>(_ x: T, _ ys: [T]) -> [[T]] {
  guard let (head, tail) = decompose(ys) else { return [[x]] }
  return [[x] + ys] + between(x, tail).map { [head] + $0 }
}
