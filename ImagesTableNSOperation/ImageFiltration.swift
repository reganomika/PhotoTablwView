//
//  ImageFiltration.swift
//  ImagesTableNSOperation
//
//  Created by MacBook on 4.03.23.
//

import Foundation
import UIKit

class ImageFiltration: Operation {
    let photoRecord: PhotoRecord

    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }

    override func main() {

        if self.isCancelled {
            return
        }

        guard photoRecord.state == .downloaded else {
            return
        }

        if let image = photoRecord.image,
           let filteredImage = applySepiaFilter(image: image) {
            photoRecord.image = filteredImage
            photoRecord.state = .filtered
        }
    }

    func applySepiaFilter(image: UIImage) -> UIImage? {
        guard let pngImageData = image.pngData() else {
            return nil
        }

        let inputImage = CIImage(data: pngImageData)

        if self.isCancelled {
            return nil
        }
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")

        if self.isCancelled {
            return nil
        }

        if let outputImage = filter?.outputImage,
           let outImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: outImage)
        }
        return nil
    }
}
