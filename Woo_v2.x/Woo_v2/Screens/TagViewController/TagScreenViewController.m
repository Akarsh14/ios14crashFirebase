//
//  TagScreenViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/17/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "TagScreenViewController.h"
#import "VPImageCropperViewController.h"
#import "FindTagViewController.h"
#import "TagScreenAPIClass.h"
#import "Woo_v2-Swift.h"

@interface TagScreenViewController ()<VPImageCropperDelegate>{
    SKView *skView;
    BubblesScene *floatingCollectionScene;
    __weak IBOutlet UILabel *lblPageNumber;
    
}
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (weak, nonatomic) IBOutlet ERJustifiedFlowLayout *customJustifiedFlowLayout;
@property (nonatomic, strong) TagCollectionViewCell *sizingCell;

@end

@implementation TagScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDismissTheScreenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissTheScreen) name:kDismissTheScreenNotification object:nil];

    preselectedTagCount = 0;        //initialising preselectedTag count to zero so that it does not effect previous implementation.
    botImage.hidden = TRUE;
    
    // Swrve Event
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_TagsSelection.OB_TagS_Landing" andScreen:@"Onboard_TagsSelection"];
    [[Utilities sharedUtility] sendMixPanelEventWithName:@"OnBoarding_MyTags_Landing"];

    [[Utilities sharedUtility]colorStatusBar: [UIColor whiteColor]];
    self.dataSourceArray = [[NSMutableArray alloc] init];
//    shortTagViewArray = [[NSMutableArray alloc] init];
    _totalTagArray = [[NSMutableArray alloc] init];

    if (APP_DELEGATE.onBaordingPageNumber <= ON_BOARDING_PAGE_NUMBER_ONE &&
        !LoginModel.sharedInstance.isAlternateLogin)
        btnBack.hidden = YES;
    else if (LoginModel.sharedInstance.isAlternateLogin){
        if (_isThisFirstScreenAfterRegistration){
            btnBack.hidden = YES;
        }
        else{
            btnBack.hidden = NO;
        }
    }

    isShowMoreTagButtonVisible = FALSE;
    UINib *cellNib = [UINib nibWithNibName:@"TagCollectionViewCell" bundle:nil];
    [tagCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"TagCollectionViewCell"];
    
    self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] firstObject];
    
    NSString *searchStr = [NSString stringWithFormat:@"\nFind"];
    
    NSMutableArray *allTagWithSearch = [[NSMutableArray alloc] initWithArray:[TagsModel sharedInstance].allTags];
    [allTagWithSearch insertObject:@{kTagsIdKey:@9991999, kTagsNameKey:searchStr, kTagsColorCodeKey:@"#F74A4E"} atIndex:0];
    bubbleDataArray = [NSMutableArray arrayWithArray:allTagWithSearch];
    
    
    if (_isPushedFromDiscover) { // Comes From Edit Profile Screen
        btnBack.hidden = YES;
        btnNext.hidden = NO;
        [btnNext setTitle:NSLocalizedString(@"DONE", @"Done") forState:UIControlStateNormal];
        lblPageNumber.hidden = YES;
        
        NSLog(@"%@",_editProfileTagArray);
        
        //for loop to set tag that not present in all tags arraya and tag that present in all tags are use color of them in the selected tag array provided by the edit profile class
        //this should be removed when server will provide the data in desired form
        
        
        for (int index = 0; index < [_editProfileTagArray count]; index++) {
            
            TagModel *model = [_editProfileTagArray objectAtIndex:index];
            NSNumber *tagId = [NSNumber numberWithInt:[model.tagId intValue]];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:model.name ,kTagsNameKey , tagId ,kTagsIdKey ,@"#F74A4E", kTagsColorCodeKey , model.name , kTagsName , kTagTypeValue , kTappableTagTypeKey, nil];
            //this is temp solution when suparno will provide the color this code will change
            BOOL isThisTagExistInMainArray = FALSE;
            for (NSDictionary *tagDetail in bubbleDataArray) {
                if ([[tagDetail objectForKey:kTagsIdKey] intValue] == [[dict objectForKey:kTagsIdKey] intValue]) {
                    isThisTagExistInMainArray = TRUE;
                    NSLog(@"dict mila %@",dict);
                    dict = tagDetail;
                    break;
                }
            }
            if (!isThisTagExistInMainArray) {
                NSLog(@"dict nahi mila :%@",dict);
                [bubbleDataArray addObject:dict];
            }
            if (![_totalTagArray containsObject:dict]) {
                [_totalTagArray addObject:dict];
            }
            
        }
    }
    
    indexToBeAnimated = -1;
    
    [self.customJustifiedFlowLayout setTagIsMovingOutOfViewBlock:^(int indexOfTag, BOOL isTagMoving) {
        NSLog(@"indexOfTag :%d",indexOfTag);
        [self makeNewDataAccordingToTheViewWithOutOfViewIndex:indexOfTag];
    }];
    self.customJustifiedFlowLayout.horizontalJustification = FlowLayoutHorizontalJustificationCenter;
    [self.customJustifiedFlowLayout setNotifyWhenTagWillGoBeyondViewHeight:TRUE];
    self.customJustifiedFlowLayout.horizontalCellPadding = 5;
    self.customJustifiedFlowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    bubbleViewHeightContraint.constant = self.view.frame.size.height*0.52;
    tagViewBottomHeightConstraint.constant = (self.view.frame.size.height*0.5) + 21;
    
    
    shadowLabel.layer.masksToBounds = NO;
    shadowLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowLabel.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    shadowLabel.layer.shadowOpacity = 0.5f;
    
    
    NSLog(@"[LoginModel sharedInstance].botUrl :%@",[LoginModel sharedInstance].botUrl);
    [botImage sd_setImageWithURL:[LoginModel sharedInstance].botUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    botImage.layer.cornerRadius = 35.0;
    botImage.layer.masksToBounds = TRUE;
    
    tagCollectionView.backgroundColor = [UIColor whiteColor];
    
    [lblPageNumber setText:[NSString stringWithFormat:@"%d of %d",APP_DELEGATE.onBaordingPageNumber , APP_DELEGATE.totalOnboardingPages]];
   // [self performSelector:@selector(getTagsDataFromServerAndUpdateView) withObject:nil afterDelay:0.3];
    //[self getTagsDataFromServerAndUpdateView];
    
    [self showTagHelpOverLay];
    [self checkIfMaximumBubbleLimitReached];
    [self showBubbleHelpOverlay];
    
    if (!wooloaderObj) {
        wooloaderObj = [[WooLoader alloc] initWithFrame:self.view.frame];
    }
    [wooloaderObj customLoadingText:@""];
    [wooloaderObj startAnimationOnView:APP_DELEGATE.window WithBackGround:FALSE];
    
}
-(void)getTagsDataFromServerAndUpdateView{
    [[TagsModel sharedInstance] getNewTagsIfAny:^(NSArray *newTagsArray) {
        if (newTagsArray && [newTagsArray count] > 0) {
            //if (isInitialBubblesAdded) {
                [self addNewTagBubbles:newTagsArray];
           // }

        }
    }];
}

- (void)dismissTheScreen
{
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

-(void)addNewTagBubbles:(NSArray *)tagsArray{
    if (!isInitialBubblesAdded) {
        [self performSelector:@selector(addNewTagBubbles:) withObject:tagsArray afterDelay:1.5];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            floatingCollectionScene.userInteractionEnabled = FALSE;
            [floatingCollectionScene setTotalBubbleCount:[tagsArray count]];
            for (int nodeIndex = 0; nodeIndex < [tagsArray count]; nodeIndex++) {
                NSDictionary *tagDetail = [tagsArray objectAtIndex:nodeIndex];
                int nodeIndexValue = [[tagDetail valueForKey:kTagsIdKey] intValue];
                BubbleNode *node = [BubbleNode instantiateWithTitle:[tagDetail valueForKey:kTagsNameKey] withIndex:nodeIndexValue];
                if([tagDetail valueForKey:kFormattedTagsNameKey] != nil)
                {
                    node = [BubbleNode instantiateWithTitle:[tagDetail valueForKey:kFormattedTagsNameKey] withIndex:nodeIndexValue];
                }
                
                [node setLabelIndexValue:nodeIndexValue];
                [node setNodeDetailValue:tagDetail];
                [node nodeDestroyed:^(BOOL success, int indexValue, BubbleNode *bubbleNodeObj) {
                    if (success) {
                        NSLog(@"count before :%lu",(unsigned long)[floatingCollectionScene.children count]);
                        [node removeFromParent];
                        [self addNodeFromNode:node];
                        [self checkIfMaximumBubbleLimitReached];
                        
                        NSLog(@"count before :%lu",(unsigned long)[floatingCollectionScene.children count]);
                    }
                }];
                UIColor *backgroundColor = [APP_Utilities getUIColorObjectFromHexString:[tagDetail objectForKey:kTagsColorCodeKey] alpha:1.0];
                [node setBackgroundColor:backgroundColor];
                [node changeStateValueOfNode:FALSE];
                [floatingCollectionScene addChild:node];
            }
            floatingCollectionScene.userInteractionEnabled = TRUE;
        });
        
    }
    
    
}
-(void)showTagHelpOverLay{
    if (_totalTagArray && [_totalTagArray count]> 0) {
        tagTutorialView.hidden = TRUE;
        tagCollectionView.hidden = FALSE;
        shadowLabel.hidden = FALSE;
    }
    else{
        [self.dataSourceArray removeAllObjects];
        isTagViewFullyVisible = FALSE;
        [tagCollectionView reloadData];
        [self performSelector:@selector(showTagTutorialViewAndReduceCollectionViewSize) withObject:nil afterDelay:0.5];
        
        
    }
}

-(void)showTagTutorialViewAndReduceCollectionViewSize{
    tagTutorialView.hidden = FALSE;
    tagCollectionView.hidden = TRUE;
    shadowLabel.hidden = TRUE;
    [self.customJustifiedFlowLayout setNotifyWhenTagWillGoBeyondViewHeight:TRUE];
    tagViewBottomHeightConstraint.constant = (self.view.frame.size.height*0.5) + 21;
}

-(void)checkIfMaximumBubbleLimitReached{
//    if ([_totalTagArray count] >= [TagsModel sharedInstance].maxTagsAllowedCount) {
    if (([_totalTagArray count] + preselectedTagCount) >= [LoginModel sharedInstance].maxTagsAllowedCount) {

    [floatingCollectionScene setMaximumNumberOfTagsSelected:TRUE];
    }
    else{
        [floatingCollectionScene setMaximumNumberOfTagsSelected:FALSE];
    }
}

-(void)showBubbleHelpOverlay{
//    if (_totalTagArray && [_totalTagArray count]>= [TagsModel sharedInstance].maxTagsAllowedCount) {
    if (_totalTagArray && ([_totalTagArray count] + preselectedTagCount) >= [LoginModel sharedInstance].maxTagsAllowedCount) {

        bubbleTutorialView.hidden = FALSE;
        NSLog(@"[LoginModel sharedInstance].botUrl :%@",[LoginModel sharedInstance].botUrl);
        [botImage sd_setImageWithURL:[LoginModel sharedInstance].botUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
    else{
        bubbleTutorialView.hidden = TRUE;
    }
}

-(void)makeNewDataAccordingToTheViewWithOutOfViewIndex:(int)index{
    isShowMoreTagButtonVisible = TRUE;
    indexToBeAnimated = -1;
    [self.dataSourceArray removeAllObjects];
    for (int idx=0; idx<(index-1); idx++) {
        [self.dataSourceArray addObject:_totalTagArray[idx]];
    }
    int totalNumberOfInvisibleTags = (int)([_totalTagArray count] - ([self.dataSourceArray count]));
    NSString *titleForButton = [NSString stringWithFormat:@"%d more",totalNumberOfInvisibleTags];
    [self.dataSourceArray addObject:@{kTagsIdKey:@9991999, kTagsNameKey:titleForButton}];
    [tagCollectionView reloadData];
    isShowMoreTagButtonVisible = TRUE;
}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if ([LoginModel sharedInstance].isAlternateLogin){
        [lblPageNumber setHidden:true];
    }
    
}

-(void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDismissTheScreenNotification object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
//    NSArray *visibleCellArray = [tagCollectionView visibleCells];
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
    }
    
    
    NSString *selecteMinTagString = [NSString stringWithFormat:NSLocalizedString(@"Just to put a little flavor on your profile pick %d tags to get you started. Don't worry you can always pick more later.", @""),[LoginModel sharedInstance].minTagsAllowedCount];
   // selectMinTagMessageLbl.text = selecteMinTagString;
    self.navigationItem.hidesBackButton = TRUE;
    
    if (_isPushedFromDiscover) {
//        preselectedTagCount = (int)[[DiscoverProfileCollection sharedInstance].myProfileData.tags count];
    }
    
   // selecteMinTagString = NSLocalizedString(@"Masterchef finalist of your own kitchen?\nThat should definitely go on your profile.", @"");
    minTagSecondMessageLbl.text = [NSString stringWithFormat:@"Add at least %d tags",[LoginModel sharedInstance].minTagsAllowedCount];
    //selectMinTagMessageLbl.text = selecteMinTagString;
    
    [self addBubbleView];
    [self showTagHelpOverLay];
    [self checkIfMaximumBubbleLimitReached];
    [self showBubbleHelpOverlay];
    [self reloadCollectionViewWithAllData];
    
    [wooloaderObj removeFromSuperview];
    wooloaderObj = nil;
}


-(void)addBubbleView{
//    bubbleContainerView.backgroundColor = [UIColor whiteColor];
    floatingCollectionScene.userInteractionEnabled = TRUE;
//    if ([_totalTagArray count]>0) {
    if ([self.dataSourceArray count]>0) {
        [self.dataSourceArray removeAllObjects];
    }
    [self.dataSourceArray addObjectsFromArray:_totalTagArray];
    [tagCollectionView reloadData];
//    }
    if (skView) {
        return;
    }
    CGRect viewFrame = bubbleContainerView.bounds;
    skView = [[SKView alloc] initWithFrame:viewFrame];
    skView.backgroundColor = [UIColor redColor];
    skView.translatesAutoresizingMaskIntoConstraints = NO;
    [bubbleContainerView addSubview:skView];
    
    NSDictionary *viewsDictionary = @{@"skView":skView};
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[skView]-0-|" options:0 metrics:nil views:viewsDictionary];
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[skView]-0-|" options:0 metrics:nil views:viewsDictionary];
    
    [bubbleContainerView addConstraints:constraint_POS_V];
    [bubbleContainerView addConstraints:constraint_POS_H];
    
    
    floatingCollectionScene = [[BubblesScene alloc] initWithSize:skView.bounds.size];
    floatingCollectionScene.topOffset = 0;
    [skView presentScene:floatingCollectionScene];
    [floatingCollectionScene nodeSelectedBlock:^(NSDictionary * nodeDetail) {
        
        if (nodeDetail) {
            floatingCollectionScene.userInteractionEnabled = FALSE;
            isShowMoreTagButtonVisible = FALSE;
            if ([[nodeDetail valueForKey:kTagsIdKey] intValue] == 9991999) {
                //Find screen
                [self performSegueWithIdentifier:kPushToFindTagView sender:nil];
            }
            else{
                [self addANewItemInTagViewWithObject:nodeDetail];
                [self showTagHelpOverLay];
                [self checkIfMaximumBubbleLimitReached];
            }
        }
        else{
            [self showBubbleHelpOverlay];
        }
        
        
        
    }];
//    [floatingCollectionScene setFloatingDelegate:self];
    floatingCollectionScene.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.98 alpha:1.0];
//    UIColor(red:0.97, green:0.97, blue:0.98, alpha:1.00)
    

//    if (!bubbleDataArray) {
//        bubbleDataArray = [NSMutableArray arrayWithArray:mainBubbleArray];
//    }
    
    isInitialBubblesAdded = FALSE;
    [floatingCollectionScene setTotalBubbleCount:[bubbleDataArray count]];
    for (int nodeIndex = 0; nodeIndex < [bubbleDataArray count]; nodeIndex++) {
        NSDictionary *tagDetail = [bubbleDataArray objectAtIndex:nodeIndex];
        int nodeIndexValue = [[tagDetail valueForKey:kTagsIdKey] intValue];
        NSString *titleString = [tagDetail valueForKey:kTagsNameKey];
        UIColor *backgroundColor = [APP_Utilities getUIColorObjectFromHexString:[tagDetail objectForKey:kTagsColorCodeKey] alpha:1.0];
        NSLog(@"tag detail :%@,", tagDetail);
        if (([_totalTagArray count] > 0) &&  [_totalTagArray containsObject:tagDetail]) {
            backgroundColor = [APP_Utilities getUIColorObjectFromHexString:[tagDetail objectForKey:kTagsColorCodeKey] alpha:0.5];
            titleString = @"";
        }
        BubbleNode *node = [BubbleNode instantiateWithTitle:titleString withIndex:nodeIndexValue];
        if([tagDetail valueForKey:kFormattedTagsNameKey] != nil)
        {
            node = [BubbleNode instantiateWithTitle:[tagDetail valueForKey:kFormattedTagsNameKey] withIndex:nodeIndexValue];
        }
        [node setLabelIndexValue:nodeIndexValue];
        [node setNodeDetailValue:tagDetail];
        [node nodeDestroyed:^(BOOL success, int indexValue, BubbleNode *bubbleNodeObj) {
            if (success) {
                NSLog(@"count before :%lu",(unsigned long)[floatingCollectionScene.children count]);
                [node removeFromParent];
                [self addNodeFromNode:node];
                [self checkIfMaximumBubbleLimitReached];

                NSLog(@"count before :%lu",(unsigned long)[floatingCollectionScene.children count]);
            }
        }];
        
        
        [node setBackgroundColor:backgroundColor];
        [node changeStateValueOfNode:FALSE];
        [floatingCollectionScene addChild:node];
    }
    isInitialBubblesAdded = TRUE;
    [self.view sendSubviewToBack:bubbleContainerView];
    [self.view addSubview:tagCollectionView];
}

-(void)addNodeFromNode:(BubbleNode *)node{
    BubbleNode *newNode = [BubbleNode instantiateWithTitle:@"" withIndex:node.labelIndex];
    [newNode setLabelIndexValue:node.labelIndex];
    [newNode setNodeDetailValue:node.nodeDetail];
    [newNode nodeDestroyed:^(BOOL success, int indexValue, BubbleNode *bubbleNodeObj) {
        if (success) {
            NSLog(@"count before :%lu",(unsigned long)[floatingCollectionScene.children count]);
            [self checkIfMaximumBubbleLimitReached];

            NSLog(@"count before :%lu",(unsigned long)[floatingCollectionScene.children count]);
        }
    }];
    [newNode changeStateValueOfNode:TRUE];
    [newNode setBackgroundColor:[node.nodeBackgroundColor colorWithAlphaComponent:0.5]];
    [floatingCollectionScene addChild:newNode];
    floatingCollectionScene.userInteractionEnabled = TRUE;
    
}

-(void)addNodeFromData:(NSDictionary *)nodeDetail withChangeState:(BOOL)isNodeSelected{
//    NSString *titleString = [nodeDetail valueForKey:kTagsNameKey];
//    if (isNodeSelected) {
//        titleString = @"";
//    }
    BubbleNode *newNode = [BubbleNode instantiateWithTitle:[nodeDetail valueForKey:kTagsNameKey] withIndex:[[nodeDetail valueForKey:kTagsIdKey] intValue]];
    [newNode setLabelIndexValue:[[nodeDetail valueForKey:kTagsIdKey] intValue]];
    [newNode setNodeDetailValue:nodeDetail];
    [newNode nodeDestroyed:^(BOOL success, int indexValue, BubbleNode *bubbleNodeObj) {
        if (success) {
            NSLog(@"count before :%lu",(unsigned long)[floatingCollectionScene.children count]);
            [newNode removeFromParent];
            [self addNodeFromNode:newNode];
            [self checkIfMaximumBubbleLimitReached];

            NSLog(@"count before :%lu",(unsigned long)[floatingCollectionScene.children count]);
        }
    }];
    [newNode changeStateValueOfNode:isNodeSelected];
    UIColor *backgroundColor = [APP_Utilities getUIColorObjectFromHexString:[nodeDetail objectForKey:kTagsColorCodeKey] alpha:1.0];
    [newNode setBackgroundColor:backgroundColor];
    [floatingCollectionScene addChild:newNode];
    floatingCollectionScene.userInteractionEnabled = TRUE;
}



- (void) settingNavigationBarView{
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    UILabel *navBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    
    
    navBarLabel.text = NSLocalizedString(@"Tag Screen", nil);
    
    navBarLabel.textColor = kHeaderTextRedColor;
    [navBarLabel setFont:kHeaderTextFont];
    [navBarLabel setBackgroundColor:[UIColor clearColor]];
    [navBarLabel sizeToFit];
    [self.navigationItem setTitleView:navBarLabel];
    
    
}

#pragma mark ------------ Button Action Event -------------


- (IBAction)backButtonClicked:(id)sender{
    
    btnBack.userInteractionEnabled = NO;
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];

        return;
    }
    
//    if (_isPushedFromDiscover) {
//        
//        
////        if ([_totalTagArray count]<[TagsModel sharedInstance].minTagsAllowedCount) {
//
//        if (([_totalTagArray count] + preselectedTagCount) < [LoginModel sharedInstance].minTagsAllowedCount) {
//
//            [APP_Utilities addingNoInternetSnackBarWithText:[NSString stringWithFormat:NSLocalizedString(@"Please select minimum %d tags", @""), [LoginModel sharedInstance].minTagsAllowedCount] withActionTitle:@"" withDuration:3.0];
//            return;
//        }
//
//        if (_blockHandler) {
//            _blockHandler(_totalTagArray);
//        }
//    }
    
    
    APP_DELEGATE.onBaordingPageNumber--;
    if (self.navigationController != nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:TRUE completion:nil];
    }
    [self removeAllTheView];
}

-(IBAction)NextButtonClicked:(id)sender{
    

    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];

        return;
    }
    
    if (([_totalTagArray count] + preselectedTagCount )<[LoginModel sharedInstance].minTagsAllowedCount) {
   
        [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_TagsSelection.TagS_Count_SnackBar" andScreen:@"Onboard_TagsSelection"];

        
        [APP_Utilities addingNoInternetSnackBarWithText:[NSString stringWithFormat:NSLocalizedString(@"Please select minimum %d tags", @""), [LoginModel sharedInstance].minTagsAllowedCount] withActionTitle:@"" withDuration:3.0];

        
        return;
    }
    
    if (_isPushedFromDiscover) {
        if (([_totalTagArray count] + preselectedTagCount) < [LoginModel sharedInstance].minTagsAllowedCount) {
            
            [APP_Utilities addingNoInternetSnackBarWithText:[NSString stringWithFormat:NSLocalizedString(@"Please select minimum %d tags", @""), [LoginModel sharedInstance].minTagsAllowedCount] withActionTitle:@"" withDuration:3.0];
            return;
        }
        
        if (_blockHandler) {
            _blockHandler(_totalTagArray);
        }
        
        if (self.navigationController != nil) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self dismissViewControllerAnimated:TRUE completion:nil];
        }
        [self removeAllTheView];
    }
    else{
        [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_TagsSelection.TagS_Next" andScreen:@"Onboard_TagsSelection"];
        
        
        /*
        [TagScreenAPIClass postTagsDataToServerWithTagsArray:_totalTagArray successBlock:^(BOOL success, int statusCode, id response) {
            // Waited for response only in this case as my profile call can go in parallel
            if(!([[LoginModel sharedInstance] personalQuoteText]) && ([[LoginModel sharedInstance] profilePicUrl] != nil)){
                if ([[LoginModel sharedInstance].gender isEqualToString:@"MALE"]){
                [APP_Utilities sendToDiscover];
                }
            }
        }];
         */
        
        if([[LoginModel sharedInstance] personalQuoteText]){
            
            APP_DELEGATE.onBaordingPageNumber++;
            [self performSegueWithIdentifier:kAboutMeScreenControllerID sender:nil];
        }else if([LoginModel sharedInstance].profilePicUrl == nil){ // new user no pic
            
            if([LoginModel sharedInstance].isAlternateLogin){
                [APP_Utilities sendToDiscover];
            }
            else{
            
            int width = SCREEN_WIDTH * .7361;
            
            VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:[UIImage imageNamed:@"crop_default"] cropFrame:CGRectMake((SCREEN_WIDTH - width)/2,0.122*SCREEN_HEIGHT, width, 0.655*SCREEN_HEIGHT) limitScaleRatio:3.0];
            
            imgCropperVC.delegate = self;
            imgCropperVC.isImageAdded = YES;
            [self.navigationController pushViewController:imgCropperVC animated:YES];
            }
        }
        else{
            if([LoginModel sharedInstance].isAlternateLogin){
                [APP_Utilities sendToDiscover];
            }
            else{
            if ([[LoginModel sharedInstance].gender isEqualToString:@"FEMALE"]){
                APP_DELEGATE.onBaordingPageNumber++;
                WizardPhotoViewController *photoViewController = [[WizardPhotoViewController alloc] initWithNibName:@"WizardPhotoViewController" bundle:[NSBundle mainBundle]];
                [self.navigationController pushViewController:photoViewController animated:true];
            }
            }
        }
        
    }
}

#pragma mark - VPIImage Cropper Delegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData {
    
    //    self.portraitImageView.image = [editedImageData objectForKey:@"imageObj"];
    [cropperViewController.navigationController popViewControllerAnimated:NO];
    [APP_Utilities sendToDiscover];

}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
    [cropperViewController.navigationController popViewControllerAnimated:NO];
    [APP_Utilities sendToDiscover];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.dataSourceArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagCollectionViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.sizingCell forIndexPath:indexPath];
    NSLog(@"[self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize] :%@",NSStringFromCGSize([self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize]));

    if (@available(iOS 12, *)) {
        float widthIs =
        [self.sizingCell.stringLabel.text
         boundingRectWithSize:CGSizeMake(200, 32)
         options:NSStringDrawingUsesLineFragmentOrigin
         attributes:@{ NSFontAttributeName:self.sizingCell.stringLabel.font }
         context:nil]
        .size.width;
        
        return CGSizeMake(widthIs + 50.0, 32);
    }
    
    return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
}


-(void)configureCell:(TagCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellDetail = self.dataSourceArray[indexPath.row % self.dataSourceArray.count];
    [cell setItemData:cellDetail];
    [cell setIsShowLessButton:isTagViewFullyVisible];
    cell.labelText = [cellDetail valueForKey:kTagsNameKey];
    cell.animateView = (indexToBeAnimated == indexPath.row);
    cell.destroyCellOnSelection = TRUE;
    
    [cell animateMyView:^(BOOL success) {
        NSLog(@"Bool success");
    }];
    [cell destroyMe:^(BOOL success, NSDictionary *destroyedObj) {
        if (success) {
//            isShowMoreTagButtonVisible = FALSE;
            if ([[destroyedObj valueForKey:kTagsIdKey] intValue] == 9991999) {
                if (isTagViewFullyVisible) {
                    isTagViewFullyVisible = FALSE;
                    
                    tagViewBottomHeightConstraint.constant = (self.view.frame.size.height*0.5) + 21;
                    [tagCollectionView setNeedsUpdateConstraints];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        [self.view layoutIfNeeded];

                    }];
                    
                    
                    [self.dataSourceArray removeAllObjects];
                    [self.dataSourceArray addObjectsFromArray:_totalTagArray];
                    [tagCollectionView reloadData];
//                    tagCollectionView.backgroundColor = [UIColor greenColor];
                    [self.customJustifiedFlowLayout setNotifyWhenTagWillGoBeyondViewHeight:TRUE];
//                    [self showBubbleHelpOverlay];
//                    [self showTagHelpOverLay];
                    
                }
                else{
                    [self.customJustifiedFlowLayout setNotifyWhenTagWillGoBeyondViewHeight:FALSE];
//                    heightOfTheBubbleView = bubbleContainerView.frame.size.height;
                    isTagViewFullyVisible = TRUE;
//                    [self.view layoutIfNeeded];

                    tagViewBottomHeightConstraint.constant = 1;
                    [tagCollectionView setNeedsUpdateConstraints];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        [self.view layoutIfNeeded];
                    }];
//                    tagCollectionView.backgroundColor = [UIColor yellowColor];

                    [self.dataSourceArray removeAllObjects];
                    [self.dataSourceArray addObjectsFromArray:_totalTagArray];
                    [self.dataSourceArray addObject:@{kTagsIdKey:@9991999, kTagsNameKey:@"Show Less"}];
                    [tagCollectionView reloadData];
                    

                    
                }
                

            }
            else{
                [self reloadViewAfterRemovingCellData:destroyedObj];
            }
            isShowMoreTagButtonVisible = FALSE;
        }
    }];
    
}

-(void)reloadViewAfterRemovingCellData:(NSDictionary *)objectToBeRemoved{
    if (objectToBeRemoved ) {
        tagCollectionView.userInteractionEnabled = FALSE;
        if ([self.dataSourceArray containsObject:objectToBeRemoved]) {
            if ([_totalTagArray containsObject:objectToBeRemoved]) {
                [_totalTagArray removeObject:objectToBeRemoved];
            }
            int indexOfObject = (int)[self.dataSourceArray indexOfObject:objectToBeRemoved];
            [self.dataSourceArray removeObject:objectToBeRemoved];
            NSIndexPath *indexObj = [NSIndexPath indexPathForRow:indexOfObject inSection:0];
            [tagCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexObj]];
            
            [self performSelector:@selector(reloadCollectionViewWithAllData) withObject:nil afterDelay:0.6];
            
            
            [floatingCollectionScene removeShadowNodeAtIndex:[[objectToBeRemoved valueForKey:kTagsIdKey] intValue]];
            [self addNodeFromData:objectToBeRemoved withChangeState:FALSE];
        }
        [self showTagHelpOverLay];
        [self checkIfMaximumBubbleLimitReached];
        [self showBubbleHelpOverlay];
    }
}
-(void)reloadCollectionViewWithAllData{
    if ([self.dataSourceArray count]>0) {
        [self.dataSourceArray removeAllObjects];
    }
    [self.dataSourceArray addObjectsFromArray:_totalTagArray];
    if (isTagViewFullyVisible) {
        [self.dataSourceArray addObject:@{kTagsIdKey:@9991999, kTagsNameKey:@"Show Less"}];
    }
    [tagCollectionView reloadData];
    tagCollectionView.userInteractionEnabled = TRUE;
}


-(void)floatingScene:(SIFloatingCollectionScene *)scene didSelectFloatingNodeAtIndex:(int)index{
    NSLog(@"select aaya hai yaha pe");
}

-(BOOL)floatingScene:(SIFloatingCollectionScene *)scene shouldSelectFloatingNodeAtIndex:(int)index{
    NSLog(@"shouldSelectFloatingNodeAtIndex");
    

    return TRUE;
}

-(void)addANewItemInTagViewWithObject:(NSDictionary *)tagValue{
    

    [_totalTagArray addObject:tagValue];
    if ([self.dataSourceArray count]>0) {
        [self.dataSourceArray removeAllObjects];
        
    }
    [self.dataSourceArray addObjectsFromArray:_totalTagArray];
    [self checkIfMaximumBubbleLimitReached];
    indexToBeAnimated = (int)[self.dataSourceArray indexOfObject:tagValue];
    tagCollectionView.userInteractionEnabled = TRUE;
    [tagCollectionView reloadData];
    return;
    
}

-(void)configureCell:(TagCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withTitle:(NSDictionary *)cellDetail{
//    NSDictionary *cellDetail = self.dataSourceArray[indexPath.row % self.dataSourceArray.count];
    cell.labelText = [cellDetail valueForKey:kTagsNameKey];
    cell.animateView = (indexToBeAnimated == indexPath.row);
    [cell setItemData:cellDetail];
    [cell animateMyView:^(BOOL success) {
        NSLog(@"Bool success");
    }];
    [cell destroyMe:^(BOOL success, NSDictionary *destroyedObj) {
        if (success) {
            if ([[destroyedObj valueForKey:kTagsIdKey] intValue] == 9991999) {
//                heightOfTheBubbleView = bubbleContainerView.frame.size.height;
                isTagViewFullyVisible = TRUE;
                bubbleViewHeightContraint.constant = 0;
//                tagCollectionView.backgroundColor = [UIColor greenColor];
                //                bubbleContainerView.hidden = TRUE;
                //                tagViewHeightContraint.constant = tagCollectionView.frame.size.height + heightOfTheBubbleView;
                [self.dataSourceArray removeAllObjects];
                [self.dataSourceArray addObjectsFromArray:_totalTagArray];
                [tagCollectionView reloadData];
            }
            else{
                [self reloadViewAfterRemovingCellData:destroyedObj];
            }
            
        }
    }];
    
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kPushToFindTagView]) {
        
        [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_TagsSelection.TagS_TapSearch" andScreen:@"Onboard_TagsSelection"];

        FindTagViewController *findTagVCObj = (FindTagViewController *)segue.destinationViewController;
//        NSMutableArray *remainingTotalTags = [[NSMutableArray alloc] initWithArray:_totalTagArray];
        
        [findTagVCObj setSelectedTagArray:_totalTagArray];
        [findTagVCObj setTagScreenViewControllerObj:self];
    }
}

-(void)addBubbleWithDetail:(NSDictionary *)bubbleDetail makeBubbleShadowBubble:(BOOL)isBubbleShadow{
    if (isBubbleShadow) {
        //below line is removing the bubble irrespective of shadow or not
        NSArray *allChild = [floatingCollectionScene children];
        
        for (SIFloatingNode *nodeObj in allChild) {
            if ([nodeObj isKindOfClass:[SIFloatingNode class]]) {
                if (nodeObj.labelIndex == [[bubbleDetail valueForKey:kTagsIdKey] intValue]) {
                    [nodeObj removeFromParent];
                    [self addNodeFromNode:(BubbleNode*)nodeObj];
                }
            }
        }
    }
    else{
        [floatingCollectionScene removeShadowNodeAtIndex:[[bubbleDetail valueForKey:kTagsIdKey] intValue]];
        [self addNodeFromData:bubbleDetail withChangeState:FALSE];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)removeAllTheView{
    if (_removeBubbleViewsWhenViewDisappears) {
        if (skView) {
            [skView removeFromSuperview];
            skView = nil;
        }
        if (floatingCollectionScene) {
            [floatingCollectionScene removeFromParent];
            floatingCollectionScene = nil;
        }
    }
}


@end
