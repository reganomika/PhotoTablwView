//
//  PhotoCell.swift
//  ImagesTableNSOperation
//
//  Created by MacBook on 4.03.23.
//

import Foundation
import UIKit

class PhotoCell: UITableViewCell {

    static let reuseIdentifier: String = "PhotoCell"

    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor, multiplier: 1),

            nameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 20),
            nameLabel.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
    }

    func configure(text: String, image: UIImage?) {
        nameLabel.text = text
        photoImageView.image = image
    }
}
