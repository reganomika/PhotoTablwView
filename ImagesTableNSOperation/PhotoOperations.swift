//
//  PhotoOperations.swift
//  ImagesTableNSOperation
//
//  Created by MacBook on 4.03.23.
//

import Foundation

class PendingOperations {
    lazy var downloadsInProgress = [IndexPath: Operation]()
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    lazy var filtrationsInProgress = [IndexPath: Operation]()
    lazy var filtrationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
