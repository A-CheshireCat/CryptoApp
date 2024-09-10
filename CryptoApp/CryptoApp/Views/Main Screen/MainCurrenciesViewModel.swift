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
        var result = cryptoAPI.connect()
    
        switch result {
        case .success(let connected):
            if !connected {
                print("API returned false")
            }
        case .failure(let error):
            print("API returned error: \(error)")
        }
        
        print("API connected")
    }
    
    func disconnectFromCryptoAPI() {
        cryptoAPI.disconnect()
        print("API disconnected")
    }

    func cryptoAPIDidConnect() {
        // Get all coins on connect if the realm is empty
        if realm.objects(CryptoCurrency.self).count == 0 {
            let coins = cryptoAPI.getAllCoins()
            coins.forEach { coin in
                try! realm.write {
                    // Use the .create method with `update: .modified` to copy the existing object into the realm
                    let cryptoCurrency = realm.create(CryptoCurrency.self, value:
                                                                                ["name": coin.name,
                                                                                 "imageName": coin.imageUrl ?? "",
                                                                                 "code": coin.code,
                                                                                 "currentValue": coin.price,
                                                                                 "minValue": coin.price,
                                                                                 "maxValue": coin.price],
                                                                            update: .modified)
                    realm.add(cryptoCurrency)
                }
            }
        }
    }
    
    func cryptoAPIDidUpdateCoin(_ coin: CryptoAPI.Coin) {
        // TODO: Why is this not received on main and caused thread issues?
        DispatchQueue.main.async { [weak self] in
            print("new coin: \(coin)")
            guard let currencyToUpdate = self?.realm.objects(CryptoCurrency.self).where({ $0.name == coin.name }).first else {return}
            print("currency to update: \(currencyToUpdate)")
            try! self?.realm.write {
                currencyToUpdate.formerValue = currencyToUpdate.currentValue
                currencyToUpdate.currentValue = coin.price
                if coin.price > currencyToUpdate.maxValue {
                    currencyToUpdate.maxValue = coin.price
                }
                if coin.price < currencyToUpdate.minValue {
                    currencyToUpdate.minValue = coin.price
                }
            }
        }
    }
    
    func cryptoAPIDidDisconnect() {}
}
