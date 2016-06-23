//
//  RealmHelper.swift
//  iTax
//
//  Created by Kamil Kowalski on 15.06.2016.
//  Copyright © 2016 Kamil Kowalski. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
  /// Kolejkuje migrację dla bazy danych Realm
  static func configureMigrations() {
    let config = Realm.Configuration(
      schemaVersion: 3,
      migrationBlock: { migration, oldSchemaVersion in
    })
    
    Realm.Configuration.defaultConfiguration = config
  }
}