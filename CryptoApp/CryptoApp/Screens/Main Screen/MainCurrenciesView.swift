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
        if let itemGroup = viewModel.itemGroups.first {
            CurreciesListView(itemGroup: itemGroup)
        } else {
            // For now, if there is no itemGroup, add one here.
            ProgressView().onAppear {
                viewModel.$itemGroups.append(CryptoGroup())
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
                    }.onDelete(perform: $itemGroup.items.remove)
                        .onMove(perform: $itemGroup.items.move)
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle("Items", displayMode: .large)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: self.leadingBarButton,
                    // Edit button on the right to enable rearranging items
                    trailing: EditButton())
                // Action bar at bottom contains Add button.
                HStack {
                    Spacer()
                    Button(action: {
                        // The bound collection automatically
                        // handles write transactions, so we can
                        // append directly to it.
                        $itemGroup.items.append(CryptoCurrency())
                    }) { Image(systemName: "plus") }
                }.padding()
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
                    Image(systemName: "cat")
                    Text(item.name)
                    Text(item.shorthand)
                    Spacer()
                }
                HStack{
                    Text("min: \(item.minValue)")
                    Text("max: \(item.maxValue)")
                    Spacer()
                }
            }
            Text("\(item.currentValue)")
                .padding(5)
                .background(Color(item.currentValue>item.formerValue ? .green : .red))
        }
    }
}

#Preview {
    MainCurrenciesView()
}
