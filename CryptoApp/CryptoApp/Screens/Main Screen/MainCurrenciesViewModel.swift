//
//  MainCurrenciesViewModel.swift
//  CryptoApp
//
//  Created by Alexandra on 05.09.2024.
//

import Foundation
import RealmSwift

class MainCurrenciesViewModel: ObservableObject {
    //@Published var cryptoCurrencies = CryptoGroup()
    // Implicitly use the default realm's objects(ItemGroup.self)
    @ObservedResults(CryptoGroup.self) var itemGroups
}
