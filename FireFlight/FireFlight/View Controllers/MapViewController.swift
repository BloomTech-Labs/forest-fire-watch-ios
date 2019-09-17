//
//  MapViewController.swift
//  FireFlight
//
//  Created by Kobe McKee on 8/21/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import UIKit
import Mapbox
import Floaty
import SideMenu

class MapViewController: UIViewController, MGLMapViewDelegate {

    
    var apiQueue = DispatchQueue(label: "apiQueue")
    var mapView: MGLMapView!
    var apiController: APIController?
    var addresses: [UserAddress]? {
        didSet {
            //print("Addresses: \(addresses)")
            mapAddresses()
             getFires()
        }
    }
    var fires: [Fire]? {
        didSet {
            //print("Fires: \(fires?.count)")
            mapFires()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserAddresses()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getUserAddresses()
        setupMap()
        setupFloaty()
        setupSideMenu()
    }
    
    
    func setupSideMenu() {
        let hamburgerButton = UIButton(frame: CGRect(x: view.frame.width / 17, y: view.frame.height / 20, width: 40, height: 40))
        let hamburgerImage = UIImage(named: "hamburgerMenu")
        let tintedHamburger = hamburgerImage?.withRenderingMode(.alwaysTemplate)
        hamburgerButton.setImage(tintedHamburger, for: .normal)
        hamburgerButton.tintColor = AppearanceHelper.ming
        
        hamburgerButton.addTarget(self, action: #selector(sideMenuSegue), for: .touchUpInside)
        self.view.addSubview(hamburgerButton)
        
    }
    
    
    
    func setupMap() {
        //let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //mapView.setCenter(CLLocationCoordinate2D(latitude: 37, longitude: 122), zoomLevel: 12, animated: true)
        view.addSubview(mapView)
        mapView.delegate = self
        
        //mapView.showsUserLocation = true
        //mapView.setUserTrackingMode(.none, animated: true, completionHandler: nil)
    }
    
    
    func setupFloaty() {
        let houseIcon = UIImage(named: "HouseOutline")
        let floaty = Floaty()
        floaty.addItem("Add Address", icon: houseIcon) { (item) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "AddAddressSegue", sender: self)
            }
        }
        floaty.paddingY = 42
        floaty.buttonColor = AppearanceHelper.ming
        floaty.plusColor = AppearanceHelper.begonia
        
        
        self.view.addSubview(floaty)
    }
    
    
    
    @objc func sideMenuSegue(sender: UIButton!) {
        self.performSegue(withIdentifier: "ShowSideMenu", sender: self)
    }
    
    
    func mapDefaultAddress() {
        self.addresses = [UserAddress(id: nil, latitude: 44.4, longitude: -110.5, address: "Yellowstone National Park", label: "Yellowstone National Park", radius: 500)]
        DispatchQueue.main.async {
            let coords = CLLocationCoordinate2D(latitude: 44.4, longitude: -110.5)
            self.mapView.setCenter(coords, zoomLevel: 3, animated: true)
        }
    }
    
    
    
    // MARK: - API Calls
    func getUserAddresses() {
        let getAddressesItem = DispatchWorkItem {
            self.apiController?.getAddresses(completion: { (addresses, error) in
                if let error = error {
                    NSLog("Error getting user addresses: \(error), mapping default address")
                    self.mapDefaultAddress()
                    return
                }
                
                if let addresses = addresses {
                    if addresses.isEmpty {
                        self.mapDefaultAddress()
                        return
                    }
                }
                
                self.addresses = addresses
                DispatchQueue.main.async {
                    guard let address = self.addresses?.last else { return }
                    let coords = CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude)
                    self.mapView.setCenter(coords, zoomLevel: 3, animated: true)
                }
                
            })
        }
        
        apiQueue.sync(execute: getAddressesItem)
        
    }
    
    
    
    func getFires() {
        var location: CLLocation?
        var radius: Double?
        var totalFires: [Fire] = []
        guard let addresses = addresses else { return }
    
        let fireGroup = DispatchGroup()
        
        for address in addresses {
            location = CLLocation(latitude: address.latitude, longitude: address.longitude)
            radius = address.radius
            
            fireGroup.enter()
            self.apiController?.checkForFires(location: location!, distance: radius!, completion: { (firelocations, error) in
                if let error = error {
                    NSLog("Error fetching fires: \(error)")
                    return
                }
                
                if let fires = firelocations {
                    totalFires.append(contentsOf: fires)
                }
                fireGroup.leave()
            })

        }
        fireGroup.notify(queue: apiQueue) { self.fires = totalFires }
 
    }
    
    
    
    
    
    // MARK: - Mapping Functions
    func mapAddresses() {
        
        guard let addresses = addresses else { return }
        
        DispatchQueue.main.async {
            
            for address in addresses {
                let marker = CustomPointAnnotation()
                marker.coordinate = CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude)
                marker.title = address.label
                marker.subtitle = address.address
                marker.useFireImage = false
                
                self.polygonCircleForCoordinate(coordinate: marker.coordinate, withMeterRadius: address.radius * 1609.34)//Converting from miles to meters
                
                self.mapView.addAnnotation(marker)
            }
        }
    }
    
    
    func mapFires() {
        //print("FIRES Nearby: \(fires?.count)")
        
        guard let fires = fires else { return }
        
        DispatchQueue.main.async {
            
            for fire in fires {
                let fireMarker = CustomPointAnnotation()
                fireMarker.coordinate = CLLocationCoordinate2D(latitude: fire.latitude, longitude: fire.longitude)
                fireMarker.useFireImage = true
                self.mapView.addAnnotation(fireMarker)
                
            }
            
        }
        
    }
    
    
    
    func polygonCircleForCoordinate(coordinate: CLLocationCoordinate2D, withMeterRadius: Double) {
        let degreesBetweenPoints = 8.0
        //45 sides
        let numberOfPoints = floor(360.0 / degreesBetweenPoints)
        let distRadians: Double = withMeterRadius / 6371000.0
        // earth radius in meters
        let centerLatRadians: Double = coordinate.latitude * Double.pi / 180
        let centerLonRadians: Double = coordinate.longitude * Double.pi / 180
        var coordinates = [CLLocationCoordinate2D]()
        //array to hold all the points
        for index in 0 ..< Int(numberOfPoints) {
            let degrees: Double = Double(index) * Double(degreesBetweenPoints)
            let degreeRadians: Double = degrees * Double.pi / 180
            let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
            let pointLonRadians: Double = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
            let pointLat: Double = pointLatRadians * 180 / Double.pi
            let pointLon: Double = pointLonRadians * 180 / Double.pi
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
            
            coordinates.append(point)
        }
        let polygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
        
        self.mapView.addAnnotation(polygon)
    }
    
    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat { return 0.10 }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor { return .red }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor { return .white }
    
    // MARK: - MapBox Functions
    
    //Allow callout view to appear when annotation is tapped
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if let castAnnotation = annotation as? CustomPointAnnotation {
            if (castAnnotation.useFireImage) {
                return nil
            }
        }
        
        // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
        let reuseIdentifier = "reusableDotView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            
            
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 4.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView!.backgroundColor = AppearanceHelper.ming
        }
        
        
        return annotationView
    }
    
    
    
    
//     This delegate method is where you tell the map to load an image for a specific annotation based on the userFireImage property of the custom subclass.
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {

        if let castAnnotation = annotation as? CustomPointAnnotation {
            if (!castAnnotation.useFireImage) {
                return nil
            }
        }

        // For better performance, always try to reuse existing annotations.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "fire")

        // If there is no reusable annotation image available, initialize a new one.
        if(annotationImage == nil) {

            let image = UIImage(named: "flameIcon")!
            let size = CGSize(width: 40, height: 40)
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

            annotationImage = MGLAnnotationImage(image: resizedImage, reuseIdentifier: "fire")
        }

        return annotationImage
    }
    
    
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAddressSegue" {
            guard let destinationVC = segue.destination as? NewAddressViewController else { return }
            destinationVC.apiController = apiController
        }
        
        if segue.identifier == "ShowSideMenu" {
            guard let destinationNavC = segue.destination as? SideMenuNavigationController,
                let destinationVC = destinationNavC.topViewController as? SideMenuViewController else { return }
            
//            let menuManager = SideMenuManager()
//            menuManager.menuFadeStatusBar = false
//            destinationNavC.sideMenuManager = menuManager
    
            destinationNavC.statusBarEndAlpha = 0
            destinationVC.apiController = apiController
        }
        
        
        
    }


}
