//
//  MapKitUtils.m
//  SAMS
//
//  Created by Gerardo Ramirez on 9/15/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

#import "MapKitUtils.h"

@implementation MapKitUtils

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.50
#define MAX_DEGREES_ARC 360

+ (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView
                           animated:(BOOL)animated {
    NSArray *annotations = mapView.annotations;
    if (annotations.count == 0) {
        return; //bail if no annotations
    }
    
    //convert NSArray of id <MKAnnotation>
    //into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    
    // C array of MKMapPoint struct
    // load points C array by converting coordinates to points
    MKMapPoint points[annotations.count];
    for( int i = 0; i < annotations.count; i++ ) {
        id annotation = [annotations objectAtIndex:i];
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)annotation coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:annotations.count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) {
        region.span.latitudeDelta  = MAX_DEGREES_ARC;
    }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ) {
        region.span.longitudeDelta = MAX_DEGREES_ARC;
    }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) {
        region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) {
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in
    //instead of max zoom-out
    if(annotations.count == 1 ) {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    
    [mapView setRegion:region animated:animated];
}

@end
