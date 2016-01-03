//
//  MapViewController.m
//  Thirdplace
//
//  Created by Yang Yu on 9/04/13.
//
//

#import "MapViewController.h"
#import "MapAnnotation.h"
#import <AddressBookUI/AddressBookUI.h>
#import "thirdplace-Swift.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize address;

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
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    UIBarButtonItem* switchMapItem = [[UIBarButtonItem alloc] initWithTitle:@"Hybrid View" style:UIBarButtonItemStylePlain target:self action:@selector(switchMap:)];
    self.navigationItem.rightBarButtonItem =  switchMapItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self forwardGeoLocation];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self setMapView:nil];
}


-(void)forwardGeoLocation
{
    // Do any additional setup after loading the view from its nib.
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    // don't use a hint region
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (error)
        {
            [ErrorHandler showPopupMessage:self.view text:@"Location can't be translated into coordinates"];
            return;
        }
        //put the coordinate on map
        CLPlacemark *placemark = [placemarks lastObject];
        [self displayPinOnMap:placemark];
    }];
}

-(void)displayPinOnMap:(CLPlacemark*)placemark
{
    CLLocationDegrees latitude = placemark.location.coordinate.latitude;
    CLLocationDegrees longitude = placemark.location.coordinate.longitude;
    CLLocationCoordinate2D cord;
    cord.latitude = latitude;
    cord.longitude = longitude;
    MapAnnotation *a2 = [[MapAnnotation alloc] init];
    a2.coordinate = cord;
    a2.currentTitle = [placemark.addressDictionary objectForKey:@"Street"];
    a2.subTitle = [NSString stringWithFormat:@"%@, %@, %@",[placemark.addressDictionary objectForKey:@"City"],[placemark.addressDictionary objectForKey:@"State"],[placemark.addressDictionary objectForKey:@"ZIP"]];;
    [self.mapView addAnnotation:a2];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(cord, 1200, 1200);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    [self.mapView selectAnnotation:a2 animated:NO];
}

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation
{	
	if([annotation isKindOfClass:[MapAnnotation class]])
	{
		static NSString* pinAnnotationIdentifier = @"userlocationPinAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:pinAnnotationIdentifier];
        if (pinView == nil)
        {
            // if an existing pin view was not available, create one
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinAnnotationIdentifier];
        }
        else
        {
            pinView.annotation = annotation;
        }
		pinView.pinColor = MKPinAnnotationColorPurple;
		pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
		return pinView;
	}
    return nil;
}

-(void)switchMap:(id)button
{
    UIBarButtonItem* b = button;
    if(self.mapView.mapType == MKMapTypeHybrid)
    {
        [b setTitle:@"Hybrid View"];
        self.mapView.mapType = MKMapTypeStandard;
    }
    else
    {
        [b setTitle:@"Standard View"];
        self.mapView.mapType = MKMapTypeHybrid;
    }
}

@end
