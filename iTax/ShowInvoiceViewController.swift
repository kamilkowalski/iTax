//
//  ShowInvoiceViewController.swift
//  iTax
//
//  Created by Kamil Kowalski on 16.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Cocoa

class ShowInvoiceViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

  @IBOutlet weak var fullNameField: NSTextField!
  @IBOutlet weak var shortNameField: NSTextField!
  @IBOutlet weak var streetAddressField: NSTextField!
  @IBOutlet weak var zipCodeField: NSTextField!
  @IBOutlet weak var cityField: NSTextField!
  
  @IBOutlet weak var invoiceNumberField: NSTextField!
  @IBOutlet weak var issueDateField: NSTextField!
  @IBOutlet weak var paymentDeadlineField: NSTextField!
  
  @IBOutlet weak var itemsTable: NSTableView!
  
  var invoice: Invoice? {
    didSet {
      refreshData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    itemsTable.setDelegate(self)
    itemsTable.setDataSource(self)
  }
  
  private func refreshData() {
    if let i = invoice {
      let formatter = NSDateFormatter()
      formatter.dateStyle = .MediumStyle
      
      fullNameField.stringValue = i.customerFullName
      shortNameField.stringValue = i.customerShortName
      streetAddressField.stringValue = i.customerAddressStreet
      zipCodeField.stringValue = i.customerAddressPostalCode
      cityField.stringValue = i.customerAddressCity
      
      invoiceNumberField.stringValue = i.number
      if let issueDate = i.issueDate {
        issueDateField.stringValue = formatter.stringFromDate(issueDate)
      }
      
      if let paymentDeadline = i.paymentDeadline {
        paymentDeadlineField.stringValue = formatter.stringFromDate(paymentDeadline)
      }
    }
    itemsTable.reloadData()
  }
  
  // MARK: - IBAction
  @IBAction func closeWindow(sender: NSButton) {
    let application = NSApplication.sharedApplication()
    application.abortModal()
    self.view.window?.close()
  }
  
  // MARK: - NSTableViewDelegate
  /// Podaje ilość wierszy do wyświetlenia w tabeli pozycji faktury
  /// - Parameter tableView: `NSTableView` którego dotyczy zapytanie
  /// - Returns: liczbę wierszy
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return invoice?.items.count ?? 0
  }
  
  /// Zwraca widok komórki w tabeli pozycji faktury
  /// - Parameter tableView: `NSTableView` którego dotyczy zapytanie
  /// - Parameter tableColumn: kolumna, której komórka ma zostać zwrócona
  /// - Parameter row: wiersz, którego komórka ma zostać zwrócona
  /// - Returns: widok komórki
  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let items = invoice?.items else { return nil }
    var text:String = ""
    var cellIdentifier: String = ""
    let item = items[row]
    
    guard let column = tableColumn else {
      return nil
    }
    
    guard let index = tableView.tableColumns.indexOf(column) else {
      return nil
    }
    let columnSpec: [(String, String)] = [
      (item.name, "NameCellID"),
      (item.unit, "UnitCellID"),
      (String(format: "%d", item.quantity), "QuantityCellID"),
      (String(format: "%d%%", item.taxRate), "TaxCellID"),
      (String(format: "%.2f", item.netPrice), "NetCellID"),
      (String(format: "%.2f", item.grossPrice), "GrossCellID"),
      (String(format: "%.2f", item.totalNetPrice), "TotalNetCellID"),
      (String(format: "%.2f", item.totalGrossPrice), "TotalGrossCellID")
    ]
    
    (text, cellIdentifier) = columnSpec[index]
    
    if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    return nil
  }
}
