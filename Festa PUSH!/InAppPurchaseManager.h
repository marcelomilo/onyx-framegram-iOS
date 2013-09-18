//
//  InAppPurchaseManager.h
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"




@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate> {
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
    
    BOOL isAlert;
}

@property (nonatomic) BOOL isRestore;
@property (nonatomic) int index;
@property (nonatomic, retain) NSString *idString;

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;

@end
