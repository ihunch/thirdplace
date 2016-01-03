//
//  MapAnnotation.h
//  iPhoneXMPP
//
//  Created by Yang Yu on 12/14/10.
//  Copyright 2010 WN China. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject<MKAnnotation> 
{
    NSString *currentTitle;
    NSString *subTitle;
    CLLocationCoordinate2D coordinate;
	NSString* locationAttribute;
	NSString* annotationID;
}

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString* locationAttribute;
@property (nonatomic, strong) NSString* annotationID;

@end
