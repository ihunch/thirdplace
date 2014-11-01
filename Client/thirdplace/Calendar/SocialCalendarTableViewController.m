//
// Created by David Lawson on 15/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SocialCalendarTableViewController.h"
#import "FriendsCollectionViewController.h"
#import "Event.h"
#import "PlaceCell.h"

@interface SocialCalendarTableViewController ()

@property (nonatomic, strong) NSMutableArray *events;

@end

@implementation SocialCalendarTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.events = [[Event MR_findAllSortedBy:@"date" ascending:YES] mutableCopy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = self.events[(NSUInteger)indexPath.row];

    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    cell.friendsCVC.friends = event.friends.allObjects;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE d MMMM, h:mm a";
    cell.dateLabel.text = [formatter stringFromDate:event.date];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 295;
}

- (IBAction)pressedMapButton:(id)sender
{
    if ([[UIApplication sharedApplication] canOpenURL:
            [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
                [NSURL URLWithString:@"comgooglemaps://?q=Brother+Baba+Budan&center=-37.813552,144.962092&zoom=14&views=traffic"]];
    } else {
        // Check for iOS 6
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            // Create an MKMapItem to pass to the Maps app
            CLLocationCoordinate2D coordinate =
                    CLLocationCoordinate2DMake(-37.813552, 144.962092);
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                           addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:@"Brother Baba Budan"];
            // Pass the map item to the Maps app
            [mapItem openInMapsWithLaunchOptions:nil];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Event *event = self.events[(NSUInteger)indexPath.row];
        [event MR_deleteEntity];
        [event.managedObjectContext MR_saveToPersistentStoreAndWait];

        [self.events removeObjectAtIndex:(NSUInteger)indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


@end