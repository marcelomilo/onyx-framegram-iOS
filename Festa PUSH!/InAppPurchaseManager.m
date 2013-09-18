//
//  InAppPurchaseManager.m
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import "InAppPurchaseManager.h"

@implementation InAppPurchaseManager

- (void)requestProUpgradeProductData
{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"PaidIdList" ofType:@"plist"];
    NSArray *arrList = [NSArray arrayWithContentsOfFile:path];
    
    NSSet *productIdentifiers = [NSSet setWithArray:arrList];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    isAlert = NO;
    NSArray *products = response.products;
    NSLog(@"%@", response.products);
    
    proUpgradeProduct = [[SKProduct alloc]init];
    proUpgradeProduct = [products count] == 1 ? [[products objectAtIndex:self.index] retain] : nil;
    if (proUpgradeProduct)
    {
        NSLog(@"Product title: %@" , proUpgradeProduct.localizedTitle);
        NSLog(@"Product description: %@" , proUpgradeProduct.localizedDescription);
        NSLog(@"Product price: %@" , proUpgradeProduct.price);
        NSLog(@"Product id: %@" , proUpgradeProduct.productIdentifier);

        if (!self.isRestore) {
            [self purchaseProUpgrade];
        } else {
            [self restoreUpgrade];
        }
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [productsRequest release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

#pragma -
#pragma Public methods

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestProUpgradeProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (void)restoreUpgrade {
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    
    NSString *msgStr = nil;
    if (queue.transactions.count == 0) {
        msgStr = @"Toque no cadeado para adquirir as molduras!";
    } else {
        msgStr = @"Obrigado por adquirir as molduras! Em breve novidades!";
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadFrames" object:nil];

    }
    
    if (!isAlert) {
        isAlert = YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FalaToy" message:msgStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
 

    [[NSNotificationCenter defaultCenter]postNotificationName:@"stopStartAnimate" object:nil];

}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {

    [[NSNotificationCenter defaultCenter]postNotificationName:@"stopStartAnimate" object:nil];
    
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade
{
    SKPayment *payment = [SKPayment paymentWithProduct:proUpgradeProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:self.idString])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"upgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:self.idString])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadFrames" object:nil];
        
        NSString *msgStr = nil;
        if (self.isRestore) {
            msgStr = @"Molduras restauradas com sucesso!";
        } else {
            msgStr = @"Obrigado por adquirir as molduras! Em breve novidades!";
        }
        if (!isAlert) {
            isAlert = YES;

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FalaToy" message:@"Obrigado por adquirir as molduras! Em breve novidades!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        }
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
        if (!isAlert) {
            isAlert = YES;

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FalaToy" message:@"Falha na requisição." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        }
    }
    
    [self stopActivityIndicator];

}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    [self stopActivityIndicator];

}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"%@", transaction.originalTransaction.payment.productIdentifier);
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    [self stopActivityIndicator];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    [self stopActivityIndicator];

}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)stopActivityIndicator {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"stopAnimating" object:nil];
}

@end
