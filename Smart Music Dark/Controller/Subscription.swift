//
//  IAPHelper.swift
//  8DWave
//
//  Created by Ky Nguyen on 2/15/19.
//  Copyright © 2019 Abraham Sameer. All rights reserved.
//

import Foundation
import StoreKit

struct Subscription {
    let product: SKProduct
    let formattedPrice: String

    init(product: SKProduct) {
        self.product = product

        if formatter.locale != self.product.priceLocale {
            formatter.locale = self.product.priceLocale
        }

        formattedPrice = formatter.string(from: product.price) ?? "\(product.price)"
    }
}


public struct PaidSubscription {
    public let productId: String
    public let purchaseDate: Date
    public let expiresDate: Date

    public var isActive: Bool {
        // is current date between purchaseDate and expiresDate?
        return (purchaseDate...expiresDate).contains(Date())
    }

    init?(json: [String: Any]) {
        guard
            let productId = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let purchaseDate = dateFormatter.date(from: purchaseDateString),
            let expiresDateString = json["expires_date"] as? String,
            let expiresDate = dateFormatter.date(from: expiresDateString)
            else {
                return nil
        }

        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expiresDate = expiresDate
    }
}



public enum Result<T> {
    case failure(Error)
    case success(T)
}
public typealias UploadReceiptCompletion = (_ result: Result<(sessionId: String, currentSubscription: PaidSubscription?)>) -> Void

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"

    return formatter
}()


private var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.formatterBehavior = .behavior10_4

    return formatter
}()
