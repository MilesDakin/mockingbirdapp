//
//  ViewController.swift
//  MapTest
//
//  Created by Miles Dakin on 3/29/16.
//  Copyright © 2016 Miles. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MessageUI
import CoreData


class ViewController: UIViewController, UITextFieldDelegate{

    let locationManager = CLLocationManager()
    var birdlat = Double()
    var birdlong = Double()
    var bird = [NSManagedObject]()
    var count = 0
    var sighting = "Bird"
    var singing = 0
    var behavior = 0
    var behaviorstring = ""
    var singingstring = ""
    @IBOutlet weak var singingswitch: UISwitch!

    @IBOutlet weak var behaviorswitch: UISwitch!
    @IBOutlet weak var addInfo: UITextField!
   

    @IBOutlet weak var SightingControl: UISegmentedControl!
   
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        self.navigationItem.title = "Bird Map"
        button.layer.cornerRadius = 5
        //used to dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self,action: Selector("dismissKeyboard")))
        addInfo.delegate = self
    }
    
    //functions that dismiss keyboard
    func dismissKeyboard(){
        addInfo.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField)-> Bool{
        addInfo.resignFirstResponder()
        return true
    }
    @IBAction func SightingAction(_ sender: AnyObject) {
        if SightingControl.selectedSegmentIndex == 0 {
            sighting = "Bird"
       
        }
        if SightingControl.selectedSegmentIndex == 1 {
            sighting = "Nest"
            singing = 0
            singingstring = ""
            behavior = 0
            behaviorstring = ""
        }
            
    }
 
    @IBAction func singingswitchAction(_ sender: AnyObject) {
        if singingswitch.isOn {
            singing = 0
            singingstring = ""
            singingswitch.setOn(false, animated:true)
        } else {
            singing = 1
            singingstring = "Singing"

            singingswitch.setOn(true, animated:true)
        }
    }
    
    @IBAction func behaviorswitchAction(_ sender: AnyObject) {
        if behaviorswitch.isOn {
            behavior = 0
            behaviorstring = ""
            behaviorswitch.setOn(false, animated:true)
        } else {
            behavior = 1
            behaviorstring = "Aggressive"
            behaviorswitch.setOn(true, animated:true)
        }
    }
    
    

    
    //Function attached to submit button that stores data and creates annotation pin
@IBAction func dropPin(){
    let annotation = MKPointAnnotation()
    count += 1

    var todaysDate:NSDate = NSDate()
    var dateFormatter:DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
    var DateInFormat:String = dateFormatter.string(from: todaysDate as Date)

     if sighting == "Nest"{
        singing = 0
        singingstring = ""
        behavior = 0
        behaviorstring = ""
    }
    annotation.coordinate = CLLocationCoordinate2D(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude)
  
    annotation.subtitle = DateInFormat



    annotation.title = behaviorstring + " " + singingstring + " " + sighting
    self.mapView.addAnnotation(annotation)
    birdlat = self.mapView.userLocation.coordinate.latitude as Double
    birdlong = self.mapView.userLocation.coordinate.longitude as Double

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity =  NSEntityDescription.entity(forEntityName: "Mocking",in:managedContext)

    let birdz = NSManagedObject(entity: entity!,insertInto: managedContext)
    let infoz = addInfo
    birdz.setValue(birdlat, forKey: "lat")
    birdz.setValue(birdlong, forKey: "long")
    birdz.setValue(DateInFormat, forKey: "date")
    birdz.setValue(count, forKey: "id")
    birdz.setValue(sighting, forKey: "sighting")
    birdz.setValue(behavior, forKey: "behavior")
    birdz.setValue(singing, forKey: "singing")
    birdz.setValue(infoz?.text, forKey: "info")
    print("INFO")
    print(infoz?.text)
    
    var request = URLRequest(url: URL(string: "http://localhost:3000/birds")!)
    request.httpMethod = "POST"
    let postString = "typez=\(sighting)&lat=\(birdlat)&long=\(birdlong)&singing=\(singing)&aggressive=\(behavior)&notes=\(infoz!.text!)"
    request.httpBody = postString.data(using: .utf8)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            // check for fundamental networking error
            print("error=\(error)")
            return
        }
        
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            // check for http errors
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
        }
        
        let responseString = String(data: data, encoding: .utf8)
        print("responseString = \(responseString)")
    }
    task.resume()
 
   
    
    
    }
    
    //Loading previous pin funtions
    
    func fetchresults() -> [NSManagedObject]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var listItems = [NSManagedObject]()
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mocking")
        do {
            let fetchedbirds = try managedContext.fetch(fetchRequest)
            listItems = fetchedbirds as! [NSManagedObject]
          
        } catch {
            fatalError("Failed to fetch data: \(error)")
        }
        return listItems 
    }
    
    func Pin(x: [NSManagedObject]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let results = x as NSArray
        var counterz = 0
        for y in results {
            
            let piny = (results[counterz] as AnyObject).value(forKey: "lat") as! Double
            let pinz = (results[counterz] as AnyObject).value(forKey: "long") as! Double
            
         
            let pin = MKPointAnnotation()
       
            pin.subtitle = (results[counterz] as AnyObject).value(forKey: "date") as! String
            var behaviorz = ((results[counterz]) as AnyObject).value(forKey: "behavior") as! Int
            var singingz = ((results[counterz]) as AnyObject).value(forKey: "singing") as! Int
            
            let sightingz = ((results[counterz]) as AnyObject).value(forKey: "sighting") as! String
            if behaviorz == 1 {behaviorstring = "Aggressive"}
            
            if sightingz == "Nest"{behaviorstring = ""}
            if behaviorz == 0 {behaviorstring = ""}
            if  singingz == 1 {singingstring = "Singing"}
            if singingz == 0 {singingstring = ""}
           
            pin.title =   behaviorstring + " " + singingstring +  " " + sightingz
            pin.coordinate = CLLocationCoordinate2D(latitude: piny, longitude: pinz)
            mapView.addAnnotation(pin)
            counterz += 1
            count = counterz

        }

        
        
        appDelegate.saveContext()


    }

    
 


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (fetchresults().isEmpty){}
        else{
            Pin(x: fetchresults())
        }
    
        
        
    }
    
    
}

    extension ViewController : CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                locationManager.requestLocation()
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                let span = MKCoordinateSpanMake(0.06, 0.06)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("error:: \(error)")
        }
}




