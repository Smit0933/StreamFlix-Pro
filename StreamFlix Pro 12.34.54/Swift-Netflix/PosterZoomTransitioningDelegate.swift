//
//  PosterZoomTransitioningDelegate.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 29/04/2025.
//


import UIKit

class PosterZoomTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var originFrame: CGRect = .zero
    var posterImage: UIImage?

    func animationController(forPresented presented: UIViewController,
                              presenting: UIViewController,
                              source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PosterZoomAnimator()
        animator.isPresenting = true
        animator.originFrame = originFrame
        animator.posterImage = posterImage
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PosterZoomAnimator()
        animator.isPresenting = false
        animator.originFrame = originFrame
        animator.posterImage = posterImage
        return animator
    }
}