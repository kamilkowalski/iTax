//
//  Invoice.swift
//  iTax
//
//  Created by Kamil Kowalski on 14.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class Invoice: Object {
  dynamic var number = ""
  dynamic var issueDate: NSDate?
  dynamic var paymentDeadline: NSDate?
  dynamic var paid = false
  dynamic var typeRaw = InvoiceType.CostInvoice.rawValue
  dynamic var customerFullName = ""
  dynamic var customerShortName = ""
  dynamic var customerAddressStreet = ""
  dynamic var customerAddressCity = ""
  dynamic var customerAddressPostalCode = ""
  
  let items = List<InvoiceItem>()
  
  var type: InvoiceType {
    get {
      return InvoiceType(rawValue: typeRaw)!
    }
    
    set {
      typeRaw = newValue.rawValue
    }
  }
  
  var netPrice: Double {
    get {
      return items.map { $0.totalNetPrice }.reduce(0, combine: +)
    }
  }
  
  var grossPrice: Double {
    get {
      return items.map { $0.totalGrossPrice }.reduce(0, combine: +)
    }
  }
}