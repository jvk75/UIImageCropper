//
//  UIImageCropper.swift
//  UIImageCropper
//
//  Created by Jari Kalinainen jari@klubitii.com
//
//  Licensed under MIT License 2017
//

import UIKit

@objc public protocol UIImageCropperProtocol: class {
    /// Called when user presses crop button (or when there is unknown situation (one or both images will be nil)).
    /// - parameter originalImage
    ///   Orginal image from camera/gallery
    /// - parameter croppedImage
    ///   Cropped image in cropRatio aspect ratio
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?)
    /// (optional) Called when user cancels the picker. If method is not available picker is dismissed.
    @objc optional func didCancel()
}

public class UIImageCropper: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Aspect ratio of the cropped image
    public var cropRatio: CGFloat = 1
    /// delegate that implements UIImageCropperProtocol
    public var delegate: UIImageCropperProtocol?
    /// UIImagePickerController picker
    public var picker: UIImagePickerController? {
        didSet {
            picker?.delegate = self
            picker?.allowsEditing = false
        }
    }

    /// Crop button text
    public var cropButtonText: String = "Crop"
    /// Retake/Cancel button text
    public var cancelButtonText: String = "Retake"

    /// original image from camera or gallery
    public var image: UIImage? {
        didSet {
            guard let image = self.image else {
                return
            }
            ratio = image.size.height / image.size.width
            imageView.image = image
        }
    }
    /// cropped image
    public var cropImage: UIImage? {
        return crop()
    }
    
    private let topView = UIView()
    private let imageView: UIImageView = UIImageView()
    private let cropView: UIView = UIView()

    private var topConst: NSLayoutConstraint?
    private var leadConst: NSLayoutConstraint?

    private var imageHeightConst: NSLayoutConstraint?
    private var imageWidthConst: NSLayoutConstraint?

    private var ratio: CGFloat = 1
    private var layoutDone: Bool = false
    
    private var orgHeight: CGFloat = 0
    private var orgWidth: CGFloat = 0
    private var topStart: CGFloat = 0
    private var leadStart: CGFloat = 0
    private var pinchStart: CGPoint = .zero
    
    //MARK: - inits
    /// initializer
    /// - parameter cropRatio
    /// Aspect ratio of the cropped image
    convenience public init(cropRatio: CGFloat) {
        self.init()
        self.cropRatio = cropRatio
    }

    //MARK: - overrides
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black

        //main views
        topView.backgroundColor = UIColor.clear
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.clear
        self.view.addSubview(topView)
        self.view.addSubview(bottomView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalTopConst = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[view]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": topView])
        let horizontalBottomConst = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[view]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": bottomView])
        let verticalConst = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top]-(0)-[bottom(70)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bottom": bottomView, "top": topView])
        self.view.addConstraints(horizontalTopConst + horizontalBottomConst + verticalConst)

        // image view
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(imageView)
        topConst = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .top, multiplier: 1, constant: 0)
        topConst?.priority = .defaultHigh
        leadConst = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: topView, attribute: .leading, multiplier: 1, constant: 0)
        leadConst?.priority = .defaultHigh
        imageWidthConst = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 1)
        imageHeightConst = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 1)
        imageView.addConstraints([imageHeightConst!, imageWidthConst!])
        topView.addConstraints([topConst!, leadConst!])
        imageView.image = self.image

        // imageView gestures
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        imageView.addGestureRecognizer(pinchGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        imageView.addGestureRecognizer(panGesture)
        imageView.isUserInteractionEnabled = true

        // crop overlay
        cropView.translatesAutoresizingMaskIntoConstraints = false
        cropView.isUserInteractionEnabled = false
        topView.addSubview(cropView)
        let centerXConst = NSLayoutConstraint(item: cropView, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConst = NSLayoutConstraint(item: cropView, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConst = NSLayoutConstraint(item: cropView, attribute: .width, relatedBy: .equal, toItem: topView, attribute: .width, multiplier: 0.8, constant: 0)
        let ratioConst = NSLayoutConstraint(item: cropView, attribute: .width, relatedBy: .equal, toItem: cropView, attribute: .height, multiplier: cropRatio, constant: 0)
        cropView.addConstraints([ratioConst])
        topView.addConstraints([widthConst, centerXConst, centerYConst])
        cropView.layer.borderWidth = 2
        cropView.layer.borderColor = UIColor.white.cgColor
        cropView.backgroundColor = UIColor.clear

        // control buttons
        var cropCenterXMultiplier: CGFloat = 1.0
        if picker!.sourceType != .camera { //hide retake/cancel when using camera as camera has its own preview
            let cancelButton = UIButton(type: .custom)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.setTitle(cancelButtonText, for: .normal)
            cancelButton.addTarget(self, action: #selector(cropCancel), for: .touchUpInside)
            bottomView.addSubview(cancelButton)
            let centerCancelXConst = NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 0.5, constant: 0)
            let centerCancelYConst = NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 0)
            bottomView.addConstraints([centerCancelXConst, centerCancelYConst])
            cropCenterXMultiplier = 1.5
        }
        let cropButton = UIButton(type: .custom)
        cropButton.translatesAutoresizingMaskIntoConstraints = false
        cropButton.setTitle(cropButtonText, for: .normal)
        cropButton.addTarget(self, action: #selector(cropDone), for: .touchUpInside)
        bottomView.addSubview(cropButton)
        let centerCropXConst = NSLayoutConstraint(item: cropButton, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: cropCenterXMultiplier, constant: 0)
        let centerCropYConst = NSLayoutConstraint(item: cropButton, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 0)
        bottomView.addConstraints([centerCropXConst, centerCropYConst])


        bottomView.layoutIfNeeded()
        topView.layoutIfNeeded()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !layoutDone else {
            return
        }
        layoutDone = true
        imageWidthConst?.constant = cropView.frame.height / ratio
        imageHeightConst?.constant = cropView.frame.height

        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(<=\(cropView.frame.origin.x))-[view]-(<=\(cropView.frame.origin.x))-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": imageView])
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(<=\(cropView.frame.origin.y))-[view]-(<=\(cropView.frame.origin.y))-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": imageView])
        topView.addConstraints(horizontal + vertical)
        orgWidth = imageWidthConst!.constant
        orgHeight = imageHeightConst!.constant
    }

    //MARK: - button actions
    @objc func cropDone() {
        delegate?.didCropImage(originalImage: self.image, croppedImage: self.cropImage)
        self.dismiss(animated: false, completion: {
            self.picker?.dismiss(animated: true, completion: nil)
        })
    }

    @objc func cropCancel() {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: - gesture handling
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
        if pinch.state == .began {
            orgWidth = imageWidthConst!.constant
            orgHeight = imageHeightConst!.constant
            pinchStart = pinch.location(in: self.view)
        }
        let scale = pinch.scale
        let height = max(orgHeight * scale, cropView.frame.height)
        let width = max(orgWidth * scale, cropView.frame.height / ratio)
        imageHeightConst?.constant = height
        imageWidthConst?.constant = width
    }
    
    @objc func pan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            topStart = topConst!.constant
            leadStart = leadConst!.constant
        }
        let trans = pan.translation(in: self.view)
        leadConst?.constant = leadStart + trans.x
        topConst?.constant = topStart + trans.y
    }

    //MARK: - cropping done here
    private func crop() -> UIImage? {
        guard let image = self.image else {
            return nil
        }
        let imageSize = image.size
        let width = cropView.frame.width / imageView.frame.width
        let height = cropView.frame.height / imageView.frame.height
        let x = (cropView.frame.origin.x - imageView.frame.origin.x) / imageView.frame.width
        let y = (cropView.frame.origin.y - imageView.frame.origin.y) / imageView.frame.height

        let cropFrame = CGRect(x: x * imageSize.width, y: y * imageSize.height, width: imageSize.width * width, height: imageSize.height * height)

        if let cropCGImage = image.cgImage?.cropping(to: cropFrame) {
            let cropImage = UIImage(cgImage: cropCGImage)
            return cropImage
        }
        return nil
    }

    //MARK: - UIImagePickerControllerDelegates
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if delegate?.didCancel?() == nil {
            picker.dismiss(animated: true, completion: nil)
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        layoutDone = false
        self.image = image
        picker.present(self, animated: true, completion: nil)
    }
}
