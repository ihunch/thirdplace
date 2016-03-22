//
//  MapViewController.h
//  Thirdplace
//
//  Created by Yang Yu on 9/04/13.
//
//

#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) NSString* street;
@property (strong,nonatomic) NSString* city;
@property (strong,nonatomic) NSString* postcode;
@property (strong,nonatomic) NSString* state;

- (IBAction)Back:(id)sender;
- (IBAction)switchmap:(id)sender;

@end
