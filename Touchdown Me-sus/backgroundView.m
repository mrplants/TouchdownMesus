//
//  backgroundView.m
//  Touchdown Me-sus
//
//  Created by Sean Fitzgerald on 5/27/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "backgroundView.h"

@implementation backgroundView

- (void)drawRect:(CGRect)rect
{
	// draw a rounded rect bezier path filled with blue
	CGContextRef aRef = UIGraphicsGetCurrentContext();
	CGContextSaveGState(aRef);
	UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:18.0f];
	[bezierPath setLineWidth:5.0f];
	[[UIColor blackColor] setStroke];
	
	UIColor *fillColor = [UIColor colorWithRed:0 green:43.0/255.0	blue:92.0/255.0 alpha:1];
	[fillColor setFill];
	
//	[bezierPath stroke];
	[bezierPath fill];
	CGContextRestoreGState(aRef);
}

@end
