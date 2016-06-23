//
//  Customer.swift
//  iTax
//
//  Created by Kamil Kowalski on 11.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class Customer: Object {
  dynamic var fullName = ""
  dynamic var shortName = ""
  dynamic var nip = ""
  dynamic var streetAddress = ""
  dynamic var zipCode = ""
  dynamic var city = ""
}