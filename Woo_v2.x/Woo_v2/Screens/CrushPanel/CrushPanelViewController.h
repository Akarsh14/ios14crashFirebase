//
//  CrushPanelViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 1/15/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//
@class ProfileCardModel;
@class MeSectionEmptyView;
#import <UIKit/UIKit.h>
#import "CrushesDashboard.h"
#import "CrushCell.h"
#import "WooLoader.h"
#import "MatchedUsersImageView.h"
@interface CrushPanelViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>{
    
    NSMutableArray *crushesDataArray;
    NSMutableArray *crushesDataArrayWhileBoosted;
    int currentlySelectedSection;
    CrushesDashboard *currentlySelectedProfile;

    
    ProfileCardModel                    *profileCardModel;
    __weak IBOutlet UIView              *viewNoCrush;
    __weak IBOutlet UILabel             *viewNoCrushTitle;
    __weak IBOutlet UILabel             *viewNoCrushDesc;
    __weak IBOutlet UIButton            *btnViewNoCrush;
    __weak IBOutlet UIView              *activityIndicatorView;
    __weak IBOutlet UIView              *emptyScreenUserImageView;
    MatchedUsersImageView *matchedUserViewObj;
    NSMutableArray *viewedCrushProfileIdArray;
    MeSectionEmptyView *meSectionEmptyViewObj;
}

@property (nonatomic , strong) NSMutableDictionary *dictCrushData;
@property (nonatomic , strong) NSArray       *totalSectionArray;
-(IBAction)btnMoreInfoClicked:(id)sender;
-(void)addEmptyScreenUserImageView;

@end
