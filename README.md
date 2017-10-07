# ShopBag

![ShopBag Screenshot](https://raw.githubusercontent.com/altamic/ShopBag/master/Images/screenshot.png)


[Online Demo](https://appetize.io/app/2q2w19r1qcvvvrhkepabpjwjdw?device=iphone5s&scale=100&orientation=portrait&osVersion=11.0&deviceColor=black)

### Design notes

Pretty standard Apple MVC. We have 2 view controllers: `ProductsViewController`, the first one, lets the user select (or deselect) products; the second one is `CheckoutViewController`: manages quantities and the grand total. As requested in the assignment, the user can select a different currency in which prices are converted and shown accordingly.

### Some habits and observations

I usually minimize the use of optionals and nils by unwrapping aggressively when I am in control of the optional at compile time<sup>1</sup> (that is the same principle of IBOutlets) or when I can instantiate a dummy/default instance of a class, instead of spreading nils around<sup>2</sup>, for example:

#### Case 1

```swift
let urlString = "http://apilayer.net/api/live?currencies=EUR,CHF,GBP"
let url = URL(string: urlString)!
```

#### Case 2

```swift
var layer = CALayer()
var path = UIBezierPath()
```

I am a fan of [IIFE](https://en.wikipedia.org/wiki/Immediately-invoked_function_expression) in JavaScript. Since I also can do the same in Swift, I tend to isolate boring initialization details as in:

```swift
lazy var badgeLabel: UILabel = {
  let label = UILabel(frame: CGRect(x: 22, y: -2, width: 11, height: 11))
  label.backgroundColor = UIColor.red
  label.textColor = UIColor.white
  label.font = UIFont.boldSystemFont(ofSize: 7)
  label.textAlignment = .center
  label.text = "0"
  label.layer.cornerRadius = label.bounds.size.height / 2
  label.layer.masksToBounds = true
  label.layer.borderWidth = 1
  label.layer.borderColor = UIColor.white.cgColor
  label.isHidden = true
  return label
}()
```
I am a long-time rubyist. It shines through my Swift code:

```swift
let lineItems = range.reduce(emptyLineItem) { (acc, itemNumber) -> [LineItem] in
  let quantity = sample(Array(0 ... 9))
  let productName = "Product #\(itemNumber)"
  let productUnit = "Unit of Product #\(itemNumber)"
  let price = sample([1.43, 0.74, 2.13, 1.19, 3.42, 4.32])
  let productToAppend = Product(name: productName,
                                unit: productUnit,
                                priceInDollars: Decimal(price))
  let lineItemToAppend = LineItem(product: productToAppend,
                                  quantity: quantity)

  return acc + [lineItemToAppend]
}
```

Ruby is dynamic… but I also like statically typed languages with parametric polymorphism (the so called Generics):
```swift
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
```

### Tests

I've produced two different test targets:

* ShopBagTests: scoring 25 Unit Tests (models, utils)
* ShopBagUITests: with 13 UI Tests (view controllers)

![ShopBag coverage](https://raw.githubusercontent.com/altamic/ShopBag/master/Images/coverage.png)

for a coverage of about 87.5% over less than 750 lines of code (ShopBag target).
ShopBagTests and ShopBagUITests score respectively 446 and 497 LOC.

You can run the test suite from XCode issuing a ⌘U.

> Thanks for your time!

# License

Copyright 2017 Michelangelo Altamore. It may be redistributed under the terms specified in the [LICENSE](LICENSE) file.

