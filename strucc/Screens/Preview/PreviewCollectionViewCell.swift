//
//  PreviewCollectionViewCell.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 28/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

struct EditorCollectionCellViewModel {
    let title, imageName: String
}

final class EditorCollectionViewCell: UICollectionViewCell {
    static let identifier = "EditorCollectionViewCell"
    var imageView: UIImageView!
    var filterNameLabel: UILabel!

    private var scale: CGFloat = -1

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func updateScale(_ scale: CGFloat) {
        let scale = 1 - scale

        let minCornerRadius = CellConstants.normalWidth / 2
        let diffCornerRadius = (CellConstants.centeredWidth - CellConstants.normalWidth) / 2
        let newCornerRadius: CGFloat = minCornerRadius + diffCornerRadius * scale
        let diff: CGFloat = newCornerRadius - imageView.layer.cornerRadius

        // Prevent abrupt changes
        guard abs(diff) < (diffCornerRadius - 1)  ||
            imageView.layer.cornerRadius == 0 else { return }

        imageView.layer.cornerRadius = newCornerRadius
        filterNameLabel.alpha = scale
    }

    func setup(with viewModel: EditorCollectionCellViewModel, index: Int) {
        imageView.image = UIImage(named: viewModel.imageName)
        filterNameLabel.text = viewModel.title
        updateScale(index == 0 ? 0:1 )
    }
}

private extension EditorCollectionViewCell {

    func setupView() {
        imageView = UIImageView(image: #imageLiteral(resourceName: "ThumbNoFilter.pdf"))
        imageView.contentMode = .scaleToFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true

        filterNameLabel = UILabel()
        filterNameLabel.font = UIFont(name: "PostGrotesk-Bold", size: 14)
        filterNameLabel.textColor = .white
        filterNameLabel.textAlignment = .center

        [imageView, filterNameLabel]
            .compactMap { $0 }
            .forEach { view in
                addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
        }

        setupConstraints()
    }

    func setupConstraints() {
        [
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ].active()

        [
            filterNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            filterNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        ].active()
    }
}
