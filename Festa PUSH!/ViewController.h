//
//  ViewController.h
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import<Social/Social.h>
#import "CaptureManager.h"
#import "UIImage+Utilities.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "InAppView.h"
#import "InAppPurchaseManager.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CaptureManagerDelegate,  UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate> {
    UIView *previewView;
    AVCaptureVideoPreviewLayer *previewLayer;
    CALayer *focusBox;
    CALayer *exposeBox;
    UIImageView *newFrame;
    UIImage *finalImage;
    
    BOOL processingTakePhoto;
    BOOL isShowShotButton;
    int currentIndex;
    BOOL isUpgraded;
    BOOL isHaveFrame;
    InAppView *inAppView;
    BOOL isSaveCameraRoll;
    BOOL isSendToInstagram;
    BOOL isTorch;
    
    UIImageView *imgGrid;
    BOOL isGrid;
    CGPoint pointTag;
}

@property (retain, nonatomic) UIImage *imageToSend;
@property (retain, nonatomic) IBOutlet UIImageView *iconFalaToy;
@property (retain, nonatomic) IBOutlet UIImageView *imgBranch;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spin;
@property (nonatomic, retain) CaptureManager *captureManager;
@property (retain, nonatomic) IBOutlet UIButton *shutterButton;
@property (retain, nonatomic) IBOutlet UIButton *albumButton;
@property (retain, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) IBOutlet UIButton *btConfirm;
@property (retain, nonatomic) IBOutlet UIButton *btFrontCamera;
@property (retain, nonatomic) IBOutlet UIButton *btExcluir;
@property (retain, nonatomic) IBOutlet UIImageView *imgLastPhoto;
@property (retain, nonatomic) IBOutlet UIImageView *albumImgV;
@property (retain, nonatomic) IBOutlet UIButton *btFlash;
@property (retain, nonatomic) IBOutlet UIButton *btGrid;
@property (retain, nonatomic) IBOutlet UIImageView *imgTabBar;

@property (retain, nonatomic) NSArray *arrFrames;
@property (retain, nonatomic) NSMutableArray *arrSelection;

- (IBAction)btExcluir:(id)sender;
- (IBAction)btFrontCamera:(id)sender;
- (IBAction)shutterButtonPushed:(id)sender;
- (IBAction)photoAlbumButtonPushed:(id)sender;
- (IBAction)btConfirm:(id)sender;
- (IBAction)btFlash:(id)sender;
- (IBAction)btGrid:(id)sender;

- (void)drawFocusBoxAtPointOfInterest:(CGPoint)point;
- (void)drawExposeBoxAtPointOfInterest:(CGPoint)point;

@end
