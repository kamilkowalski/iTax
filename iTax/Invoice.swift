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
  /// Numer faktury
  dynamic var number = ""
  /// Data wystawienia
  dynamic var issueDate: NSDate?
  /// Termin płatności
  dynamic var paymentDeadline: NSDate?
  /// Status płatności
  dynamic var paid = false
  /// Typ faktury w postaci `String`
  dynamic var typeRaw = InvoiceType.CostInvoice.rawValue
  /// Pełna nazwa kontrahenta
  dynamic var customerFullName = ""
  /// Nazwa skrócona kontrahenta
  dynamic var customerShortName = ""
  /// Adres kontrahenta
  dynamic var customerAddressStreet = ""
  /// Miasto kontrahenta
  dynamic var customerAddressCity = ""
  /// Kod pocztowy kontrahenta
  dynamic var customerAddressPostalCode = ""
  
  /// Lista pozycji faktury
  let items = List<InvoiceItem>()
  
  /// Typ faktury w formie `InvoiceType`
  var type: InvoiceType {
    get {
      return InvoiceType(rawValue: typeRaw)!
    }
    
    set {
      typeRaw = newValue.rawValue
    }
  }
  
  /// Wartość netto faktury
  var netPrice: Double {
    get {
      return items.map { $0.totalNetPrice }.reduce(0, combine: +)
    }
  }
  
  /// Wartośc brutto faktury
  var grossPrice: Double {
    get {
      return items.map { $0.totalGrossPrice }.reduce(0, combine: +)
    }
  }

  /// Dodaje pozycję do faktury
  /// - Parameter item: pozycja do dodania
  func addInvoiceItem(item: InvoiceItem) {
    if items.indexOf(item) == nil {
      items.append(item)
      item.invoice = self
    }
  }
  
  /// Usuwa pozycję z faktury
  /// - Parameter item: pozycja do usunięcia
  func removeInvoiceItem(item: InvoiceItem) {
    if let index = items.indexOf(item) {
      items.removeAtIndex(index)
    }
  }
}

/// Enumerator zawierający typ faktury
enum InvoiceType: String {
  case CostInvoice, IncomeInvoice
}