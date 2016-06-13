//
//  InvoicesViewController.swift
//  iTax
//
//  Created by Kamil Kowalski on 12.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Cocoa

class InvoicesViewController: NSViewController {

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
    
    if alert.runModal() == NSAlertFirstButtonReturn {
      let invoiceType = InvoiceType.CostInvoice
    } else {
      let invoiceType = InvoiceType.IncomeInvoice
    }
    
    let addInvoiceWindowController = self.storyboard?.instantiateControllerWithIdentifier("addInvoiceView") as! NSWindowController
    
    if let addInvoiceWindow = addInvoiceWindowController.window {
      let application = NSApplication.sharedApplication()
      application.runModalForWindow(addInvoiceWindow)
    }
  }
}