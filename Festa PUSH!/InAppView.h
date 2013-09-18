//
//  InAppView.h
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InAppView : UIView {
    UIActivityIndicatorView *spin;
}

@property (nonatomic, retain) NSString *idString;
@property (nonatomic) int index;

- (void)didCancel:(id)sender;

@end
