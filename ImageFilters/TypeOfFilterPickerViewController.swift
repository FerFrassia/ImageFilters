//
//  TypeOfFilterPickerViewController.swift
//  ImageFilters
//
//  Created by Fernando N. Frassia on 12/22/23.
//

import UIKit

class TypeOfFilterPickerViewController: UIViewController {
    
    @IBAction func oneImageTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "OneImageFilterSegue", sender: self)
    }
    
    @IBAction func twoImageTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "TwoImageFilterSegue", sender: self)
    }
    
}
