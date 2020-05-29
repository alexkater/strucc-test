//
//  TransitionAnimator.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 29/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

final class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let duration: Double
    private let originFrame: CGRect
    var presenting = true

    init(_ duration: Double = 0.8, originFrame: CGRect) {
        self.duration = duration
        self.originFrame = originFrame
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let recorderView = presenting ? toView : transitionContext.view(forKey: .from)!

        let finalFrame = presenting ? recorderView.frame : originFrame

        containerView.addSubview(toView)
        containerView.bringSubviewToFront(recorderView)

        recorderView.frame = presenting ? originFrame : recorderView.frame
        let buttonRadius: CGFloat = originFrame.width / 2
        recorderView.layer.cornerRadius = presenting ? buttonRadius : 0

        UIView.animate(
          withDuration: duration,
          delay: 0.0,
          usingSpringWithDamping: 4,
          initialSpringVelocity: 0.2,
          animations: { [weak self] in
            guard let strongSelf = self else { return }

            if strongSelf.presenting {
                recorderView.frame.size = finalFrame.size
            } else {
                let xScaleFactor = finalFrame.width / recorderView.frame.width
                let yScaleFactor = finalFrame.height / recorderView.frame.height
                let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
                recorderView.backgroundColor = .clear
            }
            recorderView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            recorderView.layer.cornerRadius = !strongSelf.presenting ? 0 : buttonRadius
            recorderView.alpha = strongSelf.presenting ? 1:0
        }, completion: { _ in
          transitionContext.completeTransition(true)
        })
    }
}
