//
//  MapViewController.m
//  HowFar
//
//  Created by Alex on 12/30/15.
//  Copyright © 2015 Alex Flores. All rights reserved.
//
#import "MapViewController.h"
@import MapKit;
#define METERS_TO_MILES 0.000621371

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *distanceTextField;
@property (strong, nonatomic) MKGeodesicPolyline *geodesicPolyLine;
@property (weak, nonatomic) IBOutlet UIButton *clearPinsButton;
@property (strong, nonatomic) NSMutableArray *pinsArray;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *pin;
@property (nonatomic) NSInteger pinCounter;
@property (nonatomic) NSInteger tapCounter;

@end

@implementation MapViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _pinCounter = 0;
    _tapCounter = 0;
    _mapView.delegate = self;
    _pinsArray = [[NSMutableArray alloc]init];
    [self setPlaceholderUnits];
    [_mapTypeSegmentedControl setSelectedSegmentIndex:0]; //Default index is 0 for Standard MapType
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector(handleLongPressGesture:)];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearMap:)];
    tapGR.numberOfTapsRequired = 1;
    [_mapView addGestureRecognizer:longPress];
    [_mapView addGestureRecognizer:tapGR];
    _clearPinsButton.layer.cornerRadius = 8;
    _clearPinsButton.clipsToBounds = YES;
}

#pragma mark - Gesture Recognizer Methods
/**
 * Allocates and drops a MKPointAnnotation on the map.
 */
-(void)handleLongPressGesture:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged)
        return;
    else {
        //Get CGPoint for touch and convert it to a latitude and longitude to display on the map.
        CGPoint point = [sender locationInView:_mapView];
        CLLocationCoordinate2D coord = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        //Create annotation and add it to map
        _pin = [[MKPointAnnotation alloc]init];
        _pin.coordinate = coord;
        _pin.title = [NSString stringWithFormat:@"Pin #%ld", _pinCounter += 1];
        [_pinsArray addObject:_pin];
        [_mapView addAnnotations:_pinsArray];
        [self displayDistanceBetweenPins];
        [self changeUnits:nil];
    }
}

/**
 * Clears all pins from the map using a Tap Gesture recognizer with one tap
 * required to set off the action.
 */
- (void)clearMap:(UIGestureRecognizer *)sender {
    [self clearAllPins:nil];
}

#pragma mark - Distance calculation and Manipulation Methods
/**
 * Calculates the distance between the two pins on the map.
 * in the units chosen by the user.
 */
-(CGFloat)displayDistanceBetweenPins {
    CGFloat calculatedDistance = 0;
    if([_pinsArray count] <= 2) {
        CLLocation *pointA = [_pinsArray firstObject];
        CLLocation *A = [[CLLocation alloc]initWithLatitude:pointA.coordinate.latitude longitude:pointA.coordinate.longitude];
        CLLocation *pointB = [_pinsArray lastObject];
        CLLocation *B = [[CLLocation alloc]initWithLatitude:pointB.coordinate.latitude longitude:pointB.coordinate.longitude];
        CLLocationDistance distance = [B distanceFromLocation:A];
        calculatedDistance = distance;
        //Draws a MKGeodesicPolyline between the two points.
        CLLocationCoordinate2D coords[2] = {A.coordinate, B.coordinate};
        _geodesicPolyLine = [MKGeodesicPolyline polylineWithCoordinates:coords count:2];
        [_mapView addOverlay:_geodesicPolyLine];
    }
    else
        [self clearAllPins:nil];
    
    return calculatedDistance;
}

/**
 * Removes all pins from the pinsArray and resets the Labels on the UI.
 */
- (IBAction)clearAllPins:(UIButton *)sender {
    [_mapView removeAnnotations:_pinsArray];
    [_pinsArray removeAllObjects];
    if ([_mapView.overlays count] > 0) {
        [_mapView removeOverlays:[_mapView overlays]];
    }
    _distanceTextField.text = nil;
    _pinCounter = 0;
    [self setPlaceholderUnits];
}

-(void)displayMetricDistance {
    CGFloat distance = [self displayDistanceBetweenPins];
    double metricDistance = distance / 1000;
    _distanceTextField.text = [NSString stringWithFormat:@"%.2f km", metricDistance];
}

-(void)displayImperialDistance {
    CGFloat distance = [self displayDistanceBetweenPins];
    double imperialDistance = distance * METERS_TO_MILES;
    _distanceTextField.text = [NSString stringWithFormat:@"%.2f mi", imperialDistance];
}

- (IBAction)changeMapType:(UISegmentedControl *)sender {
    //Get selected index position.
    NSInteger index = [_mapTypeSegmentedControl selectedSegmentIndex];
    switch (index) {
        case 0:
            _mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            _mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

- (IBAction)changeUnits:(UISegmentedControl *)sender {
    NSInteger index = [_unitsSegmentedControl selectedSegmentIndex];
    if (index == 0)
        [self displayMetricDistance];
    else
        [self displayImperialDistance];
}

-(void)setPlaceholderUnits {
    NSInteger index = [_unitsSegmentedControl selectedSegmentIndex];
    if (index == 0)
        _distanceTextField.placeholder = @"0.0 km";
    else
        _distanceTextField.placeholder = @"0.0 mi";
}

#pragma mark - MKMapViewDelegate
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if (![overlay isKindOfClass:[MKPolyline class]])
        return nil;
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithPolyline:(MKPolyline *)overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 2.0f;
    renderer.alpha = 0.5;
    
    return renderer;
}
@end
