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
@property (strong,nonatomic) NSString* address;

- (IBAction)Back:(id)sender;
- (IBAction)switchmap:(id)sender;

@end
