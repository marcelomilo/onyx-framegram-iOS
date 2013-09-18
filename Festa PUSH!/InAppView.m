//
//  InAppView.m
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import "InAppView.h"
#import "InAppPurchaseManager.h"

@implementation InAppView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopAnimating) name:@"stopAnimating" object:nil];
    
    BOOL isIphone5Inch = [[UIScreen mainScreen]bounds].size.height > 480;

    int imgY;
    if (isIphone5Inch)
        imgY = 65;
    else
        imgY = 30;
    
    UIImageView *imgBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"comprarMolduras"]];
    [imgBackground setFrame:CGRectMake(7, imgY, 306, 420)];
    [self addSubview:imgBackground];
    
    int btY;
    if (isIphone5Inch)
        btY = self.bounds.size.height - 130;
    else
        btY = self.bounds.size.height - 78;

    UIButton *btCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btCancel setBackgroundImage:[UIImage imageNamed:@"BtCancelar"] forState:UIControlStateNormal];
    [btCancel setFrame:CGRectMake(14, btY, 140, 40)];
    [btCancel addTarget:self action:@selector(didCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btCancel];
    
    UIButton *btBuy = [UIButton buttonWithType:UIButtonTypeCustom];
    [btBuy setBackgroundImage:[UIImage imageNamed:@"BtComprar"] forState:UIControlStateNormal];
    [btBuy setFrame:CGRectMake(166, btY, 140, 40)];
    [btBuy addTarget:self action:@selector(didBuy:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btBuy];
    
    spin = [[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.bounds.size.width/2 -10, self.bounds.size.height/2 -10, 20, 20)]autorelease];
    [spin setHidesWhenStopped:YES];
    [spin setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:spin];
    
    [imgBackground release];
}

- (void)stopAnimating {
    [spin stopAnimating];
}

- (void)didCancel:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:0];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)didBuy:(id)sender {
    if (![spin isAnimating]) {
        [spin startAnimating];
        InAppPurchaseManager *inAppManager = [[InAppPurchaseManager alloc]init];
        inAppManager.idString = self.idString;
        inAppManager.index = self.index;
        [inAppManager loadStore];
    }
}
 

@end
