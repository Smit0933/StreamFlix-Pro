//
//  PosterZoomAnimator.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 29/04/2025.
//


import UIKit

class PosterZoomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var originFrame: CGRect = .zero
    var posterImage: UIImage?
    var isPresenting = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView

        if isPresenting {
            guard let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }

            let posterView = UIImageView(image: posterImage)
            posterView.contentMode = .scaleAspectFill
            posterView.clipsToBounds = true
            posterView.frame = originFrame

            toView.alpha = 0
            container.addSubview(toView)
            container.addSubview(posterView)

            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                posterView.frame = toView.frame
                toView.alpha = 1
            }) { _ in
                posterView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        } else {
            guard let fromView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
            }

            let posterView = UIImageView(image: posterImage)
            posterView.contentMode = .scaleAspectFill
            posterView.clipsToBounds = true
            posterView.frame = fromView.frame

            container.addSubview(posterView)
            fromView.alpha = 0

            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                posterView.frame = self.originFrame
            }) { _ in
                posterView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}