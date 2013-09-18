//
//  LibraryViewController.m
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import "LibraryViewController.h"
#import "LibraryCell.h"

@interface LibraryViewController ()


@end

static NSString * const CellIdentifier = @"Cell";


@implementation LibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.table registerClass:[LibraryCell class] forCellWithReuseIdentifier:CellIdentifier];

    
    self.arrMain = [[NSMutableArray alloc]init];
    
    
}

- (void)loadImages {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        for (int i = 0; i < [group numberOfAssets]-1; i ++) {
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i]
                                    options:0
                                 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                     
                                     if (alAsset) {
                                         ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                         UIImage *photo = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                                         [self.arrMain addObject:photo];
                                     }
                                 }];
            
        }
        
        [self.table reloadData];
        
        NSLog(@"%i", [self.arrMain count]);
        
    }failureBlock: ^(NSError *error) {
        
        NSLog(@"No groups");
    }];
    

}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.arrMain count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    LibraryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.imgPhoto setImage:[self.arrMain objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(50, 50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_table release];
    [super dealloc];
}
@end
