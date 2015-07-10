//
//  FirstViewController.m
//  HowFar
//
//  Created by Alejandro Flores on 5/1/15.
//  Copyright (c) 2015 Alex Flores. All rights reserved.
//

#import "FirstViewController.h"
#import <MapKit/MapKit.h>
#define METERS_TO_MILES 0.000621371

@interface FirstViewController () <MKMapViewDelegate>
- (IBAction)clearAllPins:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *clearPinsButton;
@property (weak, nonatomic) IBOutlet UITextField *distanceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;
@property (strong, nonatomic) MKGeodesicPolyline *geodesicPolyLine;
@property (strong, nonatomic) NSMutableArray *pinsArray;
@property (strong, nonatomic) MKPointAnnotation *pin;
- (IBAction)changeUnits:(UISegmentedControl *)sender;
@end

@implementation FirstViewController
int pinCounter = 0;
int tapCounter = 0;

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.pinsArray = [[NSMutableArray alloc]init];
    [self setPlaceholderUnits];
    [self.mapTypeSegmentedControl setSelectedSegmentIndex:0]; //Default index is 0 for Standard MapType
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector(handleLongPressGesture:)];
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
        self.pin = [[MKPointAnnotation alloc]init];
        self.pin.coordinate = coord;
        self.pin.title = [NSString stringWithFormat:@"Pin #%d", pinCounter += 1];
        [self.pinsArray addObject:self.pin];
        [self.mapView addAnnotations:self.pinsArray];
        [self displayDistanceBetweenPins];
        [self changeUnits:nil];
    }
}

#pragma mark - Miscellaneous
-(CGFloat)displayDistanceBetweenPins {
    CGFloat calculatedDistance = 0;
    if([self.pinsArray count] == 2) {
        CLLocation *pointA = [self.pinsArray firstObject];
        CLLocation *A = [[CLLocation alloc]initWithLatitude:pointA.coordinate.latitude longitude:pointA.coordinate.longitude];
        CLLocation *pointB = [self.pinsArray lastObject];
        CLLocation *B = [[CLLocation alloc]initWithLatitude:pointB.coordinate.latitude longitude:pointB.coordinate.longitude];
        CLLocationDistance distance = [B distanceFromLocation:A];
        calculatedDistance = distance;
        //Draws a MKGeodesicPolyline between the two points.
        CLLocationCoordinate2D coords[2] = {A.coordinate, B.coordinate};
        self.geodesicPolyLine = [MKGeodesicPolyline polylineWithCoordinates:coords count:2];
        [self.mapView addOverlay:self.geodesicPolyLine];
    }
    else {
        self.distanceTextField.text = nil;
        //TODO: Don't allow creating a third pin.
    }
    return calculatedDistance;
}

-(void)displayMetricDistance {
    CGFloat distance = [self displayDistanceBetweenPins];
    double metricDistance = distance / 1000;
    self.distanceTextField.text = [NSString stringWithFormat:@"%.2f km", metricDistance];
}

-(void)displayImperialDistance {
    CGFloat distance = [self displayDistanceBetweenPins];
    double imperialDistance = distance * METERS_TO_MILES;
    self.distanceTextField.text = [NSString stringWithFormat:@"%.2f mi", imperialDistance];
}

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

- (IBAction)changeUnits:(UISegmentedControl *)sender {
    NSInteger index = [self.unitsSegmentedControl selectedSegmentIndex];
    if(index == 0) {
        [self displayMetricDistance];
    }
    else {
        [self displayImperialDistance];
    }
}

- (IBAction)clearAllPins:(UIButton *)sender {
    [self.mapView removeAnnotations:self.pinsArray];
    [self.pinsArray removeAllObjects];
    if ([self.mapView.overlays count] > 0) {
        [self.mapView removeOverlays:[self.mapView overlays]];
    }
    self.distanceTextField.text = nil;
    pinCounter = 0;
    [self setPlaceholderUnits];
}

-(void)setPlaceholderUnits {
    NSInteger index = [self.unitsSegmentedControl selectedSegmentIndex];
    if(index == 0) {
        self.distanceTextField.placeholder = @"0.0 km";
    }
    else {
        self.distanceTextField.placeholder = @"0.0 mi";
    }
}

#pragma mark - MKMapViewDelegate
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if (![overlay isKindOfClass:[MKPolyline class]]) {
        return nil;
    }
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithPolyline:(MKPolyline *)overlay];
    renderer.lineWidth = 5.0f;
    renderer.strokeColor = [UIColor redColor];
    renderer.alpha = 0.5;
    
    return renderer;
}
@end