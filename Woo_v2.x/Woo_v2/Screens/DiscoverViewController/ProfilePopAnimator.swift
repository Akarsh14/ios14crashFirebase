//
//  ProfilePopAnimator.swift
//  Woo_v2
//
//  Created by Ankit Batra on 13/12/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class ProfilePopAnimator: NSObject,UIViewControllerAnimatedTransitioning {
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
            var toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        snapshot.frame = originFrame
        
        containerView.insertSubview(toVC.view, at: 0)
        containerView.addSubview(snapshot)
        fromVC.view.isHidden = true
        let duration = transitionDuration(using: transitionContext)
       
        if let toViewController = toVC as? DiscoverViewController
        {
            toViewController.view.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
            toViewController.areWeMovingUpOrLeftRight = ""
            let height = UIScreen.main.bounds.height
            toViewController.deckViewHeightConstraint.constant = height - safeAreaBoth - topMarginForDeckView
            if let localProfileDeckViewObject = toViewController.deckView.viewForCardAtIndex(Int(toViewController.deckView.currentCardIndex)) as? ProfileDeckView {
                localProfileDeckViewObject.profileDeckMainContainerViewLeadingConstraint.constant = 10.0
                localProfileDeckViewObject.profileDeckMainContainerViewTrailingConstraint.constant = 10.0
                localProfileDeckViewObject.myProfileBottomViewTrailingConstraint.constant = 20
                localProfileDeckViewObject.myProfileBottomViewLeadingConstraint.constant = 20
                print("frame of buttons coming back = \(toViewController.actionButtonBottomConstraint.constant)")
                localProfileDeckViewObject.aboutMeLabelContainerViewYValue = SCREEN_HEIGHT - toViewController.actionButtonBottomConstraint.constant
                localProfileDeckViewObject.aboutMeLabelContainerViewHeightValue = 45.0
                localProfileDeckViewObject.crushMessageContainerViewYValue = SCREEN_HEIGHT - toViewController.actionButtonBottomConstraint.constant
                localProfileDeckViewObject.crushMessageContainerViewWidthValue = 0
                localProfileDeckViewObject.crushMessageContainerViewHeightValue = 0
                localProfileDeckViewObject.needTobeShownOrHiddenAsBeingShownInDeck()
                
                if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                    localProfileDeckViewObject.profileDetails?.about = DiscoverProfileCollection.sharedInstance.myProfileData?.about
                    localProfileDeckViewObject.profileDetails?.personalQuote = DiscoverProfileCollection.sharedInstance.myProfileData?.personalQuote
                    localProfileDeckViewObject.setPersonalQuoteAndAboutMe()
                    
                    localProfileDeckViewObject.myProfileProgressView.progressValue = CGFloat(NumberFormatter().number(from: (DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)!)
                    localProfileDeckViewObject.myProfileProfileCompleteLabel.text = "\((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)%"
                    
                    localProfileDeckViewObject.profileDetails?.height = DiscoverProfileCollection.sharedInstance.myProfileData?.height
                    localProfileDeckViewObject.profileDetails?.showHeightType = (DiscoverProfileCollection.sharedInstance.myProfileData?.showHeightType)!
                    if (DiscoverProfileCollection.sharedInstance.myProfileData?.location) != nil {
                        localProfileDeckViewObject.profileDetails?.location = (DiscoverProfileCollection.sharedInstance.myProfileData?.location)!
                    }
                    
                    localProfileDeckViewObject.setHeightLocationText()
                }
            }
        }
        
        UIView.animate(withDuration: duration, animations: {
            snapshot.removeFromSuperview()

            if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE &&  !(toVC is TagSearchViewController) {
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            }
            
            
                if let toViewController = toVC as? DiscoverViewController
                {
                    toViewController.view.layoutIfNeeded()
                    
                    if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                        toViewController.actionButtonsContainerView.transform = CGAffineTransform.identity
                    }
                    
                    if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE  &&
                        !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown){
                        toViewController.chatBotScreenForMyProfile.alpha = 1
                    }
                    
                    if (toViewController.deckView.viewForCardAtIndex(Int(toViewController.deckView.currentCardIndex)) as? ProfileDeckView) != nil {
                        //localProfileDeckViewObject.updateCommonalityTagsViewBasedOnThereAvailability(localProfileDeckViewObject.profileDetails)
                    }
                    if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                        WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                    }
                    else{
                        if let localProfileDeckViewObject = toViewController.deckView.viewForCardAtIndex(Int(toViewController.deckView.currentCardIndex)) as? ProfileDeckView {
                            localProfileDeckViewObject.myProfileBottomView.alpha = 1
                        }
                    }
                }
            },
                       completion: { _ in
                        //fromVC.view.layer.transform = CATransform3DIdentity

                        if let toViewController = toVC as? DiscoverViewController
                        {
                            if(toViewController.showActionButton)
                            {
                                toViewController.nowPerformButtonActions(showActionButton: true)
                            }
                            if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == false{
                                
                                if let localProfileDeckViewObject = toViewController.deckView.viewForCardAtIndex(Int(toViewController.deckView.currentCardIndex+1)) {
                                    
                                    localProfileDeckViewObject.isHidden = false
                                    
                                }
                                
                                if let localProfileDeckViewObject = toViewController.deckView.viewForCardAtIndex(Int(toViewController.deckView.currentCardIndex+2)) {
                                    localProfileDeckViewObject.isHidden = false
                                }
                            }
                            
                            
                        }
                        
                        toVC.view.isHidden = false

                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
