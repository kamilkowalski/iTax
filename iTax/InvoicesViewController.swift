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
  
  /// Tabela faktur
  @IBOutlet weak var invoicesTable: NSTableView!
  
  /// Kolekcja faktur do wyświetlenia w tabeli
  var invoices: Results<Invoice>?
  
  /// Połączenie z bazą danych Realm
  lazy var realm = try! Realm()

  override func viewDidLoad() {
    super.viewDidLoad()
    RealmHelper.configureMigrations()
    invoicesTable.setDataSource(self)
    invoicesTable.setDelegate(self)
    invoicesTable.doubleAction = #selector(InvoicesViewController.showInvoice)
    reloadInvoices()
    loadSampleData()
  }
  
  /// Wczytuje dane o fakturach z bazy danych i odświeża tabelę
  func reloadInvoices() {
    invoices = realm.objects(Invoice.self).sorted("issueDate")
    invoicesTable.reloadData()
  }
  
  private func loadSampleData() {
    if realm.objects(Customer.self).count == 0 {
      let c1 = Customer()
      c1.fullName = "Orange Sp. z o. o."
      c1.shortName = "Orange"
      c1.nip = "58310593"
      c1.streetAddress = "Nowy Świat 15"
      c1.zipCode = "01-001"
      c1.city = "Warszawa"
      
      let c2 = Customer()
      c2.fullName = "Telekomunikacja Polska SA"
      c2.shortName = "TPSA"
      c2.nip = "407195821"
      c2.streetAddress = "Al. Jerozolimskie 301"
      c2.zipCode = "02-511"
      c2.city = "Warszawa"
      
      let c3 = Customer()
      c3.fullName = "Comarch SA"
      c3.shortName = "Comarch"
      c3.nip = "58719351"
      c3.streetAddress = "al. Jana Pawła II 39"
      c3.zipCode = "31-864"
      c3.city = "Kraków"
      
      try! realm.write {
        realm.add(c1)
        realm.add(c2)
        realm.add(c3)
      }
    }
    
    if realm.objects(Product.self).count == 0 {
      let p1 = Product()
      p1.name = "Suszarka do włosów"
      p1.unit = "szt."
      p1.taxRate = 18
      p1.netPrice = 56.50
      
      let p2 = Product()
      p2.name = "Mąka tortowa"
      p2.unit = "kg"
      p2.netPrice = 3.20
      
      let p3 = Product()
      p3.name = "Mysz Logitech"
      p3.unit = "szt."
      p3.netPrice = 82.20
      
      try! realm.write {
        realm.add(p1)
        realm.add(p2)
        realm.add(p3)
      }
    }
  }
  
  @objc private func showInvoice() {
    let index = invoicesTable.clickedRow
    guard let invoice = invoices?[index] else { return }
    
    let showInvoiceWindowController = self.storyboard?.instantiateControllerWithIdentifier("showInvoiceView") as! NSWindowController
    
    guard let showInvoiceWindow = showInvoiceWindowController.window else { return }
    guard let viewController = showInvoiceWindow.contentViewController as? ShowInvoiceViewController else { return }
    
    viewController.invoice = invoice
    NSApplication.sharedApplication().runModalForWindow(showInvoiceWindow)
  }
  
  // MARK: - IBAction
  
  /// Usuwa fakturę zaznaczoną w tabeli faktur `invoicesTable`
  /// - Parameter sender: obiekt wysyłający żądanie
  @IBAction func deleteInvoice(sender: NSButton) {
    if invoices?.count > invoicesTable.selectedRow && invoicesTable.selectedRow >= 0 {
      let alert = NSAlert()
      alert.addButtonWithTitle("Tak")
      alert.addButtonWithTitle("Nie")
      alert.messageText = "Potwierdź usunięcie"
      alert.informativeText = "Czy na pewno chcesz usunąć fakturę?"
      alert.alertStyle = .WarningAlertStyle
    
      if alert.runModal() == NSAlertFirstButtonReturn {
        guard let invoice = invoices?[invoicesTable.selectedRow] else { return }
        
        try! realm.write {
          realm.delete(invoice)
        }
        
        reloadInvoices()
      }
    }
  }
  
  /// Otwiera okno wyboru typu faktury, a następnie okno dodawania faktury
  /// - Parameter sender: obiekt wysyłający żądanie
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
  
  // MARK: - NSTableViewDataSource
  
  /// Podaje ilość wierszy do wyświetlenia w tabeli faktur
  /// - Parameter tableView: `NSTableView` którego dotyczy zapytanie
  /// - Returns: liczbę wierszy
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return invoices?.count ?? 0
  }
  
  /// Zwraca widok komórki w tabeli faktur
  /// - Parameter tableView: `NSTableView` którego dotyczy zapytanie
  /// - Parameter tableColumn: kolumna, której komórka ma zostać zwrócona
  /// - Parameter row: wiersz, którego komórka ma zostać zwrócona
  /// - Returns: widok komórki
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
    
    let sign = invoice.type == InvoiceType.IncomeInvoice ? "+" : "-"
    
    let columnSpec: [(String, String)] = [
      (invoice.number, "NumberCellID"),
      (invoice.customerShortName, "CustomerCellID"),
      (formatter.stringFromDate(invoice.issueDate!), "IssueDateCellID"),
      (formatter.stringFromDate(invoice.paymentDeadline!), "PaymentDeadlineCellID"),
      (String(format: "\(sign)%.2f", invoice.netPrice), "NetCellID"),
      (String(format: "\(sign)%.2f", invoice.grossPrice), "GrossCellID")
    ]
    
    (text, cellIdentifier) = columnSpec[index]
    
    var color = NSColor.textColor()
    
    if ["NetCellID", "GrossCellID"].contains(cellIdentifier) {
      switch invoice.type {
      case .IncomeInvoice:
        color = NSColor(calibratedRed: 92.0/255.0, green: 184.0/255.0, blue: 92.0/255.0, alpha: 1.0)
      case .CostInvoice:
        color = NSColor(calibratedRed: 217.0/255.0, green: 83.0/255.0, blue: 79.0/255.0, alpha: 1.0)
      }
    }
    
    if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      cell.textField?.textColor = color
      return cell
    }
    return nil
  }
}