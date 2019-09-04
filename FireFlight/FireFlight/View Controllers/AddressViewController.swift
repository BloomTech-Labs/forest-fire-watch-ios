//
//  AddressViewController.swift
//  FireFlight
//
//  Created by Kobe McKee on 8/26/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import UIKit
import CoreLocation

class AddressViewController: UIViewController, UITextFieldDelegate {

    var apiController: APIController?
    var addressLabel: String?
    var addressString: String?
    var newLocation: CLLocation? {
        didSet {
            //print(newLocation)
            saveAddress() 
        }
    }
    
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBOutlet weak var addAddressButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylize()
        zipCodeTextField.delegate = self
    }
    
    func stylize() {
        
        labelTextField.backgroundColor = AppearanceHelper.ming
        labelTextField.textColor = .white
        labelTextField.attributedPlaceholder = NSAttributedString(string: "Label", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        
        streetTextField.backgroundColor = AppearanceHelper.ming
        streetTextField.textColor = .white
        streetTextField.attributedPlaceholder = NSAttributedString(string: "Street", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        
        cityTextField.backgroundColor = AppearanceHelper.ming
        cityTextField.textColor = .white
        cityTextField.attributedPlaceholder = NSAttributedString(string: "City", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        
        stateTextField.backgroundColor = AppearanceHelper.ming
        stateTextField.textColor = .white
        stateTextField.attributedPlaceholder = NSAttributedString(string: "State (Ex: CA)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        
        zipCodeTextField.backgroundColor = AppearanceHelper.ming
        zipCodeTextField.textColor = .white
        zipCodeTextField.attributedPlaceholder = NSAttributedString(string: "Zip Code", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        
        
        addAddressButton.layer.cornerRadius = 10
        addAddressButton.setTitleColor(AppearanceHelper.ming, for: .normal)
        addAddressButton.backgroundColor = .white
        
        
        let gradient = CAGradientLayer()
        gradient.colors = [AppearanceHelper.macAndCheese.cgColor, AppearanceHelper.begonia.cgColor, AppearanceHelper.turkishRose.cgColor, AppearanceHelper.oldLavender.cgColor, AppearanceHelper.ming.cgColor]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    @IBAction func addAddressPressed(_ sender: Any) {
        
        guard let street = streetTextField.text,
            let city = cityTextField.text,
            let state = stateTextField.text,
            let zipCode = zipCodeTextField.text,
            !street.isEmpty, !city.isEmpty, !state.isEmpty, !zipCode.isEmpty else { return }
        let formattedState = state.uppercased()

        let addressString = "\(street), \(city), \(formattedState) \(zipCode)"
        
        self.addressString = street
        
        
        if let label = labelTextField.text {
            self.addressLabel = label
        } else {
            self.addressLabel = street
        }
        
        convertAddress(addressString: addressString)
    }
    
    
    func convertAddress(addressString: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(addressString, completionHandler: {(placemarks, error) -> Void in
            if let error = error {
                NSLog("Error converting address: \(error)")
            }
            self.newLocation = placemarks?.first?.location
        })
    }
    
    
    func saveAddress() {
        
        guard let label = addressLabel,
            let address = addressString,
            let location = newLocation
            else {
                NSLog("Address Not Valid")
                return
        }
        let radius = radiusSlider.value
        
        
        apiController?.postAddress(label: label, address: address, location: location, shownFireRadius: radius)
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
