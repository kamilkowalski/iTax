//
//  Product.swift
//  iTax
//
//  Created by Kamil Kowalski on 22.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class Product: Object {
  dynamic var name = ""
  dynamic var unit = ""
  dynamic var taxRate = 23
  dynamic var netPrice = 100.0
  
  /// Mnożnik podatku, mnożąc przez niego wartość netto otrzymamy wartość brutto
  private var taxRateMultiplier: Double {
    get {
      return 1 + (Double(taxRate) / 100)
    }
  }
  
  /// Wartość jednostkowa brutto
  var grossPrice: Double {
    get {
      return netPrice * taxRateMultiplier
    }
    set {
      netPrice = newValue / taxRateMultiplier
    }
  }
}