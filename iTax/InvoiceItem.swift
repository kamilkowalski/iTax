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
  /// Nazwa pozycji faktury
  dynamic var name = ""
  /// Jednostka
  dynamic var unit = ""
  /// Ilość
  dynamic var quantity = 1
  /// Stawka podatku
  dynamic var taxRate = 23
  /// Wartość jednostkowa netto
  dynamic var netPrice = 100.0
  
  /// Faktura
  dynamic var invoice: Invoice? {
    willSet {
      if invoice == newValue {
        return
      }
      
      if invoice != nil {
        invoice?.removeInvoiceItem(self)
      }
    }
    
    didSet {
      if invoice != oldValue {
        invoice?.addInvoiceItem(self)
      }
    }
  }
  
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
  
  /// Suma netto
  var totalNetPrice: Double {
    get {
      return netPrice * Double(quantity)
    }
  }
  
  /// Suma brutto
  var totalGrossPrice: Double {
    get {
      return grossPrice * Double(quantity)
    }
  }
}