//
//  Session.swift
//  8DWave
//
//  Created by Ky Nguyen on 2/15/19.
//  Copyright © 2019 Abraham Sameer. All rights reserved.
//

import Foundation

public typealias SessionId = String
public struct Session {
    public let id: SessionId
    public var paidSubscriptions: [PaidSubscription]

    public var currentSubscription: PaidSubscription? {
        let sortedSubscriptions = paidSubscriptions.sorted(by: {$0.purchaseDate > $1.purchaseDate })
        let latestItem = sortedSubscriptions.first
        return latestItem?.isActive == true ? latestItem : nil
    }

    public var receiptData: Data
    public var parsedReceipt: [String: Any]

    init(receiptData: Data, parsedReceipt: [String: Any]) {
        id = UUID().uuidString
        self.receiptData = receiptData
        self.parsedReceipt = parsedReceipt

        if let receipt = parsedReceipt["receipt"] as? [String: Any], let purchases = receipt["in_app"] as? Array<[String: Any]> {
            paidSubscriptions = purchases.compactMap({ return PaidSubscription(json: $0) })
        } else {
            paidSubscriptions = []
        }
    }

}

// MARK: - Equatable

extension Session: Equatable {
    public static func ==(lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }
}
