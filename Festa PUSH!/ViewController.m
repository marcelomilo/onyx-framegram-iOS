//
//  ViewController.m
//  Festa Push
//
//  Created by Marcelo Milo on 04/09/13.
//  Copyright (c) 2013 Marcelo Milo. All rights reserved.
//

#import "ViewController.h"
#import "LibraryViewController.h"
#import "InAppPurchaseManager.h"

@interface ViewController ()

#define IMAGE_WIDTH 612.0f
#define IMAGE_HEIGHT 612.0f

@end

@implementation ViewController

@synthesize captureManager;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [captureManager performSelector:@selector(startRunning) withObject:nil afterDelay:0.0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    previewLayer.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [captureManager performSelector:@selector(stopRunning) withObject:nil afterDelay:0.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.spin setHidesWhenStopped:YES];
    
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(loadFrames) name:@"loadFrames" object:nil];
    [defaultCenter addObserver:self selector:@selector(stopAnimate) name:@"stopStartAnimate" object:nil];
    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [panGesture setDelegate:self];
//    [panGesture setMaximumNumberOfTouches:1];
//    [self.imgBranch addGestureRecognizer:panGesture];

    
    [self loadFrames];
    
#if !TARGET_IPHONE_SIMULATOR
    
    NSError *error;
    self.captureManager = [[[CaptureManager alloc] init] autorelease];
    captureManager.delegate = self;
    if ([captureManager setupSessionWithPreset:AVCaptureSessionPresetPhoto error:&error]) {
        CGRect frame;
        frame = CGRectMake(7.0f, 52.0f, 306.0f, 306.0f);
        
        previewView = [[UIView alloc] initWithFrame:frame];
        previewView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:previewView];
        [self.view sendSubviewToBack:previewView];
        [previewView release];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [previewView addGestureRecognizer:singleTap];
        [singleTap release];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToExpose:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [previewView addGestureRecognizer:doubleTap];
        [doubleTap release];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        CGRect bounds = previewView.bounds;
        previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureManager.session];
        previewLayer.frame = bounds;
        previewLayer.hidden = YES;
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        NSDictionary *unanimatedActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"bounds", [NSNull null], @"frame", [NSNull null], @"position", nil];
        
        focusBox = [CALayer layer];
        focusBox.actions = unanimatedActions;
        focusBox.borderWidth = 2.0f;
        focusBox.borderColor = [[UIColor colorWithRed:1 green:0.2 blue:0.4 alpha:1] CGColor]; //#ff3366
        focusBox.opacity = 0.0f;
        [previewLayer addSublayer:focusBox];
        
        exposeBox = [CALayer layer];
        exposeBox.actions = unanimatedActions;
        exposeBox.borderWidth = 2.0f;
        exposeBox.borderColor = [[UIColor colorWithRed:1 green:0.2 blue:0.4 alpha:1] CGColor]; //#ff3366
        exposeBox.opacity = 0.0f;
        [previewLayer addSublayer:exposeBox];
        
        [unanimatedActions release];
        
        [previewView.layer addSublayer:previewLayer];
        
    }
#endif
    
    //[self addCropFrame];
    
    [self buildScrollFrames];
    
    [self getLastPhoto];
    
    if ([self isIphone4inch]) {
        CGRect scrollFrame = self.scroll.frame;
        scrollFrame.origin.y -= 88;
        scrollFrame.size.height += 82;
        [self.scroll setFrame:scrollFrame];
        
        CGRect navBarFrame = self.imgTabBar.frame;
        navBarFrame.size.height += 50;
        navBarFrame.origin.y -= 50;
        [self.imgTabBar setFrame:navBarFrame];
        
        [self.shutterButton setImage:[UIImage imageNamed:@"ButtonTirarFoto"] forState:UIControlStateNormal];
        CGRect shutterBtFrame = self.shutterButton.frame;
        shutterBtFrame.origin.y -=50;
        shutterBtFrame.origin.x -= 25;
        shutterBtFrame.size.height +=50;
        shutterBtFrame.size.width +=50;

        [self.shutterButton setFrame:shutterBtFrame];
        
        
        [self.btConfirm setImage:[UIImage imageNamed:@"Check5"] forState:UIControlStateNormal];
        CGRect confirmBtFrame = self.btConfirm.frame;
        confirmBtFrame.origin.y -=50;
        confirmBtFrame.origin.x -= 25;
        confirmBtFrame.size.height +=50;
        confirmBtFrame.size.width +=50;
        
        [self.btConfirm setFrame:confirmBtFrame];
        
        [self.btExcluir setImage:[UIImage imageNamed:@"Cancel5"] forState:UIControlStateNormal];
        CGRect excluirBtFrame = self.btExcluir.frame;
        excluirBtFrame.origin.y -=25;
        excluirBtFrame.origin.x -= 25;
        excluirBtFrame.size.height +=50;
        excluirBtFrame.size.width +=50;
        
        [self.btExcluir setFrame:excluirBtFrame];
        
        
    }
    isHaveFrame = YES;
}


- (void)stopAnimate {
    [self.spin stopAnimating];
    
}

- (void)loadFrames {
    self.arrFrames = [[[NSArray alloc]init]autorelease];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"MoldurasPlist" ofType:@"plist"];
    NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:path];
    
    isUpgraded = [[NSUserDefaults standardUserDefaults]boolForKey:@"isUpgradePurchased"];
    
    if (isUpgraded) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"UpgradedPlist" ofType:@"plist"];
        NSArray *arrUpgraded = [NSMutableArray arrayWithContentsOfFile:path];
        for (NSString *str in arrUpgraded) {
            [arr addObject:str];
        }
    } else {
        [arr addObject:@"frame-locked"];
        [arr addObject:@"frame-restore"];
    }
    
    self.arrFrames = [NSArray arrayWithArray:arr];
    
    [self buildScrollFrames];
}


//- (void)addCropFrame {
//    UIImageView *cropFrameView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crop_frame.png"]];
//    cropFrameView.alpha = 0.3f;
//    CGRect frame = cropFrameView.bounds;
//    frame.origin.y = 45.0f;
//    [cropFrameView setFrame:frame];
//    [previewView addSubview:cropFrameView];
//    [cropFrameView release];
//}


- (void)captureStillImageFinished:(UIImage *)image {
    
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGRect cropRect;
    if (height > width) {
        cropRect = CGRectMake((height - width) / 2.0f, 0.0f, width, width);
    } else {
        cropRect = CGRectMake((width - height) / 2.0f, 0.0f, width, width);
    }
    
    UIImage *croppedImage = [image croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT) imageOrientation:image.imageOrientation];
    
    self.albumImgV = [[[UIImageView alloc]initWithImage:resizedImage]autorelease];
    [self.albumImgV setFrame:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT)];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    processingTakePhoto = NO;
    [self showConfirmButton];
    [self.spin stopAnimating];
    
    
}

- (IBAction)shutterButtonPushed:(id)sender {
    if (processingTakePhoto) {
        return;
    }
    [self.spin startAnimating];
    processingTakePhoto = YES;
    
#if !TARGET_IPHONE_SIMULATOR
    [captureManager captureStillImage];
#endif
    
}

- (IBAction)photoAlbumButtonPushed:(id)sender {
    
    previewLayer.hidden = YES;
    [captureManager stopRunning];
    [self performSelector:@selector(showImagePicker) withObject:nil afterDelay:0.0];
    
    
     // LibraryViewController *library = [[LibraryViewController alloc]initWithNibName:@"LibraryViewController" bundle:nil];
     // [self presentViewController:library animated:YES completion:^{
     // [library loadImages];
     // }];
     // [library release];
     
}

#pragma mark - Capture

- (void)captureSessionDidStartRunning {
    previewLayer.hidden = NO;
    
    CGRect bounds = previewView.bounds;
    CGPoint screenCenter = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    [self drawFocusBoxAtPointOfInterest:screenCenter];
    [self drawExposeBoxAtPointOfInterest:screenCenter];
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

#pragma mark - Adjust

+ (void)addAdjustingAnimationToLayer:(CALayer *)layer removeAnimation:(BOOL)remove {
    if (remove) {
        [layer removeAnimationForKey:@"animateOpacity"];
    }
    if ([layer animationForKey:@"animateOpacity"] == nil) {
        [layer setHidden:NO];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setDuration:0.3f];
        [opacityAnimation setRepeatCount:1.0f];
        [opacityAnimation setAutoreverses:YES];
        [opacityAnimation setFromValue:[NSNumber numberWithFloat:1.0f]];
        [opacityAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
        [layer addAnimation:opacityAnimation forKey:@"animateOpacity"];
    }
}

- (void)drawFocusBoxAtPointOfInterest:(CGPoint)point {
    if ([captureManager hasFocus]) {
        [focusBox setFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
        [focusBox setPosition:point];
        [ViewController addAdjustingAnimationToLayer:focusBox removeAnimation:YES];
    }
}

- (void)drawExposeBoxAtPointOfInterest:(CGPoint)point {
    if ([captureManager hasExposure]) {
        [exposeBox setFrame:CGRectMake(0.0f, 0.0f, 114.0f, 114.0f)];
        [exposeBox setPosition:point];
        [ViewController addAdjustingAnimationToLayer:exposeBox removeAnimation:YES];
    }
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
    CGSize frameSize = previewView.frame.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = previewLayer;
    
    if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.0f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in captureManager.videoInput.ports) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = 0.5f;
                CGFloat yc = 0.5f;
                
                if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.0f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.0f - (point.x / x2);
                        }
                    }
                } else if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.0f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.0f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

#pragma mark - Image Picker

- (void)showImagePicker {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.allowsEditing = YES;
    [self presentViewController:pickerController animated:YES completion:^{}];
}

- (void)hideImagePickerAnimated:(BOOL)animated {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    cropRect = [originalImage convertCropRect:cropRect];
    
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT) imageOrientation:originalImage.imageOrientation];
    
    finalImage = resizedImage;
    
    self.albumImgV = [[[UIImageView alloc]initWithImage:resizedImage]autorelease];
    [self.albumImgV setFrame:CGRectMake(0, 0, previewView.frame.size.width, previewView.frame.size.height)];
    [previewView addSubview:self.albumImgV];
    
    [captureManager stopRunning];
    
    [self hideImagePickerAnimated:NO];
    [self showConfirmButton];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self hideImagePickerAnimated:YES];
}

#pragma mark - Focus Methods

- (void)tapToFocus:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:previewView];
    if (captureManager.videoInput.device.isFocusPointOfInterestSupported) {
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:point];
        [captureManager focusAtPoint:convertedFocusPoint];
        [self drawFocusBoxAtPointOfInterest:point];
    }
}

- (void)tapToExpose:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:previewView];
    if (captureManager.videoInput.device.isExposurePointOfInterestSupported) {
        CGPoint convertedExposurePoint = [self convertToPointOfInterestFromViewCoordinates:point];
        [captureManager exposureAtPoint:convertedExposurePoint];
        [self drawExposeBoxAtPointOfInterest:point];
    }
}

- (void)resetFocusAndExpose:(UIGestureRecognizer *)recognizer {
    CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
    [captureManager focusAtPoint:pointOfInterest];
    [captureManager exposureAtPoint:pointOfInterest];
    
    CGRect bounds = previewView.bounds;
    CGPoint screenCenter = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    
    [self drawFocusBoxAtPointOfInterest:screenCenter];
    [self drawExposeBoxAtPointOfInterest:screenCenter];
    
    [captureManager setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
}

#pragma mark - Background Manager

- (void)applicationDidEnterBackground:(NSNotification *)note {
    UIViewController *modalViewController = self.presentedViewController;
    if (modalViewController) {
        [modalViewController dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)note {
    [self btExcluir:nil];
}

#pragma mark - Scroll Frames

- (void)buildScrollFrames {
    
    if (inAppView) {
        [inAppView didCancel:nil];
    }
    
//    int offSetX = 5.5;
    int width = 60;
    
    if ([self isIphone4inch]) {
        width = 71;
        
        self.arrSelection = [[NSMutableArray alloc]init];
    } else {
        width = 60;
    }
    
    for (int i = 0; i <[self.arrFrames count]; i ++) {
        
        CGRect frame;
        if (![self isIphone4inch]) {
            frame = CGRectMake((width + 5.5) * i + 5.5, 5, 60, 60);
        } else {
            frame = CGRectMake((width + 5.5) * i + 5.5, 5, width, width);
        }
        
        NSString *frameName = [NSString stringWithFormat:@"%@-thumbnail", [self.arrFrames objectAtIndex:i]];
        
        UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:frameName]];
        [imgV setClipsToBounds:YES];
        [imgV setFrame:frame];
        [self.scroll addSubview:imgV];
        
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        [bt setFrame:frame];
        [bt addTarget:self action:@selector(addFrameButton:) forControlEvents:UIControlEventTouchUpInside];
        [bt setTag:i];
        [self.scroll addSubview:bt];
             
        [imgV release];
    }
    
    [self.scroll setContentSize:CGSizeMake((width + 5.5) * [self.arrFrames count] + 5.5, self.scroll.frame.size.height)];
    
    if ([self.spin isAnimating]) {
        [self.spin stopAnimating];
    }
    
    [self.scroll setContentOffset:CGPointZero animated:NO];

}

- (void)addFrameButton:(id)sender {
    
    if (![self.spin isAnimating]) {
        
        
        int index = [sender tag];
        currentIndex = index;
        
        if (newFrame != nil) {
            [newFrame removeFromSuperview];
        }
        
//        if (index == 0) {
//            [self dragBranch];
//            return;
//        } else {
//            [self.imgBranch setHidden:YES];
//        }

        [self.imgBranch setHidden:YES];
        
        if (!isUpgraded && currentIndex == [self.arrFrames count]-2) {
            
            NSString *path = [[NSBundle mainBundle]pathForResource:@"PaidIdList" ofType:@"plist"];
            NSArray *arrList = [NSArray arrayWithContentsOfFile:path];
            int index = currentIndex - [self.arrFrames count]+2;
            
             isHaveFrame = NO;
             inAppView = [[InAppView alloc]initWithFrame:self.view.bounds];
             inAppView.idString = [arrList objectAtIndex:index];
            inAppView.index = index;
             [self.view addSubview:inAppView];
             [inAppView setAlpha:0];
             [UIView animateWithDuration:0.5 animations:^{
             [inAppView setAlpha:0.8];
             }];
             
        } else if (!isUpgraded && currentIndex == [self.arrFrames count]-1) {
            
             [self.spin startAnimating];
            
            NSString *path = [[NSBundle mainBundle]pathForResource:@"PaidIdList" ofType:@"plist"];
            NSArray *arrList = [NSArray arrayWithContentsOfFile:path];
            int index = currentIndex - [self.arrFrames count] +1;
            
             InAppPurchaseManager *inAppManager = [[InAppPurchaseManager alloc]init];
             inAppManager.isRestore = YES;
             inAppManager.index = index;
             inAppManager.idString = [arrList objectAtIndex:index];
             [inAppManager loadStore];
        }
        else {
            isHaveFrame = YES;
            
            newFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[self.arrFrames objectAtIndex:index]]];

            [newFrame setFrame:CGRectMake(0, 0, 306, 306)];
        
            [previewView addSubview:newFrame];
            
        }
    }
}


#pragma mark - Drag

//- (void)dragBranch {
//    
//    [self.imgBranch setHidden:NO];
//}

//- (void)handlePan:(UIPanGestureRecognizer*)recognizer {

//    CGPoint translation = [recognizer translationInView:recognizer.view];
//    
//    pointTag = self.imgBranch.center;
//    
//    
//    if (pointTag.x > 255) {
//        pointTag.x = 255;
//    }
//    if (pointTag.x < 63) {
//        pointTag.x = 63;
//    }
//    
//    if (pointTag.y < 83) {
//        pointTag.y = 83;
//    }
//    if (pointTag.y > 326) {
//        pointTag.y = 326;
//    }
//    
//    recognizer.view.center=CGPointMake(pointTag.x+translation.x, pointTag.y+ translation.y);
//    [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];

//}

- (IBAction)btExcluir:(id)sender {
    
    [self.albumButton setHidden:NO];
    [self.imgLastPhoto setHidden:NO];
    
    if (self.albumImgV) {
        [self.albumImgV removeFromSuperview];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.btExcluir setAlpha:0];
        [self.btConfirm setAlpha:0];
        [self.imgLastPhoto setAlpha:1];
        [self.shutterButton setAlpha:1];
    } completion:^(BOOL finished) {
        isShowShotButton = YES;
        [self.btConfirm setHidden:YES];
        [self.btExcluir setHidden:YES];
        
        [captureManager startRunning];
        
    }];
}

- (IBAction)btFrontCamera:(id)sender {
    [captureManager cameraToggle];
}

- (void)showConfirmButton {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.btExcluir setAlpha:1];
        [self.btConfirm setAlpha:1];
        [self.imgLastPhoto setAlpha:0];
        [self.shutterButton setAlpha:0];
    }completion:^(BOOL finished) {
        isShowShotButton = NO;
        [self.btConfirm setHidden:NO];
        [self.albumButton setHidden:YES];
        [self.btExcluir setHidden:NO];
        [self.imgLastPhoto setHidden:YES];
    }];
    
}

- (IBAction)btConfirm:(id)sender {
    isSaveCameraRoll = NO;
    [self.spin startAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Festa PUSH!" message:@"Deseja salvar também no seu álbum de fotos?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
    [alert show];
    [alert release];
}

- (IBAction)btFlash:(id)sender {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasFlash]) {
        [device lockForConfiguration:nil];
                
        switch (device.flashMode) {
            case 0: // off
                [device setFlashMode:AVCaptureFlashModeOn];
                [self.btFlash setImage:[UIImage imageNamed:@"button-flash-on"] forState:UIControlStateNormal];
                [self.btFlash setImage:[UIImage imageNamed:@"button-flash-on-touch"] forState:UIControlStateHighlighted];
                break;
            case 1: // on
                [device setFlashMode:AVCaptureFlashModeAuto];
                [self.btFlash setImage:[UIImage imageNamed:@"button-flash-auto"] forState:UIControlStateNormal];
                [self.btFlash setImage:[UIImage imageNamed:@"button-flash-auto-touch"] forState:UIControlStateHighlighted];
                break;
            case 2: // auto
                [device setFlashMode:AVCaptureFlashModeOff];
                [self.btFlash setImage:[UIImage imageNamed:@"button-flash-off"] forState:UIControlStateNormal];
                [self.btFlash setImage:[UIImage imageNamed:@"button-flash-off-touch"] forState:UIControlStateHighlighted];
                break;
        }
    }
}

- (IBAction)btGrid:(id)sender {    
    if (isGrid) {
        [imgGrid removeFromSuperview];
    } else {
        imgGrid = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"grid"]];
        [imgGrid setFrame:previewView.frame];
        [self.view addSubview:imgGrid];
    }
    
    isGrid = !isGrid;
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
    
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newImageSize);
    }

    [firstImage drawAtPoint:CGPointMake(roundf((newImageSize.width-firstImage.size.width)/2), roundf((newImageSize.height-firstImage.size.height)/2))];
    [secondImage drawAtPoint:CGPointMake(roundf((newImageSize.width-secondImage.size.width)/2), roundf((newImageSize.height-secondImage.size.height)/2))];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)screenShotView{
    
    CGSize size = previewView.frame.size;
    
    UIGraphicsBeginImageContext(size);
	[previewView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return viewImage;
    
}

-(void)shareImageOnInstagram:(UIImage*)shareImage
{
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        
        NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.ig"];
        NSData *imageData=UIImagePNGRepresentation(self.imageToSend);
        [imageData writeToFile:saveImagePath atomically:YES];
        
        NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
        
        UIDocumentInteractionController *docController=[[UIDocumentInteractionController alloc]init];
        docController.delegate = self;
        [docController retain];
        docController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:@"#festapush", @"InstagramCaption", nil];

        [docController setURL:imageURL];
        
        docController.UTI = @"com.instagram.exclusivegram";
        docController.delegate = self;
        
        [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram Não instalado!" message:@"É necessário a instalação do aplicativo Instagram para postagens." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - UIDocumentInteractionController Delegate


- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    isSendToInstagram = YES;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [self.spin stopAnimating];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    if (!isSendToInstagram) {
        [self.spin stopAnimating];
    }
    isSendToInstagram = NO;
}


#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        isSaveCameraRoll = YES;
    } else {
        isSaveCameraRoll = NO;
    }
    
    if (isHaveFrame || currentIndex == 0) {
        
        UIImage *img = nil;
        
        UIImage *photo = self.albumImgV.image;
        photo = [photo resizedImage:CGSizeMake(612, 612) imageOrientation:UIImageOrientationUp];
        
        if (currentIndex == 0) {
            UIImage *imgTag = [UIImage imageNamed:@"tag@2x"];
            //self.imageToSend = [self imageByCombiningImageTag:photo withImage:imgTag];
            self.imageToSend = [self addImage:photo toImage:imgTag];
        } else {
            NSString *frameNameString =  frameNameString = [NSString stringWithFormat:@"%@",[self.arrFrames objectAtIndex:currentIndex]];
            img = [UIImage imageNamed:frameNameString];

            UIImage *combinedImage = [self imageByCombiningImage:photo withImage:img];
            self.imageToSend = combinedImage;
        }
              
        if (isSaveCameraRoll)
            UIImageWriteToSavedPhotosAlbum(self.imageToSend, nil, nil, nil);
        
        [self performSelector:@selector(loadActionSheetWithImage) withObject:nil afterDelay:0.1];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Festa PUSH!" message:@"Selecione uma moldura." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (UIImage*)imageByCombiningImageTag:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    [firstImage drawAtPoint:CGPointMake(0, 0)];
    
    CGPoint pointImage = CGPointMake(self.imgBranch.frame.origin.x + self.imgBranch.frame.size.width/2, self.imgBranch.frame.origin.y+ self.imgBranch.frame.size.height/2);
    [secondImage drawAtPoint:pointImage];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*) addImage:(UIImage*)theimageView toImage:(UIImage*)Birdie{
    CGSize size = CGSizeMake(theimageView.size.width, theimageView.size.height);
    UIGraphicsBeginImageContext(size);
    
    CGPoint pointImage1 = CGPointMake(0, 0);
    [theimageView drawAtPoint:pointImage1];
    
    NSLog(@"%f, %f, %f, %f", self.imgBranch.frame.origin.x, self.imgBranch.frame.origin.y, self.imgBranch.frame.size.width, self.imgBranch.frame.size.height);
    CGPoint pointImage2 = CGPointMake((self.imgBranch.frame.origin.x *2)+ self.imgBranch.frame.size.width/2 - 60, (self.imgBranch.frame.origin.y*2)+ self.imgBranch.frame.size.height/2 -130);
    
    [Birdie drawAtPoint:pointImage2];

    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark - ActionSheet

- (void)loadActionSheetWithImage{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Compartilhar com" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Instagram", @"Twitter", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];
	[popupQuery release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self  shareImage:self.imageToSend facebook:YES];
    } else if (buttonIndex == 1) {
        [self  shareImageOnInstagram:self.imageToSend];
    } else if (buttonIndex == 2) {
        [self  shareImage:self.imageToSend facebook:NO];
    } else {
        [self.spin stopAnimating];
    }
    
}

#pragma mark - Facebook

- (void)shareImage:(UIImage*)imageToShare facebook:(BOOL)isFacebook {
    SLComposeViewController *fbController= nil;
    
    if (isFacebook) {
        fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    } else {
        fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    }
    
    if([SLComposeViewController isAvailableForServiceType:fbController.serviceType])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    [self.spin stopAnimating];
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    [self.spin stopAnimating];
                }
                    break;
            }};
        
        [fbController addImage:self.imageToSend];
        [fbController setInitialText:@"#festapush"];
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }
    
}


#pragma mark - Camera Roll

- (void)getLastPhoto {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets]-1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                 
                                 if (alAsset) {
                                     ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                     UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                                     
                                     [self.imgLastPhoto setImage:[self resizeImageForButton:latestPhoto]];
                                     
                                     self.imgLastPhoto.layer.cornerRadius = 3;
                                     // self.imgLastPhoto.layer.shadowColor = [UIColor blackColor].CGColor;
                                     // self.imgLastPhoto.layer.shadowOffset = CGSizeMake(3, -1);
                                     // self.imgLastPhoto.layer.shadowOpacity = 0.7;
                                     // self.imgLastPhoto.layer.shadowRadius = 5;
                                 }
                             }];
    }
    
    failureBlock: ^(NSError *error) {
        NSLog(@"No groups");
    }];
}

- (UIImage*)resizeImageForButton:(UIImage*)latestPhoto {
    UIImage * portraitImage = [[[UIImage alloc] initWithCGImage: latestPhoto.CGImage scale: 1.0 orientation: UIImageOrientationUp]autorelease];
    
    CGSize imageSize = portraitImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGRect cropRect;
    if (height > width) {
        cropRect = CGRectMake((height - width) / 2, 0, width, width);
    } else {
        cropRect = CGRectMake((width - height) / 2, 0, width, width);
    }
    
    UIImage *croppedImage = [portraitImage croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImage:CGSizeMake(46, 46) imageOrientation:portraitImage.imageOrientation];
    
    return resizedImage;
}

- (BOOL)isIphone4inch{
    return [[UIScreen mainScreen]bounds].size.height > 480;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_scroll release];
    [_btConfirm release];
    [_btFrontCamera release];
    [_btExcluir release];
    [_imgLastPhoto release];
    [_spin release];
    [_btFlash release];
    [_imgTabBar release];
    [_iconFalaToy release];
    [_imgBranch release];
    [super dealloc];
}

@end
