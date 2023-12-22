//
//  ImageFilteredViewController.swift
//  ImageFilters
//
//  Created by Fernando N. Frassia on 12/21/23.
//

import UIKit

class ImageFilteredViewController: UIViewController {
    
    @IBOutlet weak var originalImgView: UIImageView?
    @IBOutlet weak var filteredImgView: UIImageView?
    var originalImg: UIImage?
    var filteredImg: UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        originalImgView?.image = originalImg
        filteredImgView?.image = filteredImg
    }
    
    
    
}
