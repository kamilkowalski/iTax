//
//  AddInvoiceViewController.swift
//  iTax
//
//  Created by Kamil Kowalski on 13.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Cocoa
import RealmSwift

class AddInvoiceViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource, NSComboBoxDelegate {

  /// Pole numeru faktury
  @IBOutlet weak var numberField: NSTextField!
  /// Pole daty wystawienia faktury
  @IBOutlet weak var issueDateField: NSDatePicker!
  /// Pole terminu płatności faktury
  @IBOutlet weak var paymentDeadlineField: NSDatePicker!
  
  // Pole pełnej nazwy kontrahenta
  @IBOutlet weak var fullNameField: NSComboBox!
  /// Pole nazwy skróconej kontrahenta
  @IBOutlet weak var shortNameField: NSTextField!
  /// Pole adresu kontrahenta
  @IBOutlet weak var streetAddressField: NSTextField!
  /// Pole pierwszej części kodu pocztowego kontrahenta
  @IBOutlet weak var zipSmallField: NSTextField!
  /// Pole drugiej części kodu pocztowego kontrahenta
  @IBOutlet weak var zipBigField: NSTextField!
  /// Pole miasta kontrahenta
  @IBOutlet weak var cityField: NSTextField!
  
  /// Tabela pozycji faktury
  @IBOutlet weak var itemsTable: NSTableView!
  /// Nagłówek formularza dodawania faktury
  @IBOutlet weak var header: NSTextField!
  
  /// Kontroler głównego widoku okna nadrzędnego - listy faktur
  var invoicesViewController: InvoicesViewController?
  /// Typ dodawanej faktury
  var invoiceType: InvoiceType = InvoiceType.CostInvoice {
    didSet {
      if oldValue != InvoiceType.IncomeInvoice && invoiceType == InvoiceType.IncomeInvoice {
        numberField.stringValue = generateInvoiceNumber()
        numberField.enabled = false
      }
      
      var title = "Dodawanie faktury"
      
      switch invoiceType {
      case .CostInvoice:
        title = "Dodawanie faktury kosztowej"
      case .IncomeInvoice:
        title = "Dodawanie faktury przychodowej"
      }
      
      self.view.window?.title = title
      header.stringValue = title
    }
  }
  /// Lista pozycji faktury do wyświetlenia
  var items: [InvoiceItem] = []
  /// Lista klientów do wyboru
  var customers: Results<Customer>?
  /// Lista produktów do wyboru
  var products: Results<Product>?
  /// Połączenie z bazą danych Realm
  lazy var realm = try! Realm()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
    
    itemsTable.setDelegate(self)
    itemsTable.setDataSource(self)
    
    fullNameField.usesDataSource = true
    fullNameField.dataSource = self
    fullNameField.setDelegate(self)

    resetDates()
  }
  
  func insertItemFromProduct(product: Product) {
    let item = InvoiceItem()
    item.name = product.name
    item.unit = product.unit
    item.taxRate = product.taxRate
    item.netPrice = product.netPrice
    itemsTable.reloadData()
  }
  
  // MARK: - private
  
  private func loadData() {
    customers = realm.objects(Customer.self).sorted("fullName")
    products = realm.objects(Product.self).sorted("name")
  }
  
  /// Ustawia datę wydania faktury na dzisiejszą, a datę terminu na 5 dni wstecz
  private func resetDates() {
    issueDateField.dateValue = NSDate()
    
    let calendar = NSCalendar.currentCalendar()
    let dayComponent = NSDateComponents()
    dayComponent.day = 5
    
    guard let paymentDate = calendar.dateByAddingComponents(dayComponent, toDate: NSDate(), options: []) else { return }
    
    paymentDeadlineField.dateValue = paymentDate
  }
  
  /// Dodaje nową pustą pozycję faktury
  private func addEmptyItem() {
    items.append(InvoiceItem())
    itemsTable.reloadData()
  }
  
  /// Zamyka okno dodawania faktury i przeładowuje listę faktur w oknie nadrzędnym
  private func closeWindow() {
    let application = NSApplication.sharedApplication()
    application.abortModal()
    self.view.window?.close()
    invoicesViewController?.reloadInvoices()
  }
  
  /// Zapisuje zmiany do pola tekstowego na liście pozycji faktury do instancji `InvoiceItem`
  /// - Parameter sender: zmienione pole tekstowe
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
  
  /// Generuje kolejny numer faktury przychodowej
  /// - Returns: nowy numer faktury przychodowej
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
  
  /// Zwraca zakres całego obecnego roku - od północy 1 stycznia do północy 31 grudnia
  /// - Parameter calendar: kalendarz według którego ma zostać utworzona data
  /// - Parameter year: rok dla którego ma zostać wygenerowany zakres
  /// - Returns: krotka z dwoma obiektami `NSDate` - datą początkową i datą końcową
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
  
  /// Zapisuje fakturę w bazie Realm
  /// - Returns: `true` jeżeli zapis się powiódł, `false` w przeciwnym wypadku
  private func saveInvoice() -> Bool {
    let invoice = Invoice()
    invoice.type = invoiceType
    invoice.number = numberField.stringValue
    invoice.issueDate = issueDateField.dateValue
    invoice.paymentDeadline = paymentDeadlineField.dateValue
    
    invoice.customerFullName = fullNameField.stringValue
    invoice.customerShortName = shortNameField.stringValue
    invoice.customerAddressCity = cityField.stringValue
    invoice.customerAddressStreet = streetAddressField.stringValue
    let postalCode = "\(zipSmallField.stringValue)-\(zipBigField.stringValue)"
    invoice.customerAddressPostalCode = postalCode
    
    items.forEach{ invoice.addInvoiceItem($0) }
    
    try! realm.write {
      realm.add(invoice)
    }
    
    return true
  }
  
  // MARK: - IBAction
  
  /// Akcja wywoływana po zmianie wartości komórki tabeli pozycji faktury
  /// - Parameter sender: pole które zostało zmienione
  @IBAction func cellValueChanged(sender: NSTextField) {
    persistChangesTo(sender)
  }
  
  /// Akcja wywoływana po naciśnięciu przycisku "Dodaj pozycję faktury"
  /// - Parameter sender: przycisk, który wywołał akcję
  @IBAction func addItem(sender: NSButton) {
    addEmptyItem()
  }
  
  /// Akcja wywoływana po naciśnięciu przycisku "Usuń pozycję faktury"
  /// - Parameter sender: przycisk, który wywołał akcję
  @IBAction func deleteItem(sender: NSButton) {
    if items.count > itemsTable.selectedRow && itemsTable.selectedRow >= 0 {
      items.removeAtIndex(itemsTable.selectedRow)
      itemsTable.reloadData()
    }
  }
  
  @IBAction func openProductSearch(sender: NSButton) {
  }
  
  /// Akcja wywoływana po naciśnięciu przycisku "Zapisz fakturę"
  /// - Parameter sender: przycisk, który wywołał akcję
  @IBAction func save(sender: NSButton) {
    if saveInvoice() {
      closeWindow()
    }
  }
  
  /// Akcja wywoływana po naciśnięciu przycisku "Anuluj"
  /// - Parameter sender: przycisk, który wywołał akcję
  @IBAction func cancel(sender: NSButton) {
    closeWindow()
  }
  
  // MARK: - NSTableViewDataSource
  
  /// Podaje ilość wierszy do wyświetlenia w tabeli pozycji faktury
  /// - Parameter tableView: `NSTableView` którego dotyczy zapytanie
  /// - Returns: liczbę wierszy
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return items.count
  }
  
  /// Zwraca widok komórki w tabeli pozycji faktury
  /// - Parameter tableView: `NSTableView` którego dotyczy zapytanie
  /// - Parameter tableColumn: kolumna, której komórka ma zostać zwrócona
  /// - Parameter row: wiersz, którego komórka ma zostać zwrócona
  /// - Returns: widok komórki
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
  
  // MARK: - NSComboBoxDataSource
  func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
    return customers?.count ?? 0
  }
  
  func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
    return customers![index].fullName
  }
  
  func comboBoxSelectionDidChange(notification: NSNotification) {
    if fullNameField.indexOfSelectedItem < customers!.count {
      let selectedCustomer = customers![fullNameField.indexOfSelectedItem]
      
      shortNameField.stringValue = selectedCustomer.shortName
      streetAddressField.stringValue = selectedCustomer.streetAddress
      
      let zipComponents = selectedCustomer.zipCode.componentsSeparatedByString("-")
      
      if zipComponents.count == 2 {
        zipSmallField.stringValue = zipComponents[0]
        zipBigField.stringValue = zipComponents[1]
      }
      
      cityField.stringValue = selectedCustomer.city
    }
  }
}
