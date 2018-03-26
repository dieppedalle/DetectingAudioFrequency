//
//  MapViewController.swift
//  Audio Beacons
//
//  Created by Gauthier Dieppedalle on 3/26/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class MapViewController: UIViewController, HomeModelProtocol {
    var feedItems: NSArray = NSArray()
    func itemsDownloaded(items: NSArray) {
        feedItems = items
        
        for item in feedItems {
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: Double(((item as! LocationModel).latitude)!)!, longitude:Double(((item as! LocationModel).longitude)!)!)
            annotation.coordinate = centerCoordinate
            annotation.title = (item as! LocationModel).name
            mapView.addAnnotation(annotation)
        }
        
        print(Float(((feedItems[0] as! LocationModel).longitude)!)!)
    }
    

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapView.showsUserLocation = true
        //locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
