//
//  StoreKitService.swift
//  Filmikus
//
//  Created by Андрей Козлов on 19.05.2020.
//  Copyright © 2020 Андрей Козлов. All rights reserved.
//

import StoreKit
import UIKit

protocol StoreKitServiceType: class {
	func loadProducts(completion: ((Result<[SKProduct], Error>) -> Void)?)
	func purchase(product: SKProduct, completion: ((Result<Void, Error>) -> Void)?)
	func restorePurchases(completion: ((Result<Void, Error>) -> Void)?)
	func loadReceipt(completion: ((Result<String, Error>) -> Void)?)
}

class StoreKitService: NSObject, StoreKitServiceType {
	
	typealias SubscriptionBlock = (Result<Void, Error>) -> Void
	typealias ProductsBlock = (Result<[SKProduct], Error>) -> Void
	typealias ReceiptBlock = (Result<String, Error>) -> Void
	
	private var subscriptionBlock: SubscriptionBlock?
	private var refreshSubscriptionBlock: SubscriptionBlock?
	private var productsBlock: ProductsBlock?
	private var receiptBlock: ReceiptBlock?
		
	private(set) var products: [SKProduct] = []

	static let shared = StoreKitService()
    
    let callToAction = "Смотреть бесплатно"
    let subtitle = "Отменить подписку можно в любой момент"
    func terms(price: String) -> String {
        return "Первые 7 дней бесплатно, далее \(price) в месяц, c автоматическим продлением каждые 30 дней. Подписка автоматически продлится, если автопродление не будет отключено по крайней мере за 24 часа до окончания текущего периода. Для управления подпиской и отключения автоматического продления вы можете перейти в настройки  iTunes. Деньги будут списаны со счета вашего аккаунта iTunes при подтверждении покупки. Если вы оформите подписку до истечения срока бесплатной пробной версии, оставшаяся часть бесплатного пробного периода будет аннулирована в момент подтверждения покупки"
    }
    
    var callToActionAttributed: NSAttributedString {
        var mainFont: UIFont!
        var smallFont: UIFont!
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainFont = .systemFont(ofSize: 24, weight: .medium)
            smallFont = .systemFont(ofSize: 20, weight: .medium)
        } else {
            mainFont = .systemFont(ofSize: 20, weight: .medium)
            smallFont = .systemFont(ofSize: 16, weight: .medium)
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let string = NSMutableAttributedString(string: callToAction + "\nпервые 7 дней",
                                               attributes: [
                                                NSAttributedString.Key.foregroundColor : UIColor.white,
                                                NSAttributedString.Key.font : mainFont!,
                                                NSAttributedString.Key.paragraphStyle : paragraph
        ])
        
        string.addAttributes([NSAttributedString.Key.font : smallFont!],
                             range: (string.string as NSString).range(of: "первые 7 дней"))
        return string
    }
	
	private override init() {
		super.init()
		SKPaymentQueue.default().add(self)
	}
	
	// MARK:- Main methods
	
	func purchase(product: SKProduct, completion: SubscriptionBlock? = nil) {
		guard SKPaymentQueue.canMakePayments() else { return }
		guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else { return }
		subscriptionBlock = completion
		let payment = SKPayment(product: product)
		SKPaymentQueue.default().add(payment)
	}
	
	func restorePurchases(completion: SubscriptionBlock? = nil) {
		subscriptionBlock = completion
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
	
	func loadReceipt(completion: ReceiptBlock? = nil) {
		self.receiptBlock = completion
		guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
			refreshReceipt()
			return
		}
		guard let receiptData = try? Data(contentsOf: receiptUrl).base64EncodedString() else {
            completion?(.failure(NSError.error(with: "Что-то пошло не так")))
            return
        }
		completion?(.success(receiptData))
	}
    
	private func refreshReceipt() {
		let request = SKReceiptRefreshRequest(receiptProperties: nil)
		request.delegate = self
		request.start()
	}
	
	func loadProducts(completion: ProductsBlock? = nil) {
		guard products.isEmpty else {
			completion?(.success(products))
			return
		}
		let productIds: Set<String> = [
            "com.inspiritum.filmikus.1month7daysfree"
		]
		let request = SKProductsRequest(productIdentifiers: productIds)
		productsBlock = completion
		request.delegate = self
		request.start()
	}
}

// MARK: - SKRequestDelegate

extension StoreKitService: SKRequestDelegate {
	
	func requestDidFinish(_ request: SKRequest) {
		guard request is SKReceiptRefreshRequest else { return }
		loadReceipt(completion: receiptBlock)
	}
	
	func request(_ request: SKRequest, didFailWithError error: Error){
		guard request is SKReceiptRefreshRequest else { return }
		DispatchQueue.main.async {
			self.receiptBlock?(.failure(error))
			self.receiptBlock = nil
		}
	}
}

// MARK: - SKProductsRequestDelegate

extension StoreKitService: SKProductsRequestDelegate {
	
	public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		products = response.products
		DispatchQueue.main.async {
			self.productsBlock?(.success(response.products))
		}
	}
}

// MARK: - SKPaymentTransactionObserver

extension StoreKitService: SKPaymentTransactionObserver {
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("restored transactions, loading receipt...")
        loadReceipt() { result in
            print("receipt loaded")
            DispatchQueue.main.async {
                let subscriptionResult = result.map { _ in Void() }
                self.subscriptionBlock?(subscriptionResult)
                self.subscriptionBlock = nil
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("failed to restore transactions")
        DispatchQueue.main.async {
            self.subscriptionBlock?(.failure(NSError.error(with: error.localizedDescription)))
            self.subscriptionBlock = nil
        }
    }
    
	public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch (transaction.transactionState) {
			case .purchased:
				SKPaymentQueue.default().finishTransaction(transaction)
                
                loadReceipt() { result in
                    DispatchQueue.main.async {
                        let subscriptionResult = result.map { _ in Void() }
                        self.subscriptionBlock?(subscriptionResult)
                        self.subscriptionBlock = nil
                    }
                }
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
			case .failed:
				SKPaymentQueue.default().finishTransaction(transaction)
                
				DispatchQueue.main.async {
                    self.subscriptionBlock?(.failure(transaction.error ?? NSError()))
                    self.subscriptionBlock = nil
				}
			case .deferred, .purchasing:
				break
			default:
				break
			}
		}
	}
}

extension NSError {
    static func error(with title: String) -> NSError {
        let bundle = Bundle.main.bundleIdentifier ?? "com.filmikus.app"
        return NSError(domain: bundle, code: 0, userInfo: [NSLocalizedDescriptionKey : title])
    }
}
