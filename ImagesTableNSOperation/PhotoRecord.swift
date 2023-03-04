//
//  PhotoRecord.swift
//  ImagesTableNSOperation
//
//  Created by MacBook on 4.03.23.
//

import UIKit

enum PhotoRecordState {
    case new
    case downloaded
    case filtered
    case failed
}

class PhotoRecord {
    var name: String
    var url: URL
    var state: PhotoRecordState = .new
    var image: UIImage? = UIImage(named: "placeholder")

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}
