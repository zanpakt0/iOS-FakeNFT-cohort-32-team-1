//
//  PaymentViewModel.swift
//  FakeNFT
//
//  Created by Svetlana Varenova on 04.12.2025.
//

import UIKit

final class PaymentViewModel {
    
    private(set) var items: [CryptoPayment] = [
        .init(iconName: "Bitcoin (BTC)", title: "Bitcoin", ticker: "BTC"),
        .init(iconName: "Dogecoin (DOGE)", title: "Dogecoin", ticker: "DOGE"),
        .init(iconName: "Tether (USDT)", title: "Tether", ticker: "USDT"),
        .init(iconName: "ApeCoin (APE)", title: "ApeCoin", ticker: "APE"),
        .init(iconName: "Solana (SOL)", title: "Solana", ticker: "SOL"),
        .init(iconName: "Ethereum (ETH)", title: "Ethereum", ticker: "ETH"),
        .init(iconName: "Cardano (ADA)", title: "Cardano", ticker: "ADA"),
        .init(iconName: "Shiba Inu (SHIB)", title: "Shiba Inu", ticker: "SHIB")
    ]
    
    private(set) var selectedIndex: IndexPath?
    
    func selectItem(at indexPath: IndexPath) {
        selectedIndex = indexPath
    }
}

