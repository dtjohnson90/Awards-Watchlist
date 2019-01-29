//
//  AwardsWatchlistProducts.swift
//  Oscars
//
//  Created by Dustin Johnson on 11/12/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import Foundation

public struct AwardsWatchlistProducts {
    
    public static let SwiftShopping = "AWPRO"
    private static let productIdentifiers: Set<ProductIdentifier> = [AwardsWatchlistProducts.SwiftShopping]
    public static let store = IAPHelper(productIds: AwardsWatchlistProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
