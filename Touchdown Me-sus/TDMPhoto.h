//
//  TDMPhoto.h
//  Touchdown Me-sus
//
//  Created by Sean Fitzgerald on 6/12/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TDMPhoto : NSManagedObject

@property (nonatomic) float imageX;
@property (nonatomic) float imageY;
@property (nonatomic) float libraryX;
@property (nonatomic) float libraryY;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic) float imageWidth;
@property (nonatomic) float imageHeight;
@property (nonatomic) float libraryWidth;
@property (nonatomic) float libraryHeight;

@end
