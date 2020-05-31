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
    lazy var animatedBackground = UIImageView(image: UIImage(named: "cinema"))

    init(_ duration: Double = 0.4, originFrame: CGRect) {
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

        if presenting {
            animatedBackground.contentMode = .scaleAspectFill
            animatedBackground.frame = recorderView.bounds

            recorderView.addSubview(animatedBackground)

            animatedBackground.alpha = 0

            recorderView.bringSubviewToFront(animatedBackground)
        }

        UIView.animate(
          withDuration: duration,
          delay: 0.0,
          usingSpringWithDamping: 4,
          initialSpringVelocity: 0.2,
          animations: { [weak self] in
            guard let strongSelf = self else { return }

            if strongSelf.presenting {
                self?.presentingChanges(recorderView, finalFrame: finalFrame)
            } else {
                self?.dismissChanges(recorderView, finalFrame: finalFrame)
            }

            recorderView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            recorderView.alpha = strongSelf.presenting ? 1:0
        }, completion: { _ in
            self.firstAnimationCompletion(transitionContext)
        })
    }
}

private extension TransitionAnimator {

    func firstAnimationCompletion(_ transitionContext: UIViewControllerContextTransitioning) {

        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 5,
                       options: .curveEaseInOut, animations: {
                        let scaleTransform = CGAffineTransform(scaleX: 4, y: 4)
                        self.animatedBackground.transform = scaleTransform
                        self.animatedBackground.alpha = 0
        }) { _ in
            self.animatedBackground.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }

    func presentingChanges(_ recorderView: UIView, finalFrame: CGRect) {
        recorderView.frame.size = finalFrame.size
        animatedBackground.frame.size = finalFrame.size
        animatedBackground.alpha = 1
    }

    func dismissChanges(_ recorderView: UIView, finalFrame: CGRect) {
        let xScaleFactor = finalFrame.width / recorderView.frame.width
        let yScaleFactor = finalFrame.height / recorderView.frame.height

        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        recorderView.transform = scaleTransform
    }
}
