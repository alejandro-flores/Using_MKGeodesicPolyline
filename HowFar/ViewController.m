//
//  ViewController.m
//  HowFar
//
//  Created by Alejandro Flores on 5/6/15.
//  Copyright (c) 2015 Alex Flores. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - Touch Methods
//When the user taps anywhere in a blank space in the view, the keyboard is hidden
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //Round the corners of the clearAllButton
    _clearAllButton.layer.cornerRadius = 8;
    _clearAllButton.clipsToBounds = YES;
}

@end
