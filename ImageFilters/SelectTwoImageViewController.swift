//
//  SelectTwoImageFilterViewController.swift
//  ImageFilters
//
//  Created by Fernando N. Frassia on 12/22/23.
//

import UIKit

class SelectTwoImageViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var originalImgView1: UIImageView?
    @IBOutlet weak var originalImgView2: UIImageView?
    var originalImg1: UIImage?
    var originalImg2: UIImage?
    var imagePicker1 = UIImagePickerController()
    var imagePicker2 = UIImagePickerController()
    
    @IBAction func selectImg1Tapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker1.delegate = self
            imagePicker1.sourceType = .savedPhotosAlbum
            imagePicker1.allowsEditing = false
            present(imagePicker1, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectImg2Tapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker2.delegate = self
            imagePicker2.sourceType = .savedPhotosAlbum
            imagePicker2.allowsEditing = false
            present(imagePicker2, animated: true, completion: nil)
        }
    }
    
    @IBAction func applyFilterTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Pick a filter", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Combine", style: .default, handler: { _ in
            self.combine()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func combine() {
        if originalImg1 == nil {
            originalImg1 = originalImgView1?.image
        }
        
        if originalImg2 == nil {
            originalImg2 = originalImgView2?.image
        }
        
        guard let combinedImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CombinedImagesViewController") as? CombinedImagesViewController else {return}
        combinedImageVC.combinedImage = ImageProcessor.combine(originalImg1!, originalImg2!)
        navigationController?.pushViewController(combinedImageVC, animated: true)
    }
    
}


extension SelectTwoImageViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {return}
        if picker == imagePicker1 {
            originalImg1 = image
            originalImgView1?.image = originalImg1
        } else {
            originalImg2 = image
            originalImgView2?.image = originalImg2
        }
    }
    
}
