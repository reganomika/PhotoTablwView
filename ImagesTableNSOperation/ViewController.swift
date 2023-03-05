//
//  ViewController.swift
//  ImagesTableNSOperation
//
//  Created by MacBook on 4.03.23.
//

import UIKit

final class ViewController: UIViewController {

    enum Constants {
        static var rowHeight: CGFloat { 80.0 }
    }

    var photos = [PhotoRecord]()
    let pendingOperations = PendingOperations()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = Constants.rowHeight
        tableView.estimatedRowHeight = Constants.rowHeight
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classic Photos"
        fetchPhotoDetails()

        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.reuseIdentifier)

        setup()
    }

    private func setup() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchPhotoDetails() {
        if let path = Bundle.main.path(forResource: "ClassicPhotosDictionary", ofType: "plist"),
           let datasourceDictionary = NSDictionary(contentsOfFile: path) {

            for(key, value) in datasourceDictionary {
                let name = key as? String
                let url = URL(string: value as? String ?? "")

                if let name, let url {
                    let photoRecord = PhotoRecord(name: name, url: url)
                    self.photos.append(photoRecord)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            showErrorAlert()
        }
    }

    private func showErrorAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Oops!",
                message: "Something was wrong",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func startOperationsForPhotoRecord(photoDetails: PhotoRecord, indexPath: IndexPath) {
        switch photoDetails.state {
        case .new:
            startDownloadForRecord(photoDetails: photoDetails, indexPath: indexPath)
        case .downloaded:
            startFiltrationForRecord(photoDetails: photoDetails, indexPath: indexPath)
        default:
            break
        }
    }

    private func startDownloadForRecord(photoDetails: PhotoRecord, indexPath: IndexPath) {
        if let _ = pendingOperations.downloadsInProgress[indexPath] {
            return
        }

        let downloader = PhotoDownloader(photoRecord: photoDetails)

        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }

        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }

    private func startFiltrationForRecord(photoDetails: PhotoRecord, indexPath: IndexPath) {
        if let _ = pendingOperations.filtrationsInProgress[indexPath] {
            return
        }

        let downloader = ImageFiltration(photoRecord: photoDetails)

        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async {
                self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }

        pendingOperations.filtrationsInProgress[indexPath] = downloader
        pendingOperations.filtrationQueue.addOperation(downloader)
    }

    private func suspendAllOperations () {
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.filtrationQueue.isSuspended = true
    }

    private func resumeAllOperations () {
        pendingOperations.downloadQueue.isSuspended = false
        pendingOperations.filtrationQueue.isSuspended = false
    }

    private func loadImagesForOnscreenCells() {
        if let pathsArray = tableView.indexPathsForVisibleRows {
            var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys).union(pendingOperations.filtrationsInProgress.keys)

            let visiblePaths = Set(pathsArray)
            let toBeCancelled = allPendingOperations.subtracting(visiblePaths)

            let toBeStarted = visiblePaths.subtracting(allPendingOperations)

            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)

                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }

                for indexPath in toBeStarted {
                    let recordToProcess = photos[indexPath.row]
                    startOperationsForPhotoRecord(photoDetails: recordToProcess, indexPath: indexPath)
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }

        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(style: .medium)
            cell.accessoryView = indicator
        }

        let indicator = cell.accessoryView as? UIActivityIndicatorView

        let photoDetails = photos[indexPath.row]

        cell.configure(text: photoDetails.name, image: photoDetails.image)

        switch photoDetails.state {
        case .filtered:
            indicator?.stopAnimating()
        case .failed:
            indicator?.stopAnimating()
        case .new, .downloaded:
            indicator?.startAnimating()

            if !tableView.isDragging && !tableView.isDecelerating {
                startOperationsForPhotoRecord(photoDetails: photoDetails, indexPath: indexPath)
            }
        }

        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.rowHeight
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
}

