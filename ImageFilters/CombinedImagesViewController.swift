//
//  CombinedImagesViewController.swift
//  ImageFilters
//
//  Created by Fernando N. Frassia on 12/22/23.
//

import UIKit

class CombinedImagesViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView?
    var combinedImage: UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imgView?.image = combinedImage
    }

}
