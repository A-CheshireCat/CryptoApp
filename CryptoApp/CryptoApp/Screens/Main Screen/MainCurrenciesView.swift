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
                        CurrencyRow(item: item)
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct CurrencyRow: View {
    var item: CryptoCurrency
    @State private var opacity: Double = 1.0
    @State private var color: Color = .white
    
    var body: some View {
        HStack{
            VStack{
                HStack{
                    AsyncImage(url: URL(string: item.imageName)){ result in
                        result.image?
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(width: 20, height: 20)
                    Text(item.name)
                    Text(item.shorthand)
                    Spacer()
                }
                HStack{
                    Text("min: " + String(format: "%g", item.minValue))
                        .lineLimit(1)
                    Text("max: " + String(format: "%g", item.maxValue))
                        .lineLimit(1)
                    Spacer()
                }
            }
            Text(String(format: "%g", item.currentValue))
                .padding(5)
                .background(Color(color))
                .opacity(opacity)
                .onChange(of:item.currentValue) {
                    withAnimation(.linear(duration: 0.5)) {
                        opacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        withAnimation(.linear(duration: 0)) {
                            opacity = 1.0
                            if item.currentValue < item.formerValue {
                                color = .red
                            } else if item.currentValue > item.formerValue {
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
