//
//  AddInvoiceViewController.swift
//  iTax
//
//  Created by Kamil Kowalski on 13.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Cocoa

class AddInvoiceViewController: NSViewController {

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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
  @IBAction func addItem(sender: NSButton) {
  }
  
  @IBAction func save(sender: NSButton) {
  }
    
  @IBAction func cancel(sender: NSButton) {
    fullNameField.resignFirstResponder()
    let application = NSApplication.sharedApplication()
    application.abortModal()
    print("Cancelled")
  }
}
