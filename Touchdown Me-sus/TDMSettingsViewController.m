//
//  TDMSettingsViewController.m
//  Touchdown Me-sus
//
//  Created by Sean Fitzgerald on 5/27/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "TDMSettingsViewController.h"

@interface TDMSettingsViewController ()

@property (nonatomic, strong) NSUserDefaults* defaults;

@end

@implementation TDMSettingsViewController

- (IBAction)cancelButtonTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveButtonTapped:(id)sender
{
	[self saveUserDefaults];
	[self dismissViewControllerAnimated:YES completion:NULL];
}

-(void) saveUserDefaults
{
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
