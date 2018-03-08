//
//  File.swift
//  Photo Map
//
//  Created by Samuel on 3/7/18.
//  Copyright © 2018 Timothy Lee. All rights reserved.
//

import MapKit

import Foundation

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}
