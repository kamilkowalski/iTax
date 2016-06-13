//
//  PESEL.swift
//  iTax
//
//  Created by Kamil Kowalski on 11.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class PESEL: IDNumber {
  static func validateNumber(number: String) -> Bool {
    return true
  }
}