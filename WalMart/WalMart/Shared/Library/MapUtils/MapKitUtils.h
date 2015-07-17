//
//  MapKitUtils.h
//  SAMS
//
//  Created by Gerardo Ramirez on 9/15/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapKitUtils : NSObject

+ (void) zoomMapViewToFitAnnotations:(MKMapView *)mapView
                            animated:(BOOL)animated;

@end
