//
//  SavedAddressesViewController.swift
//  FireFlight
//
//  Created by Kobe McKee on 9/12/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import UIKit

class SavedAddressesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var apiController: APIController? {
        didSet {
            print(apiController)
        }
    }
    
    var addresses: [UserAddress]? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var addressTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressTableView.delegate = self
        addressTableView.dataSource = self
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getAddresses()
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.stylize()
            self.addressTableView.reloadData()
        }
    }
    
    
    
    func stylize() {
        
        let closeImage = UIImage(named: "closeButton")
        let tintedImage = closeImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = AppearanceHelper.ming
        
        let gradient = CAGradientLayer()
        gradient.colors = [AppearanceHelper.macAndCheese.cgColor, AppearanceHelper.begonia.cgColor, AppearanceHelper.turkishRose.cgColor, AppearanceHelper.oldLavender.cgColor, AppearanceHelper.ming.cgColor]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        
        addressTableView.backgroundColor = .clear
    }
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = addressTableView.dequeueReusableCell(withIdentifier: "AddressCell"),
            let address = addresses?[indexPath.row] else { return UITableViewCell() }
        
        cell.textLabel?.text = address.label ?? "Address"
        cell.detailTextLabel?.text = address.address
        
        return cell
    }
    
    
    func getAddresses() {
        
        apiController?.getAddresses(completion: { (addresses, error) in
            if let error = error {
                NSLog("Error gettng user addresses: \(error)")
                return
            }
            
            self.addresses = addresses
            
        })
        
        
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
