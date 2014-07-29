//
// Created by David Lawson on 4/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "CreateEventViewController.h"
#import "FriendsCollectionViewController.h"

@interface CreateEventViewController () <UITextFieldDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) FriendsCollectionViewController *friendsCVC;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@end

@implementation CreateEventViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FriendsCollectionViewController"])
    {
        self.friendsCVC = segue.destinationViewController;
        self.friendsCVC.friends = self.friends;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)tappedLocationButton:(UIButton *)locationButton
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];

    locationButton.hidden = YES;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = [self.view convertPoint:locationButton.center fromView:locationButton.superview];
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.locationButton.hidden = NO;
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;

    [manager stopUpdatingLocation];

    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark* placemark in placemarks) {
            self.locationTextField.text = [placemark locality];
            break;
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Location Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
}


@end