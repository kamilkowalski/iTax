//
//  UserAccount.swift
//  iTax
//
//  Created by Kamil Kowalski on 11.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class UserAccount: Object {
  dynamic var email = ""
  dynamic var passwordDigest = ""
  var access: UserAccountRole?
}

enum UserAccountRole {
  case Accounting, HumanRelations, Executive
}