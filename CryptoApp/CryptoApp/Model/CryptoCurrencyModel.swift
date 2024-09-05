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
    @Persisted var name = "CatCoin"
    @Persisted var shorthand = "CC"
    @Persisted var currentValue = 0.0
    @Persisted var formerValue = 0.0
    @Persisted var minValue = 0.0
    @Persisted var maxValue = 0.0
    
    /// The backlink to the group this item is a part of.
    @Persisted(originProperty: "items") var group: LinkingObjects<CryptoGroup>
    
    /// Store the user.id as the ownerId so you can query for the user's objects with Flexible Sync
    /// Add this to both the group and the  objects so you can read and write the linked objects.
    @Persisted var ownerId = ""
}

/// Represents a collection of items.
final class CryptoGroup: Object, ObjectKeyIdentifiable {
    /// The unique ID. `primaryKey: true` declares the
    /// _id member as the primary key to the realm.
    @Persisted(primaryKey: true) var _id: ObjectId
    
    /// The collection of Items in this group.
    @Persisted var items = RealmSwift.List<CryptoCurrency>()
    
    /// Store the user.id as the ownerId so you can query for the user's objects with Flexible Sync
    /// Add this to both the group and the objects so you can read and write the linked objects.
    @Persisted var ownerId = ""
}
