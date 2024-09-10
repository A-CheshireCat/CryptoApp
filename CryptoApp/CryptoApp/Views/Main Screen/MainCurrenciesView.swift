//
//  MainCurrenciesView.swift
//  CryptoApp
//
//  Created by Alexandra on 05.09.2024.
//

import RealmSwift
import SwiftUI

struct MainCurrenciesView: View {
    @StateObject var viewModel = MainCurrenciesViewModel()
    
    var body: some View {
        CurreciesListView()
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                print("app entering foreground now")
                viewModel.connectToCryptoAPI()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                print("app entering background now")
                viewModel.disconnectFromCryptoAPI()
            }
    }
}

struct CurreciesListView: View {
    @ObservedResults(CryptoCurrency.self) var currencies
    
    var leadingBarButton: AnyView?
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(currencies) { item in
                        CurrencyRow(currency: item)
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct CurrencyRow: View {
    var currency: CryptoCurrency
    @State private var opacity: Double = 1.0
    @State private var color: Color = .white
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    AsyncImage(url: URL(string: currency.imageName)) { result in
                        result.image?
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(width: 20, height: 20)
                    Text(currency.name)
                    Text(currency.code)
                    Spacer()
                }
                HStack {
                    Text("min: " + String(format: "%g", currency.minValue))
                        .lineLimit(1)
                    Text("max: " + String(format: "%g", currency.maxValue))
                        .lineLimit(1)
                    Spacer()
                }
            }
            Text(String(format: "%g", currency.currentValue))
                .padding(5)
                .background(Color(color))
                .opacity(opacity)
                .onChange(of:currency.currentValue) {
                    withAnimation(.linear(duration: 0.5)) {
                        opacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        withAnimation(.linear(duration: 0)) {
                            opacity = 1.0
                            if currency.currentValue < currency.formerValue {
                                color = .red
                            } else if currency.currentValue > currency.formerValue {
                                color = .green
                            } else {
                                color = .white
                            }
                        }
                    })
                }
        }
    }
}

#Preview {
    MainCurrenciesView()
}
