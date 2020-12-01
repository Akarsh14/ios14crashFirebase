//
//  FindTagViewController.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 20/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERJustifiedFlowLayout.h"
#import "TagCollectionViewCell.h"
#import "TagScreenViewController.h"
#import "TagsModel.h"


#define kMostPopularTagsText    @"Most Popular Tags"
#define kTopSuggestedTagsText   @"Top Suggested Tags"

@class TagScreenViewController;

@interface FindTagViewController : UIViewController<UITextFieldDelegate>{
    NSMutableArray *mainBubbleArray;
    NSMutableArray *availableTagArray;
    NSMutableArray *searchedTagArray;
    NSMutableArray *selectedTagArrayInFindView;
    NSMutableArray *addedSelectedTagArrayInFindView;
    NSMutableArray *mostPopularTag;
    
    IBOutlet UICollectionView *tagCollectionView;
    IBOutlet UILabel *sectionHeaderLbl;
    
    NSMutableArray *dataSourceArray;
    
    IBOutlet UITextField *searchTextFiled;
    IBOutlet UIButton *crossBtn;
    
    IBOutlet NSLayoutConstraint *collectionViewBottomConstraint;
    __weak IBOutlet UIButton *crossButton;
    __weak IBOutlet UILabel *selectedTagInformationLbl;
    __weak IBOutlet UILabel *noResultFoundLbl;
    __weak IBOutlet UIButton *addBtn;
    
    
}

-(IBAction)backButtonTapped:(id)sender;
-(IBAction)crossButtonTapped:(id)sender;
-(IBAction)searchStringChanged:(id)sender;
-(IBAction)addButtonTapped:(id)sender;
@property(nonatomic, strong) TagScreenViewController *tagScreenViewControllerObj;

@property (weak, nonatomic) IBOutlet ERJustifiedFlowLayout *customJustifiedFlowLayout;
@property (nonatomic, strong) TagCollectionViewCell *sizingCell;
@property(nonatomic, retain)NSMutableArray *selectedTagArray;
@property (nonatomic, copy) void (^TagSelectionBlock)(NSMutableArray*);

@end
