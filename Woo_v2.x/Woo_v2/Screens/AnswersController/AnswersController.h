//
//  AnswersController.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 05/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyQuestions.h"

@interface AnswersController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>{
    
    __weak IBOutlet UITableView *answersTableView;
    NSMutableArray *answersArray;
    
    int currentSelectedCell;
    
    int pendingReplies;
    
    BOOL isContentOffsetIsSet;
}

@property(nonatomic, retain)MyQuestions *questionObj;

- (IBAction)backButtonTapped:(id)sender;
@end
