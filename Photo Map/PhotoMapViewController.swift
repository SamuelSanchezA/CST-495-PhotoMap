//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var imageTaken : UIImage!
    var imagePickerController : UIImagePickerController!
    private static var selectedAnnotationImage : UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        cameraButton.layer.cornerRadius = 28
        cameraButton.clipsToBounds = true
        cameraButton.backgroundColor = UIColor.white
        
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            imagePickerController.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            imagePickerController.sourceType = .photoLibrary
        }
        
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber, photo: UIImage) {
        self.navigationController?.popViewController(animated: true)
        var coord = CLLocationCoordinate2D()
        coord.latitude = latitude as! Double
        coord.longitude = longitude as! Double
        
        let annotation = PhotoAnnotation()
        annotation.coordinate = coord
        annotation.photo = photo
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
        }
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x:0, y:0, width:45, height:45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        imageView.image = thumbnail
        
        let detailButton = UIButton(type: .detailDisclosure)
        detailButton.addTarget(self, action: #selector(fullsizeImage(_:)), for: .touchUpInside)
        
        annotationView?.rightCalloutAccessoryView = detailButton
        
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //PhotoMapViewController.selectedAnnotationImage = (mapView.selectedAnnotations[0] as! PhotoAnnotation).photo
        performSegue(withIdentifier: "fullImageSegue", sender: (mapView.selectedAnnotations[0] as! PhotoAnnotation).photo)
    }
    
    @objc func fullsizeImage(_ sender: Any){
        //performSegue(withIdentifier: "fullImageSegue", sender: nil)
    }
    
    @IBAction func openCamera(_ sender: Any) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Do something with the images (based on your use case)
        
        imageTaken = originalImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: {
           self.performSegue(withIdentifier: "tagSegue", sender: nil)
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "tagSegue"){
            let destVC = segue.destination as! LocationsViewController
            destVC.selectedPhoto = imageTaken
            destVC.delegate = self
        }
        else if(segue.identifier == "fullImageSegue"){
            let destVC = segue.destination as! FullImageViewController
            destVC.photo = sender as! UIImage
        }
    }
    

}
