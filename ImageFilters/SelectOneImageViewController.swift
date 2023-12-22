//
//  SelectImageViewController.swift
//  ImageFilters
//
//  Created by Fernando N. Frassia on 12/21/23.
//

import UIKit

class SelectOneImageViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    var selectedImage: UIImage?
    var imagePicker = UIImagePickerController()
    
    @IBAction func selectImageTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func applyFilterTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Pick a filter", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Rotate 180 and Flip", style: .default, handler: { _ in
            self.rotateAndFlipPressed()
        }))
        alert.addAction(UIAlertAction(title: "Shear", style: .default, handler: { _ in
            self.shearPressed()
        }))
        alert.addAction(UIAlertAction(title: "Rotate 90", style: .default, handler: { _ in
            self.rotate90()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func rotateAndFlipPressed() {
        guard let originalImage = selectedImage else {return}
        guard let filteredImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImageFilteredViewController") as? ImageFilteredViewController else {return}
        filteredImageVC.originalImg = originalImage
        filteredImageVC.filteredImg = ImageProcessor.rotateAndFlip(originalImage)
        navigationController?.pushViewController(filteredImageVC, animated: true)
    }
    
    private func shearPressed() {
        guard let originalImage = selectedImage else {return}
        guard let filteredImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImageFilteredViewController") as? ImageFilteredViewController else {return}
        filteredImageVC.originalImg = originalImage
        filteredImageVC.filteredImg = ImageProcessor.shear(originalImage)
        navigationController?.pushViewController(filteredImageVC, animated: true)
    }
    
    private func rotate90() {
        guard let originalImage = selectedImage else {return}
        guard let filteredImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImageFilteredViewController") as? ImageFilteredViewController else {return}
        filteredImageVC.originalImg = originalImage
        filteredImageVC.filteredImg = ImageProcessor.rotate90(originalImage)
        navigationController?.pushViewController(filteredImageVC, animated: true)
    }

}

extension SelectOneImageViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {return}
        selectedImage = image
        imgView.image = selectedImage
    }
    
}
