//
//  AddInvoiceViewController.swift
//  iTax
//
//  Created by Kamil Kowalski on 13.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Cocoa
import RealmSwift

class AddInvoiceViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

  @IBOutlet weak var numberField: NSTextField!
  @IBOutlet weak var issueDateField: NSDatePicker!
  @IBOutlet weak var paymentDeadlineField: NSDatePicker!
  
  @IBOutlet weak var fullNameField: NSTextField!
  @IBOutlet weak var shortNameField: NSTextField!
  @IBOutlet weak var streetAddressField: NSTextField!
  @IBOutlet weak var zipSmallField: NSTextField!
  @IBOutlet weak var zipBigField: NSTextField!
  @IBOutlet weak var cityField: NSTextField!
  
  @IBOutlet weak var itemsTable: NSTableView!
  
  var invoicesViewController: InvoicesViewController?
  var invoiceType: InvoiceType = InvoiceType.CostInvoice {
    didSet {
      if oldValue != InvoiceType.IncomeInvoice && invoiceType == InvoiceType.IncomeInvoice {
        numberField.stringValue = generateInvoiceNumber()
        numberField.enabled = false
      }
    }
  }
  var items: [InvoiceItem] = []
  lazy var realm = try! Realm()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    itemsTable.setDelegate(self)
    itemsTable.setDataSource(self)
    
    resetDates()
  }
  
  // MARK: - private
  
  private func resetDates() {
    issueDateField.dateValue = NSDate()
    
    let calendar = NSCalendar.currentCalendar()
    let dayComponent = NSDateComponents()
    dayComponent.day = 5
    
    guard let paymentDate = calendar.dateByAddingComponents(dayComponent, toDate: NSDate(), options: []) else { return }
    
    paymentDeadlineField.dateValue = paymentDate
  }
  
  private func addEmptyItem() {
    items.append(InvoiceItem())
    itemsTable.reloadData()
  }
  
  private func closeWindow() {
    let application = NSApplication.sharedApplication()
    application.abortModal()
    self.view.window?.close()
    invoicesViewController?.reloadInvoices()
  }
  
  private func persistChangesTo(sender: NSTextField) {
    let cellView = sender.superview as! NSTableCellView
    
    guard let identifier = cellView.identifier else {
      return
    }
    
    let row = itemsTable.selectedRow
    
    switch identifier {
    case "NameCellID":
      items[row].name = sender.stringValue
    case "UnitCellID":
      items[row].unit = sender.stringValue
    case "QuantityCellID":
      if let quantity = Int(sender.stringValue) {
        items[row].quantity = quantity
      }
    case "TaxCellID":
      if let taxRate = Int(sender.stringValue.stringByReplacingOccurrencesOfString("%", withString: "")) {
        items[row].taxRate = taxRate
      }
    case "NetCellID":
      if let netPrice = Double(sender.stringValue) {
        items[row].netPrice = netPrice
      }
    case "GrossCellID":
      if let grossPrice = Double(sender.stringValue) {
        items[row].grossPrice = grossPrice
      }
    default: break
    }
    
    itemsTable.reloadData()
  }
  
  private func generateInvoiceNumber() -> String {
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let year = calendar.component(.Year, fromDate: date)
    
    let (dateFrom, dateTo) = yearBoundariesFor(calendar, year: year)
    
    guard let from = dateFrom, to = dateTo else {
      return ""
    }
    
    let typePredicate = NSPredicate(format: "typeRaw = %@", InvoiceType.IncomeInvoice.rawValue)
    let datePredicate = NSPredicate(format: "issueDate >= %@ AND issueDate <= %@", from, to)
    let count = realm.objects(Invoice.self).filter(typePredicate).filter(datePredicate).count
    return "\(count+1)/\(year)"
  }
  
  private func yearBoundariesFor(calendar: NSCalendar, year: Int) -> (NSDate?, NSDate?) {
    let components = NSDateComponents()
    components.year = year
    components.month = 1
    components.day = 1
    let from = calendar.dateFromComponents(components)
    components.month = 12
    components.day = 31
    components.hour = 23
    components.minute = 59
    components.second = 59
    let to = calendar.dateFromComponents(components)
    
    return (from, to)
  }
  
  private func saveInvoice() -> Bool {
    let invoice = Invoice()
    invoice.number = numberField.stringValue
    invoice.issueDate = issueDateField.dateValue
    invoice.paymentDeadline = paymentDeadlineField.dateValue
    
    invoice.customerFullName = fullNameField.stringValue
    invoice.customerShortName = shortNameField.stringValue
    invoice.customerAddressCity = cityField.stringValue
    invoice.customerAddressStreet = streetAddressField.stringValue
    let postalCode = "\(zipSmallField.stringValue)-\(zipBigField.stringValue)"
    invoice.customerAddressPostalCode = postalCode
    
    invoice.items.appendContentsOf(items)
    
    try! realm.write {
      realm.add(invoice)
    }
    
    return true
  }
  
  // MARK: - IBAction
  
  @IBAction func cellValueChanged(sender: NSTextField) {
    persistChangesTo(sender)
  }
  
  @IBAction func addItem(sender: NSButton) {
    addEmptyItem()
  }
  
  @IBAction func deleteItem(sender: NSButton) {
    if items.count > itemsTable.selectedRow && itemsTable.selectedRow >= 0 {
      items.removeAtIndex(itemsTable.selectedRow)
      itemsTable.reloadData()
    }
  }
  
  @IBAction func save(sender: NSButton) {
    if saveInvoice() {
      closeWindow()
    }
  }
  
  @IBAction func cancel(sender: NSButton) {
    closeWindow()
  }
  
  // MARK: - NSTableViewDataSource
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return items.count
  }
  
  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
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
      (String(format: "%.2f", item.grossPrice), "GrossCellID")
    ]
    
    (text, cellIdentifier) = columnSpec[index]
    
    if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    return nil
  }
}
