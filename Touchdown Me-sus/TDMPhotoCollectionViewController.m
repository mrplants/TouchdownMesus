//
//  TDMPhotoCollectionViewController.m
//  Touchdown Me-sus
//
//  Created by Sean Fitzgerald on 5/27/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "TDMPhotoCollectionViewController.h"
#import "TDMMesusHeadCollectionViewCell.h"
#import "TDMDetailViewController.h"
#import <CoreData/CoreData.h>
#import "TDMPhoto.h"

#define kCELL_ID @"MesusHeadCell"


@interface TDMPhotoCollectionViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIManagedDocument * databaseDocument;
@property (nonatomic, strong) NSManagedObjectContext * databaseContext;
@property (nonatomic, strong) NSArray * imageArray;

@property (nonatomic, strong) TDMPhoto * selectedPhoto;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imagesLoadingActivityIndicator;

@end

@implementation TDMPhotoCollectionViewController

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
	self.imageArray = [[NSArray alloc] init];
	NSURL * documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	
	documentsURL = [documentsURL URLByAppendingPathComponent:@"myDataModel"];

	[self.imagesLoadingActivityIndicator startAnimating];
	self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:documentsURL];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[documentsURL path]])
	{
		[self.databaseDocument openWithCompletionHandler:^(BOOL success) {
			if (success)
			{
				[self.imagesLoadingActivityIndicator stopAnimating];
				[self documentIsReady];
			}
			else [[[UIAlertView alloc] initWithTitle:@"Storage Error"
																			 message:nil
																			delegate:self
														 cancelButtonTitle:nil
														 otherButtonTitles: nil] show];
		}];
	}
	else
	{
		[self.databaseDocument saveToURL:documentsURL
										forSaveOperation:UIDocumentSaveForCreating
									 completionHandler:^(BOOL success){
										 if (success)
										 {
											 [self.imagesLoadingActivityIndicator stopAnimating];
											 [self newDocumentIsReady];
										 }
										 else [[[UIAlertView alloc] initWithTitle:@"Storage Error"
																											message:nil
																										 delegate:self
																						cancelButtonTitle:nil
																						otherButtonTitles: nil] show];
									 }];
	}
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(TDMPhoto *)savePhotoWithPath:(NSString*)path
{
	TDMPhoto * photo = [NSEntityDescription insertNewObjectForEntityForName:@"TDMPhoto"
																													inManagedObjectContext:self.databaseContext];
	
	photo.imagePath = path;
	return photo;
}

-(void)newDocumentIsReady
{
	self.databaseContext = self.databaseDocument.managedObjectContext;
	
	NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"TDMPhoto"];
	// fetch the photos, store them to imageArray
	
	NSError * error;
	NSArray * savedPhotoObjectsArray = [self.databaseContext executeFetchRequest:request error:&error];
	
	NSMutableArray * tempImageArray = [[NSMutableArray alloc] init];
	
	for (TDMPhoto * photoObject in savedPhotoObjectsArray)
	{
    [tempImageArray addObject:photoObject];
	}
	self.imageArray = [tempImageArray copy];
	[self.collectionView reloadData];


	UIImage * capturedimage = [UIImage imageNamed:@"fillerImage.png"];
	
	capturedimage = [self fixOrientation:capturedimage];
	
	NSData *imageData = UIImagePNGRepresentation(capturedimage);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.png",[self.imageArray count]+1]];
	
//	NSLog((@"pre writing to file"));
	if (![imageData writeToFile:imagePath atomically:NO])
	{
//    NSLog((@"Failed to cache image data to disk"));
	}
	else
	{
//    NSLog(@"the cachedImagedPath is %@",imagePath);
		TDMPhoto* photo = [self savePhotoWithPath:imagePath];
		NSMutableArray* tempImageArray = [self.imageArray mutableCopy];
		[tempImageArray  addObject:photo];
		self.imageArray = [tempImageArray copy];
		
	}
	
	[self.collectionView reloadData];
	
}

-(void)documentIsReady
{
	self.databaseContext = self.databaseDocument.managedObjectContext;
	
	NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"TDMPhoto"];
	// fetch the photos, store them to imageArray
	
	NSError * error;
	NSArray * savedPhotoObjectsArray = [self.databaseContext executeFetchRequest:request error:&error];
	
	NSMutableArray * tempImageArray = [[NSMutableArray alloc] init];
	
	for (TDMPhoto * photoObject in savedPhotoObjectsArray)
	{
    [tempImageArray addObject:photoObject];
	}
	self.imageArray = [tempImageArray copy];
	[self.collectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = YES;
	self.navigationController.navigationBarHidden = NO;
	[super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[self.imagesLoadingActivityIndicator stopAnimating];
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//actions
- (IBAction)cameraButtonTapped:(id)sender
{
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	else
	{
		[[[UIAlertView alloc] initWithTitle:@"No Camera Available"
															 message:nil
															delegate:self
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil] show];
		return;
	}
	picker.delegate = self;
	[self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)libraryButtonTapped:(UIBarButtonItem *)sender
{
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	picker.delegate = self;
	[self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage * capturedimage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	capturedimage = [self fixOrientation:capturedimage];
	
	NSData *imageData = UIImagePNGRepresentation(capturedimage);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.png",[self.imageArray count]+1]];
		
//	NSLog((@"pre writing to file"));
	if (![imageData writeToFile:imagePath atomically:NO])
	{
//    NSLog((@"Failed to cache image data to disk"));
	}
	else
	{
//    NSLog(@"the cachedImagedPath is %@",imagePath);
		TDMPhoto* photo = [self savePhotoWithPath:imagePath];
		NSMutableArray* tempImageArray = [self.imageArray mutableCopy];
		[tempImageArray  addObject:photo];
		self.imageArray = [tempImageArray copy];

	}
	
	[self.collectionView reloadData];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

//collectionView methods

-(BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

-(BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	if (action == @selector(cut:))
	{
		return YES;
	} else return NO;
}

-(void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	if (action == @selector(cut:))
	{
		int itemIndex = [indexPath indexAtPosition:1];
		TDMPhoto * photo = self.imageArray[itemIndex];
		NSMutableArray * tempImageArray = [self.imageArray mutableCopy];
		[tempImageArray removeObject:photo];
		self.imageArray = [tempImageArray copy];
		[self.databaseContext deleteObject:photo];
		[self.collectionView reloadData];
	}
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self.imagesLoadingActivityIndicator startAnimating];
	self.selectedPhoto = self.imageArray[[indexPath indexAtPosition:1]];
	[self performSegueWithIdentifier:@"Show Detail View Controller" sender:self];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
	return [self.imageArray count]; //Until there is a data model, simulate the presence of cells
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	
	// we're going to use a custom UICollectionViewCell, which will hold a head image and its label
	//
	TDMMesusHeadCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCELL_ID forIndexPath:indexPath];
	
	// set the cell's title from the data model
	cell.titleLabel.text = @"Photo";
	
	// set the cell's image from the file path in the data model
	int imageIndex = [indexPath indexAtPosition:1];
	TDMPhoto* photo = self.imageArray[imageIndex];
	cell.headImageView.image = [UIImage imageWithContentsOfFile:photo.imagePath];//[UIImage imageNamed:@"helmet.jpg"];
	
	return cell;
}

// the user tapped a collection item, load and set the image on the detail view controller
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	if ([[segue identifier] isEqualToString:@"Show Detail View Controller"])
	{
		TDMDetailViewController * detailViewController = [segue destinationViewController];
		detailViewController.photo = self.selectedPhoto;
	}
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
												layout:(UICollectionViewLayout*)collectionViewLayout
				insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (UIImage *)fixOrientation:(UIImage *) image
{
	
	// No-op if the orientation is already correct
	if (image.imageOrientation == UIImageOrientationUp) return image;
	
	// We need to calculate the proper transformation to make the image upright.
	// We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	switch (image.imageOrientation) {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, image.size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationUpMirrored:
			break;
	}
	
	switch (image.imageOrientation) {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
			
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			break;
	}
	
	// Now we draw the underlying CGImage into a new context, applying the transform
	// calculated above.
	CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
																					 CGImageGetBitsPerComponent(image.CGImage), 0,
																					 CGImageGetColorSpace(image.CGImage),
																					 CGImageGetBitmapInfo(image.CGImage));
	CGContextConcatCTM(ctx, transform);
	switch (image.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			// Grr...
			CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
			break;
			
		default:
			CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
			break;
	}
	
	// And now we just create a new UIImage from the drawing context
	CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
	CGContextRelease(ctx);
	CGImageRelease(cgimg);
	return img;
}


@end
