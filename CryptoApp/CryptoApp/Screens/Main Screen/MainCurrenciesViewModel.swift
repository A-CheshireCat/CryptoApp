//
//  MainCurrenciesViewModel.swift
//  CryptoApp
//
//  Created by Alexandra on 05.09.2024.
//

import Foundation
import RealmSwift
import CryptoAPI

class MainCurrenciesViewModel: ObservableObject, CryptoDelegate {
    
    @ObservedResults(CryptoGroup.self) var cryptoCurrenciesRealm
    lazy var cryptoAPI : Crypto = { [unowned self] in
        Crypto(delegate: self)
    }()
    
    init() {
        connectToCryptoAPI()
    }
    
    func connectToCryptoAPI() {
        cryptoAPI = Crypto(delegate: self)
        var _ = cryptoAPI.connect()
        
        print("API connected")
    }
    
    func disconnectFromCryptoAPI() {
        cryptoAPI.disconnect()
        
        print("API disconnected")
    }

    func cryptoAPIDidConnect() {
        // get all coins on connect if the realm is empty
        guard let cryptoGroup = cryptoCurrenciesRealm.first, cryptoGroup.items.count == 0 else {return}
        
        let coins = cryptoAPI.getAllCoins()
        coins.forEach { coin in
            print("\(coin)")

            // Thaw the object and get its realm to perform the write to append the new item
            let thawedCryptoCurrenciesRealm = cryptoCurrenciesRealm.thaw()!.realm!
            try! thawedCryptoCurrenciesRealm.write {
                // Use the .create method with `update: .modified` to copy the existing object into the realm
                let cryptoCurrency = thawedCryptoCurrenciesRealm.create(CryptoCurrency.self, value:
                                                    ["name": coin.name,
                                                     "imageName": coin.imageUrl ?? "",
                                                     "shorthand": coin.code,
                                                     "currentValue": coin.price],
                                                                        update: .modified)
                cryptoGroup.items.append(cryptoCurrency)
            }
        }
    }
    
    func cryptoAPIDidUpdateCoin(_ coin: CryptoAPI.Coin) {
//        guard let cryptoGroup = cryptoCurrenciesRealm.first else {return}
//        // Thaw the realm so you can write to it.
//        let thawedCryptoCurrenciesRealm = cryptoCurrenciesRealm.thaw()!.realm!
//           // Thawing the `Company` object that you passed in also thaws the objects in its List properties.
//           // This lets you append the `Dog` to the `Employee` without individually thawing both of them.
//        let currency = cryptoGroup.items.where { $0.name == coin.name }.first!
//
//        try! thawedCryptoCurrenciesRealm.write {
//            currency.currentValue = coin.price
//        }
    }
    
    func cryptoAPIDidDisconnect() {}
}
