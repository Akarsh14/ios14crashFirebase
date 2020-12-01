//
//  ProfilePresentAnimator.swift
//  Woo_v2
//
//  Created by Ankit Batra on 13/12/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class ProfilePresentAnimator: NSObject,UIViewControllerAnimatedTransitioning {

    private let originFrame: CGRect
    
    let topMarginForDeckView:CGFloat = (isIphoneX() || isIphoneXSMAX() || isIphoneXR()) ? 70 : 84

    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        snapshot.frame = originFrame
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        toVC.view.isHidden = true
        let duration = transitionDuration(using: transitionContext)
        
        if let fromVC = fromVC  as?  DiscoverViewController
        {
            if let localProfileDeckViewObject = fromVC.deckView.viewForCardAtIndex(Int(fromVC.deckView.currentCardIndex)) as? ProfileDeckView {
                localProfileDeckViewObject.profileDeckMainContainerViewLeadingConstraint.constant = 0.0
                localProfileDeckViewObject.profileDeckMainContainerViewTrailingConstraint.constant = 0.0
               
                localProfileDeckViewObject.myProfileBottomViewTrailingConstraint.constant = 0
                localProfileDeckViewObject.myProfileBottomViewLeadingConstraint.constant = 0
                let height = UIScreen.main.bounds.height
                fromVC.deckViewHeightConstraint.constant = height - safeAreaBoth
                
                localProfileDeckViewObject.NameAgeLabel.alpha = 0
                localProfileDeckViewObject.heightLabel.alpha = 0
                localProfileDeckViewObject.locationLabel.alpha = 0
                localProfileDeckViewObject.commonalityTagsView.alpha = 0
                //localProfileDeckViewObject.myProfileBottomView.alpha = 0
                if fromVC.userHasChoosedToMoveMyProfileUp == true{
                    //localProfileDeckViewObject.myProfileBottomViewBottomConstraint.constant = -105
                }
                localProfileDeckViewObject.hadAlreadyBeenShownInDiscover = true
                localProfileDeckViewObject.badgeView.alpha = 0
                localProfileDeckViewObject.updateProfileDeckMainContainerViewHeightRelatedConstraints()
                
                //localProfileDeckViewObject.perform(#selector(localProfileDeckViewObject.setupViewProperties), with: nil, afterDelay: 0.2)
                localProfileDeckViewObject.setupViewProperties()
            }
            
            if let localProfileDeckViewObject = fromVC.deckView.viewForCardAtIndex(Int(fromVC.deckView.currentCardIndex+1)) {
                
                localProfileDeckViewObject.isHidden = true
            }
            
            if let localProfileDeckViewObject = fromVC.deckView.viewForCardAtIndex(Int(fromVC.deckView.currentCardIndex+2)) {
                
                localProfileDeckViewObject.isHidden = true
                
            }
        }
        else
        {
            if let fromVC =  fromVC  as? TagSearchViewController
            {
                if let localProfileDeckViewObject = fromVC.deckView.viewForCardAtIndex(Int(fromVC.deckView.currentCardIndex)) as? ProfileDeckView {
                    localProfileDeckViewObject.profileDeckMainContainerViewLeadingConstraint.constant = 0.0
                    localProfileDeckViewObject.profileDeckMainContainerViewTrailingConstraint.constant = 0.0
                    localProfileDeckViewObject.myProfileBottomViewTrailingConstraint.constant = 0
                    localProfileDeckViewObject.myProfileBottomViewLeadingConstraint.constant = 0
                    if #available(iOS 11.0, *) {
                        if (Int(UIApplication.shared.keyWindow!.safeAreaInsets.top) > 0)
                        {
                            fromVC.deckViewTopConstraint.constant = 0.0
                        }
                        else{
                            fromVC.deckViewTopConstraint.constant = -20.0
                        }
                    }
                    else{
                        fromVC.deckViewTopConstraint.constant = -20.0
                    }
                }
                
                if let localProfileDeckViewObject = fromVC.deckView.viewForCardAtIndex(Int(fromVC.deckView.currentCardIndex+1)) {
                    
                    localProfileDeckViewObject.isHidden = true
                }
                
                if let localProfileDeckViewObject = fromVC.deckView.viewForCardAtIndex(Int(fromVC.deckView.currentCardIndex+2)) {
                    
                    localProfileDeckViewObject.isHidden = true
                    
                }
                if let localProfileDeckViewObject = fromVC.deckView.viewForCardAtIndex(Int(fromVC.deckView.currentCardIndex)) as? ProfileDeckView {
                    localProfileDeckViewObject.NameAgeLabel.alpha = 0
                    localProfileDeckViewObject.heightLabel.alpha = 0
                    localProfileDeckViewObject.locationLabel.alpha = 0
                    localProfileDeckViewObject.commonalityTagsView.alpha = 0
                    //localProfileDeckViewObject.myProfileBottomView.alpha = 0
                    localProfileDeckViewObject.hadAlreadyBeenShownInDiscover = true
                    localProfileDeckViewObject.updateProfileDeckMainContainerViewHeightRelatedConstraints()
                    localProfileDeckViewObject.perform(#selector(localProfileDeckViewObject.setupViewProperties), with: nil, afterDelay: 0.0)
                }
            }
        }
        

        UIView.animate(withDuration: duration, animations: {
            
          fromVC.view.layoutIfNeeded()
            ;        },
            completion: { _ in
                toVC.view.isHidden = false
                snapshot.removeFromSuperview()
                //fromVC.view.layer.transform = CATransform3DIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
