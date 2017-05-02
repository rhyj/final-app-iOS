//
//  MapViewController.m
//  bookworm
//
//  Created by Yash Jalan on 4/16/17.
//  Copyright © 2017 nyu.edu. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Place.h"
@import Firebase;

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (copy, nonatomic) NSArray *places;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.ref = [[FIRDatabase database] reference];
    
    [[self.ref child:@"books"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //NSLog(@"snapshot = %@",snapshot.value);
        NSDictionary *dict = snapshot.value;
        NSArray *keys = [dict allKeys];
        //NSMutableArray *pl = [[NSMutableArray alloc] init];
        
        for (NSString *key in keys) {
            NSDictionary *object = [dict objectForKey: key];
            if (object[@"lattitude"] && object[@"longitude"] && ![object[@"longitude"] isEqualToString:@""] && ![object[@"lattitude"] isEqualToString:@""]) {
                CLLocationCoordinate2D center;
                center.latitude = [object[@"lattitude"] doubleValue];
                center.longitude = [object[@"longitude"] doubleValue];
                if (CLLocationCoordinate2DIsValid(center)) {
                
                    Place *p = [[Place alloc] init];
                    p.coordinate = center;
                    p.title = key;
                    if (object[@"user"]) {
                        p.subtitle = object[@"user"];
                    } else {
                        p.subtitle = object[@"author"];
                    }
                    //[pl addObject:p];
                    [self.mapView addAnnotation:p];
                }
            }
        }
        
        //self.places = [pl copy];
        
    }];

    
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Authorization status changed to %d", status);
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            self.mapView.showsUserLocation = YES;
            break;
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            [self.locationManager stopUpdatingLocation];
            self.mapView.showsUserLocation = NO;
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    
    if (self.previousPoint == nil) {

//        Place *start = [[Place alloc] init];
//        start.coordinate = newLocation.coordinate;
//        start.title = @"Start Point";
//        start.subtitle = @"This is where we started!";
//        [self.mapView addAnnotation:start];
        
        MKCoordinateRegion region;
        region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate,
                                                    10000, 10000);
        [self.mapView setRegion:region animated:YES];
    }
    
    self.previousPoint = newLocation;
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSString *errorType = error.code == kCLErrorDenied ? @"Access Denied"
    : [NSString stringWithFormat:@"Error %ld", (long)error.code, nil];
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"Location Manager Error"
                                        message:errorType
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
