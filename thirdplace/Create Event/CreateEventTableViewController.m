//
// Created by David Lawson on 15/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "CreateEventTableViewController.h"
#import "FriendsCollectionViewController.h"
#import "GCPlaceholderTextView.h"
#import "TextFieldToolbar.h"
#import "Event.h"
#import "RootEntity.h"

@interface CreateEventTableViewController () <CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) FriendsCollectionViewController *friendsCVC;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *descriptionTextView;

@property (nonatomic) BOOL showingDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation CreateEventTableViewController

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1)
    {
        return self.showingDatePicker ? 261 : 45;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)setDateLabel:(UILabel *)dateLabel
{
    _dateLabel = dateLabel;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE d MMMM, h:mm a";
    self.dateLabel.text = [formatter stringFromDate:[NSDate date]];
}

- (IBAction)datePickerValueChanged:(UIDatePicker *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE d MMMM, h:mm a";
    self.dateLabel.text = [formatter stringFromDate:sender.date];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1)
    {
        self.showingDatePicker = !self.showingDatePicker;
        [tableView beginUpdates];
        [tableView endUpdates];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FriendsCollectionViewController"])
    {
        self.friendsCVC = segue.destinationViewController;
        self.friendsCVC.friends = self.friends;
    }
}

- (void)setDescriptionTextView:(GCPlaceholderTextView *)descriptionTextView
{
    _descriptionTextView = descriptionTextView;
    descriptionTextView.placeholder = @"Message";
    descriptionTextView.inputAccessoryView = [[TextFieldToolbar alloc] initWithTextFields:@[descriptionTextView]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)pressedSend:(id)sender
{
    Event *event = [Event MR_createEntity];
    event.rootEntity = [RootEntity rootEntity];
    event.date = self.datePicker.date;
    event.friends = [[NSSet alloc] initWithArray:self.friends];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressedCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
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