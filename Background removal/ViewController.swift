//
//  ViewController.swift
//  Background removal
//
//  Created by Amir Lahav on 09/06/2021.
//

import UIKit
import CoreML
import Vision
import VideoToolbox

class ViewController: UIViewController {

    @IBOutlet weak var inputImage: UIImageView!
    @IBOutlet weak var segmentedImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "child.jpg")

        let resize = (image?.cropImage(toRect: CGRect(x: 0, y: 0, width: 320, height: 320)))!
        inputImage.image = image
        let model = try? LaLabsu2netp.init()
        
        let result = try? model?.prediction(in_0: buffer(from: resize)!)
        
        let out = UIImage(pixelBuffer: result!.out_p1)
        segmentedImage.image = out
        // Do any additional setup after loading the view.
    }

    func buffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
}

extension UIImage {
    func cropImage(toRect rect: CGRect) -> UIImage? {
        if let imageRef = self.cgImage?.cropping(to: rect) {
            return UIImage(cgImage: imageRef)
        }
        return nil
    }
}

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}
