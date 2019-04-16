//
//  SubscriptionService.swift
//  8DWave
//
//  Created by Ky Nguyen on 2/15/19.
//  Copyright © 2019 Abraham Sameer. All rights reserved.
//

import Foundation
import StoreKit

class SubscriptionService: NSObject {
    static let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
    static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")


    static let shared = SubscriptionService()

    var hasReceiptData: Bool {
        return loadReceipt() != nil
    }

    var currentSessionId: String? {
        didSet {
            NotificationCenter.default.post(name: SubscriptionService.sessionIdSetNotification, object: currentSessionId)
        }
    }

    var currentSubscription: PaidSubscription?

    var options: [Subscription]?

    func loadSubscriptionOptions() {
        let premiumIdentifier = Bundle.main.bundleIdentifier! + ".premium"
        let productIDs = Set([premiumIdentifier])

        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }

    func purchase(subscription: Subscription) {
        let payment = SKPayment(product: subscription.product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
            upload(receipt: receiptData) { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let result):
                    strongSelf.currentSessionId = result.sessionId
                    strongSelf.currentSubscription = result.currentSubscription
                    completion?(true)
                case .failure(let error):
                    print("🚫 Receipt Upload Failed: \(error)")
                    completion?(false)
                }
            }
        }
    }

    private func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion) {
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": Setting.itcAccountSecret
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])

        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData

        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                print(json)
                let session = Session(receiptData: data, parsedReceipt: json)
                let result = (sessionId: session.id, currentSubscription: session.currentSubscription)
                completion(.success(result))
            }
        }

        task.resume()
    }

    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - SKProductsRequestDelegate

extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        options = response.products.map { Subscription(product: $0) }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
        }
    }
}

