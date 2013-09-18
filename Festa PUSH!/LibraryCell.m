//
//  LibraryCell.m
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import "LibraryCell.h"

@implementation LibraryCell

- (id)initWithFrame:(CGRect)frame
{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"LibraryCell" owner:self options:nil];
    
    if ([arrayOfViews count] < 1) {
        return nil;
    }
    
    if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) { return nil; }
    
    self = [arrayOfViews objectAtIndex:0];
    
    return self;
}

- (void)dealloc {
    [_imgPhoto release];
    [super dealloc];
}
@end
