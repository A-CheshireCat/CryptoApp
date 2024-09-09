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
    let realm: Realm
    
    lazy var cryptoAPI : Crypto = { [unowned self] in
        Crypto(delegate: self)
    }()
    
    init() {
        realm = try! Realm()

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
        if realm.objects(CryptoCurrency.self).count == 0 {
            let coins = cryptoAPI.getAllCoins()
            coins.forEach { coin in
                print("\(coin)")
                try! realm.write {
                    // Use the .create method with `update: .modified` to copy the existing object into the realm
                    let cryptoCurrency = realm.create(CryptoCurrency.self, value:
                                                                                ["name": coin.name,
                                                                                 "imageName": coin.imageUrl ?? "",
                                                                                 "shorthand": coin.code,
                                                                                 "currentValue": coin.price],
                                                                            update: .modified)
                    realm.add(cryptoCurrency)
                }
            }
        }
    }
    
    func cryptoAPIDidUpdateCoin(_ coin: CryptoAPI.Coin) {
        DispatchQueue.main.async { [weak self] in
            print("new coin: \(coin)")
            guard let currencyToUpdate = self?.realm.objects(CryptoCurrency.self).where({ $0.name == coin.name }).first else {return}
            print("currency to update: \(currencyToUpdate)")
            try! self?.realm.write {
                currencyToUpdate.currentValue = coin.price
            }
        }
    }
    
    func cryptoAPIDidDisconnect() {}
}
