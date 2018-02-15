//
//  ViewController.swift
//  CropperExample
//
//  Created by Jari Kalinainen on 28.12.17.
//  Copyright © 2017 Jari Kalinainen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private let picker = UIImagePickerController()
    private let cropper = UIImageCropper(cropRatio: 2/3)

    override func viewDidLoad() {
        super.viewDidLoad()

        //setup the cropper
        cropper.picker = picker
        cropper.delegate = self
        //cropper.cropRatio = 2/3 //(can be set during runtime or in init)
        cropper.cropButtonText = "Crop" // this can be localized if needed (as well as the cancelButtonText)
    }
    
    @IBAction func cropExistingImage(_ sender: Any) {
        cropper.image = UIImage(named: "image")
        cropper.cancelButtonText = "Cancel"
        self.present(cropper, animated: true, completion: nil)
    }

    @IBAction func takePicturePressed(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        cropper.cancelButtonText = "Retake"
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { _ in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default) { _ in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UIImageCropperProtocol {
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        imageView.image = croppedImage
    }

    //optional
    func didCancel() {
        picker.dismiss(animated: true, completion: nil)
        print("did cancel")
    }
}
