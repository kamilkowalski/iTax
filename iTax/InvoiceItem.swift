//
//  InvoiceItem.swift
//  iTax
//
//  Created by Kamil Kowalski on 14.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class InvoiceItem: Object {
  dynamic var name = ""
  dynamic var unit = ""
  dynamic var quantity = 1
  dynamic var taxRate = 23
  dynamic var netPrice = 100.0
  
  private var taxRateMultiplier: Double {
    get {
      return 1 + (Double(taxRate) / 100)
    }
  }
  
  var grossPrice: Double {
    get {
      return netPrice * taxRateMultiplier
    }
    set {
      netPrice = newValue / taxRateMultiplier
    }
  }
}