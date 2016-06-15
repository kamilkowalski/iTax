//
//  InvoicesViewController.swift
//  iTax
//
//  Created by Kamil Kowalski on 12.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Cocoa
import RealmSwift

class InvoicesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
  
  @IBOutlet weak var invoicesTable: NSTableView!
  
  var invoices: Results<Invoice>?
  lazy var realm = try! Realm()

  override func viewDidLoad() {
    super.viewDidLoad()
    RealmHelper.configureMigrations()
    invoicesTable.setDataSource(self)
    invoicesTable.setDelegate(self)
    reloadInvoices()
  }
  
  @IBAction func addInvoice(sender: NSButton) {
    let alert = NSAlert()
    alert.addButtonWithTitle("Faktura kosztowa")
    alert.addButtonWithTitle("Faktura przychodowa")
    alert.messageText = "Wybór typu faktury"
    alert.informativeText = "Jakiego typu fakturę chcesz dodać?"
    alert.alertStyle = .InformationalAlertStyle
    
    var invoiceType = InvoiceType.CostInvoice
    
    if alert.runModal() == NSAlertSecondButtonReturn {
      invoiceType = InvoiceType.IncomeInvoice
    }
    
    let addInvoiceWindowController = self.storyboard?.instantiateControllerWithIdentifier("addInvoiceView") as! NSWindowController
    
    guard let addInvoiceWindow = addInvoiceWindowController.window else { return }
    guard let viewController = addInvoiceWindow.contentViewController as? AddInvoiceViewController else { return }
    
    viewController.invoiceType = invoiceType
    viewController.invoicesViewController = self
    NSApplication.sharedApplication().runModalForWindow(addInvoiceWindow)
  }
  
  func reloadInvoices() {
    invoices = realm.objects(Invoice.self).sorted("issueDate")
    invoicesTable.reloadData()
  }
  
  // MARK: - NSTableViewDataSource
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return invoices?.count ?? 0
  }
  
  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let invoice = invoices?[row] else { return nil }
    
    var text:String = ""
    var cellIdentifier: String = ""
    
    guard let column = tableColumn else {
      return nil
    }
    
    guard let index = tableView.tableColumns.indexOf(column) else {
      return nil
    }
    
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    
    let columnSpec: [(String, String)] = [
      (invoice.number, "NumberCellID"),
      (invoice.customerShortName, "CustomerCellID"),
      (formatter.stringFromDate(invoice.issueDate!), "IssueDateCellID"),
      (formatter.stringFromDate(invoice.paymentDeadline!), "PaymentDeadlineCellID"),
      (String(format: "%.2f", invoice.netPrice), "NetCellID"),
      (String(format: "%.2f", invoice.grossPrice), "GrossCellID")
    ]
    
    (text, cellIdentifier) = columnSpec[index]
    
    if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    return nil
  }
}