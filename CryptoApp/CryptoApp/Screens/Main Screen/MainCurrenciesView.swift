//
//  MainCurrenciesView.swift
//  CryptoApp
//
//  Created by Alexandra on 05.09.2024.
//

import RealmSwift
import SwiftUI

struct MainCurrenciesView: View {
    @State var searchFilter: String = ""
    @StateObject var viewModel = MainCurrenciesViewModel()
    
    var body: some View {
        if let itemGroup = viewModel.cryptoCurrenciesRealm.first {
            CurreciesListView(itemGroup: itemGroup)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    print("app entering foreground now")
                    viewModel.connectToCryptoAPI()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    print("app entering background now")
                    viewModel.disconnectFromCryptoAPI()
                }
        } else {
            // For now, if there is no itemGroup, add one here.
            ProgressView().onAppear {
                viewModel.$cryptoCurrenciesRealm.append(CryptoGroup())
            }
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
}

struct CurreciesListView: View {
    @ObservedRealmObject var itemGroup: CryptoGroup
    
    var leadingBarButton: AnyView?
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(itemGroup.items) { item in
                        CurrencyRow(item: item)
                    }//.onDelete(perform: $itemGroup.items.remove)
                }
                .listStyle(GroupedListStyle())
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct CurrencyRow: View {
    @ObservedRealmObject var item: CryptoCurrency
    
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
                .background(Color(item.currentValue>item.formerValue ? .green : .red))
        }
    }
}

#Preview {
    MainCurrenciesView()
}
