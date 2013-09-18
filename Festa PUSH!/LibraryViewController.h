//
//  LibraryViewController.h
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface LibraryViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (retain, nonatomic) IBOutlet UICollectionView *table; 
@property (nonatomic, retain) NSMutableArray *arrMain;

- (void)loadImages;

@end
