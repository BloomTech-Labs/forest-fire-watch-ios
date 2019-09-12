//
//  SideMenuViewController.swift
//  FireFlight
//
//  Created by Kobe McKee on 9/12/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.cornerRadius = 32
        view.backgroundColor = AppearanceHelper.ming
    }
    
    
    
    @IBAction func profileButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func savedAddressesButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func LogOutButtonPressed(_ sender: Any) {
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
