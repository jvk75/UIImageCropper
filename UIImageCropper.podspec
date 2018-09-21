#
# Be sure to run `pod lib lint NFCNDEFParse.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name          = 'UIImageCropper'
  s.version       = '1.4.0'
  s.summary       = 'Simple Image cropper for UIImage and UIImagePickerController with customisable aspect ratio.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description   = <<-DESC
Simple Image cropper for UIImage and UIImagePickerController with customisable crop aspect ratio. Made purely with Swift!
Replaces the iOS "crop only to square" functionality. Easy few line setup with delegate method. With possibility to localized button texts.
See example for usage details.
DESC

  s.homepage      = 'https://github.com/jvk75/UIImageCropper'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { 'Jari Kalinainen' => 'jari@klubitii.com' }
  s.source        = { :git => 'https://github.com/jvk75/UIImageCropper.git', :tag => s.version.to_s }
  s.swift_version = '4.2'

  s.ios.deployment_target = '10.0'

  s.source_files = 'UIImageCropper/*'
  
end
