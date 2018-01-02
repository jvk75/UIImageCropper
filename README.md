# UIImageCropper

Simple Image cropper for UIImagePickerController with customisable crop aspect ratio. Made purely with Swift 4!

Replaces the iOS "crop only to square" functionality. Easy few line setup with delegate method/s.

## Requirements

- iOS10+
- Xcode 9.2+
- Swift 4


## Install
UIImageCropper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod 'UIImageCropper'
```

 (or add UIImageCropper folder to your project)

## Usage

Import the pod

```
import UIImageCropper
```

Create instanses of UIImagePickerController and UIImageCropper

UIImageCropper can take  ```cropRatio``` as parameter.  Default ratio is 1 (square).

```
let picker = UIImagePickerController()
let cropper = UIImageCropper(cropRatio: 2/3)
```

Setup UIImageCropper

```
cropper.picker = picker
cropper.delegate = self
//cropper.cropRatio = 2/3 //(can be set during runtime or in init)
```

Implement ```UIImageCropperProtocol```delegate method/s

```
func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
    imageView.image = croppedImage
}

//optional (if not implemented cropper will close itself and picker)
func didCancel() {
    picker.dismiss(animated: true, completion: nil)
}

```

The UIImageCropper will handle the image picking (delegate methods). To start image picking just present the UIImagePickerController instance.

```
self.present(self.picker, animated: true, completion: nil)
```

For full usage exmaple see **CropperExample** in Example folder.

## Coming soon

* Possibility to use cropper without UIImagePickerController

## Issues and contribution

If you find any issues please add and issue to this repository.

Improvements and/or fixes as pull requests are more than welcome.

## Author

Jari Kalinainen, jari@klubitii.com

## License

UIImageCropper is available under the MIT license. See the LICENSE file for more info.
