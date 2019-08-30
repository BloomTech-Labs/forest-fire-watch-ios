//
//  LogInViewController.swift
//  FireFlight
//
//  Created by Kobe McKee on 8/20/19.
//  Copyright © 2019 Lambda. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    
    var apiController: APIController?
    
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var joinNowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stylize()
        
        self.passwordTextField.delegate = self
    }
    

        
    
    func stylize() {
        
        signInButton.layer.cornerRadius = 10
        signInButton.setTitleColor(AppearanceHelper.ming, for: .normal)
        signInButton.backgroundColor = .white
        
        iconImageView.image = UIImage(named: "fireIcon")
        
        usernameTextField.backgroundColor = AppearanceHelper.ming
        usernameTextField.textColor = .white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        
        passwordTextField.backgroundColor = AppearanceHelper.ming
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        
        
        
        let gradient = CAGradientLayer()
        gradient.colors = [AppearanceHelper.macAndCheese.cgColor, AppearanceHelper.begonia.cgColor, AppearanceHelper.turkishRose.cgColor, AppearanceHelper.oldLavender.cgColor, AppearanceHelper.ming.cgColor]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        
    }
    
    
    @IBAction func signInPressed(_ sender: Any) {
        var username: String?
        var password: String?
        if usernameTextField.text != "" && passwordTextField.text != "" {
            username = usernameTextField.text
            password = passwordTextField.text
        } else {
            NSLog("Entered username or password is not valid")
            return
            
        }
        

        apiController?.loginUser(username: username!, password: password!, completion: { (error) in
            if let error = error {
                NSLog("Error logging in user: \(error)")
                return
            } else if self.apiController?.bearer?.token != "" {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LogInToMap", sender: self)
                }
            }
        })
        
        
    }
    
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    

     //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LogInToSignUp" {
            guard let destinationVC = segue.destination as? SignUpViewController else { return }
            destinationVC.apiController = apiController
        }
        else if segue.identifier == "LogInToMap" {
            guard let destinationVC = segue.destination as? MapViewController else { return }
            destinationVC.apiController = apiController
        }

    }


}
