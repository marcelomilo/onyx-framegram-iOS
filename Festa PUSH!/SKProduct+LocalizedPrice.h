//
//  SKProduct+LocalizedPrice.h
//  InstaLOVEgram
//
//  Created by Renato Toshio Kuroe on 05/06/13.
//  Copyright (c) 2013 Renato Toshio Kuroe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end