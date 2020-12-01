//
//  PermissionView.h
//  Woo
//
//  Created by Umesh Mishra on 11/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @author : Umesh Mishra
 
Class to shwo permissions.
 
 
 */

@interface PermissionView : UIView<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIView *permissionContainerView;
@property (weak, nonatomic) IBOutlet UITableView *permissionTableView;


/**
 @author Umesh Mishra
 Method to show view with fade in animation
 */
-(void)fadeInView;
/**
  @author Umesh Mishra
 Method to initise view with default property when view loads
 */
-(void)initialiseView;
/**
  @author Umesh Mishra
 Method to get permission text message for a row. 
 @param row, row for which message is required
 */
-(NSMutableAttributedString *)getMessageTextForRow:(NSInteger)row;
/**
  @author Umesh Mishra
 Method to add tap gesture to view. Tapping on view will remove the view.
 */
-(void)addTapGesture;
/**
  @author Umesh Mishra
 Method to get height for the text for permission text for a row.
 @param row, for which height is required.
 */
-(float)getHeightForText:(NSInteger)row;
/**
  @author Umesh Mishra
 Method to get permission text for a row.
 @param row, for which text is required.
 */
-(NSString *)getTextForIndex:(NSInteger)row;

@end
