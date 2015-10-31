//
// Created by David Lawson on 17/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "ProfileViewController.h"
#import "FriendView.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet FriendView *friendView;
@property (weak, nonatomic) IBOutlet UILabel *travelDistanceLabel;
@property (weak, nonatomic) IBOutlet UISlider *travelDistanceSlider;
@property (weak, nonatomic) IBOutlet UISwitch *discoverNewPlacesSwitch;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    Friend *me = [RootEntity rEntity].me;
//    self.friendView.friend = me;
//    
//    self.travelDistanceSlider.value = me.travelDistanceValue;
//    self.travelDistanceLabel.text = [NSString stringWithFormat:@"%.2fkm", me.travelDistanceValue];
//    self.discoverNewPlacesSwitch.on = me.discoverNewPlacesValue;
}

- (IBAction)changedTravelSlider:(UISlider *)slider
{
    self.travelDistanceLabel.text = [NSString stringWithFormat:@"%.2fkm", slider.value];
}

- (IBAction)toggleDiscoverNewPlaces:(UISwitch *)_switch
{
//    [RootEntity rEntity].me.discoverNewPlacesValue = _switch.on;
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
}

@end