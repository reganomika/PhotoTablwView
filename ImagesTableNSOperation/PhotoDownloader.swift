//
//  PhotoDownloader.swift
//  ImagesTableNSOperation
//
//  Created by MacBook on 4.03.23.
//

import Foundation
import UIKit

class PhotoDownloader: Operation {
    let photoRecord: PhotoRecord

    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }

    override func main() {

        if self.isCancelled {
            return
        }

        guard let imageData = try? Data(contentsOf: photoRecord.url) else {
            return
        }

        if self.isCancelled {
            return
        }

        if imageData.count > 0 {
            self.photoRecord.image = UIImage(data: imageData)
            self.photoRecord.state = .downloaded
        } else {
            self.photoRecord.state = .failed
        }
    }
}
