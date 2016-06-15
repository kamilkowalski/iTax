//
//  InvoicesViewController.swift
//  iTax
//
//  Created by Kamil Kowalski on 12.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Cocoa
import RealmSwift

class InvoicesViewController: NSViewController {
  
  var invoices: Results<Invoice>?
  lazy var realm = try! Realm()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
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
  }
}