//
//  FirstViewController.m
//  HowFar
//
//  Created by Alejandro Flores on 5/1/15.
//  Copyright (c) 2015 Alex Flores. All rights reserved.
//

#import "FirstViewController.h"
#import <MapKit/MapKit.h>

@interface FirstViewController ()

- (IBAction)clearAllPins:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *distanceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *clearPinsButton;

@end

@implementation FirstViewController
MKPointAnnotation *pin;
NSMutableArray *pinsArray;
int pinCounter = 0;

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.distanceTextField.placeholder = @"0 km";
    //Default segmentedControl index is 0 for Standard MapType
    [self.mapTypeSegmentedControl setSelectedSegmentIndex:0];
    pinsArray = [[NSMutableArray alloc]init];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPress];
}

#pragma mark - Gesture Recognizer Methods
-(void)handleLongPressGesture:(UIGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged) {
        return;
    }
    else {
        //Get CGPoint for touch and convert it to lat and long to display on map
        CGPoint p = [sender locationInView:self.mapView];
        CLLocationCoordinate2D coord = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
        //Create annotation and add it to map
        pin = [[MKPointAnnotation alloc]init];
        pin.coordinate = coord;
        pin.title = [NSString stringWithFormat:@"%d", pinCounter += 1];
        [pinsArray addObject:pin];
        [_mapView addAnnotations:pinsArray];
        NSLog(@"%lu", (unsigned long)[pinsArray count]);
        [self displayDistanceBetweenPins];
    }
}

-(void)displayDistanceBetweenPins {
    if([pinsArray count] == 2) {
        CLLocation *pointA = [pinsArray firstObject];
        CLLocation *A = [[CLLocation alloc]initWithLatitude:pointA.coordinate.latitude longitude:pointA.coordinate.longitude];
        CLLocation *pointB = [pinsArray lastObject];
        CLLocation *B = [[CLLocation alloc]initWithLatitude:pointB.coordinate.latitude longitude:pointB.coordinate.longitude];
        CLLocationDistance distance = [B distanceFromLocation:A];
        _distanceTextField.text = [NSString stringWithFormat:@"%.2f km", distance / 1000];
    }
    else {
        _distanceTextField.text = nil;
    }
}

- (IBAction)clearAllPins:(UIButton *)sender {
    [_mapView removeAnnotations:pinsArray];
    [pinsArray removeAllObjects];
    pinCounter = 0;
}

#pragma mark - Map Methods
- (IBAction)changeMapType:(UISegmentedControl *)sender {
    //Get selected index position
    NSInteger index = [self.mapTypeSegmentedControl selectedSegmentIndex];
    if (index == 0) {
        self.mapView.mapType = MKMapTypeStandard;
    }
    else if (index == 1) {
        self.mapView.mapType = MKMapTypeSatellite;
    }
    else {
        self.mapView.mapType = MKMapTypeHybrid;
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
