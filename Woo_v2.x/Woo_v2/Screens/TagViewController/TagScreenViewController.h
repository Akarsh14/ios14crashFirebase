//
//  TagScreenViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 5/17/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubblesScene.h"
#import "BubbleNode.h"
#import "ERJustifiedFlowLayout.h"
#import "TagCollectionViewCell.h"
#import "TagsModel.h"


typedef void (^addTagsActionBlockForDiscover)(NSMutableArray*);

@interface TagScreenViewController : UIViewController<SIFloatingCollectionSceneDelegate>{
    
    __weak  IBOutlet     UIButton       *btnBack;
    __weak  IBOutlet     UIButton       *btnNext;

    
    __weak IBOutlet UICollectionView *tagCollectionView;
    __weak IBOutlet UIView *bubbleContainerView;
    
    IBOutlet NSLayoutConstraint *bubbleViewHeightContraint;
    IBOutlet NSLayoutConstraint *tagViewBottomHeightConstraint;
    IBOutlet UILabel *shadowLabel;
    
    IBOutlet UIView *tagTutorialView;
    
    IBOutlet UILabel *selectMinTagMessageLbl;
    
    IBOutlet UILabel *minTagSecondMessageLbl;
    
    IBOutlet UIView *bubbleTutorialView;
    
    long indexToBeAnimated;
    int newTags;
    
    NSMutableArray *bubbleDataArray;
    
    BOOL isShowMoreTagButtonVisible;
    
    BOOL isTagViewFullyVisible;
    
    IBOutlet UIImageView *botImage;
    BOOL isInitialBubblesAdded;
    
    int preselectedTagCount;
    WooLoader *wooloaderObj;
    
}

@property(nonatomic, retain)NSMutableArray *totalTagArray;
@property (assign) BOOL     isPushedFromDiscover;
@property (assign) BOOL     isThisFirstScreenAfterRegistration;
@property (nonatomic , strong) NSMutableArray       *editProfileTagArray;
@property (nonatomic, copy) addTagsActionBlockForDiscover    blockHandler;
@property (nonatomic, assign) BOOL removeBubbleViewsWhenViewDisappears;
@property (nonatomic, assign) BOOL isPresentedForTagSelectionCard;


-(IBAction)NextButtonClicked:(id)sender;

- (IBAction)backButtonClicked:(id)sender;

-(void)addBubbleWithDetail:(NSDictionary *)bubbleDetail makeBubbleShadowBubble:(BOOL)isBubbleShadow;

@end
