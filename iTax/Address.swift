//
//  Address.swift
//  iTax
//
//  Created by Kamil Kowalski on 11.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class Address: Object {
  dynamic var streetAddress = ""
  dynamic var city = ""
  dynamic var postalCode = ""
}