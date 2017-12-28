//
//  UIImageCropper.swift
//  UIImageCropper
//
//  Created by Jari Kalinainen jari@klubitii.com
//
//  Licensed under MIT License 2017
//

import UIKit

public class UIImageCropper: UIViewController {
    
    public var cropRatio: CGFloat = 1
    
    var imageView: UIImageView = UIImageView()
    var cropView: UIView = UIView()
    
    var topConst: NSLayoutConstraint?
    var leadConst: NSLayoutConstraint?
    
    var imageHeightConst: NSLayoutConstraint?
    var imageWidthConst: NSLayoutConstraint?
    
    var doneCallback: ((UIImage?) -> ())?
    var retakeCallback: (() -> ())?
    
    public var image: UIImage? {
        didSet {
            guard let image = self.image else {
                return
            }
            ratio = image.size.height / image.size.width
        }
    }
    var cropImage: UIImage? {
        return crop()
    }
    
    private var ratio: CGFloat = 1
    private var layoutDone: Bool = false
    
    private var orgHeight: CGFloat = 0
    private var orgWidth: CGFloat = 0
    private var topStart: CGFloat = 0
    private var leadStart: CGFloat = 0
    private var pinchStart: CGPoint = .zero
    
    @IBAction func cropDone() {
        doneCallback?(self.cropImage)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func retakePicture() {
        if retakeCallback == nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
        retakeCallback?()
    }
    
//    convenience init(cropRatio: CGFloat) {
//        self.init()
//    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        topConst = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        topConst?.priority = .defaultHigh
        leadConst = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        leadConst?.priority = .defaultHigh
        imageWidthConst = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 1)
        imageHeightConst = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 1)

        imageView.addConstraints([imageHeightConst!, imageWidthConst!])
        self.view.addConstraints([topConst!, leadConst!])
        imageView.image = self.image
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        imageView.addGestureRecognizer(pinchGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        imageView.addGestureRecognizer(panGesture)
        imageView.isUserInteractionEnabled = true
        
        cropView.translatesAutoresizingMaskIntoConstraints = false
        cropView.isUserInteractionEnabled = false
        self.view.addSubview(cropView)
        let centerXConst = NSLayoutConstraint(item: cropView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConst = NSLayoutConstraint(item: cropView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConst = NSLayoutConstraint(item: cropView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.8, constant: 0)
        let ratioConst = NSLayoutConstraint(item: cropView, attribute: .width, relatedBy: .equal, toItem: cropView, attribute: .height, multiplier: cropRatio, constant: 0)
        cropView.addConstraints([ratioConst])
        self.view.addConstraints([widthConst, centerXConst, centerYConst])
        cropView.layer.borderWidth = 2
        cropView.layer.borderColor = UIColor.white.cgColor
        cropView.backgroundColor = UIColor.clear
        
        view.layoutIfNeeded()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
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
        self.view.addConstraints(horizontal + vertical)
        orgWidth = imageWidthConst!.constant
        orgHeight = imageHeightConst!.constant
        imageView.layer.anchorPoint = CGPoint(x: imageView.frame.width/2, y: imageView.frame.height/2)
    }
    
    private func crop() -> UIImage? {
        guard let image = self.image else {
            return nil
        }
        let imageSize = image.size
        let width = cropView.frame.width / imageView.frame.width
        let height = cropView.frame.height / imageView.frame.height
        let x = (cropView.frame.origin.x - imageView.frame.origin.x) / imageView.frame.width
        let y = (cropView.frame.origin.y - imageView.frame.origin.y) / imageView.frame.height
        //print(size)
        
        let cropFrame = CGRect(x: x * imageSize.width, y: y * imageSize.height, width: imageSize.width * width, height: imageSize.height * height)
        //print(String(format: "x: %.2f, y: %.2f (w: %.2f, h: %.2f)", x, y, width, height))
        //print(String(format: "x: %.2f, y: %.2f (w: %.2f, h: %.2f)", cropFrame.origin.x, cropFrame.origin.y, cropFrame.width, cropFrame.height))
        
        if let cropCGImage = image.cgImage?.cropping(to: cropFrame) {
            let cropImage = UIImage(cgImage: cropCGImage)
            //print(String(format: "(w: %.2f, h: %.2f)",  cropImage.size.width, cropImage.size.height))
            return cropImage
        }
        return nil
    }
}
