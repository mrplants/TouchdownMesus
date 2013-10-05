//
//  TDMDetailViewController.m
//  Touchdown Me-sus
//
//  Created by Sean Fitzgerald on 5/27/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "TDMDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <iAd/iAd.h>

@interface TDMDetailViewController () <UIScrollViewDelegate,UIGestureRecognizerDelegate,ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet ADBannerView *bannerAd;

//the scrollView for the library
@property (weak, nonatomic) IBOutlet UIScrollView *libraryScrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *renderingActivityIndicator;

//the library, photo, and mural overlay UIImageViews
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UIImageView* muralOverlayImageView;
@property (strong, nonatomic)  UIImageView *libraryImageView;

//the library, photo, and mural UIImages for the UIImageViews
@property (nonatomic, strong) UIImage* libraryNoMuralImage;
@property (nonatomic, strong) UIImage* muralOverlay;

//the slider to control the alphs of the mural;
@property (weak, nonatomic) IBOutlet UISlider *muralSlider;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) UIView* muralView;
@property CGFloat initialMuralScale;
@property CGFloat initialMuralRotation;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapHideToolbarGesture;
@property (weak, nonatomic) IBOutlet UIToolbar *saveToPhoneBarButton;

@end

@implementation TDMDetailViewController

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	banner.frame = CGRectMake(0,
														self.view.frame.size.height,
														banner.frame.size.width,
														banner.frame.size.height);
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	banner.frame = CGRectMake(0,
														self.view.frame.size.height - banner.frame.size.height,
														banner.frame.size.width,
														banner.frame.size.height);
}

//gestures for manipulating the mural image
- (void)panPhoto:(UIPanGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateChanged)
	{
		//get the relative distance moved
		CGPoint distance = [sender translationInView:self.view];
		
		//apply that distance by translating the image
		
		CGFloat newX = self.muralView.frame.origin.x + distance.x;
		
		newX = (newX + self.muralView.frame.size.width / 2 > self.view.frame.size.width) ? self.view.frame.size.width - self.muralView.frame.size.width / 2 : newX;
		
		newX = (newX + self.muralView.frame.size.width / 2  < 0) ?  - self.muralView.frame.size.width / 2 : newX;

		CGFloat newY = self.muralView.frame.origin.y + distance.y;
		
		newY = (newY + self.muralView.frame.size.height / 2 > self.view.frame.size.height) ? self.view.frame.size.height - self.muralView.frame.size.height / 2 : newY;

		newY = (newY + self.muralView.frame.size.height / 2 < 0) ?  - self.muralView.frame.size.height / 2 : newY;
		
		
//		NSLog(@"newX: %f, newY: %f", newX, newY);
		self.muralView.frame = CGRectMake(newX,
																			newY,
																			self.muralView.frame.size.width,
																			self.muralView.frame.size.height);
		self.photo.imageX = newX;
		self.photo.imageY = newY;
		
		//reset the translation to 0.0f
		[sender setTranslation:CGPointZero inView:self.photoImageView];
	}
}
//- (void)rotatePhoto:(UIRotationGestureRecognizer *)sender
//{
//	if (sender.state == UIGestureRecognizerStateBegan) {
//		
////		self.initialMuralRotation = acosf(self.muralView.transform.a);
//		
//	}
//	else
//	{
//		self.muralView.layer.anchorPoint = [sender locationInView:self.muralView];
//
//    CGFloat newRotation = self.initialMuralRotation + sender.rotation;
//		
//    CGAffineTransform transform = CGAffineTransformMakeRotation(newRotation);
//		
//    self.muralView.transform = transform;
//		
//	}
//}
- (void)pinchPhoto:(UIPinchGestureRecognizer *)sender
{
	
	
	if (sender.state == UIGestureRecognizerStateBegan) {
		
		self.initialMuralScale = self.muralView.transform.a;
		
	}
	else if(self.muralView.frame.size.width > self.view.frame.size.width / 3 || sender.scale > 1)
	{
    CGFloat newScale = self.initialMuralScale * sender.scale;
		
    CGAffineTransform transform = CGAffineTransformMakeScale(newScale,newScale);
		
    self.muralView.transform = transform;
		
		self.photo.imageWidth = self.muralView.frame.size.width;
		self.photo.imageHeight = self.muralView.frame.size.height;
		
	}
}

//showing and hiding the top and bottom bars
-(void)hideNavigationBarWithAnimation
{
	[UIView animateWithDuration:0.5
									 animations:^{
										 self.navigationController.navigationBar.alpha = 0;
										 self.toolbar.alpha = 0;
									 }
									 completion:^(BOOL finished){
										 self.navigationController.navigationBarHidden = YES;
										 self.toolbar.hidden = YES;
									 }];
}
-(void)showNavigationBarWithAnimation
{
	self.navigationController.navigationBarHidden = NO;
	self.toolbar.hidden = NO;
	[UIView animateWithDuration:0.2
									 animations:^{
										 self.navigationController.navigationBar.alpha = 1;
										 self.toolbar.alpha = 1;
									 }
									 completion:^(BOOL finished){
									 }];
	[self performSelector:@selector(hideNavigationBarWithAnimation) withObject:nil afterDelay:3.0];
}
- (IBAction)tap:(UITapGestureRecognizer *)sender
{
	if(self.toolbar.hidden) [self showNavigationBarWithAnimation];
	else [self hideNavigationBarWithAnimation];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self performSelector:@selector(hideNavigationBarWithAnimation) withObject:nil afterDelay:0.5];
}
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView
											withView:(UIView *)view atScale:(float)scale
{
	[self performSelector:@selector(hideNavigationBarWithAnimation) withObject:nil afterDelay:0.5];
}

//getters
-(UIImageView *)libraryImageView
{
	if(!_libraryImageView) _libraryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	return _libraryImageView;
}
-(UIImageView *)photoImageView
{
	if (!_photoImageView)
	{
		_photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.contentMode = UIViewContentModeScaleAspectFill;
	}
	return _photoImageView;
}
-(UIImageView *)muralOverlayImageView
{
	if (!_muralOverlayImageView) _muralOverlayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	return _muralOverlayImageView;
}
-(UIView *)muralView
{
	if(!_muralView) _muralView = [[UIView alloc] initWithFrame:CGRectZero];
	return _muralView;
}

//view lifecycle methods
- (void)viewDidLoad
{
	//setup the delegate for the banner view as self
	self.bannerAd.delegate = self;
	
	self.tapHideToolbarGesture.delegate = self;
	self.muralOverlay = [UIImage imageNamed:@"mural_overlay.png"];
	//this should come from the data model
//	self.photoImage = [UIImage imageNamed:@"uglySweater.png"];
	//this should come from the data model
	self.libraryNoMuralImage = [UIImage imageNamed:@"TDJ_no_mural_low_res.png"];
	
	//this should not be visible unless the library is gone
	self.muralSlider.hidden = YES;
	
	//setup the scrolling view and library imageView
	[self setupLibraryImageWithScrollView];
	
	//setup the photo and mural overlay imageViews in their own view
	[self setupViewForPhotoAndMural];

	[super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
	[self sliderValueChanged:self.muralSlider];
//	self.libraryScrollView.frame = self.view.bounds;
	
//	self.photoImageView.frame = CGRectMake(0,
//																				 0,
//																				 self.photoImageView.image.size.width,
//																				 self.photoImageView.image.size.height);
	
	//add the necessary views as subviews of the self.view
	[self.view addSubview:self.muralView];
	[self.view addSubview:self.libraryScrollView];
	
	//make it so the toolbar will appear on top of the other views
	[self.view bringSubviewToFront:self.toolbar];
	
	//hide the status bar for taking screenShots
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self.libraryScrollView setZoomScale:self.libraryScrollView.minimumZoomScale];
	
	[super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = YES;
	self.navigationController.navigationBarHidden = NO;
	if (self.photo.imageHeight == 0)
	{
		CGFloat scale = self.view.frame.size.height / self.muralView.frame.size.height;
		self.muralView.transform = CGAffineTransformMakeScale(scale, scale);
	}
	[self.libraryScrollView setZoomScale:self.libraryScrollView.minimumZoomScale];
	[self.libraryScrollView scrollRectToVisible:CGRectMake(self.libraryScrollView.contentSize.width / 2 - self.view.bounds.size.width / 2,
																												self.libraryScrollView.contentSize.height / 2 - self.view.bounds.size.height / 2,
																												self.view.bounds.size.width,
																												 self.view.bounds.size.height)
																		 animated:NO];
	if (self.photo.imageHeight == 0)self.muralView.center = self.view.center;
	[super viewDidAppear:animated];
	[self performSelector:@selector(hideNavigationBarWithAnimation) withObject:nil afterDelay:3.0];
}

//view setup methods
-(void) setupLibraryImageWithScrollView
{
	//this is the only default value that I don't really want.
	//The others will work and we don't have to change anything else
	self.libraryScrollView.scrollsToTop = NO;
	
	//set the correct iamge and frame to the UIImageView
	self.libraryImageView.image = self.libraryNoMuralImage;
	self.libraryImageView.frame = CGRectMake(0,
																					 0,
																					 self.libraryNoMuralImage.size.width,
																					 self.libraryNoMuralImage.size.height);
	
	//set the zoom scales of the scrollView
	self.libraryScrollView.minimumZoomScale = 0.2;
	self.libraryScrollView.maximumZoomScale = 1.0;
	
	//set the zoom delegates
	self.libraryScrollView.delegate = self;
	
	//set the content size inside the scrollView
	self.libraryScrollView.contentSize = self.libraryNoMuralImage.size;
	
	//add the imageView as a subview
	[self.libraryScrollView addSubview:self.libraryImageView];

	//since this is being called inside -viewDidLoad, we cannot set the
	//scrollView frame because self.view bounds haven't been set yet.
	//that will be implemented in -viewWillAppear to guarantee that the
	//bounds are set.
}
-(void) setupViewForPhotoAndMural
{
	//set the correct image to the mural overlay imageview and the photoImageView
	self.muralOverlayImageView.image = self.muralOverlay;
	self.photoImageView.image = [UIImage imageWithContentsOfFile:self.photo.imagePath];
	
	//
	//Somehow need to make the images the same size. I think I will scale the mural
	//overlay to not lose and photo integrity from the start.
	//
	
	//set the frames for the imageViews
	self.photoImageView.frame = CGRectMake(0,
																				 0,
																				 self.photoImageView.image.size.width,
																				 self.photoImageView.image.size.height);
	self.muralOverlayImageView.frame = self.photoImageView.frame;
	
	//set the size for the UIView that will hold the photo and mural overlay
	self.muralView.frame = self.photoImageView.frame;
	
	if (self.photo.imageHeight != 0)
	{
		self.muralView.frame = CGRectMake(self.photo.imageX,
																			self.photo.imageY,
																			self.photo.imageWidth,
																			self.photo.imageHeight);
		self.photoImageView.frame = self.muralView.bounds;
		self.muralOverlayImageView.frame = self.muralView.bounds;
	}
	
	//add the photo and mural overlay as subviews of the muralView
	[self.muralView addSubview:self.photoImageView];
	[self.muralView addSubview:self.muralOverlayImageView];
	
	//create the gesture recognizers for the mural view
	UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
																																				action:@selector(panPhoto:)];
	UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
																																				action:@selector(pinchPhoto:)];
	
	//add the gestureRecognizers to the muralView
	[self.muralView addGestureRecognizer:pan];
//	[self.muralView addGestureRecognizer:rotate];
	[self.muralView addGestureRecognizer:pinch];
	
	//the content shouldn't go past the bounds, so we set the content mode to maintain aspect and fill, while clipping the extra
	self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.muralOverlayImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.photoImageView.clipsToBounds = YES;
	self.muralOverlayImageView.clipsToBounds = YES;
	
}

//scrollview delegate methods
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.libraryImageView;
}

//uigesturerecognizer delegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	// test if our control subview is on-screen
	if (self.saveToPhoneBarButton.superview != nil) {
		if ([touch.view isDescendantOfView:self.saveToPhoneBarButton]) {
			// we touched our control surface
			return NO; // ignore the touch
		}
	}
	return YES; // handle the touch
}


//actions from the storyboard
- (IBAction)sliderValueChanged:(UISlider *)sender
{
	self.muralOverlayImageView.alpha = sender.value;
//	self.photoImageView.alpha = 1 - sender.value;
}
- (IBAction)switchSwitched:(UISwitch *)sender
{
	if (sender.on)
	{
		self.libraryScrollView.hidden = NO;
		[UIView animateWithDuration:0.5
										 animations:^{
											 self.libraryScrollView.alpha = 1;
											 self.muralSlider.alpha = 0;
										 } completion:^(BOOL finished){
											 self.muralSlider.hidden = YES;
										 }];
	}
	else
	{
		self.muralSlider.hidden = NO;
		[UIView animateWithDuration:0.5
										 animations:^{
											 self.libraryScrollView.alpha = 0;
											 self.muralSlider.alpha = 1;
										 } completion:^(BOOL finished){
											 self.libraryScrollView.hidden = YES;
										 }];
	}
}
- (IBAction)saveToPhoneTapped:(UIBarButtonItem *)sender
{
	UIImage * image = [self screenshot];
	UIImageWriteToSavedPhotosAlbum(image, NULL, NULL, NULL);
}

//got this method from apple's website:
//http://developer.apple.com/library/ios/#qa/qa1703/_index.html#//apple_ref/doc/uid/DTS40010193
- (UIImage*)screenshot
{
	//hide the toolbars and other screen acoutrements
	self.toolbar.hidden = YES;
	self.navigationController.navigationBarHidden = YES;
	self.muralSlider.hidden = YES;
//	NSLog(@"time stamp");

	// Create a graphics context with the target size
	// On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
	// On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
	CGSize imageSize = [[UIScreen mainScreen] bounds].size;
	if (NULL != UIGraphicsBeginImageContextWithOptions)
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	else
		UIGraphicsBeginImageContext(imageSize);
//	NSLog(@"time stamp");

	CGContextRef context = UIGraphicsGetCurrentContext();
//	NSLog(@"time stamp");
	// Iterate over every window from back to front
	for (UIWindow *window in [[UIApplication sharedApplication] windows])
	{
//		NSLog(@"time stamp");
		if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
		{
			// -renderInContext: renders in the coordinate space of the layer,
			// so we must first apply the layer's geometry to the graphics context
			CGContextSaveGState(context);
			// Center the context around the window's anchor point
			CGContextTranslateCTM(context, [window center].x, [window center].y);
			// Apply the window's transform about the anchor point
			CGContextConcatCTM(context, [window transform]);
			// Offset by the portion of the bounds left of and above the anchor point
			CGContextTranslateCTM(context,
														-[window bounds].size.width * [[window layer] anchorPoint].x,
														-[window bounds].size.height * [[window layer] anchorPoint].y);
			
			// Render the layer hierarchy to the current context
			[[window layer] renderInContext:context];
			
			// Restore the context
			CGContextRestoreGState(context);
		}
	}
//	NSLog(@"time stamp");

	// Retrieve the screenshot image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//	NSLog(@"time stamp");

	UIGraphicsEndImageContext();
	
	[self showNavigationBarWithAnimation];
	
	[[[UIAlertView alloc] initWithTitle:@"Image Saved!"
														 message:nil
														delegate:self
									 cancelButtonTitle:@"OK"
										otherButtonTitles:nil] show];
	
	return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
