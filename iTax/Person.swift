//
//  Person.swift
//  iTax
//
//  Created by Kamil Kowalski on 11.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class Person: Object {
  dynamic var firstName = ""
  dynamic var secondName = ""
  dynamic var lastName = ""
  var address: Address?
}