//
//  RecordButton.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

final class RecordButton: UIButton {

    private var redAreaLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = #colorLiteral(red: 1, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        return layer
    }()

    private var whiteAreaLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.700395976)
        return layer
    }()

    var tapAction: (() -> Void)?

    override var isSelected: Bool {
        didSet {
            animate()
        }
    }

    var borderWidth: CGFloat = 6 {
        didSet {
            updateView()
        }
    }

    init(width: CGFloat, borderWidth: CGFloat = 6) {
        self.borderWidth = borderWidth
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: width)))
        updateView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc func tapped() {
        isSelected = !isSelected
        tapAction?()
    }
}

private extension RecordButton {
    var reducedCornerRadius: CGFloat { return 4 }
    var initialCornerRadius: CGFloat { return (frame.width - borderWidth) / 2 }

    func updateView() {
        let width = self.frame.width
        self.layer.backgroundColor = UIColor.white.cgColor
        let size = frame.size.width - borderWidth
        redAreaLayer.frame = CGRect(origin: CGPoint(x: frame.origin.x + borderWidth/2, y: frame.origin.y + borderWidth/2), size: CGSize(width: size, height: size))
        redAreaLayer.cornerRadius = (width - borderWidth) / 2
        whiteAreaLayer.frame = frame
        whiteAreaLayer.cornerRadius = width / 2
        self.layer.addSublayer(whiteAreaLayer)
        self.layer.addSublayer(redAreaLayer)
    }

    var transformScaleAnimation: CAPropertyAnimation {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.fromValue = isSelected ? initialCornerRadius : reducedCornerRadius
        animation.toValue = isSelected ? reducedCornerRadius : initialCornerRadius
        return animation
    }

    var cornerRadiusAnimation: CAPropertyAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = isSelected ? 1 : 0.5
        animation.toValue = isSelected ? 0.5 : 1
        return animation
    }

    func animate() {

        let animation = CAAnimationGroup()
        animation.duration = 0.2
        animation.animations = [transformScaleAnimation, cornerRadiusAnimation]
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        redAreaLayer.add(animation, forKey: nil)
    }
}
