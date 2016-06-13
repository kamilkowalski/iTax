//
//  Company.swift
//  iTax
//
//  Created by Kamil Kowalski on 11.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class Company: Object {
  dynamic var fullName = ""
  dynamic var shortName = ""
  let telephones = List<PhoneNumber>()
  let emails = List<Email>()
  var registeredAddress: Address?
  var operationAddress: Address?
}