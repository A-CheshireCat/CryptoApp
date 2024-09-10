//
//  CryptoCurrencyModel.swift
//  CryptoApp
//
//  Created by Alexandra on 05.09.2024.
//

import Foundation
import RealmSwift
import SwiftUI

final class CryptoCurrency: Object, ObjectKeyIdentifiable {
    /// The unique ID. `primaryKey: true` declares the
    /// _id member as the primary key to the realm.
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var imageName = ""
    @Persisted var name = ""
    @Persisted var code = ""
    @Persisted var currentValue = 0.0
    @Persisted var formerValue = 0.0
    @Persisted var minValue = 0.0
    @Persisted var maxValue = 0.0
    
    /// Store the user.id as the ownerId so you can query for the user's objects with Flexible Sync
    /// Add this to both the group and the  objects so you can read and write the linked objects.
    @Persisted var ownerId = ""
}
