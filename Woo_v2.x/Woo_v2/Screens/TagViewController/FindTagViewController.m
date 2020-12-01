//
//  FindTagViewController.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 20/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "FindTagViewController.h"
#import "IQKeyboardManager.h"
#import "LoginModel.h"
@interface FindTagViewController ()

@end

@implementation FindTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mainBubbleArray = [TagsModel sharedInstance].allTags;
    [mainBubbleArray removeObjectsInArray:[TagsModel sharedInstance].selectedTags];
    
    
    if (!mostPopularTag) {
        mostPopularTag = [[NSMutableArray alloc] init];
    }
    
    [mostPopularTag addObjectsFromArray:[TagsModel sharedInstance].popularTags];
    
    if (!dataSourceArray) {
        dataSourceArray = [[NSMutableArray alloc] init];
    }
    
    
    [dataSourceArray addObjectsFromArray:mostPopularTag];
    
    addBtn.enabled = FALSE;
    addBtn.userInteractionEnabled = FALSE;

    
    if (!availableTagArray) {
        availableTagArray = [[NSMutableArray alloc] init];
    }
    if ([availableTagArray count]>0) {
        [availableTagArray removeAllObjects];
    }
    if (!selectedTagArrayInFindView) {
        selectedTagArrayInFindView = [[NSMutableArray alloc] init];
    }
    
    [availableTagArray addObjectsFromArray:mainBubbleArray];
    [selectedTagArrayInFindView addObjectsFromArray:_selectedTagArray];
    
    if (!searchedTagArray) {
        searchedTagArray = [[NSMutableArray alloc] init];
    }
    if ([selectedTagArrayInFindView count] > 0) {
        int extraTags = 0;
        NSString *selectedTagsText = @"";
        for (int index = 0; index < [selectedTagArrayInFindView count]; index++) {
            NSDictionary *tagDetail = [selectedTagArrayInFindView objectAtIndex:index];
            if (index == 0) {
                //adding first tag
                selectedTagsText = [NSString stringWithFormat:@"%@ - #%@",NSLocalizedString(@"Selected", @""),[tagDetail objectForKey:kTagsName]];
                selectedTagInformationLbl.text = selectedTagsText;
            }
            else{
                UILabel *testLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, 21)];
                testLbl.numberOfLines = 1;
                testLbl.font = [UIFont fontWithName:@"Lato-Medium" size:14];
                testLbl.text = [NSString stringWithFormat:@"%@, #%@",selectedTagsText, [tagDetail objectForKey:kTagsName]];
                [testLbl sizeToFit];
                if (testLbl.frame.size.width > SCREEN_WIDTH-20) {
                    extraTags++;
                }
                
                if (extraTags > 0) {
                    selectedTagInformationLbl.text = [NSString stringWithFormat:@"%@ + %d",selectedTagsText, extraTags];
                    //                        selectedTagsText = [NSString stringWithFormat:@"%@ + %d",selectedTagsText, extraTags];
                }
                else{
                    selectedTagsText = [NSString stringWithFormat:@"%@, #%@",selectedTagsText, [tagDetail objectForKey:kTagsName]];
                    selectedTagInformationLbl.text = selectedTagsText;
                }
                
            }
        }
    }
    else{
        selectedTagInformationLbl.text = NSLocalizedString(@"Search for a tag or select from suggested", @"");
    }
    
    UINib *cellNib = [UINib nibWithNibName:@"TagCollectionViewCell" bundle:nil];
    [tagCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"TagCollectionViewCell"];
    
    self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] firstObject];
    
    [self.customJustifiedFlowLayout setTagIsMovingOutOfViewBlock:^(int indexOfTag, BOOL isTagMoving) {
        NSLog(@"indexOfTag :%d",indexOfTag);
//        [self makeNewDataAccordingToTheViewWithOutOfViewIndex:indexOfTag];
    }];
    self.customJustifiedFlowLayout.horizontalJustification = FlowLayoutHorizontalJustificationLeft;
    [self.customJustifiedFlowLayout setNotifyWhenTagWillGoBeyondViewHeight:FALSE];
    self.customJustifiedFlowLayout.horizontalCellPadding = 5;
    self.customJustifiedFlowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 0, 20);
    
    sectionHeaderLbl.text = NSLocalizedString(@"Most Popular Tags", @"Most Popular Tags"); //kMostPopularTagsText;
  //  [searchTextFiled becomeFirstResponder];
    crossBtn.hidden = TRUE;
    searchTextFiled.delegate = self;
    
    [searchTextFiled addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    noResultFoundLbl.hidden = TRUE;
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
//    IQKeyboardManager.sharedManager().enableAutoToolbar = false
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [searchTextFiled becomeFirstResponder];

}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    NSDictionary *userInfo = aNotification.userInfo;
    
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
//    NSValue *beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
//    CGRect keyboardBeginFrame = [self.view convertRect:beginFrameValue.CGRectValue fromView:nil];
    
    NSLog(@"end frame == %f",keyboardEndFrame.size.height);
    collectionViewBottomConstraint.constant = keyboardEndFrame.size.height+10;
    

}
- (void)keyboardWillHide:(NSNotification *)aNotification {
    
    NSDictionary *userInfo = aNotification.userInfo;
    
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    //    NSValue *beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
    //    CGRect keyboardBeginFrame = [self.view convertRect:beginFrameValue.CGRectValue fromView:nil];
    
    NSLog(@"end frame == %f",keyboardEndFrame.size.height);
    collectionViewBottomConstraint.constant = 0+10;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [dataSourceArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagCollectionViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self configureCell:self.sizingCell forIndexPath:indexPath];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0")){
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
    
    NSDictionary *cellDetail = dataSourceArray[indexPath.row % dataSourceArray.count];
    cell.labelText = [cellDetail valueForKey:kTagsNameKey];
    [cell setItemData:cellDetail];
    
    [cell animateMyView:^(BOOL success) {
        NSLog(@"Bool success");
    }];
    
    [cell destroyMe:^(BOOL success, NSDictionary *destroyedObj) {
        if (success) {
            if (  ![self tagsArray:selectedTagArrayInFindView containsObject:destroyedObj] )
                //![selectedTagArrayInFindView containsObject:destroyedObj])
            {
//                if ([selectedTagArrayInFindView count]>=[TagsModel sharedInstance].maxTagsAllowedCount) {
                if ([selectedTagArrayInFindView count]>=[LoginModel sharedInstance].maxTagsAllowedCount) {

                    [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"You've reached the maximum amount of tags. Delete a tag to replace it.", @"You've reached the maximum amount of tags. Delete a tag to replace it.") withActionTitle:@"" withDuration:3.0];

                    
                    return;
                }
                
                [selectedTagArrayInFindView addObject:destroyedObj];
//                if (_tagScreenViewControllerObj) {
//                    [_tagScreenViewControllerObj addBubbleWithDetail:destroyedObj makeBubbleShadowBubble:YES];
//                }
            }
            else{
                [self removeFromArray:selectedTagArrayInFindView tagsObject:destroyedObj];
               // [selectedTagArrayInFindView removeObject:destroyedObj];
//                if (_tagScreenViewControllerObj) {
//                    [_tagScreenViewControllerObj addBubbleWithDetail:destroyedObj makeBubbleShadowBubble:NO];
//                }
            }
            [tagCollectionView reloadData];
            
        }
        if ([selectedTagArrayInFindView count] > 0) {
            addBtn.enabled = TRUE;
            addBtn.userInteractionEnabled = TRUE;
        }
        else{
            addBtn.enabled = FALSE;
            addBtn.userInteractionEnabled = FALSE;
        }
        if ([selectedTagArrayInFindView count] > 0) {
            int extraTags = 0;
            NSString *selectedTagsText = @"";
            for (int index = 0; index < [selectedTagArrayInFindView count]; index++) {
                NSDictionary *tagDetail = [selectedTagArrayInFindView objectAtIndex:index];
                if (index == 0) {
                    //adding first tag
                    selectedTagsText = [NSString stringWithFormat:@"%@ - #%@",NSLocalizedString(@"Selected", @""),[tagDetail objectForKey:kTagsName]];
                    selectedTagInformationLbl.text = selectedTagsText;
                }
                else{
                    UILabel *testLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, 21)];
                    testLbl.numberOfLines = 1;
                    testLbl.font = [UIFont fontWithName:@"Lato-Medium" size:14];
                    testLbl.text = [NSString stringWithFormat:@"%@, #%@",selectedTagsText, [tagDetail objectForKey:kTagsName]];
                    [testLbl sizeToFit];
                    if (testLbl.frame.size.width > SCREEN_WIDTH-20) {
                        extraTags++;
                    }
                    
                    if (extraTags > 0) {
                        selectedTagInformationLbl.text = [NSString stringWithFormat:@"%@ + %d",selectedTagsText, extraTags];
//                        selectedTagsText = [NSString stringWithFormat:@"%@ + %d",selectedTagsText, extraTags];
                    }
                    else{
                        selectedTagsText = [NSString stringWithFormat:@"%@, #%@",selectedTagsText, [tagDetail objectForKey:kTagsName]];
                        selectedTagInformationLbl.text = selectedTagsText;
                    }
                    
                }
            } 
        }
        else{
            selectedTagInformationLbl.text = NSLocalizedString(@"Search for a tag or select from suggested", @"");
        }
        
    }];
    
    
    cell.showAsSelected =  NO;
    for (NSDictionary *tagsDict in selectedTagArrayInFindView) {
        if([[tagsDict objectForKey:@"tagId"] intValue] == [[cellDetail objectForKey:@"tagId"] intValue])
        {
            cell.showAsSelected = YES;
        }
    }
    //cell.showAsSelected = [selectedTagArrayInFindView containsObject:cellDetail];
    
    cell.animateView = FALSE;
    cell.showBorder = TRUE;
    cell.showAddButton = TRUE;
    
    cell.destroyCellOnSelection = FALSE;
    [cell changeViewBasedOnProperties];
    
}

-(BOOL)tagsArray:(NSArray*)tagsArray containsObject:(NSDictionary *)tagsDictionary
{
    for (NSDictionary *tagsDict in tagsArray) {
        if([[tagsDict objectForKey:@"tagId"] intValue]  == [[tagsDictionary objectForKey:@"tagId"] intValue])
        {
             return YES;
        }
    }
    return NO;
}

-(void) removeFromArray:(NSMutableArray *)tagsArray tagsObject:(NSDictionary *)tagsDictionary
{
    NSDictionary *objectToBeremoved = [NSDictionary new];
    for(NSDictionary *tagsDict in tagsArray) {
        if([[tagsDict objectForKey:@"tagId"] intValue]  == [[tagsDictionary objectForKey:@"tagId"] intValue])
        {
            objectToBeremoved = tagsDict;
        }
    }
    [tagsArray removeObject:objectToBeremoved];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
        if ([searchedTagArray count]>0) {
            sectionHeaderLbl.text = NSLocalizedString(@"Top Suggested Tags", @"Top Suggested Tags"); //kTopSuggestedTagsText;
            [dataSourceArray removeAllObjects];
            [dataSourceArray addObjectsFromArray:searchedTagArray];
        }
        else{
            sectionHeaderLbl.text = NSLocalizedString(@"Most Popular Tags", @"Most Popular Tags"); //kMostPopularTagsText;
            [dataSourceArray removeAllObjects];
            [dataSourceArray addObjectsFromArray:mostPopularTag];
        }
        [tagCollectionView reloadData];
        [searchTextFiled resignFirstResponder];
    }

    if (string.length == 0) {
//        check if we need to initial character is 1 length
        if (textField.text.length == 1) {
            crossButton.hidden = true;
        }else{
            crossButton.hidden = false;
        }
    }else{
        crossButton.hidden = false;
    }

    return TRUE;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([searchedTagArray count]>0) {
        sectionHeaderLbl.text = NSLocalizedString(@"Top Suggested Tags", @"Top Suggested Tags"); //kTopSuggestedTagsText;
        [dataSourceArray removeAllObjects];
        [dataSourceArray addObjectsFromArray:searchedTagArray];
        noResultFoundLbl.hidden = TRUE;
    }
    else{
        sectionHeaderLbl.text = NSLocalizedString(@"Most Popular Tags", @"Most Popular Tags"); //kMostPopularTagsText;
        [dataSourceArray removeAllObjects];
        [dataSourceArray addObjectsFromArray:mostPopularTag];
        noResultFoundLbl.hidden = TRUE;
    }
    [tagCollectionView reloadData];
    [searchTextFiled resignFirstResponder];
    return TRUE;
}
-(IBAction)searchStringChanged:(id)sender{
    
}

-(void)textFieldDidChange:(UITextField *)textfieldObj{
    NSLog(@"textfieldObj :%@",textfieldObj);
    [self searchTagForString:textfieldObj.text];
}

-(void)searchTagForString:(NSString *)searchString{
    
    if ([searchString length]>0) {
        if ([searchedTagArray count]>0) {
            [searchedTagArray removeAllObjects];
        }
        for (NSDictionary *tagDetail in availableTagArray) {
            NSString *matchTagName = [tagDetail objectForKey:kTagsNameKey];
            // Added by Lokesh on 15th April
            if([[APP_Utilities validString:searchString] length]>0){
                if (searchString && [matchTagName rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [searchedTagArray addObject:tagDetail];
                }
            }
        }
        sectionHeaderLbl.text = NSLocalizedString(@"Top Suggested Tags", @"Top Suggested Tags"); //kTopSuggestedTagsText;
        [dataSourceArray removeAllObjects];
        [dataSourceArray addObjectsFromArray:searchedTagArray];
        [tagCollectionView reloadData];
        if ([dataSourceArray count] < 1) {
            noResultFoundLbl.hidden = FALSE;
        }
        else{
            noResultFoundLbl.hidden = TRUE;
        }
    }
    else{
        sectionHeaderLbl.text = NSLocalizedString(@"Most Popular Tags", @"Most Popular Tags"); //kMostPopularTagsText;
        [dataSourceArray removeAllObjects];
        [dataSourceArray addObjectsFromArray:mostPopularTag];
        noResultFoundLbl.hidden = TRUE;
    }
    [tagCollectionView reloadData];
//    [searchTextFiled resignFirstResponder];
    
}

-(IBAction)backButtonTapped:(id)sender{
//    [self addButtonTapped:nil];
//    [self.navigationController popViewControllerAnimated:YES];
    for (NSDictionary *tagDetail in selectedTagArrayInFindView) {
        if (_tagScreenViewControllerObj) {
            [_tagScreenViewControllerObj addBubbleWithDetail:tagDetail makeBubbleShadowBubble:YES];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:true completion:nil];
    if (_tagScreenViewControllerObj) {
        [_tagScreenViewControllerObj setTotalTagArray:selectedTagArrayInFindView];
    }
    
    
}
-(IBAction)crossButtonTapped:(id)sender{
    searchTextFiled.text = @"";
    
    sectionHeaderLbl.text = NSLocalizedString(@"Most Popular Tags", @"Most Popular Tags"); //kMostPopularTagsText;
    [dataSourceArray removeAllObjects];
    [dataSourceArray addObjectsFromArray:mostPopularTag];
    [tagCollectionView reloadData];
    crossButton.hidden = true;
    noResultFoundLbl.hidden = TRUE;
//    [self searchTagForString:searchTextFiled.text];
    
}
-(IBAction)addButtonTapped:(id)sender{
    
    for (NSDictionary *tagDetail in selectedTagArrayInFindView) {
        if (_tagScreenViewControllerObj) {
            [_tagScreenViewControllerObj addBubbleWithDetail:tagDetail makeBubbleShadowBubble:YES];
        }
    }
    
    //pass selectedTagArrayInFindView to WizardTags
    
    if(self.TagSelectionBlock)
    {
        self.TagSelectionBlock(selectedTagArrayInFindView);
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (_tagScreenViewControllerObj) {
        [_tagScreenViewControllerObj setTotalTagArray:selectedTagArrayInFindView];
    }
    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
